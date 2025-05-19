import 'package:flutter/material.dart';


// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.
/*
import 'package:frontend_flutter/data/models/user.dart';
import 'package:frontend_flutter/utils/images.dart';
import 'package:frontend_flutter/utils/validations.dart';
import 'package:frontend_flutter/utils/constants.dart';
import 'package:frontend_flutter/providers/usuarioprovider.dart';
import 'package:frontend_flutter/widgets/formusuario.dart';
import 'package:frontend_flutter/utils/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
*/

// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.
// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/validations.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/widgets/widget_form.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';

import 'package:provider/provider.dart';


class ScreenGestionUsuarios extends StatefulWidget {
  const ScreenGestionUsuarios({super.key, required this.currentAdmin});

  final Empleado currentAdmin;

  @override
  _ScreenEstadoGestionUsuarios createState() => _ScreenEstadoGestionUsuarios();
}

class _ScreenEstadoGestionUsuarios extends State<ScreenGestionUsuarios> {
  void _createUser() {
    TextEditingController userController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    String selectedTitle = "Sr.";
    String? imagePath;
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Usuario"),
            content: SingleChildScrollView(
              child: CustomFormUsers(
                isModified: false,
                employeeController: userController,
                passwordController: passwordController,
                ageController: ageController,
                selectedTratement: selectedTitle,
                imagenPath: imagePath,
                isAdmin: isAdmin,
                onTitleChanged: (value) => setDialogState(() => selectedTitle = value!),
                onImageChanged: (value) => setDialogState(() => imagePath = value),
                onAdminChanged: (value) => setDialogState(() => isAdmin = value!),
                onModifiedUser: (user) {}, 
                onTratementChanged: (value) => setDialogState(() => selectedTitle = value!),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? userError =
                      Validations.validateRequired(userController.text);
                  String? passwordError =
                      Validations.validatePassword(passwordController.text);
                  String? ageError =
                      Validations.validateAge(ageController.text);

                  if (userError != null) {
                    CustomDialogs.showSnackBar(context, userError,
                        color: Constants.errorColor);
                    return;
                  }
                  if (passwordError != null) {
                    CustomDialogs.showSnackBar(context, passwordError,
                        color: Constants.errorColor);
                    return;
                  }
                  if (ageError != null) {
                    CustomDialogs.showSnackBar(context, ageError,
                        color: Constants.errorColor);
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);

                  Empleado newEmployee = Empleado(
                    id: 0,
                    trato: selectedTitle,
                    nombre: userController.text,
                    apellido: '', 
                    email: '', 
                    telefono: '', 
                    bloqueado: false, 
                    fechaAlta: DateTime.now(),
                    contrasena: passwordController.text,
                    contrasena2: passwordController.text,
                    imagenUsuario: imagePath ?? Images.getDefaultImage(isAdmin),
                    edad: int.parse(ageController.text),
                    lugarNacimiento: "Zaragoza",
                    administrador: isAdmin, 
                  );
                  final empleadoProvider = Provider.of<EmpleadoProvider>(context, listen: false);
                  empleadoProvider.addEmpleado(newEmployee);
                  Navigator.pop(dialogContext);
                  setState(() {});
                  CustomDialogs.showSnackBar(
                    context, "Usuario creado correctamente",
                    color: Constants.successColor
                  );
                },
                style: ElevatedButton.styleFrom
                (backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                ),
                child: const Text("Crear"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editEmployee(Empleado empleado) {

    TextEditingController userController = TextEditingController(text: empleado.nombre);
    TextEditingController passwordController = TextEditingController(text: empleado.contrasena);
    TextEditingController ageController = TextEditingController(text: empleado.edad.toString());
    String selectedTitle = empleado.trato; 
    String? imagePath = empleado.imagenUsuario;
    bool isAdmin = empleado.administrador;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Editar Usuario"),
            content: SingleChildScrollView(
              child: CustomFormUsers(
                isModified: true,
                employeeController: userController,
                passwordController: passwordController,
                ageController: ageController,
                selectedTratement: selectedTitle,
                imagenPath: imagePath,
                isAdmin: isAdmin,
                onTitleChanged: (value) => setDialogState(() => selectedTitle = value!),
                onImageChanged: (value) => setDialogState(() => imagePath = value),
                onAdminChanged: (value) => setDialogState(() => isAdmin = value!),
                onTratementChanged: (value) => setDialogState(() => selectedTitle = value!),
                onModifiedUser: (user) {},
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? passwordError = Validations.validatePassword(passwordController.text);
                  String? ageError = Validations.validateAge(ageController.text);

                  if (passwordError != null) {
                    CustomDialogs.showSnackBar(
                      context, passwordError,
                      color: Constants.errorColor);
                    return;
                  }
                  if (ageError != null) {
                    CustomDialogs.showSnackBar(
                      context, ageError,
                      color: Constants.errorColor);
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);
                  
                  Empleado empleadoEditado = empleado.copyWith(
                    trato: selectedTitle,
                    contrasena: passwordController.text,
                    contrasena2: passwordController.text,
                    edad: int.parse(ageController.text),
                    imagenUsuario: imagePath ?? '',
                    administrador: isAdmin,
                  );

                  final empleadoProvider = Provider.of<EmpleadoProvider>(context, listen: false);
                  empleadoProvider.updateEmpleado(empleado.id.toString(), empleadoEditado);

                  Navigator.pop(dialogContext);
                  setState(() {});
                  CustomDialogs.showSnackBar(
                    context, "Usuario actualizado correctamente",
                    color: Constants.successColor
                  );
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context)  {
    
    final empleadoProvider = Provider.of<EmpleadoProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: empleadoProvider.empleados.length,
      itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: Images.getImageProvider(empleadoProvider.empleados[index].getImagenUsuario()),
                backgroundColor: Colors.grey[200],
              ),
              title: Row(
                children: [
                  Text(empleadoProvider.empleados[index].nombre),
                  if (empleadoProvider.empleados[index].administrador) const SizedBox(width: 4),
                  if (empleadoProvider.empleados[index].administrador) Constants.adminBadge,
                ],
              ),
              subtitle: Text(
                "${empleadoProvider.empleados[index].trato}-${empleadoProvider.empleados[index].edad} años - ${empleadoProvider.empleados[index].lugarNacimiento}"
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editEmployee(empleadoProvider.empleados[index]),
                  ),
                  IconButton(
                    icon: Icon(
                      empleadoProvider.empleados[index].bloqueado! ? Icons.lock : Icons.lock_open,
                      color: empleadoProvider.empleados[index].bloqueado! ? Colors.red : Colors.green,
                    ),
                    onPressed: () async {
                      Empleado empleadoActual = empleadoProvider.empleados[index];
                      Empleado empleadoActualizado = empleadoActual.copyWith(bloqueado: !empleadoActual.bloqueado!);
                      await empleadoProvider.updateEmpleado(empleadoActual.id.toString(), empleadoActualizado);
                      CustomDialogs.showSnackBar(
                          context,
                          empleadoProvider.empleados[index].bloqueado!
                              ? "Usuario desbloqueado"
                              : "Usuario bloqueado",
                          color: empleadoProvider.empleados[index].bloqueado!
                              ? Constants.successColor
                              : Constants.errorColor);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirm = await CustomDialogs.showConfirmDialog(
                        context: context,
                        title: "Confirmar eliminación",
                        content: "¿Está seguro de eliminar a ${empleadoProvider.empleados[index].nombre}?", 
                        style: Text('')
                      );

                      if (confirm == true) {
                        await CustomDialogs.showLoadingSpinner(context);
                        empleadoProvider.deleteEmpleado(empleadoProvider.empleados[index].id!);
                        setState(() {});
                        CustomDialogs.showSnackBar(
                          context, "Usuario eliminado correctamente",
                          color: Constants.successColor
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
