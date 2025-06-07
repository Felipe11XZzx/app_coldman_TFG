import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/utils/custom_service.dart';
import 'package:app_coldman_sa/utils/validations.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';


class ScreenCrearServicio extends StatefulWidget {

  const ScreenCrearServicio({super.key});

  @override
  _ScreenEstadoCrearServicio createState() => _ScreenEstadoCrearServicio();
}

class _ScreenEstadoCrearServicio extends State<ScreenCrearServicio> {
  void _nuevoServicio() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController duracionEstimadaController = TextEditingController();
    String? pathImage;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Servicio"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Nombre Servicio"),
                    validator: Validations.validateRequired,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: "Descripción Servicio"),
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration:
                        const InputDecoration(labelText: "Precio Servicio"),
                    keyboardType: TextInputType.number,
                    validator: Validations.validatePrice,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pathImage ?? "No se ha seleccionado imagen",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      /*EN PRINCIPIO ESTE BOTON NO DEBERIA IR AQUI SI NO EN INFORMES 
                        AL MOMENTO DE QUE EL EMPLEADO CREE UN INFORME.
                      IconButton(
                        onPressed: () async {
                          final result = await Images.();
                          if (result != null) {
                            String? path = result['path'];
                            Uint8List? bytes = result['bytes'];
                          }
                        },
                        icon: const Icon(Icons.image),
                      ),
                      */
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  if (Validations.validateRequired(nameController.text) !=
                          null ||
                      Validations.validatePrice(priceController.text) != null) {
                    CustomDialogs.showSnackBar(context,
                        "Por favor, complete todos los campos correctamente",
                        color: Constants.errorColor);
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);
                  Servicio newService = Servicio(
                    idServicio: 0,
                    nombre: nameController.text,
                    categoriaServicio: CategoriaServicio.instalacion,
                    descripcion: descriptionController.text,
                    fechaCreacion: DateTime.now(),
                    estadoServicio: EstadoServicio.programada,
                    duracionReal: 0,
                    fechaInicioServicio: DateTime.timestamp(),
                    fechaFinServicio: DateTime.timestamp(),

                    //informe: [],
                    //empleado: Empleado.empty(),
                  );

                  final ServicioProvider servicioProvider =
                      Provider.of<ServicioProvider>(context, listen: false);
                  servicioProvider.addService(newService);

                  Navigator.pop(dialogContext);
                  setState(() {});
                  CustomDialogs.showSnackBar(
                      context, "Producto creado correctamente",
                      color: Constants.successColor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
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

  void _editService(Servicio servicio) {
    TextEditingController nombreController =
        TextEditingController(text: servicio.nombre);
    TextEditingController descripcionController =
        TextEditingController(text: servicio.descripcion);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Editar Producto"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                    validator: Validations.validateRequired,
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: "Descripción"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  if (Validations.validateRequired(nombreController.text) !=
                      null) {
                    CustomDialogs.showSnackBar(context,
                        "Por favor, complete todos los campos correctamente",
                        color: Constants.errorColor);
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);

                  Servicio servicioEditado = servicio.copyWith(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                  );

                  final servicioProvider =
                      Provider.of<ServicioProvider>(context, listen: false);
                  servicioProvider.updateService(
                      servicio.idServicio.toString(), servicioEditado);

                  Navigator.pop(dialogContext);
                  setState(() {});
                  CustomDialogs.showSnackBar(
                      context, "Servicio actualizado correctamente",
                      color: Constants.successColor);
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
  Widget build(BuildContext context) {
    final servicioProvider = Provider.of<ServicioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Servicios"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: servicioProvider.servicios.length,
            itemBuilder: (context, index) {
              return CustomService(
                servicio: servicioProvider.servicios[index],
                onEdit: () => _editService(servicioProvider.servicios[index]),
                onDelete: () async {
                  bool? confirmar = await CustomDialogs.showConfirmDialog(
                      context: context,
                      title: "Confirmar eliminación",
                      content:
                          "¿Está seguro de eliminar ${servicioProvider.servicios[index].nombre}?",
                      style: Text(''));

                  if (confirmar == true) {
                    await CustomDialogs.showLoadingSpinner(context);
                    servicioProvider.deleteService(servicioProvider
                        .servicios[index].idServicio
                        .toString());
                    CustomDialogs.showSnackBar(
                        context, "Servicio eliminado correctamente",
                        color: Constants.successColor);
                  }
                },
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              onPressed: _nuevoServicio,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
