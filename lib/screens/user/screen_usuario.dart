import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/screens/user/screen_actualizar_usuario.dart';
import 'package:app_coldman_sa/screens/user/screen_contacto.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/utils/custom_button.dart';


class ScreenUsuarioActual extends StatefulWidget {

  final Empleado empleado;
  final Function(int) onTabChange;

  const ScreenUsuarioActual({
    super.key,
    required this.empleado,
    required this.onTabChange,
  });

  @override
  State<ScreenUsuarioActual> createState() => _ScreenUsuarioActualEstado();
  
}

class _ScreenUsuarioActualEstado extends State<ScreenUsuarioActual> {
  late Empleado currentUser;


  @override
  void initState() {
    super.initState();
    currentUser=widget.empleado;
  }

  void openContact (){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> ScreenContactoEmpresa())
    );
  }

  void openUpdate () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> ScreenEditarUsuario(empleado: currentUser))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            CustomButton(
              text: "Contacto",
              myFunction: openContact,
              icon:Icons.contact_page,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "Editar usuario",
              myFunction: () async {
                final updatedEmployee = await Navigator.push<Empleado>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    ScreenEditarUsuario(empleado: currentUser)
                  ),
                );
                if (updatedEmployee != null) {
                  setState(() {
                    currentUser = updatedEmployee;
                  });
                }
              },
              icon:Icons.edit,
            ),
          ],
        ),
      ),
    );
  }
  
}
