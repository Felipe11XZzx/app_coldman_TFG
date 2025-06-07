import 'dart:io';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:app_coldman_sa/providers/cliente_provider.dart';
import 'package:app_coldman_sa/utils/constants.dart';

class ScreenRegistroCliente extends StatefulWidget {
  @override
  _ScreenRegistroClienteEstado createState() => _ScreenRegistroClienteEstado();
}

class _ScreenRegistroClienteEstado extends State<ScreenRegistroCliente> {
  Logger logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _addressLocationController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _typePlaceController = TextEditingController();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();

  String? imagePath;
  Uint8List? imageBytes;
  bool _hasSelectedImage = false;

  int _selectedAge = 25;
  String _selectedTitle = 'Sr.';
  bool _acceptTerms = false;

// METODO PARA REGISTRAR CLIENTE
  Future<void> _registerCustomer(
      ImageUploadProvider imageUploadProvider) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos correctamente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String? finalImagePath;

      // SUBIR IMAGEN SI HAY UNA SELECCIONADA.
      if (_hasSelectedImage && imageBytes != null) {
        logger.i('Subiendo imagen de cliente');

        String fileName =
            'cliente_${DateTime.now().millisecondsSinceEpoch}.jpg';

        String? uploadedFileName =
            await imageUploadProvider.uploadClienteImage(imageBytes!, fileName);

        if (uploadedFileName != null) {
          finalImagePath = uploadedFileName;
          logger.i('Imagen subida: $uploadedFileName');
        } else {
          bool? continueAnyway = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error al subir imagen'),
              content: Text('¿Deseas continuar el registro sin la imagen?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Continuar sin imagen'),
                ),
              ],
            ),
          );

          if (continueAnyway != true) return;
        }
      }

      // CREAR CLIENTE.
      final nuevoCliente = Cliente(
        nombre: _nombreController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        trato: _selectedTitle,
        edad: _selectedAge,
        contrasena: _passwordController.text,
        contrasena2: _confirmPasswordController.text,
        imagenUsuario: finalImagePath ?? '',
        fechaAlta: DateTime.now(),
        direccionDomicilio: _addressLocationController.text.trim(),
        tipoLugar: _typePlaceController.text.trim(),
      );

      logger.i('Guardando cliente en base de datos');
      final clienteProvider =
          Provider.of<ClienteProvider>(context, listen: false);
      await clienteProvider.addCliente(nuevoCliente);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cliente registrado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      logger.e('Error en registro de cliente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar cliente: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// METODO PARA OBTENER ImageProvider (SIN CAMBIOS)
  ImageProvider? _getImageProvider() {
    if (kIsWeb && imageBytes != null) {
      return MemoryImage(imageBytes!);
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('assets/')) {
        return AssetImage(imagePath!);
      } else if (!kIsWeb) {
        return FileImage(File(imagePath!));
      }
    }

    return null;
  }

// METODO PARA SELECCIONAR IMAGEN.
  Future<void> _selectImage() async {
    try {
      final result = await Images.selectImage();
      if (result != null) {
        setState(() {
          imagePath = result['path'];
          imageBytes = result['bytes'];
          _hasSelectedImage = true;
        });
        logger.i('Imagen seleccionada: ${result['path']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al seleccionar imagen: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageUploadProvider>(
      builder: (context, imageUploadProvider, child) {
        return AlertDialog(
          title: Text('Registro de Cliente'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.8,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGEN CLIENTE.
                    _buildCompactImageSection(imageUploadProvider),

                    // TRATAMIENTO CLIENTE.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'Sr.',
                          groupValue: _selectedTitle,
                          onChanged: (value) =>
                              setState(() => _selectedTitle = value!),
                        ),
                        Text('Sr.'),
                        Radio<String>(
                          value: 'Sra.',
                          groupValue: _selectedTitle,
                          onChanged: (value) =>
                              setState(() => _selectedTitle = value!),
                        ),
                        Text('Sra.'),
                      ],
                    ),

                    SizedBox(height: 15),

                    // NOMBRE CLIENTE.
                    TextFormField(
                      controller: _nombreController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: 'Nombre *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su nombre' : null,
                    ),

                    SizedBox(height: 15),

                    // APELLIDOS CLIENTE.
                    TextFormField(
                      controller: _apellidosController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Apellidos *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese sus apellidos' : null,
                    ),

                    SizedBox(height: 15),

                    // EMAIL CLIENTE.
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Ingrese su email';
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
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      maxLength: 12,
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su teléfono' : null,
                    ),

                    SizedBox(height: 15),

                    // DIRECCION CLIENTE.
                    TextFormField(
                      controller: _addressLocationController,
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

                    // TELEFONO CLIENTE.
                    TextFormField(
                      controller: _typePlaceController,
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

                    SizedBox(height: 15),

                    // CONTRAEÑA CLIENTE.
                    TextFormField(
                      controller: _passwordController,
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

                    // REPETIR CONTRASEÑA CLIENTE.
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: 'Repetir Contraseña *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),

                    SizedBox(height: 20),

                    // EDAD CLIENTE.
                    Text('Edad *',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Center(
                      child: NumberPicker(
                        value: _selectedAge,
                        minValue: 18,
                        maxValue: 65,
                        onChanged: (value) =>
                            setState(() => _selectedAge = value),
                        textStyle: TextStyle(fontSize: 14),
                        selectedTextStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: 15),

                    // TERMINOS Y CONDICIONES.
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) =>
                              setState(() => _acceptTerms = value!),
                        ),
                        Expanded(
                            child: Text('Acepto los términos y condiciones *')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: imageUploadProvider.isUploading
                  ? null
                  : () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: (imageUploadProvider.isUploading || !_acceptTerms)
                  ? null
                  : () => _registerCustomer(imageUploadProvider),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: imageUploadProvider.isUploading
                    ? Colors.grey
                    : Colors.blueAccent,
              ),
              child: imageUploadProvider.isUploading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Registrando...'),
                      ],
                    )
                  : Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  // WIDGET DE IMAGEN COMPACTA PARA DIALOG
  Widget _buildCompactImageSection(ImageUploadProvider imageUploadProvider) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: imageUploadProvider.isUploading ? null : _selectImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: _getImageProvider(),
                      backgroundColor: Colors.grey[300],
                      child: (_getImageProvider() == null)
                          ? Icon(Icons.camera_alt,
                              size: 24, color: Colors.grey[600])
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
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              _hasSelectedImage ? Icons.edit : Icons.add,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foto de Perfil',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    if (imageUploadProvider.isUploading)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                          SizedBox(width: 6),
                          Text('Procesando...', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    else if (imageUploadProvider.uploadError != null)
                      Text(
                        imageUploadProvider.uploadError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (_hasSelectedImage)
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Imagen seleccionada',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      )
                    else
                      Text(
                        'Toca para agregar foto',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // METODO PARA MOSTRAR LA MODAL DE REGISTRO.
  void _showEmployeeRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScreenRegistroCliente(),
    );
    logger.i('Cliente registrado correctamente.');
  }
}
