import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:logger/logger.dart';


class ClienteRepository {

  final ApiService _apiService = ApiService();
  final Logger logger = Logger();

  // ENDPOINT DEL FRONTEND PARA CARGAR LA LISTA DE LOS CLIENTES.
  Future<List<Cliente>> getListaCliente() async {
    try {
      final response = await _apiService.dio.get('/clientes');
      return (response.data as List)
          .map((customer) => Cliente.fromJson(customer))
          .toList();
    } catch (e) {
      logger.e("Error en la API al obtener los clientes: $e");
      throw Exception("Error en la API al obtener los clientes: $e");
    }
  }

  // ENDPOINT DEL FRONTEND PARA AGREGAR UN NUEVO CLIENTE.
  Future<void> agregarCliente(Cliente cliente) async {
    await _apiService.dio.post('/clientes', data: cliente.toJson());
  }

    // ENDPOINT DEL FRONTEND PARA ACTUALIZAR UN CLIENTE EXISTENTE.
  Future<void> actualizarCliente(String id, Cliente cliente) async {
    await _apiService.dio.put('/clientes/$id', data: cliente.toJson());
  }

  // ENDPOINT DEL FRONTEND PARA ELIMINAR UN CLIENTE.
  Future<void> eliminarCliente(int id) async {
    await _apiService.dio.delete('/clientes/$id');
  }
  
}
