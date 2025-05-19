import 'package:flutter/foundation.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/repositories/servicio_repository.dart';


class ServicioProvider with ChangeNotifier {
  final ServicioRepository servicioRepository = ServicioRepository();
  List<Servicio> servicios = [];
  bool _isLoading = false;

  List<Servicio> get obtenerServicios => servicios;
  bool get isLoading => _isLoading;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      servicios = await servicioRepository.getServices();
    } catch (e) {
      debugPrint('Error al cargar los Servicios: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(Servicio servicio) async {
    try {
      await servicioRepository.createService(servicio);
      await fetchServices();
    } catch (e) {
      debugPrint('Error al agregar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> updateService(String serviceId, Servicio servicio) async {
    try {
      await servicioRepository.updateService(serviceId, servicio);
      await fetchServices();
    } catch (e) {
      debugPrint('Error al actualizar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await servicioRepository.deleteService(serviceId);
      await fetchServices();
    } catch (e) {
      debugPrint('Error al eliminar un Servicio: $e');
      rethrow;
    }
  }

  Future<void> updatePedidoEstado(int id, String estado) async {
    await servicioRepository.actualizarEstado(id, estado);
    fetchServices();
  }
  
}