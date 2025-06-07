import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/data/repositories/cliente_repository.dart';


class ClienteProvider with ChangeNotifier {
  
  final ClienteRepository clienteRepository = ClienteRepository();
  List<Cliente> clientes = [];
  List<Cliente> get cliente => clientes;

  // METODO PARA CARGAR LOS CLIENTES Y NOTIFICAR CAMBIOS EN EL BACK.
  Future <void> fetchClientes() async {
    clientes = await clienteRepository.getListaCliente();
    notifyListeners();
  }

  // METODO PARA CARGAR LOS CLIENTES.
  Future<List<Cliente>> fetchListaClientes() async {
    return await clienteRepository.getListaCliente();
  }

  // METODO PARA AGREGAR UN CLIENTE NUEVO.
  Future<void> addCliente(Cliente cliente) async {
    await clienteRepository.agregarCliente(cliente);
    fetchClientes();
  }

  // METODO PARA ACTUALIZAR UN CLIENTE.
  Future<void> updateCliente(String id, Cliente cliente) async {
    await clienteRepository.actualizarCliente(id, cliente);
    fetchClientes();
  }

  // METODO PARA ELIMINAR UN CLIENTE.
  Future<void> deleteCliente(int id) async {
    await clienteRepository.eliminarCliente(id);
    fetchClientes();
  }
}