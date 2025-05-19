import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.

/*
import 'package:frontend_flutter/data/models/product.dart';
import 'package:frontend_flutter/utils/producto.dart';
import 'package:frontend_flutter/utils/validations.dart';
import 'package:frontend_flutter/utils/dialogs.dart';
import 'package:frontend_flutter/utils/images.dart';
import 'package:frontend_flutter/utils/constants.dart';
import 'package:frontend_flutter/providers/productoprovider.dart';
*/

// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
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
    String? PathImage;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Producto"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nombre Servicio"),
                    validator: Validations.validateRequired,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Descripción Servicio"),
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Precio Servicio"),
                    keyboardType: TextInputType.number,
                    validator: Validations.validatePrice,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          PathImage ?? "No se ha seleccionado imagen",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          String? newPath = await Images.selectImage();
                          if (newPath != null) {
                            setDialogState(() => PathImage = newPath);
                          }
                        },
                        icon: const Icon(Icons.image),
                      ),
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
                    CustomDialogs.showSnackBar(
                      context, "Por favor, complete todos los campos correctamente",
                      color: Constants.errorColor
                    );
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);
                  Servicio newService = Servicio(
                    id: 0,
                    nombre: nameController.text,
                    descripcion: descriptionController.text,
                    imagenServicio: PathImage ?? Images.getDefaultImage(false),
                    precio: double.parse(priceController.text), 
                    estado: '', 
                    informe: [], 
                    empleado: Empleado.empty(), 
                  );

                  final ServicioProvider servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
                  servicioProvider.addService(newService);

                  Navigator.pop(dialogContext);
                  setState(() {});
                  CustomDialogs.showSnackBar(
                    context, "Producto creado correctamente",
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

  void _editService(Servicio servicio) {
    TextEditingController nombreController = TextEditingController(text: servicio.nombre);
    TextEditingController descripcionController = TextEditingController(text: servicio.descripcion);
    TextEditingController precioController = TextEditingController(text: servicio.precio.toString());
    String? imagenPath = servicio.imagenServicio;

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
                  TextFormField(
                    controller: precioController,
                    decoration: const InputDecoration(labelText: "Precio"),
                    keyboardType: TextInputType.number,
                    validator: Validations.validatePrice,
                  ),
                  const SizedBox(height: 16),
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
                            setDialogState(() => imagenPath = newPath);
                          }
                        },
                        icon: const Icon(Icons.image),
                      ),
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
                  if (Validations.validateRequired(nombreController.text) != null ||
                      Validations.validatePrice(precioController.text) != null) {
                    CustomDialogs.showSnackBar(
                      context, "Por favor, complete todos los campos correctamente",
                      color: Constants.errorColor
                    );
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);

                  Servicio servicioEditado = servicio.copyWith(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    imagenServicio: imagenPath ?? Images.getDefaultImage(false),
                    precio: double.parse(precioController.text.replaceAll(',', '.')),
                  );

                  final servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
                  servicioProvider.updateService(servicio.id.toString(), servicioEditado);

                  Navigator.pop(dialogContext);
                  setState(() {});
                  CustomDialogs.showSnackBar(
                    context, "Servicio actualizado correctamente",
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
  Widget build(BuildContext context) {

    final servicioProvider = Provider.of<ServicioProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Productos"),
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
                    content: "¿Está seguro de eliminar ${servicioProvider.servicios[index].nombre}?",
                    style: Text('')
                  );

                  if (confirmar == true) {
                    await CustomDialogs.showLoadingSpinner(context);
                    servicioProvider.deleteService(servicioProvider.servicios[index].id.toString());
                    CustomDialogs.showSnackBar(
                      context, "Servicio eliminado correctamente",
                      color: Constants.successColor
                    );
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
