import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/utils/validations.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:provider/provider.dart';

const List<String> kTratamientosDisponibles = ['Sr.', 'Sra.'];

class CustomFormUsers extends StatelessWidget {
  const CustomFormUsers({
    super.key,
    required this.empleadoModified,
    required this.onModifiedUser,
    required this.isModified,
    required this.nombreController,
    required this.apellidosController,
    required this.passwordController,
    required this.ageController,
    required this.selectedTratement,
    required this.imagenPath,
    required this.isAdmin,
    required this.onTratementChanged,
    required this.onImageChanged,
    required this.onAdminChanged,
  });

  final TextEditingController ageController;
  final TextEditingController apellidosController;
  final Empleado empleadoModified;
  final String? imagenPath;
  final bool isAdmin;
  final bool isModified;
  final TextEditingController nombreController;
  final Function(bool?) onAdminChanged;
  final Function(String?) onImageChanged;
  final Function(Empleado) onModifiedUser;
  final Function(String?) onTratementChanged;
  final TextEditingController passwordController;
  final String selectedTratement;

  @override
  Widget build(BuildContext context) {
    final String? dropdownValue =
        kTratamientosDisponibles.contains(selectedTratement)
            ? selectedTratement
            : null;

    return Consumer<ImageUploadProvider>(
        builder: (context, imageUploadProvider, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: dropdownValue,
            items: kTratamientosDisponibles.map((trato) {
              return DropdownMenuItem(value: trato, child: Text(trato));
            }).toList(),
            onChanged: onTratementChanged,
            decoration: const InputDecoration(labelText: "Trato"),
            validator: (value) =>
                value == null ? 'Seleccione un trato válido' : null,
          ),
          TextFormField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: "Nombre"),
            enabled: !isModified,
            validator: Validations.validateRequired,
          ),
          TextFormField(
            controller: apellidosController,
            decoration: const InputDecoration(labelText: "Apellidos"),
            enabled: !isModified,
            validator: Validations.validateRequired,
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "Contraseña"),
            obscureText: true,
            validator: Validations.validatePassword,
          ),
          TextFormField(
            controller: ageController,
            decoration: const InputDecoration(labelText: "Edad"),
            keyboardType: TextInputType.number,
            validator: Validations.validateAge,
          ),
          Row(
            children: [
              if (imageUploadProvider.isUploading)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text('Subiendo imagen...'),
                    ],
                  ),
                ),

              if (imageUploadProvider.uploadError != null)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    imageUploadProvider.uploadError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: Text(
                  imagenPath ?? "No se ha seleccionado imagen",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  Images.getEmpleadoImageProvider(
                      empleadoModified.imagenUsuario);
                },
                icon: const Icon(Icons.image),
              ),
            ],
          ),
          CheckboxListTile(
            title: const Text("Es Administrador"),
            value: isAdmin,
            onChanged: onAdminChanged,
          ),
        ],
      );
    });
  }
}
