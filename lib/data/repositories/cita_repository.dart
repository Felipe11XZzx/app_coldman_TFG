import 'package:app_coldman_sa/data/models/cita_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:logger/logger.dart';


class CitaRepository {

  final ApiService _apiService = ApiService();
  final logger = Logger();

  // ENDPOINT DEL FRONTEND PARA CARGAR LA LISTA DE LAS CITAS.
  Future<List<Cita>> getListaCitas() async {
    try {
      final response = await _apiService.dio.get('/citas');
      return (response.data as List)
          .map((date) => Cita.fromJson(date))
          .toList();
    } catch (e) {
      logger.e('Error en la API al obtener las citas : $e');
      throw Exception("Error en la API al obtener las citas : $e");
    }
  }

  // ENDPOINT DEL FRONTEND PARA CARGAR LAS CITAS POR EL ID DEL CLIENTE.
  Future<List<Cita>> getCitasPorCliente(int id) async {
    try {
      final response = await _apiService.dio.get("/citas/clientes/$id");
      return (response.data as List)
        .map((json) => Cita.fromJson(json))
        .toList();
    } catch (e) {
      logger.e('Error al obtener las citas por el cliente.');
      throw Exception("Error al obtener las citas por el cliente.");
    }
  }

  // ENDPOINT DEL FRONTEND PARA CREAR UNA NUEVA CITA.
  Future<void> agregarCita(Cita cita) async {
    await _apiService.dio.post('/citas', data: cita.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ACTULIZAR UNA CITA.
  Future<void> actualizarCita(String id, Cita cita) async {
    await _apiService.dio.put('/citas/$id', data: cita.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ELIMINAR UNA CITA.
  Future<void> eliminarCita(int id) async {
    await _apiService.dio.delete('/citas/$id');
  }
  
}
