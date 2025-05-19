import 'dart:io';
import 'package:flutter/material.dart';
// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.
/*
import 'package:inicio_sesion/screens/pantallagestionpedidos.dart';
import 'package:inicio_sesion/screens/pantallagestionproductos.dart';
import 'package:inicio_sesion/screens/pantallagestionusuarios.dart';
import 'package:inicio_sesion/screens/pantallaperfil.dart';
import 'package:inicio_sesion/screens/pantallaprincipal.dart';
import 'package:app_coldman_sa/screens/admin/screen_gestion_clientes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:app_coldman_sa/screens/user/screen_perfil.dart';
import 'package:app_coldman_sa/screens/login/screen_inicio_sesion.dart'; // Pantalla principal de la app.
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:app_coldman_sa/utils/custom_button.dart';
import 'package:app_coldman_sa/widgets/widget_drawer.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:logger/logger.dart';
*/

// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Bienvenido ${widget.empleadoAdministrador.nombre}"),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAdminButton(
                text: 'Gestión de Usuarios',
                myFunction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScreenGestionUsuarios(
                              currentAdmin: widget.empleadoAdministrador,
                            )),
                  );
                },
                icon: Icons.supervised_user_circle,
              ),
              const SizedBox(height: 40),
              CustomAdminButton(
                text: 'Gestión de Productos',
                myFunction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScreenServicios()),
                  );
                },
                icon: Icons.shopping_bag,
              ),
              const SizedBox(height: 40),
              CustomAdminButton(
                text: 'Gestión de Pedidos',
                myFunction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScreenServicios()),
                  );
                },
                icon: Icons.shopping_cart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
