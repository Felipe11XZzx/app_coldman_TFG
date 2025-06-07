import 'package:app_coldman_sa/screens/admin/screen_crear_servicio.dart';
import 'package:app_coldman_sa/screens/admin/screen_asignar_servicio.dart';
import 'package:app_coldman_sa/screens/customer/screen_solicitar_cita.dart';
import 'package:app_coldman_sa/screens/login/screen_registro_cliente.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/screens/admin/screen_administrador.dart';
import 'package:app_coldman_sa/screens/customer/screen_cliente.dart';
import 'package:app_coldman_sa/screens/login/screen_registro_empleado.dart';
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/data/repositories/empleado_repository.dart';
import 'package:app_coldman_sa/data/repositories/cliente_repository.dart';


class ScreenInicioSesion extends StatefulWidget {

  const ScreenInicioSesion({super.key, required this.title});
  final String title;
  
  @override
  State<ScreenInicioSesion> createState() => _ScreenInicioSesionEstado();

}

class _ScreenInicioSesionEstado extends State<ScreenInicioSesion> {

  final ClienteRepository clienteRepository = ClienteRepository();
  final TextEditingController emailController = TextEditingController();
  final EmpleadoRepository empleadoRepository = EmpleadoRepository();
  final logger = Logger();
  bool obscureText = true;
  final TextEditingController passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isAdmin = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void openRegister() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScreenRegistro()));
  }

  void openCustomerRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ScreenRegistroCliente()));
  }

  Future<void> startSession() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (emailController.text == "admin" &&
            passController.text == "admin" &&
            _isAdmin) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ScreenAdministrador(
                          empleadoAdministrador: Empleado(
                        id: 99,
                        nombre: "admin",
                        apellidos: '',
                        telefono: '',
                        email: 'admincoldman@gmail.com',
                        trato: '',
                        contrasena2: '',
                        imagenUsuario: '',
                        bajaLaboral: false,
                        fechaNacimiento: DateTime.now(),
                        fechaAlta: DateTime.now(),
                        lugarNacimiento: 'Calí',
                        contrasena: "admin",
                        administrador: true,
                        paisNacimiento: 'Colombia',
                        edad: 51,
                      ))),
            );
          }
          return;
        }

        if (_isAdmin) {
          await _tryEmployeeLogin();
        } else {
          try {
            await _tryEmployeeLogin();
          } catch (employeeError) {
            logger.i('No encontrado como empleado, intentando como cliente...');
            await _tryCustomerLogin();
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

  Future<void> startSessionSimple() async {
    if (_formKey.currentState!.validate()) {
      try {
        String email = emailController.text.trim();
        String password = passController.text.trim();

        if (email == "admin" && password == "admin" && _isAdmin) {
          _navigateToAdminPanel();
          return;
        }

        // BUSCAR EMPLEADOS Y CLIENTES AL MISMO TIEMPO.
        final employeeFuture = empleadoRepository.obtenerTodosLosEmpleados();
        final customerFuture = clienteRepository.getListaCliente();

        final results = await Future.wait([employeeFuture, customerFuture]);
        final employees = results[0] as List<Empleado>;
        final customers = results[1] as List<Cliente>;

        final employee = employees.cast<Empleado?>().firstWhere(
              (e) => e?.email == email && e?.contrasena == password,
              orElse: () => null,
            );

        final customer = customers.cast<Cliente?>().firstWhere(
              (c) => c?.email == email && c?.contrasena == password,
              orElse: () => null,
            );

        if (employee != null) {
          await _handleEmployeeLogin(employee);
        } else if (customer != null && !_isAdmin) {
          await _handleCustomerLogin(customer);
        } else {
          throw Exception('Credenciales incorrectas o tipo de usuario no válido');
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

  Future<void> olvidasteContrasenaEmpleado() async {
    final emailUsuarioController = TextEditingController();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Recuperar contraseña"),
        content: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: emailUsuarioController,
            decoration: const InputDecoration(
              labelText: "Usuario",
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final employees = await empleadoRepository.obtenerTodosLosEmpleados();
                final employee = employees.firstWhere(
                  (u) => u.email == emailUsuarioController.text,
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
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  Future<void> _tryEmployeeLogin() async {
    final employees = await empleadoRepository.obtenerTodosLosEmpleados();

    final employee = employees.firstWhere(
      (e) =>
          e.email == emailController.text &&
          e.contrasena == passController.text,
      orElse: () => throw Exception('Credenciales de empleado incorrectas'),
    );

    if (employee.bajaLaboral ?? false) {
      if (mounted) {
        CustomSnackBar.showSnackBar(context,
            "El usuario actualmente se encuentra de baja y no puede acceder a la app.",
            color: Constants.errorColor);
        emailController.clear();
        passController.clear();
      }
      throw Exception('Usuario de baja laboral');
    }

    if (_isAdmin && !employee.administrador) {
      throw Exception('Usuario no es administrador');
    }

    if (mounted) {
      if (employee.administrador) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ScreenAdministrador(empleadoAdministrador: employee)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ScreenCliente(empleado: employee)),
        );
      }
    }
  }

  // METODO PARA INICIAR SESION COMO CLIENTE.
  Future<void> _tryCustomerLogin() async {
    final customers = await clienteRepository.getListaCliente();

    final customer = customers.firstWhere(
      (c) =>
          c.email == emailController.text &&
          c.contrasena == passController.text,
      orElse: () => throw Exception('Credenciales de cliente incorrectas'),
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ScreenSolicitarCita(clienteLogueado: customer)
            ),
      );
    }
  }

  Future<void> _handleEmployeeLogin(Empleado employee) async {

    if (employee.bajaLaboral ?? false) {
      _showErrorAndClearFields(
          "El usuario actualmente se encuentra de baja y no puede acceder a la app.");
      return;
    }

    if (_isAdmin && !employee.administrador) {
      throw Exception('El usuario no tiene permisos de administrador');
    }

    if (mounted) {
      if (employee.administrador) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ScreenAdministrador(empleadoAdministrador: employee)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ScreenCliente(empleado: employee)),
        );
      }
    }
  }

  Future<void> _handleCustomerLogin(Cliente customer) async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ScreenCrearServicio()),
      );
    }
  }

  void _navigateToAdminPanel() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenAdministrador(
                    empleadoAdministrador: Empleado(
                  id: 99,
                  nombre: "admin",
                  apellidos: '',
                  telefono: '',
                  email: 'admincoldman@gmail.com',
                  trato: '',
                  contrasena2: '',
                  imagenUsuario: '',
                  bajaLaboral: false,
                  fechaNacimiento: DateTime.now(),
                  fechaAlta: DateTime.now(),
                  lugarNacimiento: 'Calí',
                  contrasena: "admin",
                  administrador: true,
                  paisNacimiento: 'Colombia',
                  edad: 51,
                ))),
      );
    }
  }

  void _showErrorAndClearFields(String message) {
    if (mounted) {
      CustomSnackBar.showSnackBar(context, message,
          color: Constants.errorColor);
      emailController.clear();
      passController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF3B82F6),
        elevation: 0,
        title: Text(
          'Inicio de sesión App Coldman S.A',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/logo_coldman.png',
                      width: 300,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 60),

                    // CAMPO EMAIL LOGIN.
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Usuario, correo electrónico o móvil',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Ingrese su Correo electrónico'
                            : null,
                        onTap: () {
                          setState(() {
                            _formKey.currentState!.reset();
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 16),

                    // CAMPO CONTRASEÑA LOGIN.
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: passController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () =>
                                setState(() => obscureText = !obscureText),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
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

                    SizedBox(height: 32),

                    // BOTON INICIO SESION.
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: startSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6), // Azul
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // SWITCH ADMINISTRADOR.
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '¿Estás iniciando sesión como administrador?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _isAdmin,
                              onChanged: (value) {
                                setState(() {
                                  _isAdmin = value;
                                });
                              },
                              activeColor: Color(0xFF22C55E), 
                              activeTrackColor:
                                  Color(0xFF22C55E).withOpacity(0.3),
                              inactiveThumbColor: Colors.grey[400],
                              inactiveTrackColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    TextButton(
                      onPressed: olvidasteContrasenaEmpleado,
                      child: Text(
                        '¿Has olvidado la contraseña?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: openRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF06B6D4), // Cyan
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Crear cuenta nueva',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: openCustomerRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF06B6D4), // Cyan
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Crear cuenta nueva Cliente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
