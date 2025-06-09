import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';


class ServicioRepository {

  final ApiService _apiService = ApiService();
  Logger logger = Logger();


  // ENDPOINT DEL FRONTEND PARA OBTENER LA LISTA DE LOS SERVICIOS.
  Future<List<Servicio>> getListaServicios() async {
  try {
    final response = await _apiService.dio.get('/servicios');
    
    logger.i('Se cargaron los servicios correctamente');
    
    return (response.data as List)
        .map((json) => Servicio.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Error al obtener los Servicios: $e');
  }
}


  // ENDPOINT DEL FRONTEND PARA OBTENER LA LISTA DE LOS SERVICIOS POR EL ID DEL CLIENTE.
  Future<List<Servicio>> getServiciosPorCliente(int id) async {
    try {
      final response = await _apiService.dio.get("/servicios/cliente/$id");
      return (response.data as List)
        .map((json) => Servicio.fromJson(json))
        .toList();
    } catch (e) {
      throw Exception("Error al obtener los servicios por el id del cliente");
    }
  }

  // ENDPOINT DEL FRONTEND PARA CREAR UN NUEVO SERVICIO.
  Future<Servicio> createService(Servicio servicio) async {
    try {
      final response = await _apiService.dio.post(
        '/servicios',
        data: servicio.toJson(),
      );
      return Servicio.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear el Servicio: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA ACTUALIZAR UN SERVICIO.
  Future<Servicio> updateService(String serviceId, Servicio servicio) async {
    try {
      final response = await _apiService.dio.put(
        '/servicios/$serviceId',
        data: servicio.toJson(),
      );
      return Servicio.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar el Servicio: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA ELIMINAR UN SERVICIO.
  Future<void> deleteService(String serviceId) async {
    try {
      await _apiService.dio.delete('/servicios/$serviceId');
    } catch (e) {
      throw Exception('Error al eliminar el Servicio: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA CAMBIAR EL ESTADO DEL SERVICIO.
  Future<void> actualizarEstado(int id, String estado) async {
    await _apiService.dio.put("/servicios/$id", data: {"estado": estado});
  }

  // ENDPOINT DEL FRONTEND PARA ASIGNAR UN SERVICIO A UN EMPLEADO POR LOS IDS.
  Future<Servicio> asignarEmpleadoAServicio(int idServicio, int idEmpleado) async {
    try {
      final response = await _apiService.dio.put(
        '/servicios/$idServicio/asignar-empleado/$idEmpleado',
      );

      if (response.statusCode == 200) {
        return Servicio.fromJson(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Servicio o empleado no encontrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('No se puede asignar empleado: ${e.response?.data['message'] ?? 'Empleado en baja laboral'}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA QUITAR UN SERVICIO A UN EMPLEADO.
  Future<Servicio> desasignarEmpleadoDeServicio(int idServicio) async {
    try {
      final response = await _apiService.dio.put(
        '/servicios/$idServicio/desasignar-empleado',
      );

      if (response.statusCode == 200) {
        return Servicio.fromJson(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Servicio no encontrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('El servicio no tiene empleado asignado');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER LOS SERVICIOS POR EL ID DEL EMPLEADO.
  Future<List<Servicio>> getServiciosByEmpleado(int idEmpleado) async {
    try {
      final response = await _apiService.dio.get(
        '/servicios/empleado/$idEmpleado',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER LOS SERVICIOS QUE NO SE HAN ASIGNADO.
  Future<List<Servicio>> getServiciosSinAsignar() async {
    try {
      final response = await _apiService.dio.get('/servicios/sin-asignar');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER LAS ESTADISTICAS DE LOS SERVICIOS.
  Future<Map<String, dynamic>> getEstadisticasAsignacion() async {
    try {
      final response = await _apiService.dio.get('/servicios/estadisticas/asignacion');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA CAMBIAR UN SERVICIO DE UN EMPLEADO A OTRO EMPLEADO.
  Future<List<Servicio>> reasignarServiciosEmpleado(int idEmpleadoOrigen, int idEmpleadoDestino) async {
    try {
      final response = await _apiService.dio.put(
        '/servicios/reasignar-empleado',
        data: {
          'idEmpleadoOrigen': idEmpleadoOrigen,
          'idEmpleadoDestino': idEmpleadoDestino,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('No se puede reasignar: ${e.response?.data['message'] ?? 'Empleado destino en baja laboral'}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER LOS SERVICIOS PENDIENTES.
  Future<List<Servicio>> getServiciosPendientesByEmpleado(int idEmpleado) async {
    try {
      final response = await _apiService.dio.get(
        '/servicios/empleado/$idEmpleado/pendientes',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER LOS SERVICIOS POR UN RANGO DE FECHAS.
  Future<List<Servicio>> getServiciosCompletadosByEmpleadoAndFecha({
    required int idEmpleado,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/servicios/empleado/$idEmpleado/completados',
        queryParameters: {
          'fechaInicio': fechaInicio.toIso8601String(),
          'fechaFin': fechaFin.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER LAS ESTADISTICAS DE UN EMPLEADO.
  Future<Map<String, dynamic>> getEstadisticasProductividadEmpleados() async {
    try {
      final response = await _apiService.dio.get('/servicios/estadisticas/productividad');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA VERIFICAR SI UN EMPLEADO PUEDE TENER MAS SERVICIOS.
  Future<bool> puedeAsignarMasServicios(int idEmpleado, {int maxServicios = 5}) async {
    try {
      final response = await _apiService.dio.get(
        '/servicios/empleado/$idEmpleado/puede-asignar',
        queryParameters: {'maxServicios': maxServicios},
      );

      if (response.statusCode == 200) {
        return response.data['puedeAsignar'] ?? false;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // ENDPOINT DEL FRONTEND PARA BUSCAR SERVICIOS POR FILTROS VARIOS.
  Future<List<Servicio>> buscarServiciosConFiltros({
    String? busqueda,
    EstadoServicio? estado,
    CategoriaServicio? categoria,
    int? idEmpleadoAsignado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool? sinAsignar,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (busqueda != null && busqueda.isNotEmpty) {
        queryParams['busqueda'] = busqueda;
      }
      if (estado != null) {
        queryParams['estado'] = estado.backendValue;
      }
      if (categoria != null) {
        queryParams['categoria'] = categoria.backendValue;
      }
      if (idEmpleadoAsignado != null) {
        queryParams['empleado'] = idEmpleadoAsignado;
      }
      if (fechaDesde != null) {
        queryParams['fechaDesde'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        queryParams['fechaHasta'] = fechaHasta.toIso8601String();
      }
      if (sinAsignar != null) {
        queryParams['sinAsignar'] = sinAsignar;
      }

      final response = await _apiService.dio.get(
        '/servicios/buscar',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
