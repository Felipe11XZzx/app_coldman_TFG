import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/utils/validations.dart';
import 'package:app_coldman_sa/utils/images.dart';


class CustomFormUsers extends StatelessWidget {
  final Empleado? empleadoModified;
  final Function(Empleado) onModifiedUser;
  final bool isModified;

  final TextEditingController employeeController;
  final TextEditingController passwordController;
  final TextEditingController ageController;
  final String selectedTratement;
  final String? imagenPath;
  final bool isAdmin;
  final Function(String?) onTratementChanged;
  final Function(String?) onImageChanged;
  final Function(bool?) onAdminChanged;

  const CustomFormUsers({
    super.key,
    this.empleadoModified,
    required this.onModifiedUser,
    required this.isModified,
    required this.employeeController,
    required this.passwordController,
    required this.ageController,
    required this.selectedTratement,
    required this.imagenPath,
    required this.isAdmin,
    required this.onTratementChanged,
    required this.onImageChanged,
    required this.onAdminChanged, required void Function(dynamic value) onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: selectedTratement,
          items: ["Sr.", "Sra."].map((trato) {
            return DropdownMenuItem(value: trato, child: Text(trato));
          }).toList(),
          onChanged: onTratementChanged,
          decoration: const InputDecoration(labelText: "Trato"),
        ),
        TextFormField(
          controller: employeeController,
          decoration: const InputDecoration(labelText: "Usuario"),
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
            Expanded(
              child: Text(
                imagenPath ?? "No se ha seleccionado imagen",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () async {
                String? newPath = await Images.selectImage();
                if (newPath != null) {
                  onImageChanged(newPath);
                }
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
  }
}
