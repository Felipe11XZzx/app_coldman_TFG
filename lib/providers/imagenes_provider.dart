import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';


class ImageUploadProvider extends ChangeNotifier {
  
  Dio? _dio;
  static const String baseUrl = 'http://localhost:8080';
  static const String imageBaseEndpoint = '/api_coldman/v1/images';
  Logger logger = Logger();
  
  // CATEGORIAS DE IMAGENES PARA EL BACKEND.
  static const String clientesCategory = 'clientes';
  static const String empleadosCategory = 'empleados';
  static const String informesCategory = 'informes';
  
  // VARIABLES DE ESTADO.
  bool _isUploading = false;
  String? _uploadError;
  
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;
  
  ImageUploadProvider() {
    _initializeDio();
  }
  
  // METODO PARA INICIALIZAR EL MODELO DEL DIO.
  void _initializeDio() {
    try {
      _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 60),
        sendTimeout: Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
        },
      ));
      
      if (kDebugMode) {
        _dio!.interceptors.add(LogInterceptor(
          requestBody: false, 
          responseBody: true,
          logPrint: (obj) => logger.i('DIO: $obj'),
        ));
      }
      
      logger.e('DIO CREADO correctamente');
    } catch (e) {
      logger.e('Error al CREAR DIO: $e');
    }
  }
  
  Dio get dio {
    if (_dio == null) {
      logger.e('El DIO no se creo correctamente.');
      _initializeDio();
    }
    return _dio!;
  }
  
  // METODO PARA SUBIR LA IMAGEN.
  Future<String?> uploadImage(String category, Uint8List imageBytes, String fileName) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();
    
    try {
      logger.e('Subiendo imagen: $fileName a categoría: $category');
      logger.e('Tamaño: ${imageBytes.length} bytes');
      logger.e('URL destino: $baseUrl$imageBaseEndpoint/upload/$category');
      
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });
            
      Response response = await dio.post(
        '$imageBaseEndpoint/upload/$category',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
          // ✅ AÑADIR timeout específico para uploads
          sendTimeout: Duration(seconds: 60),
          receiveTimeout: Duration(seconds: 60),
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map) {
          String uploadedFileName = response.data['fileName'];
          logger.i('Imagen subida exitosamente: $uploadedFileName');
          return uploadedFileName;
        } else {
          logger.e('Respuesta inesperada del servidor: ${response.data}');
          _uploadError = 'Respuesta inválida del servidor';
          return null;
        }
      } else {
        logger.e('Status code inesperado: ${response.statusCode}');
        _uploadError = 'Error en el servidor: ${response.statusCode}';
        return null;
      }
    } on DioException catch (e) {
      logger.e('DioException detectada:');
      logger.e('Tipo: ${e.type}');
      logger.e('Mensaje: ${e.message}');
      
      if (e.response != null) {
        logger.i('Response status: ${e.response!.statusCode}');
        logger.i('esponse headers: ${e.response!.headers}');
        logger.i('Response data: ${e.response!.data}');
      }
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          _uploadError = 'Tiempo de conexión agotado. Verifica tu red.';
          break;
        case DioExceptionType.sendTimeout:
          _uploadError = 'Tiempo de envío agotado. La imagen es muy grande.';
          break;
        case DioExceptionType.receiveTimeout:
          _uploadError = 'Tiempo de respuesta agotado.';
          break;
        case DioExceptionType.connectionError:
          _uploadError = '¿Está funcionando tu servidor Spring Boot?';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 404) {
            _uploadError = 'Endpoint no encontrado. ¿Implementaste ImageController?';
          } else {
            _uploadError = 'Error del servidor: ${e.response?.statusCode}';
          }
          break;
        default:
          _uploadError = 'Error de red: ${e.message}';
      }
      return null;
    } catch (e) {
      logger.e('Error general inesperado: $e');
      logger.e('Tipo: ${e.runtimeType}');
      _uploadError = 'Error inesperado: $e';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
  
  // METODO PARA SUBIR LA IMAGEN DEL CLIENTE AL BACKEND.
  Future<String?> uploadClienteImage(Uint8List imageBytes, String fileName) {
    return uploadImage(clientesCategory, imageBytes, fileName);
  }
  
  // METODO PARA SUBIR LA IMAGEN DEL EMPLEADO AL BACKEND.
  Future<String?> uploadEmpleadoImage(Uint8List imageBytes, String fileName) {
    return uploadImage(empleadosCategory, imageBytes, fileName);
  }
  
  // METODO PARA SUBIR LA IMAGEN DEL INFORME AL BACKEND.
  Future<String?> uploadInformeImage(Uint8List imageBytes, String fileName) {
    return uploadImage(informesCategory, imageBytes, fileName);
  }
  
  // METODO PARA ELIMINAR LA IMAGEN DEL BACKEND.
  Future<bool> deleteImage(String category, String imageName) async {
    try {
      Response response = await dio.delete('$imageBaseEndpoint/$category/$imageName');
      return response.statusCode == 200;
    } on DioException catch (e) {
      logger.e('❌ Error al eliminar: ${e.message}');
      return false;
    }
  }
  
  // METODO PARA OBTENER LA CATEGORIA Y EL NOMBTES DE LA IMAGEN.
  String getImageUrl(String category, String imageName) {
    if (imageName.isEmpty) return '';
    return '$baseUrl$imageBaseEndpoint/$category/$imageName';
  }
  
  // GETTERS PARA LAS URLS DE LAS IMAGENES.
  String getClienteImageUrl(String imageName) => getImageUrl(clientesCategory, imageName);
  String getEmpleadoImageUrl(String imageName) => getImageUrl(empleadosCategory, imageName);
  String getInformeImageUrl(String imageName) => getImageUrl(informesCategory, imageName);
}
