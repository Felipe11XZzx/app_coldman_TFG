import 'package:flutter/material.dart';
// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.

/*
import 'package:frontend_flutter/data/models/user.dart';
import 'package:frontend_flutter/data/repositories/usuariorepository.dart';
*/

// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/repositories/empleado_repository.dart';

class EmpleadoProvider with ChangeNotifier {
  final EmpleadoRepository empleadosRepository = EmpleadoRepository();
  List<Empleado> empleados = [];
  List<Empleado> get empleado => empleados;

  Future <void> fetchEmpleados() async {
    empleados = await empleadosRepository.getListaEmpleados();
    notifyListeners();
  }

  Future<List<Empleado>> fetchListaUsuarios() async {
    return await empleadosRepository.getListaEmpleados();
  }

  Future<void> addEmpleado(Empleado empleado) async {
    await empleadosRepository.agregarEmpleado(empleado);
    fetchEmpleados();
  }

  Future<void> updateEmpleado(String id, Empleado empleado) async {
    await empleadosRepository.actualizarEmpleado(id, empleado);
    fetchEmpleados();
  }

  Future<void> deleteEmpleado(int id) async {
    await empleadosRepository.eliminarEmpleado(id);
    fetchEmpleados();
  }
}