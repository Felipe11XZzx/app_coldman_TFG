import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';


class ServicioRepository {
  final ApiService _apiService = ApiService();

  Future<List<Servicio>> getServices() async {
    try {
      final response = await _apiService.dio.get('/services/getall');
      return (response.data as List)
          .map((json) => Servicio.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener los Servicios: $e');
    }
  }

  Future<List<Servicio>> getPedidosPorCliente(int id) async {
    try {
      final response = await _apiService.dio.get("/services/customer/$id");
      return (response.data as List)
        .map((json) => Servicio.fromJson(json))
        .toList();
    } catch (e) {
      throw Exception("Error al obtener pedidos del usuario");
    }
  }

  Future<Servicio> createService(Servicio servicio) async {
    try {
      final response = await _apiService.dio.post(
        '/services',
        data: servicio.toJson(),
      );
      return Servicio.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al crear el Servicio: $e');
    }
  }

  Future<Servicio> updateService(String serviceId, Servicio servicio) async {
    try {
      final response = await _apiService.dio.put(
        '/services/$serviceId',
        data: servicio.toJson(),
      );
      return Servicio.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar el Servicio: $e');
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _apiService.dio.delete('/services/$serviceId');
    } catch (e) {
      throw Exception('Error al eliminar el Servicio: $e');
    }
  }

  Future<void> actualizarEstado(int id, String estado) async {
    await _apiService.dio.put("/services/$id", data: {"estado": estado});
  }
}
