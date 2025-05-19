import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';


class EmpleadoRepository {
  final ApiService _apiService = ApiService();

  Future<List<Empleado>> getListaEmpleados() async {
    try {
      final response = await _apiService.dio.get('/employees/getall');
      return (response.data as List)
          .map((user) => Empleado.fromJson(user))
          .toList();
    } catch (e) {
      throw Exception("Error en la API al obtener los empleados: $e");
    }
  }

  Future<void> agregarEmpleado(Empleado empleado) async {
    await _apiService.dio.post('/employee', data: empleado.toJson());
  }

  Future<void> actualizarEmpleado(String id, Empleado empleado) async {
    await _apiService.dio.put('/employee/$id', data: empleado.toJson());
  }

  Future<void> eliminarEmpleado(int id) async {
    await _apiService.dio.delete('/employee/$id');
  }
}
