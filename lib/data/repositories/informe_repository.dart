import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';


class InformeServicioRepository {
  
  final ApiService _apiService = ApiService();
  
    // ENDPOINT DEL FRONTEND PARA OBTENER LA LISTA DE LOS INFORMES DE SERVICIOS.
  Future<List<InformeServicio>> getListaInformes() async {
    try {
      final response = await _apiService.dio.get("/informes");
      return (response.data as List)
          .map((json) => InformeServicio.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Error al obtener los informes de los servicios.");
    }
  }

   // ENDPOINT DEL FRONTEND PARA OBTENER LOS INFORMES POR EL ID DEL EMPLEADO.
  Future<List<InformeServicio>> getInformesPorEmpleado(int id) async {
    try {
      final response = await _apiService.dio.get("/informes/empleado/$id");
      return (response.data as List)
        .map((json) => InformeServicio.fromJson(json))
        .toList();
    } catch (e) {
      throw Exception("Error al obtener servicios del empleado.");
    }
  }

  // ENDPOINT DEL FRONTEND PARA CREAR UN NUEVO INFORME DE SERVICIO.
  Future<void> anadirInformeServicio(InformeServicio informe) async {
    await _apiService.dio.post("/informes", data: informe.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ACTUALIZAR UN INFORME DE SERVICIO.
  Future<void> actualizarInformeServicio(String id, InformeServicio informe) async {
    await _apiService.dio.put("/informes/$id", data: informe.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ELIMINAR UN INFORME DE SERVICIO.
  Future<void> eliminarInformeServicio(int id) async {
    await _apiService.dio.delete("/informes/$id");
  }
}