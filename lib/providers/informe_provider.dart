import 'package:flutter/material.dart';

// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.
/*
import 'package:frontend_flutter/data/models/order.dart';
import 'package:frontend_flutter/data/repositories/pedidorepository.dart';
*/

// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/data/repositories/informe_repository.dart';

class InformeProvider with ChangeNotifier {
  final InformeServicioRepository informeRepository = InformeServicioRepository();
  List<InformeServicio> informesServicios = [];

  List<InformeServicio> get informes => informesServicios;

  Future<void> fetchInformesServicios() async {
    try {
      informesServicios = await informeRepository.getListaInformes();
      notifyListeners();
    } catch (e) {
      debugPrint("Error al obtener los informes dde los servicios: $e");
    }
  }

  Future<List<InformeServicio>> fetchInformePorEmpleado(int empleadoId) async {
      return await informeRepository.getPedidosPorEmpleado(empleadoId);
  }

  Future<void> addPInformeServicio(InformeServicio informe) async {
    await informeRepository.anadirInformeServicio(informe);
    fetchInformesServicios();
  }

  Future<void> deleteInformeServicio(int id) async {
    await informeRepository.eliminarInformeServicio(id);
    fetchInformesServicios();
  }

/*
  Future<void> updateInformeServicio(int id, InformeServicio informe) async {
    await informeRepository.actualizarInformeServicio(id, informe);
    fetchInformesServicios();
  }
*/
}