import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';


class InformeServicioRepository {
  final ApiService _apiService = ApiService();

  Future<List<InformeServicio>> getListaInformes() async {
    try {
      final response = await _apiService.dio.get("/reports_services/getall");
      return (response.data as List)
          .map((json) => InformeServicio.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Error al obtener detalles de los servicios.");
    }
  }

  Future<List<InformeServicio>> getPedidosPorEmpleado(int id) async {
    try {
      final response = await _apiService.dio.get("/reports_services/employee/$id");
      return (response.data as List)
        .map((json) => InformeServicio.fromJson(json))
        .toList();
    } catch (e) {
      throw Exception("Error al obtener servicios del empleado.");
    }
  }

  Future<void> anadirInformeServicio(InformeServicio informe) async {
    await _apiService.dio.post("/reports_services", data: informe.toJson());
  }

  Future<void> actualizarInformeServicio(String id, InformeServicio informe) async {
    await _apiService.dio.put("/reports_services/$id", data: informe.toJson());
  }

  Future<void> eliminarInformeServicio(int id) async {
    await _apiService.dio.delete("/reports_services/$id");
  }
}