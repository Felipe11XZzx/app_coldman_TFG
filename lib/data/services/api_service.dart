import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'dart:convert';


class ApiService {
  
  final logger = Logger();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api_coldman/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      logger.i('Request: ${options.method} ${options.path}');
      logger.i('Request Data: ${options.data}');
      return handler.next(options);
    }, onResponse: (response, handler) {
      logger.i('Response: ${response.statusCode}');
      logger.i('Response Data: ${response.data}');
      return handler.next(response);
    }, onError: (DioException e, handler) {
      logger.e(
          'API Error: ${e.response?.statusCode} ${_dio.options.baseUrl}${e.requestOptions.path}');
      logger.e('Error Data: ${e.response?.data}');
      logger.e('Error Message: ${e.message}');
      return handler.next(e);
    }));
  }

  // CREAR SERVICIO
  Future<Map<String, dynamic>> crearServicio(Map<String, dynamic> servicioData) async {
    try {
      logger.i('Creando servicio: ${servicioData['nombre']}');
      
      final response = await _dio.post('/servicios', data: servicioData);
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        logger.i('Servicio creado exitosamente: ID ${response.data['servicio']['id_servicio']}');
        return response.data;
      } else {
        throw Exception('Error del servidor: ${response.data['message'] ?? 'Error desconocido'}');
      }
    } on DioException catch (e) {
      logger.e('Error creando servicio: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception('Error del servidor: ${e.response?.data['message']}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    }
  }

  // OBTENER SERVICIO POR ID
  Future<Map<String, dynamic>?> obtenerServicio(int id) async {
    try {
      logger.i('Obteniendo servicio ID: $id');

      final response = await _dio.get('/servicios/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        logger.i('Servicio obtenido: ${response.data['servicio']['nombre_servicio']}');
        return response.data;
      } else if (response.statusCode == 404) {
        logger.w('Servicio no encontrado: ID $id');
        return null;
      } else {
        throw Exception('Error obteniendo servicio: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      logger.e('Error obteniendo servicio: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // OBTENER TODOS LOS SERVICIOS
  Future<Map<String, dynamic>> obtenerTodosLosServicios() async {
    try {
      logger.i('Obteniendo todos los servicios...');

      final response = await _dio.get('/servicios');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final int total = response.data['total'] ?? 0;
        logger.i('Obtenidos $total servicios');
        return response.data;
      } else {
        throw Exception('Error obteniendo servicios: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error obteniendo servicios: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // ELIMINAR SERVICIO
  Future<bool> eliminarServicio(int id) async {
    try {
      logger.i('Eliminando servicio ID: $id');

      final response = await _dio.delete('/servicios/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        logger.i('Servicio eliminado exitosamente');
        return true;
      } else {
        throw Exception('Error eliminando servicio: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error eliminando servicio: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // OBTENER ESTADÍSTICAS
  Future<Map<String, dynamic>> obtenerEstadisticasServicios() async {
    try {
      logger.i('Obteniendo estadísticas...');

      final response = await _dio.get('/servicios/estadisticas');

      if (response.statusCode == 200 && response.data['success'] == true) {
        logger.i('Estadísticas obtenidas');
        return response.data;
      } else {
        throw Exception('Error obteniendo estadísticas: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error obteniendo estadísticas: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // BUSCAR SERVICIOS POR CATEGORÍA
  Future<Map<String, dynamic>> obtenerServiciosPorCategoria(String categoria) async {
    try {
      logger.i('Buscando servicios por categoría: $categoria');

      final response = await _dio.get('/servicios/categoria/$categoria');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final int total = response.data['total'] ?? 0;
        logger.i('Encontrados $total servicios de categoría $categoria');
        return response.data;
      } else {
        throw Exception('Error buscando por categoría: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error buscando por categoría: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // BUSCAR SERVICIOS POR ESTADO
  Future<Map<String, dynamic>> obtenerServiciosPorEstado(String estado) async {
    try {
      logger.i('Buscando servicios por estado: $estado');

      final response = await _dio.get('/servicios/estado/$estado');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final int total = response.data['total'] ?? 0;
        logger.i('Encontrados $total servicios con estado $estado');
        return response.data;
      } else {
        throw Exception('Error buscando por estado: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error buscando por estado: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // OBTENER SERVICIOS CON COORDENADAS
  Future<Map<String, dynamic>> obtenerServiciosConCoordenadas() async {
    try {
      logger.i('Obteniendo servicios con coordenadas...');

      final response = await _dio.get('/servicios/con-coordenadas');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final int total = response.data['total'] ?? 0;
        logger.i('Encontrados $total servicios con coordenadas');
        return response.data;
      } else {
        throw Exception('Error obteniendo servicios con coordenadas: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error obteniendo servicios con coordenadas: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // BUSCAR SERVICIOS POR NOMBRE
  Future<Map<String, dynamic>> buscarServiciosPorNombre(String nombre) async {
    try {
      logger.i('Buscando servicios por nombre: $nombre');

      final response = await _dio.get('/servicios/buscar', queryParameters: {'nombre': nombre});

      if (response.statusCode == 200 && response.data['success'] == true) {
        final int total = response.data['total'] ?? 0;
        logger.i('Encontrados $total servicios que contienen "$nombre"');
        return response.data;
      } else {
        throw Exception('Error buscando por nombre: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error buscando por nombre: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // BUSCAR SERVICIOS POR RANGO DE PRECIOS.
  Future<Map<String, dynamic>> obtenerServiciosPorRangoPrecios({double? minPrecio, double? maxPrecio}) async {
    try {
      logger.i('Buscando servicios por rango de precios: \$${minPrecio ?? 0} - \$${maxPrecio ?? '∞'}');

      final queryParams = <String, dynamic>{};
      if (minPrecio != null) queryParams['minPrecio'] = minPrecio;
      if (maxPrecio != null) queryParams['maxPrecio'] = maxPrecio;

      final response = await _dio.get('/servicios/precio', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final int total = response.data['total'] ?? 0;
        logger.i('Encontrados $total servicios en el rango de precios');
        return response.data;
      } else {
        throw Exception('Error buscando por rango de precios: ${response.data['message']}');
      }
    } on DioException catch (e) {
      logger.e('Error buscando por rango de precios: ${e.message}');
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  // METODO HELPER PARA CREAR SERVICIO CON COORDENADAS.
  Future<Map<String, dynamic>> crearServicioConCoordenadas({
    required String nombre,
    required String descripcion,
    required int duracionEstimada,
    required double precio,
    required String categoria,
    String estado = 'Pendiente',
    String avanceFotos = '',
    double? latitud,
    double? longitud,
  }) async {
    final Map<String, dynamic> servicioData = {
      'nombre_servicio': nombre,
      'descripcion_servicio': descripcion,
      'duracion_estimada': duracionEstimada,
      'precio': precio,
      'categoria_servicio': categoria,
      'estado_servicio': estado,
      'avance_fotos': avanceFotos,
      'fecha_creacion_servicio': DateTime.now().toIso8601String().split('T')[0],
    };

    // AGREGAR COORDENADAS SI SE PROPORCIONAN.
    if (latitud != null && longitud != null) {
      servicioData['localizacion_coordenada'] = jsonEncode({
        'lat': latitud,
        'lng': longitud,
      });
      logger.i('Servicio con coordenadas: lat=$latitud, lng=$longitud');
    }
    return await crearServicio(servicioData);
  }

  Dio get dio => _dio;

}