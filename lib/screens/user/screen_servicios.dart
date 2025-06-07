import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/repositories/servicio_repository.dart';
import 'package:app_coldman_sa/widgets/widget_services_list.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';


class ScreenServiciosCliente extends StatefulWidget {

  const ScreenServiciosCliente({
    super.key,
    required this.empleado,
  });

  final Empleado empleado;

  @override
  _ScreenServiciosClienteEstado createState () => _ScreenServiciosClienteEstado();
  
}

class _ScreenServiciosClienteEstado extends State<ScreenServiciosCliente> {
  late Future<List<Servicio>> futureServicio;

  @override
  void initState() {
    super.initState();
        futureServicio = ServicioRepository().getServiciosPorCliente(widget.empleado.id!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Servicio>>(
      future: futureServicio,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error al cargar los pedidos",
              style: TextStyle(
                fontSize: 18,
                color: Colors.red
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No has realizado ningún pedido",
              style: TextStyle(
                fontSize: 18,
                color: Colors.orange
              ),
            ),
          );
        }

        List<Servicio> servicios = snapshot.data!;

        return ListView.builder(
          itemCount: servicios.length,
          itemBuilder: (context, index) {
            Servicio servicio = servicios[index];
            return ServicioListItem(
              servicio: servicio
            );
          },
        );
      },
    );
  }
  
}
