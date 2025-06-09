import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';


class ScreenInformes extends StatefulWidget {
  
  final Empleado empleado;
  const ScreenInformes({super.key, required this.empleado});

  @override
  _ScreenEstadoInforme createState() => _ScreenEstadoInforme();

}

class _ScreenEstadoInforme extends State<ScreenInformes> {
  late ServicioProvider servicioProvider;
  Map<int, int> cantidades = {};

  @override
  void initState() {
    super.initState();
    servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
    servicioProvider.fetchServices();
  }

  double calcularTotal() {
    double total = 0;
    for (var servicio in servicioProvider.todosMenosEliminados) {
      int cantidad = cantidades[servicio.idServicio] ?? 0;
      if (cantidad > 0) {
        total += cantidad;
      }  
    }
    return total;
  }
  
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}