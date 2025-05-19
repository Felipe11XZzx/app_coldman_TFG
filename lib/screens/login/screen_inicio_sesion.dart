import 'package:flutter/material.dart';
import 'package:app_coldman_sa/screens/admin/screen_administrador.dart';
import 'package:app_coldman_sa/screens/customer/screen_cliente.dart';
import 'package:app_coldman_sa/screens/login/screen_registro.dart';
import 'package:app_coldman_sa/utils/custom_button.dart';
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/repositories/empleado_repository.dart';

class ScreenInicioSesion extends StatefulWidget {
  const ScreenInicioSesion({super.key, required this.title});
  final String title;

  @override
  State<ScreenInicioSesion> createState() => _ScreenInicioSesionEstado();
}

class _ScreenInicioSesionEstado extends State<ScreenInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final EmpleadoRepository empleadoRepository = EmpleadoRepository();
  final logger = Logger();
  bool obscureText = true;

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  void openRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ScreenRegistro()));
  }

  Future<void> startSession() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Primero verificar si es el usuario admin
        if (userController.text == "admin" && passController.text == "admin") {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ScreenAdministrador(
                      empleadoAdministrador: Empleado(
                          id: 99,
                          nombre: "admin",
                          apellido: '',
                          telefono: '',
                          email: '',
                          trato: '',
                          contrasena2: '',
                          imagenUsuario: '',
                          bloqueado: false,
                          fechaAlta: DateTime.now(),
                          lugarNacimiento: '',
                          contrasena: "admin",
                          administrador: true,
                          edad: 51,))),
            );
          }
          return;
        }

        // Si no es admin, buscar en la base de datos
        final employees = await empleadoRepository.getListaEmpleados();
        final employee = employees.firstWhere(
          (e) =>
              e.nombre == userController.text &&
              e.contrasena == passController.text,
          orElse: () => throw Exception('Usuario o contraseña incorrectos'),
        );

        if (employee.bloqueado ?? false) {
          if (mounted) {
            CustomSnackBar.showSnackBar(
                context, "Usuario bloqueado. Contacte al administrador",
                color: Constants.errorColor);
          }
          return;
        }

        if (mounted) {
          if (employee.administrador) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ScreenAdministrador(empleadoAdministrador: employee)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ScreenCliente(empleado: employee)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showSnackBar(context, e.toString(),
              color: Constants.errorColor);
        }
        logger.e('Error en inicio de sesión: $e');
      }
    }
  }

  Future<void> olvidasteContrasena() async {
    final nombreUsuarioController = TextEditingController();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recuperar contraseña"),
        content: TextField(
          controller: nombreUsuarioController,
          decoration: const InputDecoration(labelText: "Usuario"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final employees = await empleadoRepository.getListaEmpleados();
                final employee = employees.firstWhere(
                  (u) => u.nombre == nombreUsuarioController.text,
                  orElse: () => throw Exception('Usuario no encontrado'),
                );

                Navigator.pop(context);
                if (mounted) {
                  CustomSnackBar.showSnackBar(
                      context, "La contraseña es: ${employee.contrasena}",
                      color: Constants.successColor);
                }
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  CustomSnackBar.showSnackBar(context, e.toString(),
                      color: Constants.errorColor);
                }
                logger.e('Error en recuperación de contraseña: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              textStyle: const TextStyle(fontSize: 15),
            ),
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Image.asset(
                  'assets/images/logo_coldman.png',
                  width: 450,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 40,
                  width: 300,
                  child: TextFormField(
                    controller: userController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                      errorStyle: TextStyle(fontSize: 10),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese su usuario' : null,
                    onTap: () {
                      setState(() {
                        _formKey.currentState!.reset();
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 40,
                  width: 300,
                  child: TextFormField(
                    controller: passController,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      errorStyle: const TextStyle(fontSize: 10),
                      suffixIcon: IconButton(
                        icon: Icon(obscureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => obscureText = !obscureText),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese su contraseña' : null,
                    onTap: () {
                      setState(() {
                        _formKey.currentState!.reset();
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: CustomButton(text: 'Iniciar', myFunction: startSession),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child:
                    CustomButton(text: 'Registro', myFunction: openRegister),
              ),
              TextButton(
                  onPressed: olvidasteContrasena,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 33, 150, 243),
                  ),
                  child: const Text("¿Olvidaste tu contraseña?")),
            ],
          ),
        ),
      ),
    );
  }
}
