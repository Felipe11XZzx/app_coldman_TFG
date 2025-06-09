import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/cita_model.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/providers/cita_provider.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';
import 'package:logger/logger.dart';


class ServicioCitaProvider with ChangeNotifier {
  
  
  final CitaProvider _citaProvider;
  final ServicioProvider _servicioProvider;
  final Logger logger = Logger();

  ServicioCitaProvider(this._citaProvider, this._servicioProvider);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> crearCitaConServicio({
    required Cliente cliente,
    required DateTime fechaHora,
    required int duracionEstimada,
    required CategoriaServicio categoriaServicio,
    required String direccionServicio,
    required String tipoLugar,
    required String comentariosAdicionales,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      logger.i('Iniciando creación de cita con servicio para cliente: ${cliente.nombre}');

      final nuevaCita = Cita(
        fechaHora: fechaHora,
        duracionEstimada: duracionEstimada,
        comentariosAdicionales: _construirComentariosCompletos(
          direccionServicio, 
          tipoLugar, 
          comentariosAdicionales
        ),
        estadoCita: EstadoCita.programado,
        idCliente: cliente.getId(),
        idEmpleado: null, 
        idServicio: null,
      );

      await _citaProvider.citasRepository.agregarCita(nuevaCita);
      final citasCliente = await _citaProvider.citasRepository.getCitasPorCliente(cliente.getId());
      final citaCreada = citasCliente.last;

      logger.i('Cita creada con ID: ${citaCreada.id}');

      final nuevoServicio = Servicio(
        nombre: _generarNombreServicio(categoriaServicio, cliente),
        descripcion: _generarDescripcionServicio(
          categoriaServicio, 
          direccionServicio, 
          comentariosAdicionales
        ),
        categoriaServicio: categoriaServicio,
        estadoServicio: EstadoServicio.programada,
        fechaCreacion: DateTime.now(),
        empleadoAsignado: null,
        duracionReal: duracionEstimada,
        fechaInicioServicio: fechaHora,
        fechaFinServicio: fechaHora.add(Duration(hours: duracionEstimada)),
        localizacionCoordenadas: null,
      );

      await _servicioProvider.addService(nuevoServicio);
      final serviciosRecientes = await _servicioProvider.servicioRepository.getListaServicios();
      final servicioCreado = serviciosRecientes.last;

      final citaActualizada = citaCreada.copyWith(
        idServicio: servicioCreado.idServicio,
      );

      await _citaProvider.citasRepository.actualizarCita(
        citaCreada.id.toString(), 
        citaActualizada
      );

      logger.i('Servicio creado con ID: ${servicioCreado.idServicio}');
      logger.i('Cita-Servicio vinculados correctamente');

      await _citaProvider.cargarCitas();
      await _servicioProvider.fetchServices();

      _setLoading(false);

      return {
        'success': true,
        'cita': citaActualizada,
        'servicio': servicioCreado,
        'message': 'Cita y servicio creados exitosamente'
      };

    } catch (e) {
      _setError('Error al crear cita con servicio: $e');
      _setLoading(false);
      logger.e('Error en crearCitaConServicio: $e');
      
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error al procesar la solicitud'
      };
    }
  }

  Future<List<Map<String, dynamic>>> obtenerServiciosConCitasCliente(int clienteId) async {
    try {
      final citas = await _citaProvider.citasRepository.getCitasPorCliente(clienteId);
      final servicios = _servicioProvider.todosMenosEliminados;
      
      List<Map<String, dynamic>> serviciosConCitas = [];
      
      for (final cita in citas) {
        if (cita.idServicio != null) {
          final servicio = servicios.firstWhere(
            (s) => s.idServicio == cita.idServicio,
            orElse: () => Servicio.empty(),
          );
          
          if (servicio.idServicio != null) {
            serviciosConCitas.add({
              'cita': cita,
              'servicio': servicio,
            });
          }
        }
      }
      
      return serviciosConCitas;
    } catch (e) {
      logger.e('Error obteniendo servicios con citas: $e');
      return [];
    }
  }

Future<bool> actualizarEstadosCitaServicio({
  required int citaId,
  required int servicioId,
  required EstadoCita nuevoEstadoCita,
  required EstadoServicio nuevoEstadoServicio,
  String? motivo,
}) async {
  try {
    _setLoading(true);

    final citaActual = await _citaProvider.citasRepository.getListaCitas();
    final cita = citaActual.firstWhere((c) => c.id == citaId);
    
    final citaActualizada = cita.copyWith(estadoCita: nuevoEstadoCita);
    await _citaProvider.citasRepository.actualizarCita(
      citaId.toString(), 
      citaActualizada
    );

    bool servicioActualizadoExitoso = false;
    
    if (nuevoEstadoServicio == EstadoServicio.cancelada) {
      await _servicioProvider.cambiarEstadoServicio(servicioId, EstadoServicio.cancelada);
    } else {
      final servicios = _servicioProvider.todosMenosEliminados;
      final servicio = servicios.firstWhere((s) => s.idServicio == servicioId);
      final servicioActualizadoObj = servicio.copyWith(estadoServicio: nuevoEstadoServicio);
      
      await _servicioProvider.updateService(
        servicioId.toString(), 
        servicioActualizadoObj 
      );
      servicioActualizadoExitoso = true; 
    }

    await _citaProvider.cargarCitas();
    await _servicioProvider.fetchServices();

    _setLoading(false);
    return servicioActualizadoExitoso;

  } catch (e) {
    logger.e('Error actualizando estados: $e');
    _setError('Error al actualizar estados: $e');
    _setLoading(false);
    return false;
  }
}

  String _generarNombreServicio(CategoriaServicio categoria, Cliente cliente) {
    final nombreCategoria = categoria.displayName;
    final fechaCorta = DateTime.now().toString().substring(0, 10);
    return '$nombreCategoria - ${cliente.nombre} ($fechaCorta)';
  }

  String _generarDescripcionServicio(
    CategoriaServicio categoria, 
    String direccion, 
    String comentarios
  ) {
    final descripcionBase = 'Servicio de ${categoria.displayName} solicitado por cliente.';
    final ubicacion = 'Ubicación: $direccion';
    final observaciones = comentarios.isNotEmpty 
        ? 'Observaciones: $comentarios' 
        : 'Sin observaciones adicionales.';
    
    return '$descripcionBase\n$ubicacion\n$observaciones';
  }

  String _construirComentariosCompletos(
    String direccion, 
    String tipoLugar, 
    String comentarios
  ) {
    final ubicacionCompleta = 'Dirección: $direccion ($tipoLugar)';
    final observaciones = comentarios.isNotEmpty 
        ? 'Comentarios adicionales: $comentarios' 
        : '';
    
    return observaciones.isNotEmpty 
        ? '$ubicacionCompleta\n$observaciones'
        : ubicacionCompleta;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}