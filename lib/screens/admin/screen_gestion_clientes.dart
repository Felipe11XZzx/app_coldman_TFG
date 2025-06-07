import 'dart:convert';
import 'dart:io';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/providers/cliente_provider.dart';
import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:app_coldman_sa/web_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/providers/informe_provider.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class ScreenGestionClientes extends StatefulWidget {
  
  const ScreenGestionClientes({super.key, required this.currentAdmin});
  final Empleado currentAdmin;

  @override
  _ScreenEstadoGestionClientes createState() => _ScreenEstadoGestionClientes();
}

class _ScreenEstadoGestionClientes extends State<ScreenGestionClientes> {
  final Logger logger = Logger();
  void _createUser() {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final apellidosController = TextEditingController();
    final emailController = TextEditingController();
    final telefonoController = TextEditingController();
    final userController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // VARIABLES DE ESTADO.
    String selectedTitle = 'Sr.';
    String selectedCountry = 'España';
    String selectedCity = 'Madrid';
    String selectedDate = '';
    int selectedAge = 25;
    bool isAdmin = false;
    bool acceptTerms = false;
    String? imagePath;
  }

  void _editCliente(Cliente cliente) {
    // CONTROLLERS INICIALIZADOS CON DATOS EXISTENTES DEL EMPLEADO QUE SE SELECCIONE AL ACTUALIZAR.
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: cliente.nombre);
    final apellidosController = TextEditingController(text: cliente.apellidos);
    final emailController = TextEditingController(text: cliente.email);
    final telefonoController = TextEditingController(text: cliente.telefono);
    final passwordController = TextEditingController(text: cliente.contrasena);
    final confirmPasswordController = TextEditingController(text: cliente.contrasena);
    final addressLocationController = TextEditingController(text: cliente.direccionDomicilio ?? '');
    final typePlaceController = TextEditingController(text: cliente.tipoLugar ?? '');

    // VARIABLES DE ESTADO INICIALIZADOS CON DATOS EXISTENTES DEL EMPLEADO QUE SE SELECCIONE AL ACTUALIZAR.
    String selectedTitle = cliente.trato;
    int selectedAge = cliente.edad;
    String? imagePath = cliente.imagenUsuario;
    Uint8List? imageBytes;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Consumer<ImageUploadProvider>(
              builder: (context, imageUploadProvider, child) {
            return AlertDialog(
              title: Text("Editar Cliente - ${cliente.nombre}"),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TRATAMIENTO CLIENTE.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<String>(
                              value: 'Sr.',
                              groupValue: selectedTitle,
                              onChanged: (value) =>
                                  setDialogState(() => selectedTitle = value!),
                            ),
                            Text('Sr.'),
                            Radio<String>(
                              value: 'Sra.',
                              groupValue: selectedTitle,
                              onChanged: (value) =>
                                  setDialogState(() => selectedTitle = value!),
                            ),
                            Text('Sra.'),
                          ],
                        ),

                        SizedBox(height: 15),

                        if (imageUploadProvider.isUploading)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                SizedBox(width: 10),
                                Text('Subiendo imagen...'),
                              ],
                            ),
                          ),

                        if (imageUploadProvider.uploadError != null)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              imageUploadProvider.uploadError!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                        // FOTO DE PERFIL DEL CLIENTE.
                        Center(
                          child: GestureDetector(
                            onTap: imageUploadProvider.isUploading
                                ? null
                                : () {
                                    _showImageOptionsForEdit(setDialogState,
                                        (newImagePath, newImageBytes) {
                                      setDialogState(() {
                                        imagePath = newImagePath;
                                        imageBytes = newImageBytes;
                                      });
                                    });
                                  },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      Images.getImageProviderUnified(
                                          imagePath, imageBytes,
                                          category: 'clientes'),
                                  backgroundColor: Colors.grey[300],
                                  child:
                                      (imagePath == null && imageBytes == null)
                                          ? Icon(Icons.camera_alt,
                                              size: 40, color: Colors.grey[600])
                                          : null,
                                ),
                                if (imageUploadProvider.isUploading)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (!imageUploadProvider.isUploading)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: Icon(Icons.edit,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // NOMBRE DEL CLIENTE.
                        TextFormField(
                          controller: nombreController,
                          maxLength: 30,
                          decoration: InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese el nombre' : null,
                        ),

                        SizedBox(height: 15),

                        // APELLIDOS DEL CLIENTE.
                        TextFormField(
                          controller: apellidosController,
                          maxLength: 30,
                          decoration: InputDecoration(
                            labelText: 'Apellidos *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese los apellidos' : null,
                        ),

                        SizedBox(height: 15),

                        // EMAIL CLIENTE.
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Ingrese el email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 15),

                        // TELEFONO CLIENTE.
                        TextFormField(
                          controller: telefonoController,
                          keyboardType: TextInputType.phone,
                          maxLength: 12,
                          decoration: InputDecoration(
                            labelText: 'Teléfono *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese el teléfono' : null,
                        ),

                        SizedBox(height: 15),

                        // CONTRASEÑA LOGIN.
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          maxLength: 15,
                          decoration: InputDecoration(
                            labelText: 'Contraseña *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),

                        SizedBox(height: 15),

                        // REPETIR CONTRASEÑA LOGIN.
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          maxLength: 15,
                          decoration: InputDecoration(
                            labelText: 'Repetir Contraseña *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value != passwordController.text
                              ? 'Las contraseñas no coinciden'
                              : null,
                        ),

                        SizedBox(height: 20),

                        // DIRECCION DEL CLIENTE.
                        TextFormField(
                          controller: addressLocationController,
                          keyboardType: TextInputType.streetAddress,
                          maxLength: 50,
                          decoration: InputDecoration(
                            labelText: 'Dirección Domicilio *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Ingrese su dirección de domicilio'
                              : null,
                        ),

                        SizedBox(height: 15),

                        // TIPO DE LUGAR DEL CLIENTE.
                        TextFormField(
                          controller: typePlaceController,
                          keyboardType: TextInputType.streetAddress,
                          maxLength: 50,
                          decoration: InputDecoration(
                            labelText: 'Tipo Lugar *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Ingrese su tipo de lugar de residencia'
                              : null,
                        ),

                        // EDAD DEL CLIENTE.
                        Text('Edad *',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Center(
                          child: NumberPicker(
                            value: selectedAge,
                            minValue: 18,
                            maxValue: 65,
                            onChanged: (value) =>
                                setDialogState(() => selectedAge = value),
                            textStyle: TextStyle(fontSize: 14),
                            selectedTextStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: imageUploadProvider.isUploading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            CustomDialogs.showSnackBar(context,
                                'Por favor completa todos los campos correctamente',
                                color: Constants.errorColor);
                            return;
                          }

                          await CustomDialogs.showLoadingSpinner(context);

                          try {
                            String? finalImagePath = imagePath;

                            if (imageBytes != null) {
                              logger.i('Subiendo nueva imagen al servidor');

                              String fileName =
                                  'cliente_${cliente.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

                              String? uploadedFileName =
                                  await imageUploadProvider.uploadClienteImage(
                                      imageBytes!, fileName);

                              if (uploadedFileName != null) {
                                finalImagePath = uploadedFileName;
                                logger.i(
                                    'Imagen subida correctamente: $uploadedFileName');
                              } else {
                                Navigator.pop(context);
                                CustomDialogs.showSnackBar(context,
                                    "Error al subir la imagen: ${imageUploadProvider.uploadError ?? 'Error desconocido'}",
                                    color: Constants.errorColor);
                                return;
                              }
                            }

                            // ✅ CREAR CLIENTE EDITADO
                            Cliente clienteEditado = cliente.copyWith(
                              nombre: nombreController.text.trim(),
                              apellidos: apellidosController.text.trim(),
                              email: emailController.text.trim(),
                              telefono: telefonoController.text.trim(),
                              trato: selectedTitle,
                              edad: selectedAge,
                              contrasena: passwordController.text,
                              contrasena2: confirmPasswordController.text,
                              direccionDomicilio:
                                  addressLocationController.text.trim(),
                              tipoLugar: typePlaceController.text.trim(),
                              imagenUsuario: finalImagePath,
                            );

                            logger.i('Actualizando cliente en BD');
                            final clienteProvider =
                                Provider.of<ClienteProvider>(context,
                                    listen: false);
                            await clienteProvider.updateCliente(
                                cliente.id.toString(), clienteEditado);

                            Navigator.pop(dialogContext);
                            setState(() {});

                            CustomDialogs.showSnackBar(
                                context, "Cliente actualizado correctamente",
                                color: Constants.successColor);
                          } catch (e) {
                            logger.e('Error al actualizar cliente: $e');
                            Navigator.pop(context); // Cerrar loading
                            CustomDialogs.showSnackBar(
                                context, "Error al actualizar Cliente: $e",
                                color: Constants.errorColor);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: imageUploadProvider.isUploading
                        ? Colors.grey
                        : Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: imageUploadProvider.isUploading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white)),
                            SizedBox(width: 8),
                            Text("Subiendo imagen"),
                          ],
                        )
                      : const Text("Guardar Cambios"),
                ),
              ],
            );
          });
        },
      ),
    );
  }

  // METODO PARA CREAR EL AVATAR DEL CLIENTE.
  Widget _buildClienteAvatar(Cliente cliente) {
    logger.e('Construyendo avatar para cliente ${cliente.id}');
    logger.e('imagenUsuario: "${cliente.imagenUsuario}"');

    bool hasImage = cliente.imagenUsuario != null &&
        cliente.imagenUsuario.isNotEmpty &&
        cliente.imagenUsuario != '' &&
        cliente.imagenUsuario != 'null';

    if (hasImage) {
      String imageUrl =
          'http://localhost:8080/api_coldman/v1/images/clientes/${cliente.imagenUsuario}';
      logger.e('URL de imagen: $imageUrl');

      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[200],
        onBackgroundImageError: (error, stackTrace) {
          logger.e('Error cargando imagen cliente ${cliente.id}: $error');
          logger.e('URL que falló: $imageUrl');
        },
        child: null,
      );
    } else {
      logger
          .e(' Cliente ${cliente.id} sin imagen, mostrando ícono por defecto');
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          color: Colors.grey[600],
          size: 24,
        ),
      );
    }
  }

  // METODO PARA MOSTRAR LAS OPCIONES DE LAS IMAGENES AL ACTUALIZAR.
  Future<void> _showImageOptionsForEdit(Function setDialogState,
      Function(String?, Uint8List?) onImageSelected) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGalleryForEdit(
                      setDialogState, onImageSelected);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromCameraForEdit(
                        setDialogState, onImageSelected);
                  },
                ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Imagen por defecto'),
                onTap: () {
                  Navigator.pop(context);
                  String defaultImage = Images.getDefaulCustomer();
                  onImageSelected(defaultImage, null);
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // METODO PARA MOSTRAR LAS OPCIONES DE IMAGENES.
  Future<void> _showImageOptions(
      Function setDialogState, Function(String?) onImageSelected) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery(setDialogState);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromCamera(setDialogState, onImageSelected);
                  },
                ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Imagen por defecto'),
                onTap: () {
                  Navigator.pop(context);
                  String defaultImage = Images.getDefaulCustomer();
                  onImageSelected(defaultImage);
                  setDialogState(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // METODO PARA SELECCIONAR UNA IMAGEN DE LA GALERIA.
  Future<void> _pickImageFromGallery(Function setDialogState) async {
    try {
      final ImagePicker picker = ImagePicker();
      String? imagePath;
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setDialogState(() {
          imagePath = image.path;
        });
      }
    } catch (e) {
      _showErrorMessage('Error al seleccionar imagen: $e');
    }
  }

  // METODO PARA SELECCIONAR UNA IMAGEN DE LA GALERIA AL ACTUALIZAR.
  Future<void> _pickImageFromGalleryForEdit(Function setDialogState,
      Function(String?, Uint8List?) onImageSelected) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (kIsWeb) {
          // ✅ Para web: usar bytes
          if (file.bytes != null) {
            logger.i(
                'Imagen seleccionada en web: ${file.name}, bytes: ${file.bytes!.length}');
            onImageSelected(file.name, file.bytes);
          } else {
            logger.e('Error: file.bytes es null');
          }
        } else {
          if (file.path != null) {
            logger.e('Imagen seleccionada en móvil: ${file.path}');
            onImageSelected(file.path, null);
          } else {
            logger.e('Error: file.path es null');
          }
        }
      } else {
        logger.e('No se seleccionó ningún archivo');
      }
    } catch (e) {
      logger.e('Error al seleccionar imagen: $e');
      _showErrorMessage('Error al seleccionar imagen: $e');
    }
  }

  // METODO PARA SELECCIONAR UNA IMAGEN DE LA CAMARA.
  Future<void> _pickImageFromCamera(
      Function setDialogState, Function(String?) onImageSelected) async {
    if (kIsWeb) {
      _showErrorMessage('La cámara no está disponible en web');
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        onImageSelected(image.path);
        setDialogState(() {});
      }
    } catch (e) {
      _showErrorMessage('Error al tomar foto: $e');
    }
  }

  // METODO PARA SELECCIONAR UNA IMAGEN DE LA CAMARA AL ACTUALIZAR.
  Future<void> _pickImageFromCameraForEdit(Function setDialogState,
      Function(String?, Uint8List?) onImageSelected) async {
    if (kIsWeb) {
      _showErrorMessage('La cámara no está disponible en web');
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        logger.i('Foto tomada: ${image.path}');
        onImageSelected(image.path, null);
      }
    } catch (e) {
      logger.e('Error al tomar foto: $e');
      _showErrorMessage('Error al tomar foto: $e');
    }
  }

  // METODO PARA SELECCIONAR UNA IMAGEN EN WEB.
  Future<void> _selectImageWeb(Function setDialogState) async {
    try {
      String? imagePath;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setDialogState(() {
          imagePath = result.files.first.name;
        });
      }
    } catch (e) {
      _showErrorMessage('Error al seleccionar imagen: $e');
    }
  }

  // METODO PARA MOSTRAR MENSAJES DE ERROR.
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // METODO DE DEBUG PARA EL PROVIDER DE IMAGENES.
  void _debugImageProvider(String? imagePath, Uint8List? imageBytes) {
    logger.i('=== DEBUG IMAGE PROVIDER ===');
    logger.i('imagePath: $imagePath');
    logger.i('imageBytes length: ${imageBytes?.length}');
    logger.i('kIsWeb: $kIsWeb');

    ImageProvider provider =
        Images.getImageProviderUnified(imagePath, imageBytes);
    logger.i('ImageProvider type: ${provider.runtimeType}');
    logger.i('============================');
  }

  // METODO PARA OBTENER EL IMAGE PROVIDER.
  ImageProvider? _getImageProvider(String? imagePath, Uint8List? imageBytes) {
    if (kIsWeb && imageBytes != null) {
      return MemoryImage(imageBytes);
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      if (kIsWeb) {
        if (imagePath.startsWith('http') ||
            imagePath.startsWith('data:image')) {
          return NetworkImage(imagePath);
        } else {
          return AssetImage('assets/images/$imagePath');
        }
      } else {
        return FileImage(File(imagePath));
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Clientes"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: clienteProvider.clientes.length,
        itemBuilder: (context, index) {
          if (index >= clienteProvider.clientes.length) {
            return const SizedBox.shrink();
          }

          final cliente = clienteProvider.clientes[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: _buildClienteAvatar(cliente),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${cliente.nombre} ${cliente.apellidos}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (cliente.trato == 'Sr.' || cliente.trato == 'Sra.')
                    Constants.adminBadge,
                ],
              ),
              subtitle: Text("${cliente.trato} - ${cliente.edad} años"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editCliente(cliente),
                    tooltip: 'Editar cliente',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirm = await CustomDialogs.showConfirmDialog(
                        context: context,
                        title: "Confirmar eliminación",
                        content:
                            "¿Está seguro de eliminar a ${cliente.nombre} ${cliente.apellidos}?",
                        style: const Text(''),
                      );

                      if (confirm == true) {
                        try {
                          await CustomDialogs.showLoadingSpinner(context);
                          await clienteProvider.deleteCliente(cliente.id!);
                          setState(() {});
                          CustomDialogs.showSnackBar(
                            context,
                            "Cliente eliminado correctamente",
                            color: Constants.successColor,
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          CustomDialogs.showSnackBar(
                            context,
                            "Error al eliminar cliente: $e",
                            color: Constants.errorColor,
                          );
                        }
                      }
                    },
                    tooltip: 'Eliminar cliente',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
