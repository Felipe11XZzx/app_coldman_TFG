import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:logger/logger.dart';


class ScreenPerfil extends StatelessWidget {
  final Empleado usuarioActual;
  final logger = Logger();

  ScreenPerfil({super.key, required this.usuarioActual});

  ImageProvider _getImageProvider() {
    try {
      // Verificación más robusta de la imagen
      if (usuarioActual.imagenUsuario == null || usuarioActual.imagenUsuario!.isEmpty) {
        return const AssetImage('assets/images/profile_default.jpg');
      }

      if (kIsWeb) {
        // Validación más estricta para imágenes web
        if (usuarioActual.imagenUsuario!.startsWith('http') ||
            usuarioActual.imagenUsuario!.startsWith('blob:')) {
          return NetworkImage(usuarioActual.imagenUsuario!);
        }
        return const AssetImage('assets/images/profile_default.jpg');
      } else {
        // Verificar existencia del archivo antes de cargarlo
        final imageFile = File(usuarioActual.imagenUsuario!);
        return imageFile.existsSync()
            ? FileImage(imageFile)
            : const AssetImage('assets/images/profile_default.jpg');
      }
    } catch (e) {
      logger.e('Error cargando imagen de perfil: $e');
      return const AssetImage('assets/images/profile_default.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _getImageProvider(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    usuarioActual.nombre.isNotEmpty
                        ? usuarioActual.nombre
                        : 'Sin nombre',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    usuarioActual.trato?.trim().isNotEmpty == true
                        ? usuarioActual.trato!
                        : 'Sr.',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Column(
                      children: [
                        _buildProfileTile(
                            Icons.person,
                            "Nombre",
                            usuarioActual.nombre.isNotEmpty
                                ? usuarioActual.nombre
                                : 'No especificado'),
                        _buildProfileTile(Icons.lock, "Contraseña", "********"),
                        _buildProfileTile(
                            Icons.cake,
                            "Edad",
                            usuarioActual.edad != null
                                ? usuarioActual.edad.toString()
                                : 'No especificada'),
                        _buildProfileTile(
                            Icons.location_on,
                            "Lugar de Nacimiento",
                            usuarioActual.lugarNacimiento?.trim().isNotEmpty ==
                                    true
                                ? usuarioActual.lugarNacimiento!
                                : "No especificado"),
                        _buildProfileTile(
                            usuarioActual.administrador ?? false
                                ? Icons.security
                                : Icons.person_outline,
                            "Rol",
                            usuarioActual.administrador ?? false
                                ? "Administrador"
                                : "Usuario"),
                        _buildProfileTile(
                            usuarioActual.bloqueado ?? false
                                ? Icons.block
                                : Icons.check_circle,
                            "Estado",
                            usuarioActual.bloqueado ?? false
                                ? "Bloqueado"
                                : "Activo",
                            color: usuarioActual.bloqueado ?? false
                                ? Colors.red
                                : Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(fontSize: 16, color: color)),
    );
  }
}
