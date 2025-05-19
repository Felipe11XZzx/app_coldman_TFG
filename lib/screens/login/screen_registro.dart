import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/repositories/empleado_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:logger/logger.dart';

class ScreenRegistro extends StatefulWidget {
  const ScreenRegistro({super.key});

  @override
  State<ScreenRegistro> createState() => _ScreenRegistroEstado();
}

class _ScreenRegistroEstado extends State<ScreenRegistro> {
  final EmpleadoRepository empleadoRepository = EmpleadoRepository();
  final logger = Logger();

  bool _acceptTerms = false;
  final TextEditingController _birthplaceController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  int _selectedAge = 20;
  String _selectedTitle = 'Sr.';
  final TextEditingController _userController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthplaceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
        logger.d("Imagen seleccionada: ${pickedFile.path}");
      }
    } catch (e) {
      logger.e("Error al seleccionar imagen: $e");
      if (mounted) {
        CustomSnackBar.showSnackBar(context, "Error al seleccionar imagen",
            color: Constants.errorColor);
      }
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      try {
        final newEmployee = Empleado(
          nombre: _userController.text,
          apellido: '',
          contrasena: _passwordController.text,
          contrasena2: _confirmPasswordController.text,
          edad: _selectedAge,
          email: '',
          imagenUsuario: _imagePath ?? '',
          bloqueado: false,
          lugarNacimiento: _birthplaceController.text,
          trato: _selectedTitle,
          administrador: false, 
          telefono: '', 
          fechaAlta: DateTime.now(), 
        );

        await empleadoRepository.agregarEmpleado(newEmployee);

        if (mounted) {
          CustomSnackBar.showSnackBar(context, "Usuario registrado exitosamente",
              color: Constants.successColor);
          Navigator.pop(context);
        }
      } catch (e) {
        logger.e("Error al registrar usuario: $e");
        if (mounted) {
          CustomSnackBar.showSnackBar(
              context, "Error al registrar usuario: ${e.toString()}",
              color: Constants.errorColor);
        }
      }
    } else if (_formKey.currentState!.validate() && !_acceptTerms) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Términos y Condiciones'),
                content: const Text('Debes aceptar los términos y condiciones'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver')),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registro de Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'Sr.',
                        groupValue: _selectedTitle,
                        onChanged: (value) =>
                            setState(() => _selectedTitle = value!),
                      ),
                      const Text('Sr.'),
                      Radio<String>(
                        value: 'Sra.',
                        groupValue: _selectedTitle,
                        onChanged: (value) =>
                            setState(() => _selectedTitle = value!),
                      ),
                      const Text('Sra.'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: !kIsWeb && _imagePath != null
                      ? FileImage(File(_imagePath!))
                      : null,
                  child: _imagePath == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese un usuario' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) =>
                    value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Repite Contraseña'),
                validator: (value) => value != _passwordController.text
                    ? 'Las contraseñas no coinciden'
                    : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: 'Madrid',
                decoration:
                    const InputDecoration(labelText: 'Lugar de Nacimiento'),
                onChanged: (value) =>
                    setState(() => _birthplaceController.text = value!),
                items: const [
                  'A Coruña',
                  'Albacete',
                  'Alicante',
                  'Almería',
                  'Ávila',
                  'Badajoz',
                  'Barcelona',
                  'Bilbao',
                  'Burgos',
                  'Cáceres',
                  'Cádiz',
                  'Castellón',
                  'Ciudad Real',
                  'Córdoba',
                  'Cuenca',
                  'Girona',
                  'Granada',
                  'Guadalajara',
                  'Huelva',
                  'Huesca',
                  'Jaén',
                  'La Rioja',
                  'Las Palmas',
                  'León',
                  'Lleida',
                  'Lugo',
                  'Madrid',
                  'Málaga',
                  'Murcia',
                  'Ourense',
                  'Oviedo',
                  'Palencia',
                  'Pamplona',
                  'Pontevedra',
                  'Salamanca',
                  'San Sebastián',
                  'Santander',
                  'Segovia',
                  'Sevilla',
                  'Soria',
                  'Tarragona',
                  'Teruel',
                  'Toledo',
                  'Valencia',
                  'Valladolid',
                  'Vitoria',
                  'Zamora',
                  'Zaragoza'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Text('Edad', style: TextStyle(fontSize: 18)),
              NumberPicker(
                value: _selectedAge,
                minValue: 18,
                maxValue: 60,
                onChanged: (value) => setState(() => _selectedAge = value),
                textStyle: const TextStyle(fontSize: 10),
                selectedTextStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) => setState(() => _acceptTerms = value!),
                  ),
                  const Text('Acepto los términos y condiciones'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
            onPressed: _registerUser,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text('Registrar')),
      ],
    );
  }
}
