import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {

  final VoidCallback onPantallaPrincipal;
  final VoidCallback? onMiPerfil;
  final VoidCallback onSalir;

  const CustomDrawer({
    super.key,
    required this.onPantallaPrincipal,
    this.onMiPerfil,
    required this.onSalir,
  });

  @override
  Widget build (BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color:const Color.fromARGB(255, 213, 223, 228),
            ),  
            child: Image.asset('assets/images/logo_coldman.png'),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: const Text('Pantalla principal'),
            onTap: onPantallaPrincipal,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: const Text('Mi perfil'),
            onTap: onMiPerfil,
          ),
          ListTile(
            leading: Icon(Icons.login),
            title: const Text('Salir'),
            onTap: onSalir,
          ),
        ],
      ),
    );
  }
  
}