import 'dart:io';
import 'package:app_coldman_sa/screens/admin/screen_estado_servicio.dart';
import 'package:app_coldman_sa/screens/admin/screen_gestion_clientes.dart';
import 'package:app_coldman_sa/screens/admin/screen_gestion_informes.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/utils/custom_button.dart';
import 'package:app_coldman_sa/screens/admin/screen_gestion_servicios.dart';
import 'package:app_coldman_sa/screens/admin/screen_gestion_empleados.dart';
import 'package:app_coldman_sa/screens/user/screen_perfil.dart';
import 'package:app_coldman_sa/screens/login/screen_inicio_sesion.dart';
import 'package:app_coldman_sa/widgets/widget_drawer.dart';

class ScreenAdministrador extends StatefulWidget {
  final Empleado empleadoAdministrador;
  const ScreenAdministrador({super.key, required this.empleadoAdministrador});

  @override
  _ScreenEstadoAdministrador createState() => _ScreenEstadoAdministrador();
}

class _ScreenEstadoAdministrador extends State<ScreenAdministrador> {
  void _pantallaInicio() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const ScreenInicioSesion(
                title: 'Pantalla Principal',
              )),
      (route) => false,
    );
  }

  void _salir() {
    exit(0);
  }

  void _pantallaPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ScreenPerfil(usuarioActual: widget.empleadoAdministrador)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        title: Text("Bienvenido ${widget.empleadoAdministrador.nombre}",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      drawer: CustomDrawer(
        onMiPerfil: _pantallaPerfil,
        onPantallaPrincipal: _pantallaInicio,
        onSalir: _salir,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 32),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_coldman.png',
                      width: 300,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 140),
                CustomAdminButton(
                  text: 'Gestión Usuarios',
                  myFunction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScreenGestionUsuarios(
                                currentAdmin: widget.empleadoAdministrador,
                              )),
                    );
                  },
                  icon: Icons.group,
                ),
                const SizedBox(height: 20),
                CustomAdminButton(
                  text: 'Gestión Clientes',
                  myFunction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScreenGestionClientes(
                                currentAdmin: widget.empleadoAdministrador,
                              )),
                    );
                  },
                  icon: Icons.people,
                ),
                const SizedBox(height: 20),
                CustomAdminButton(
                  text: 'Gestión Agenda Servicios',
                  myFunction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScreenServicios()),
                    );
                  },
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),
                CustomAdminButton(
                  text: 'Gestión Estado Servicios',
                  myFunction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScreenEstadoServicios()),
                    );
                  },
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),
                CustomAdminButton(
                  text: 'Gestión Informes Servicios',
                  myFunction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScreenInformes()),
                    );
                  },
                  icon: Icons.insert_chart_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
