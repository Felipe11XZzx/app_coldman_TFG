import 'package:flutter/material.dart';

// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.

/*
import 'package:inicio_sesion/commons/constants.dart';
import 'package:inicio_sesion/commons/dialogs.dart';
import 'package:inicio_sesion/models/order.dart';
import 'package:inicio_sesion/providers/OrderProvider.dart';
import 'package:inicio_sesion/widgets/orderlist.dart';
*/

// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart'; 
import 'package:app_coldman_sa/providers/servicio_provider.dart';
import 'package:app_coldman_sa/widgets/widget_services_list.dart';
import 'package:provider/provider.dart';


class ScreenServicios extends StatefulWidget {
  const ScreenServicios({super.key});

  @override
  _ScreenServiciosEstado createState() => _ScreenServiciosEstado();
}

class _ScreenServiciosEstado extends State<ScreenServicios> {
  Future<void> _confirmAndChangeEstado(Servicio servicio, String? nuevoEstado) async {
    
    if (nuevoEstado == null) return;

    bool? confirmado = await CustomDialogs.showConfirmDialog(
      context: context,
      title: "Confirmar cambio de estado",
      content: "¿Está seguro de cambiar el estado del pedido a '$nuevoEstado'?",
      style: Text('')
    );

    if (confirmado != true) return;

    await CustomDialogs.showLoadingSpinner(context);

    try {
      final servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
      await servicioProvider.updatePedidoEstado(servicio.id, nuevoEstado);

      setState(() {
      servicio.estado = nuevoEstado;
    });

    CustomDialogs.showSnackBar(
        context, "Estado actualizado a '$nuevoEstado'",
        color: Constants.estadoColores[nuevoEstado]
    );

    } catch (e) {
      CustomDialogs.showSnackBar(
        context, "Error al actualizar el pedido",
        color: Constants.errorColor);
    }    
  }

  @override
  Widget build(BuildContext context) {
    final servicioProvider = Provider.of<ServicioProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Pedidos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: servicioProvider.servicios.length,
        itemBuilder: (context, index) {
          return ServicioListItem(
            servicio: servicioProvider.servicios[index],
            onEstadoChanged: (nuevoEstado) {
              if (nuevoEstado != servicioProvider.servicios[index].estado) {
                _confirmAndChangeEstado(servicioProvider.servicios[index], nuevoEstado);
              }
            },
          );
        },
      ),
    );
  }
}