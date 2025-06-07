import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';


class Images {

  static const String baseUrl = 'http://localhost:8080';
  static const String imageBaseEndpoint = '/api_coldman/v1/images';
  static Logger logger = Logger();
  static ImageProvider? _imageProviderInstance;
  
  // METODO PARA ASIGNAR EL PROVIDER DE IMAGENES A LAS SCREENS.
  static void setImageProvider(ImageProvider provider) {
    _imageProviderInstance = provider;
  }
  
  // METODO PARA ASIGNAR IMAGENES A LOS CLIENTES EN SUS SCREENS.
  static Future<String?> uploadClienteImage(BuildContext context, Uint8List imageBytes, String fileName) {
    final imageProvider = Provider.of<ImageUploadProvider>(context, listen: false);
    return imageProvider.uploadClienteImage(imageBytes, fileName);
  }
  
  // METODO PARA ASIGNAR IMAGENES A LOS EMPLEADOS EN SUS SCREENS.
  static Future<String?> uploadEmpleadoImage(BuildContext context, Uint8List imageBytes, String fileName) {
    final imageProvider = Provider.of<ImageUploadProvider>(context, listen: false);
    return imageProvider.uploadEmpleadoImage(imageBytes, fileName);
  }
  
  // METODO PARA ASIGNAR IMAGENES A LOS INFORMES EN SUS SCREENS.
  static Future<String?> uploadInformeImage(BuildContext context, Uint8List imageBytes, String fileName) {
    final imageProvider = Provider.of<ImageUploadProvider>(context, listen: false);
    return imageProvider.uploadInformeImage(imageBytes, fileName);
  }
  

  // METODO APRA OBTENER LA URL DE LA IMAGEN DEL CLIENTE.
  static String getClienteImageUrl(String imageName) {
    if (imageName.isEmpty) return '';
    return '$baseUrl$imageBaseEndpoint/clientes/$imageName';
  }
  
  // METODO APRA OBTENER LA URL DE LA IMAGEN DEL EMPLEADO.
  static String getEmpleadoImageUrl(String imageName) {
    if (imageName.isEmpty) return '';
    return '$baseUrl$imageBaseEndpoint/empleados/$imageName';
  }
  
  // METODO APRA OBTENER LA URL DE LA IMAGEN DEL INFORME.
  static String getInformeImageUrl(String imageName) {
    if (imageName.isEmpty) return '';
    return '$baseUrl$imageBaseEndpoint/informes/$imageName';
  }
  
  // METODOS PARA UTILIZAR EL IMAGE PROVIDER.
  static ImageProvider getClienteImageProvider(String imageName) {
    return getImageProvider(imageName, category: 'clientes');
  }
  
  static ImageProvider getEmpleadoImageProvider(String imageName) {
    return getImageProvider(imageName, category: 'empleados');
  }
  
  static ImageProvider getInformeImageProvider(String imageName) {
    return getImageProvider(imageName, category: 'informes');
  }
  
  static ImageProvider getImageProvider(String imagePath, {String category = 'clientes'}) {
    if (imagePath.isEmpty) {
      return const AssetImage('assets/images/profile_default.jpg');
    }
    
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    
    if (imagePath.startsWith('http') || imagePath.startsWith('data:image')) {
      return NetworkImage(imagePath);
    }
    
    if (isServerImage(imagePath)) {
      String fullUrl = '$baseUrl$imageBaseEndpoint/$category/$imagePath';
      return NetworkImage(fullUrl);
    }
    
    if (!kIsWeb && imagePath.startsWith('/')) {
      try {
        return FileImage(File(imagePath));
      } catch (e) {
        return const AssetImage('assets/images/profile_default.jpg');
      }
    }
    
    return const AssetImage('assets/images/profile_default.jpg');
  }
  
  static ImageProvider getImageProviderUnified(String? imagePath, Uint8List? imageBytes, {String category = 'clientes'}) {
    if (kIsWeb && imageBytes != null) {
      return MemoryImage(imageBytes);
    }
    
    if (imagePath != null && imagePath.isNotEmpty) {
      return getImageProvider(imagePath, category: category);
    }
    
    return const AssetImage('assets/images/profile_default.jpg');
  }
  
  static bool isServerImage(String path) {
  return  !path.startsWith('assets/') && 
          !path.startsWith('http') && 
          !path.startsWith('data:image') &&
          !path.startsWith('/') &&
          path.contains('.');
  }

  
  // METODO Y ENDPOINT PARA OBTENER LA IMAGEN CLIENTE POR ID.
  static String getClienteImageUrlById(int clienteId) {
    return '$baseUrl$imageBaseEndpoint/clientes/$clienteId';
  }
  
  // METODO Y ENDPOINT PARA OBTENER LA IMAGEN EMPLEADO POR ID.
  static String getEmpleadoImageUrlById(int empleadoId) {
    return '$baseUrl$imageBaseEndpoint/empleados/$empleadoId';
  }
  
  // METODO Y ENDPOINT PARA OBTENER EL IMAGE PROVIDER LA IMAGEN CLIENTE POR ID.
  static ImageProvider getClienteImageProviderById(int clienteId) {
    return NetworkImage(getClienteImageUrlById(clienteId));
  }
  
  // METODO Y ENDPOINT PARA OBTENER EL IMAGE PROVIDER LA IMAGEN EMPLEADO POR ID.
  static ImageProvider getEmpleadoImageProviderById(int empleadoId) {
    return NetworkImage(getEmpleadoImageUrlById(empleadoId));
  }
  
  // METODO PARA VERIFICAR SI EL CLIENTE TIENE IMAGEN.
  static Future<bool> clienteHasImage(int clienteId) async {
    try {
      final response = await Dio().get('$baseUrl$imageBaseEndpoint/cliente/$clienteId/info');
      return response.data['hasImage'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // METODO PARA OBTENER LAS IMAGENES DE LA GALERIA DE INFORMES.
  static Future<List<Map<String, dynamic>>> getInformeGaleria(int informeId) async {
    try {
      final response = await Dio().get('$baseUrl$imageBaseEndpoint/informe/$informeId/galeria');
      List<dynamic> images = response.data['images'] ?? [];
      return images.cast<Map<String, dynamic>>();
    } catch (e) {
      logger.e('Error al obtener galería: $e');
      return [];
    }
  }
  
  // METODO PARA ACTUALIZAR LAS IMAGENES DE LOS INFORMES.
  static Future<Map<String, dynamic>?> uploadInformeImages(
    int informeId, 
    List<Uint8List> imageBytesList,
    List<String> fileNames
  ) async {
    try {
      FormData formData = FormData();
      
      for (int i = 0; i < imageBytesList.length; i++) {
        formData.files.add(MapEntry(
          'files',
          MultipartFile.fromBytes(
            imageBytesList[i],
            filename: fileNames[i],
            contentType: MediaType('image', 'jpeg'),
          ),
        ));
      }
      
      final response = await Dio().post(
        '$baseUrl$imageBaseEndpoint/upload/informe/$informeId',
        data: formData,
      );
      
      return response.data;
    } catch (e) {
      logger.e('Error al subir imágenes: $e');
      return null;
    }
  }

  // METODO PARA SELECCIONAR LA IMAGEN PRINCIPAL EN EL LOGIN.
  static Future<Map<String, dynamic>?> selectImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowedExtensions: null,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        logger.i('Archivo seleccionado: ${file.name}');
        logger.i('Tamaño: ${file.size} bytes');
        logger.i('Tipo: ${file.extension}');
        
        if (kIsWeb) {
          if (file.bytes != null) {
            logger.i('Web usando bytes');
            return {
              'path': file.name,
              'bytes': file.bytes,
              'size': file.size,
              'extension': file.extension,
            };
          } else {
            logger.e('Web file.bytes es null');
            return null;
          }
        } else {
          if (file.path != null) {
            logger.i('Movil - usando path: ${file.path}');
            File imageFile = File(file.path!);
            Uint8List bytes = await imageFile.readAsBytes();
            
            return {
              'path': file.path,
              'bytes': bytes,
              'size': file.size,
              'extension': file.extension,
            };
          } else {
            logger.e('Movil - file.path es null');
            return null;
          }
        }
      } else {
        logger.e('No se selecciono ningun archivo');
        return null;
      }
    } catch (e) {
      logger.e('Error en selectImage: $e');
      return null;
    }
  }
  
  // METODO CON VARIAS OPCIONES PARA SELECCIONAR LA IMAGEN.
  static Future<Map<String, dynamic>?> selectImageWithOptions(BuildContext context) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await selectImage();
                  Navigator.pop(context, result);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.photo_camera, color: Colors.green),
                  title: Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await _selectImageFromCamera();
                    Navigator.pop(context, result);
                  },
                ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.orange),
                title: Text('Imagen por defecto'),
                onTap: () {
                  Navigator.pop(context, {
                    'path': 'assets/images/profile_default.jpg',
                    'bytes': null,
                    'isDefault': true,
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.close, color: Colors.red),
                title: Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // METODO PARA SELECCIONAR LA IMAGEN DE CAMARA PARA MOVIL.
  static Future<Map<String, dynamic>?> _selectImageFromCamera() async {
    if (kIsWeb) {
      logger.e('❌ Cámara no disponible en web');
      return null;
    }
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        logger.e('📸 Foto tomada: ${image.path}');
        
        File imageFile = File(image.path);
        Uint8List bytes = await imageFile.readAsBytes();
        
        return {
          'path': image.path,
          'bytes': bytes,
          'size': bytes.length,
          'extension': 'jpg',
          'fromCamera': true,
        };
      }
    } catch (e) {
      logger.e('❌ Error al tomar foto: $e');
    }
    
    return null;
  }
  
  // METODO PARA VALIDAR LA IMAGEN Y SU EXTENSION.
  static bool isValidImageFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) return false;
    
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();
    
    return validExtensions.contains(extension);
  }
  
  static int getMaxFileSize() {
    return 5 * 1024 * 1024; // 5MB
  }
  
  // METODO PARA VALIDAR EL TAMAÑO DEL ARCHIVO.
  static bool isValidFileSize(int fileSize) {
    return fileSize <= getMaxFileSize();
  }
  
  // METODO PARA FORMATEAR TAMAÑO DE ARCHIVO.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  // GETTERS DE LA CLASE IMAGENES.
  static String getDefaulCustomer() => 'assets/images/profile_default.jpg';
  static String getDefaultImage(bool administrador) => 'assets/images/profile_default.jpg';
  static String getDefaultImageCustomer(String cliente) => 'assets/images/profile_default.jpg';
}