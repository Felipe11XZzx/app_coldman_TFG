import 'package:app_coldman_sa/data/models/cita_model.dart';
import 'package:app_coldman_sa/data/repositories/cita_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';


class CitaProvider with ChangeNotifier {

  final CitaRepository citasRepository = CitaRepository();
  Logger logger = Logger();
  List<Cita> citas = [];
  bool _isLoading = false;
  String? _error;

  // GETTERS DEL PROVIDER DE LAS CITAS.
  String? get error => _error;
  bool get isLoading => _isLoading;
  List<Cita> get listaCitas => citas;

  // METODO PAR ACTUALIZAR LAS CITAS.
  Future<void> actualizarCita(String id, Cita cita) async {
    try {
      await citasRepository.actualizarCita(id, cita);
      await cargarCitas();
    } catch (e) {
      logger.e('Error al actualizar la cita: $e');
      throw Exception('Error al actualizar la cita: $e');
    }
  }

  // METODO PARA CARGAR LAS CITAS.
  Future<void> cargarCitas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      citas = await citasRepository.getListaCitas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // METODO PARA ELIINAR LOS INFORMES QUE ESTAN LIGADOS CON LAS CITAS.
  Future<void> eliminarCita(int id) async {
    try {
      await citasRepository.eliminarCita(id);
      await cargarCitas();
    } catch (e) {
      logger.e('Error al actualizar la cita: $e');
      throw Exception('Error al eliminar la cita: $e');
    }
  }

  // METODO PARA OBTENER LAS CITAS Y NOTIFICAR LOS CAMBIOS.
  Future<void> fetchCitas() async {
    try {
      citas = await citasRepository.getListaCitas();
      notifyListeners();
    } catch (e) {
      logger.e("Error al obtener las citas de los servicios: $e");
    }
  }

  Future<List<Cita>> fetchInformePorCliente(int clienteId) async {
    return await citasRepository.getCitasPorCliente(clienteId);
  }
}
