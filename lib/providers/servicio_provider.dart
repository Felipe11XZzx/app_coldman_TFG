import 'dart:convert';
import 'dart:math';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/repositories/servicio_repository.dart';
import 'package:logger/logger.dart';

class ServicioProvider with ChangeNotifier {
  final ServicioRepository servicioRepository = ServicioRepository();
  Logger logger = Logger();
  List<Servicio> _servicios = [];
  bool _isLoading = false;
  String? _error;
  ApiService _apiService = ApiService();

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _servicios = await servicioRepository.getListaServicios();
    } catch (e) {
      logger.e('Error al cargar los Servicios: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(Servicio servicio) async {
    try {
      await servicioRepository.createService(servicio);
      await fetchServices();
    } catch (e) {
      logger.e('Error al agregar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> updateService(String serviceId, Servicio servicio) async {
    try {
      await servicioRepository.updateService(serviceId, servicio);
      await fetchServices();
    } catch (e) {
      logger.e('Error al actualizar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await servicioRepository.deleteService(serviceId);
      await fetchServices();
    } catch (e) {
      logger.e('Error al eliminar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> updatePedidoEstado(int id, String estado) async {
    await servicioRepository.actualizarEstado(id, estado);
    fetchServices();
  }

  Future<Servicio> asignarEmpleadoAServicio(
      int servicioId, int empleadoId) async {
    logger.i('Asignando empleado $empleadoId al servicio $servicioId');

    try {
      final response = await _apiService.dio.put(
        '/servicios/$servicioId/asignar-empleado/$empleadoId',
      );

      if (response.statusCode == 200) {
        final servicioActualizado = Servicio.fromJson(response.data);

        final index = _servicios.indexWhere((s) => s.idServicio == servicioId);

        if (index != -1) {
          logger.i('Servicio ANTES de actualizar:');
          logger.i(
              'Empleado: ${_servicios[index].empleadoAsignado?.nombre ?? "NULL"}');
          _servicios[index] = servicioActualizado;
          logger.i('Servicio DESPUÉS de actualizar:');
          logger.i(
              'Empleado: ${_servicios[index].empleadoAsignado?.nombre ?? "NULL"}');
          notifyListeners();
        }

        return servicioActualizado;
      } else {
        throw Exception('Error al asignar empleado: ${response.data}');
      }
    } catch (e) {
      logger.e('Error al asignar empleado: $e');
      throw Exception('Error al asignar empleado: $e');
    }
  }

  // METODO PARA QUITAR UN EMPLEADO DE UN SERVICIO.
  Future<Servicio> desasignarEmpleadoDeServicio(int servicioId) async {
    try {
      final response = await _apiService.dio.put(
        '/servicios/$servicioId/desasignar-empleado',
      );

      if (response.statusCode == 200) {
        final servicioActualizado = Servicio.fromJson(response.data);

        final index = servicios.indexWhere((s) => s.idServicio == servicioId);
        if (index != -1) {
          servicios[index] = servicioActualizado;
          notifyListeners();
        }

        return servicioActualizado;
      } else {
        logger.e('Error al desasignar empleado: $e');
        throw Exception('Error al desasignar empleado: ${response.data}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response != null) {
        errorMessage = 'Error ${e.response!.statusCode}: ${e.response!.data}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }

// METODO PARA ELIMINAR UN SERVICIO.
  Future<void> eliminarServicio(int servicioId) async {
    try {
      final response = await _apiService.dio.delete(
        '/servicios/$servicioId',
      );

      if (response.statusCode == 200) {
        servicios.removeWhere((servicio) => servicio.idServicio == servicioId);
        notifyListeners();
      } else {
        logger.e('Error al eliminar servicio: $e');
        throw Exception('Error al eliminar servicio: ${response.data}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response != null) {
        errorMessage = 'Error ${e.response!.statusCode}: ${e.response!.data}';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Error de conexión con el servidor';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // METODO PARA OBTENER LOS SERVICIOS.
  Future<void> obtenerServicios() async {
    try {
      final response = await _apiService.dio.get('/servicios');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        _servicios = jsonData.map((json) => Servicio.fromJson(json)).toList();
        notifyListeners();
      } else {
        logger.e('Error al obtener servicios: ${response.data}');
        throw Exception('Error al obtener servicios: ${response.data}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response != null) {
        errorMessage = 'Error ${e.response!.statusCode}: ${e.response!.data}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  // METODO PARA OBTENER LOS SERVICIOS POR ID DEL EMPLEADO.
  Future<List<Servicio>> obtenerServiciosDeEmpleado(int empleadoId) async {
    try {
      final response =
          await _apiService.dio.get('/servicios/empleado/$empleadoId');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.map((json) => Servicio.fromJson(json)).toList();
      } else {
        logger.e('Error al obtener servicios del empleado: ${response.data}');
        throw Exception(
            'Error al obtener servicios del empleado: ${response.data}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response != null) {
        errorMessage = 'Error ${e.response!.statusCode}: ${e.response!.data}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // METODO PARA OBTENER LOS SERVICIOS POR EL ID DEL EMPLEADO.
  Future<List<Servicio>> getServiciosByEmpleado(int idEmpleado) async {
    try {
      return await servicioRepository.getServiciosByEmpleado(idEmpleado);
    } catch (e) {
      logger.e('Error al obtener servicios del empleado: $e');
      throw Exception('Error al obtener servicios del empleado: $e');
    }
  }

  // METODO PARA OBTENER LOS SERVICIOS SIN ASIGNAR.
  Future<List<Servicio>> getServiciosSinAsignar() async {
    try {
      return await servicioRepository.getServiciosSinAsignar();
    } catch (e) {
      logger.e('Error al obtener servicios sin asignar: $e');
      throw Exception('Error al obtener servicios sin asignar: $e');
    }
  }

  // METODO PARA OBTENER LAS ESTADISTICAS DE LOS SERVICIOS DE LA APP.
  Future<Map<String, dynamic>> getEstadisticasAsignacion() async {
    try {
      return await servicioRepository.getEstadisticasAsignacion();
    } catch (e) {
      logger.e('Error al obtener estadísticas: $e');
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // METODO LOCAL PARA FILTRAR SERVICIOS QUE TIENE UN ID EMPLEADO ASIGNADO.
  List<Servicio> getServiciosFiltradosPorEmpleado(int? idEmpleado) {
    if (idEmpleado == null) return servicios;

    return servicios.where((servicio) {
      return false;
    }).toList();
  }

  // METODO LOCAL PARA FILTRAR SERVICIOS QUE NO TIENEN UN EMPLEADO ASIGNADO.
  List<Servicio> getServiciosSinAsignarLocal() {
    return servicios.where((servicio) {
      return true;
    }).toList();
  }

  // METODO LOCAL PARA COMPROBAR QUE EL EMPLADO TIENE SERVICIOS ASIGNADOS.
  bool empleadoTieneServicios(int idEmpleado) {
    return servicios.any((servicio) {
      return false;
    });
  }

  // METODO LOCAL PARA CONTAR LOS SERVICIOS POR ESTADO DE UN EMPLEADO.
  Map<EstadoServicio, int> getEstadisticasServiciosEmpleado(int idEmpleado) {
    final serviciosEmpleado = getServiciosFiltradosPorEmpleado(idEmpleado);

    final estadisticas = <EstadoServicio, int>{};
    for (final estado in EstadoServicio.values) {
      estadisticas[estado] =
          serviciosEmpleado.where((s) => s.estadoServicio == estado).length;
    }

    return estadisticas;
  }

  // METODO LOCAL PARA OBTENER LOS SERVICIOS DEL EMPLEADO QUE ESTAN PROGRAMADO O ESTAN PROGRESANDO.
  List<Servicio> getServiciosPendientesEmpleado(int idEmpleado) {
    return getServiciosFiltradosPorEmpleado(idEmpleado)
        .where((servicio) =>
            servicio.estadoServicio == EstadoServicio.programada ||
            servicio.estadoServicio == EstadoServicio.progresando)
        .toList();
  }

  // METODO LOCAL PARA FILTRAR SERVICIOS.
  List<Servicio> getServiciosCompletadosEmpleado(int idEmpleado) {
    return getServiciosFiltradosPorEmpleado(idEmpleado)
        .where(
            (servicio) => servicio.estadoServicio == EstadoServicio.completada)
        .toList();
  }

  // METODO LOCAL PARA OBTENER LOS SERVICIOS DEL EMPLEADO TERMINADOS.
  Future<void> reasignarServiciosEmpleado(
      int idEmpleadoOrigen, int idEmpleadoDestino) async {
    try {
      _isLoading = true;
      notifyListeners();

      await servicioRepository.reasignarServiciosEmpleado(
          idEmpleadoOrigen, idEmpleadoDestino);
      await fetchServices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      logger.e('Error al reasignar servicios: $e');
      throw Exception('Error al reasignar servicios: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // METODO PARA LIMPIAR LOS ERRORES.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // METODO LOCAL PARA ACTUALIZAR UN SERVICIO.
  void _actualizarServicioEnLista(Servicio servicioActualizado) {
    final index = servicios
        .indexWhere((s) => s.idServicio == servicioActualizado.idServicio);
    if (index != -1) {
      servicios[index] = servicioActualizado;
      notifyListeners();
    }
  }

  Map<String, dynamic> getResumenAsignaciones() {
    final total = servicios.length;
    final sinAsignar = getServiciosSinAsignarLocal().length;
    final asignados = total - sinAsignar;
    final porcentajeAsignacion =
        total > 0 ? (asignados / total * 100).round() : 0;

    final serviciosPorEmpleado = <int, List<Servicio>>{};
    for (final servicio in servicios) {}

    return {
      'totalServicios': total,
      'serviciosAsignados': asignados,
      'serviciosSinAsignar': sinAsignar,
      'porcentajeAsignacion': porcentajeAsignacion,
      'empleadosConServicios': serviciosPorEmpleado.length,
      'serviciosPorEmpleado': serviciosPorEmpleado,
    };
  }

  // GETTERS DEL PROVIDER DE LOS INFORMES.
  List<Servicio> get servicios => _servicios;
  bool get isLoading => _isLoading;
  String? get error => _error;
  get http => null;
}
