import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:dio/dio.dart';


class EmpleadoRepository {
  
  final ApiService _apiService = ApiService();

  // ENDPOINT DEL FRONTEND PARA CREAR UN NUEVO EMPLEADO.
  Future<void> agregarEmpleado(Empleado empleado) async {
    await _apiService.dio.post('/empleados', data: empleado.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ACTUALIZAR UN EMPLEADO.
  Future<void> actualizarEmpleado(String id, Empleado empleado) async {
    await _apiService.dio.put('/empleados/$id', data: empleado.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ELIMINAR UN EMPLEADO.
  Future<void> eliminarEmpleado(int id) async {
    await _apiService.dio.delete('/empleados/$id');
  }

    // ENDPOINT DEL FRONTEND PARA OBTENER LA LISTA DE LOS EMPLEADOS QUE NO ESTAN DE BAJA LABORAL.
  Future<List<Empleado>> obtenerEmpleadosDisponibles() async {
    try {
      final response = await _apiService.dio.get('/empleados/disponibles');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.map((json) => Empleado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener empleados disponibles: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }


  // ENDPOINT DEL FRONTEND PARA OBTENER EL LISTADO DE LOS EMPLEADOS.
  Future<List<Empleado>> obtenerTodosLosEmpleados() async {
    try {
      final response = await _apiService.dio.get('/empleados');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.map((json) => Empleado.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener empleados: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // ENDPOINT DEL FRONTEND PARA OBTENER EL EMPLEADO POR SU ID.
  Future<Empleado> obtenerEmpleadoPorId(int id) async {
    try {
      final response = await _apiService.dio.get('/empleados/$id');
      
      if (response.statusCode == 200) {
        return Empleado.fromJson(response.data);
      } else {
        throw Exception('Empleado no encontrado');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // ENDPOINT DEL FRONTEND PARA CREAR UN NUEVO EMPLEADO.
  Future<Empleado> crearEmpleado(Empleado empleado) async {
    try {
      final response = await _apiService.dio.post(
        '/empleados',
        data: empleado.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Empleado.fromJson(response.data);
      } else {
        throw Exception('Error al crear empleado: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // ENDPOINT DEL FRONTEND PARA CAMBIAR DAR DE BAJA LABORAL A UN EMPLEADO.
  Future<Empleado> darDeBajaEmpleado(int id) async {
    try {
      final response = await _apiService.dio.put('/empleados/$id/baja');
      
      if (response.statusCode == 200) {
        return Empleado.fromJson(response.data);
      } else {
        throw Exception('Error al dar de baja empleado: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // ENDPOINT DEL FRONTEND PARA CAMBIAR DAR DE ALTA DE LA BAJA LABORAL A UN EMPLEADO.
  Future<Empleado> darDeAltaEmpleado(int id) async {
    try {
      final response = await _apiService.dio.put('/empleados/$id/alta');
      
      if (response.statusCode == 200) {
        return Empleado.fromJson(response.data);
      } else {
        throw Exception('Error al dar de alta empleado: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // ENDPOINT DEL FRONTEND PARA BUSCAR UN EMPLEADO POR SU EMAIL.
  Future<Empleado> buscarEmpleadoPorEmail(String email) async {
    try {
      final response = await _apiService.dio.get('/empleados/email/$email');
      
      if (response.statusCode == 200) {
        return Empleado.fromJson(response.data);
      } else {
        throw Exception('Empleado no encontrado');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Empleado no encontrado con ese email');
      } else if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }
}