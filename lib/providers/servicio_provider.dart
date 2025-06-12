import 'dart:convert';
import 'dart:math';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/repositories/servicio_repository.dart';
import 'package:logger/logger.dart';


// EXCEPCIÓN PERSONALIZADA PARA DEPENDENCIAS
class DependencyException implements Exception {
    final String message;
    DependencyException(this.message);
    
    @override
    String toString() => message;
}

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
      logger.i('Obteniendo servicios desde el backend...');
      _servicios = await servicioRepository.getListaServicios();
      
      logger.i('Servicios obtenidos: ${_servicios.length}');
      for (int i = 0; i < _servicios.length; i++) {
        final servicio = _servicios[i];
        logger.i('Servicio [$i]:');
        logger.i('ID: ${servicio.idServicio}');
        logger.i('Nombre: ${servicio.nombre}');
        logger.i('Estado: ${servicio.estadoServicio.displayName}');
        logger.i('Categoría: ${servicio.categoriaServicio.displayName}');
        logger.i('Empleado asignado: ${servicio.tieneEmpleadoAsignado ? servicio.nombreEmpleadoAsignado : "Sin asignar"}');
        logger.i('Tiene cita: ${servicio.tieneCita}');
        if (servicio.tieneCita) {
          logger.i('Estado cita: ${servicio.cita!.estadoDisplayName}');
          logger.i('Fecha cita: ${servicio.cita!.fechaHora}');
        }
        logger.i('Fecha eliminación: ${servicio.fechaEliminacion}');
        logger.i('Motivo eliminación: ${servicio.motivoEliminacion ?? "N/A"}');
        logger.i('---');
      }
    } catch (e) {
      logger.e('Error al cargar los Servicios: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(Servicio servicio) async {
    try {
      logger.i('Agregando nuevo servicio: ${servicio.nombre}');
      await servicioRepository.createService(servicio);
      await fetchServices();
      logger.i('Servicio agregado exitosamente');
    } catch (e) {
      logger.e('Error al agregar un Servicio: $e');
      rethrow;
    }
  }


  Future<void> updateService(String serviceId, Servicio servicio) async {
  try {
    logger.i('Actualizando servicio ID: $serviceId');
    
    if (servicio.empleadoAsignado != null) {
      await asignarEmpleadoAServicio(
        int.parse(serviceId), 
        servicio.empleadoAsignado!.id!
      );
      logger.i('Empleado asignado exitosamente');
      return;
    }
    
    throw Exception('Use métodos específicos para actualizar servicios');
    
  } catch (e) {
    logger.e('Error al actualizar un Servicio: $e');
    rethrow;
  }
}

  Future<void> deleteService(String serviceId) async {
    try {
      logger.i('Eliminando servicio ID: $serviceId');
      await servicioRepository.deleteService(serviceId);
      await fetchServices();
      logger.i('Servicio eliminado exitosamente');
    } catch (e) {
      logger.e('Error al eliminar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> updateEstadoServicio(int id, String estado) async {
    logger.i('Actualizando estado del servicio $id a: $estado');
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
        logger.i('Empleado asignado correctamente');
        logger.i('Verificando asignación:');
        logger.i('Servicio ID: ${servicioActualizado.idServicio}');
        logger.i('Empleado asignado: ${servicioActualizado.tieneEmpleadoAsignado}');
        if (servicioActualizado.tieneEmpleadoAsignado) {
          logger.i('Nombre empleado: ${servicioActualizado.nombreEmpleadoAsignado}');
        }

        final index = _servicios.indexWhere((s) => s.idServicio == servicioId);

        if (index != -1) {
          logger.i('Actualizando servicio en la lista local...');
          logger.i('Servicio ANTES de actualizar:');
          logger.i('Empleado: ${_servicios[index].empleadoAsignado?.nombre ?? "NULL"}');
          
          _servicios[index] = servicioActualizado;
          
          logger.i('Servicio DESPUÉS de actualizar:');
          logger.i('Empleado: ${_servicios[index].empleadoAsignado?.nombre ?? "NULL"}');
          notifyListeners();
        } else {
          logger.w('No se encontró el servicio en la lista local');
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
      logger.i('Desasignando empleado del servicio $servicioId');
      
      final response = await _apiService.dio.put(
        '/servicios/$servicioId/desasignar-empleado',
      );

      if (response.statusCode == 200) {
        final servicioActualizado = Servicio.fromJson(response.data);
        logger.i('Empleado desasignado correctamente');

        final index = _servicios.indexWhere((s) => s.idServicio == servicioId);
        if (index != -1) {
          _servicios[index] = servicioActualizado;
          notifyListeners();
        }

        return servicioActualizado;
      } else {
        logger.e('Error al desasignar empleado: ${response.data}');
        throw Exception('Error al desasignar empleado: ${response.data}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de conexión';

      if (e.response != null) {
        errorMessage = 'Error ${e.response!.statusCode}: ${e.response!.data}';
      }

      logger.e('DioException: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  // METODO PARA OBTENER LOS SERVICIOS POR EL ID DEL EMPLEADO.
  Future<List<Servicio>> getServiciosByEmpleado(int idEmpleado) async {
    try {
      logger.i('Obteniendo servicios asignados al empleado $idEmpleado');
      final servicios = await servicioRepository.getServiciosByEmpleado(idEmpleado);
      logger.i('${servicios.length} servicios encontrados para empleado $idEmpleado');
      return servicios;
    } catch (e) {
      logger.e('Error al obtener servicios del empleado: $e');
      throw Exception('Error al obtener servicios del empleado: $e');
    }
  }

  // METODO PARA OBTENER LOS SERVICIOS SIN ASIGNAR.
  Future<List<Servicio>> getServiciosSinAsignar() async {
    try {
      logger.i('Obteniendo servicios sin asignar...');
      final servicios = await servicioRepository.getServiciosSinAsignar();
      logger.i('${servicios.length} servicios sin asignar encontrados');
      return servicios;
    } catch (e) {
      logger.e('Error al obtener servicios sin asignar: $e');
      throw Exception('Error al obtener servicios sin asignar: $e');
    }
  }

  // METODO PARA OBTENER LAS ESTADISTICAS DE LOS SERVICIOS DE LA APP.
  Future<Map<String, dynamic>> getEstadisticasAsignacion() async {
    try {
      logger.i('Obteniendo estadísticas de asignación...');
      final estadisticas = await servicioRepository.getEstadisticasAsignacion();
      logger.i('Estadísticas obtenidas correctamente');
      return estadisticas;
    } catch (e) {
      logger.e('Error al obtener estadísticas: $e');
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // METODO LOCAL PARA FILTRAR SERVICIOS QUE TIENE UN ID EMPLEADO ASIGNADO.
  List<Servicio> getServiciosFiltradosPorEmpleado(int? idEmpleado) {
    if (idEmpleado == null) return _servicios;

    final serviciosFiltrados = _servicios.where((servicio) {
      return servicio.tieneEmpleadoAsignado && 
             servicio.empleadoAsignado!.id == idEmpleado;
    }).toList();

    logger.i('🔍 Servicios filtrados para empleado $idEmpleado: ${serviciosFiltrados.length}');
    return serviciosFiltrados;
  }

  // METODO LOCAL PARA FILTRAR SERVICIOS QUE NO TIENEN UN EMPLEADO ASIGNADO.
  List<Servicio> getServiciosSinAsignarLocal() {
    final serviciosSinAsignar = _servicios.where((servicio) {
      return !servicio.tieneEmpleadoAsignado;
    }).toList();

    logger.i('Servicios sin asignar (local): ${serviciosSinAsignar.length}');
    return serviciosSinAsignar;
  }

  // METODO LOCAL PARA COMPROBAR QUE EL EMPLEADO TIENE SERVICIOS ASIGNADOS.
  bool empleadoTieneServicios(int idEmpleado) {
    final tieneServicios = _servicios.any((servicio) {
      return servicio.tieneEmpleadoAsignado && 
             servicio.empleadoAsignado!.id == idEmpleado;
    });

    logger.i('🔍 Empleado $idEmpleado tiene servicios: $tieneServicios');
    return tieneServicios;
  }

  // METODO LOCAL PARA CONTAR LOS SERVICIOS POR ESTADO DE UN EMPLEADO.
  Map<EstadoServicio, int> getEstadisticasServiciosEmpleado(int idEmpleado) {
    final serviciosEmpleado = getServiciosFiltradosPorEmpleado(idEmpleado);

    final estadisticas = <EstadoServicio, int>{};
    for (final estado in EstadoServicio.values) {
      estadisticas[estado] =
          serviciosEmpleado.where((s) => s.estadoServicio == estado).length;
    }

    logger.i('Estadísticas empleado $idEmpleado: $estadisticas');
    return estadisticas;
  }

  // METODO LOCAL PARA OBTENER LOS SERVICIOS DEL EMPLEADO QUE ESTAN PROGRAMADO O ESTAN PROGRESANDO.
  List<Servicio> getServiciosPendientesEmpleado(int idEmpleado) {
    final serviciosPendientes = getServiciosFiltradosPorEmpleado(idEmpleado)
        .where((servicio) =>
            servicio.estadoServicio == EstadoServicio.programada ||
            servicio.estadoServicio == EstadoServicio.progresando)
        .toList();

    logger.i('Servicios pendientes empleado $idEmpleado: ${serviciosPendientes.length}');
    return serviciosPendientes;
  }

  // METODO LOCAL PARA FILTRAR SERVICIOS COMPLETADOS.
  List<Servicio> getServiciosCompletadosEmpleado(int idEmpleado) {
    final serviciosCompletados = getServiciosFiltradosPorEmpleado(idEmpleado)
        .where(
            (servicio) => servicio.estadoServicio == EstadoServicio.completada)
        .toList();

    logger.i('Servicios completados empleado $idEmpleado: ${serviciosCompletados.length}');
    return serviciosCompletados;
  }

  // METODO PARA REASIGNAR SERVICIOS DE UN EMPLEADO A OTRO.
  Future<void> reasignarServiciosEmpleado(
      int idEmpleadoOrigen, int idEmpleadoDestino) async {
    try {
      _isLoading = true;
      notifyListeners();

      logger.i('Reasignando servicios del empleado $idEmpleadoOrigen al empleado $idEmpleadoDestino');

      await servicioRepository.reasignarServiciosEmpleado(
          idEmpleadoOrigen, idEmpleadoDestino);
      await fetchServices();
      
      logger.i('Servicios reasignados correctamente');
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
    logger.i('Errores limpiados');
  }

  // METODO LOCAL PARA ACTUALIZAR UN SERVICIO.
  void _actualizarServicioEnLista(Servicio servicioActualizado) {
    final index = _servicios
        .indexWhere((s) => s.idServicio == servicioActualizado.idServicio);
    if (index != -1) {
      _servicios[index] = servicioActualizado;
      notifyListeners();
      logger.i('Servicio ${servicioActualizado.idServicio} actualizado en lista local');
    } else {
      logger.w('No se encontró el servicio ${servicioActualizado.idServicio} para actualizar');
    }
  }

  Future<void> eliminarServicio(int servicioId) async {
    try {
      final response = await _apiService.dio.delete('/servicios/$servicioId');

      if (response.statusCode == 200) {
        _servicios.removeWhere((servicio) => servicio.idServicio == servicioId);
        notifyListeners();
        logger.i('Servicio $servicioId eliminado exitosamente');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      logger.e('Error al eliminar servicio $servicioId: ${e.response?.statusCode} - ${e.response?.data}');

      if (e.response?.statusCode == 409) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData['code'] == 'HAS_DEPENDENCIES') {
          throw DependencyException(responseData['message']);
        }
      } else if (e.response?.statusCode == 404) {
        String serverMessage = e.response!.data?.toString() ?? '';
        if (serverMessage.contains('citas asociadas')) {
          throw DependencyException('No se puede eliminar el servicio porque tiene citas programadas asociadas.');
        }
      }
      
      throw Exception('Error eliminando servicio: ${e.response?.data ?? e.message}');
    } catch (e) {
      logger.e('Error inesperado al eliminar servicio $servicioId: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  // ELIMINAR CON CANCELACIÓN DE CITAS
  Future<void> eliminarServicioConCancelacionCitas(int servicioId) async {
    try {
      final response = await _apiService.dio.delete('/servicios/$servicioId/con-cancelacion-citas');
      
      if (response.statusCode == 200) {
        _servicios.removeWhere((servicio) => servicio.idServicio == servicioId);
        notifyListeners();
      }
      
    } catch (e) {
      throw Exception('Error eliminando servicio con cancelación: $e');
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


Future<void> cambiarEstadoServicio(int servicioId, EstadoServicio nuevoEstado) async {
  try {
    
    String estadoString = nuevoEstado.backendValue;

    final response = await _apiService.dio.put(
      '/servicios/$servicioId/estado',
      data: {
        'estado': estadoString,
      },
    );
    
    if (response.statusCode == 200) {
      logger.i('Estado del servicio cambiado exitosamente');
      await obtenerServicios();
    }
  } catch (e) {
    logger.i('Error al cambiar estado del servicio: $e');
  }
}

  Future<void> eliminarServicioFisico(int servicioId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.dio.delete('/servicios/$servicioId/hard-delete');

      if (response.statusCode == 200) {
        // Remover de la lista local
        _servicios.removeWhere((s) => s.idServicio == servicioId);
        logger.i('Servicio $servicioId eliminado físicamente');
      } else {
        throw Exception('Error al eliminar físicamente: ${response.data}');
      }
    } on DioException catch (e) {
      logger.e('Error en eliminación física: ${e.response?.data}');
      throw _handleDioException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Servicio> get serviciosActivos {
    return _servicios.where((s) => s.esVisible).toList();
  }

  List<Servicio> get serviciosEliminados {
    return _servicios.where((s) => s.estaEliminado).toList();
  }

  List<Servicio> get serviciosArchivados {
    return _servicios.where((s) => s.estaArchivado).toList();
  }

  List<Servicio> get todosMenosEliminados {
    return _servicios.where((s) => !s.estaEliminado).toList();
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 409) {
      final message = e.response?.data['message'] ?? 'Conflicto de dependencias';
      return DependencyException(message);
    } else if (e.response?.statusCode == 404) {
      return Exception('Servicio no encontrado');
    } else if (e.response?.statusCode == 403) {
      return Exception('Sin permisos para realizar esta acción');
    } else {
      return Exception('Error del servidor: ${e.response?.statusCode}');
    }
  }

  Map<String, int> getEstadisticasResumen() {
    final total = _servicios.length;
    final activos = _servicios.where((s) => s.esVisible).length;
    final eliminados = _servicios.where((s) => s.estaEliminado).length;
    final archivados = _servicios.where((s) => s.estaArchivado).length;
    final sinAsignar = getServiciosSinAsignarLocal().length;
    final asignados = activos - sinAsignar;

    return {
      'total': total,
      'activos': activos,
      'eliminados': eliminados,
      'archivados': archivados,
      'sinAsignar': sinAsignar,
      'asignados': asignados,
    };
  }

  
  bool get isLoading => _isLoading;
  String? get error => _error;
}