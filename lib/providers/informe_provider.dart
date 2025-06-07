import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/data/repositories/informe_repository.dart';
import 'package:logger/logger.dart';


class InformeProvider with ChangeNotifier {
  
  final InformeServicioRepository informeRepository = InformeServicioRepository();
  Logger logger = Logger();
  List<InformeServicio> informesServicios = [];
  bool _isLoading = false;
  String? _error;
  List<InformeServicio> get informes => informesServicios;

  // METODO PARA CARGAR Y ACTUALIZAR LA LISTA DE INFORMES.
  Future<void> cargarInformes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      informesServicios = await InformeServicioRepository().getListaInformes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // METODO PARA ACTUALIZAR UN INFORME DE SERVICIO.
  Future<void> actualizarInforme(String id, InformeServicio informe) async {
    try {
      await InformeServicioRepository().actualizarInformeServicio(id, informe);
      await cargarInformes();
    } catch (e) {
      logger.e('Error al actualizar el informe se servicio: $e');
      throw Exception('Error al actualizar el informe se servicio: $e');
    }
  }

  // METODO PARA EL,IMINAR UN INFORME DE SERVICIO.
  Future<void> eliminarInforme(int id) async {
    try {
      await InformeServicioRepository().eliminarInformeServicio(id);
      await cargarInformes();
    } catch (e) {
          logger.e('Error al eliminar el informe se servicio: $e');
        throw Exception('Error al eliminar el informe se servicio: $e');    }
  }

  // METODO PARA CARGAR Y NOTIFICAR MODIFICACIONES EN LOS INFORMES.
  Future<void> fetchInformesServicios() async {
    try {
      informesServicios = await informeRepository.getListaInformes();
      notifyListeners();
    } catch (e) {
      logger.e("Error al obtener los informes dde los servicios: $e");
    }
  }

  // METODO PARA OBTENER LOS INFORMES POR EL ID DEL EMPLEADO.
  Future<List<InformeServicio>> fetchInformePorEmpleado(int empleadoId) async {
      return await informeRepository.getInformesPorEmpleado(empleadoId);
  }

  // METODO PARA AGREGAR UN NUEVO INFORME DE SERVICIO.
  Future<void> addPInformeServicio(InformeServicio informe) async {
    await informeRepository.anadirInformeServicio(informe);
    fetchInformesServicios();
  }

  // METODO PARA ELIMINAR UN INFORME DE SERVICIO.
  Future<void> deleteInformeServicio(int id) async {
    await informeRepository.eliminarInformeServicio(id);
    fetchInformesServicios();
  }

  // METODO PARA ACTUALIZAR UN INFORME DE SERVICIO.
  Future<void> updateInformeServicio(String id, InformeServicio informe) async {
    await informeRepository.actualizarInformeServicio(id, informe);
    fetchInformesServicios();
  }

  // GETTERS DEL PROVIDER DE LOS INFORMES.
  List<InformeServicio> get informe => informesServicios;
  bool get isLoading => _isLoading;
  String? get error => _error;
}