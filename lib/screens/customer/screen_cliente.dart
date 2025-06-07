import 'dart:io';
import 'package:app_coldman_sa/screens/login/screen_inicio_sesion.dart';
import 'package:app_coldman_sa/screens/user/screen_pago_servicio.dart';
import 'package:app_coldman_sa/screens/user/screen_servicios.dart';
import 'package:app_coldman_sa/screens/user/screen_usuario.dart';
import 'package:app_coldman_sa/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/screens/user/screen_perfil.dart';
import 'package:app_coldman_sa/widgets/widget_drawer.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';


class ScreenCliente extends StatefulWidget {

  const ScreenCliente({super.key, required this.empleado});
  final Empleado empleado;

  @override
  _ScreenClienteEstado createState() =>  _ScreenClienteEstado();

}

class _ScreenClienteEstado extends State<ScreenCliente> {

  late final List<Widget> pages;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      ScreenPagoServicio(empleado: widget.empleado),
      ScreenServiciosCliente(empleado: widget.empleado),
      ScreenUsuarioActual(empleado: widget.empleado, onTabChange: onItemTapped)
    ];
  }

  void pantallaPrincipal() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const ScreenInicioSesion(title: 'Pantalla Principal')),
    );
  }

  void miPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScreenPerfil(usuarioActual: widget.empleado)),
    );
  }

  void salir() {
    exit(0);
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Bienvenido ${widget.empleado.nombre}"),
      ),
      drawer: CustomDrawer(
        onPantallaPrincipal: pantallaPrincipal,
        onMiPerfil: miPerfil,
        onSalir: salir,
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationCustom(
          currentIndex: selectedIndex, onTap: onItemTapped),
    );
  }
  
}
