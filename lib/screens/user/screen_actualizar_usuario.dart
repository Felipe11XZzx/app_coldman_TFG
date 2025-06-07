import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';


class ScreenEditarUsuario extends StatefulWidget {

  final Empleado empleado;
  const ScreenEditarUsuario ({super.key, required this.empleado});
  @override
  State<ScreenEditarUsuario> createState() => _ScreenEditarUsuarioEstado();

}

class _ScreenEditarUsuarioEstado extends State<ScreenEditarUsuario> {
  
  Logger logger = Logger();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  String birthplace = "";
  int _selectedAge = 20;
  String _selectedTitle= 'Sr.';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    birthplace = widget.empleado.lugarNacimiento;
    _selectedAge= widget.empleado.edad;
    _userController= TextEditingController(text:widget.empleado.nombre);
    _passwordController= TextEditingController(text: widget.empleado.contrasena);
    _confirmPasswordController = TextEditingController(text: widget.empleado.contrasena2);
    _selectedTitle = widget.empleado.trato;

    if (widget.empleado.imagenUsuario.isNotEmpty){
      _image = File(widget.empleado.imagenUsuario);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _updateEmployee(Empleado empleado) {
  if (_formKey.currentState!.validate()) {
    Empleado updatedEmployee = Empleado(
      id: empleado.id,
      trato: _selectedTitle,
      nombre: empleado.nombre,
      apellidos: empleado.apellidos,
      email: empleado.email,
      telefono: empleado.telefono,
      fechaAlta: empleado.fechaAlta,
      bajaLaboral: empleado.bajaLaboral,
      administrador: empleado.administrador,
      contrasena: _passwordController.text.isEmpty ? empleado.contrasena : _passwordController.text,
      contrasena2: _confirmPasswordController.text.isEmpty ? empleado.contrasena2 : _confirmPasswordController.text,           
      imagenUsuario: _image?.path ?? empleado.imagenUsuario,
      edad: _selectedAge, 
      fechaNacimiento: empleado.fechaNacimiento,
      lugarNacimiento: birthplace,
      paisNacimiento: empleado.paisNacimiento
    );
    final empleadoProvider = Provider.of<EmpleadoProvider>(context, listen: false);
    empleadoProvider.updateEmpleado(empleado.id.toString(), updatedEmployee);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos actualizados')),
    );

    Navigator.pop(context, updatedEmployee);
  }

}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Actualizar datos'),
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
                        onChanged: (value) => setState(() => _selectedTitle = value!),
                      ),
                      Text('Sr.'),
                      Radio<String>(
                        value: 'Sra.',
                        groupValue: _selectedTitle,
                        onChanged: (value) => setState(() => _selectedTitle = value!),
                      ),
                      Text('Sra.'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _userController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Usuario'),
                validator: (value) => value!.isEmpty ? 'Ingrese un usuario' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Repite Contraseña'),
                validator: (value) => value != _passwordController.text ? 'Las contraseñas no coinciden' : null,
              ),
              SizedBox(height: 10),
              Text('Edad', style: TextStyle(fontSize: 18),),
              NumberPicker(
                value: _selectedAge,
                minValue: 18,
                maxValue: 60,
                onChanged: (value) => setState(() => _selectedAge = value),
                textStyle: TextStyle(fontSize: 10),
                selectedTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar')
        ),
        ElevatedButton(
          onPressed: () => _updateEmployee(widget.empleado),
          style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 15),
              ),
          child: Text('Actulizar')
        ),
      ],
    );
  }
  
}