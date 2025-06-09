import 'dart:math';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/repositories/empleado_repository.dart';
import 'package:app_coldman_sa/data/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';


class EmpleadoProvider with ChangeNotifier {
  
  final EmpleadoRepository empleadosRepository = EmpleadoRepository();
  final Logger logger = Logger();
  List<Empleado> empleados = [];
  List<Empleado> _empleadosDisponibles = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  String? _error;

  // GETTERS DEL PROVIDER DE LOS EMPLEADOS.
  List<Empleado> get empleado => empleados;

  List<Empleado> get empleadosDisponibles {
    logger.i(
        'Getter empleadosDisponibles llamado - retornando ${_empleadosDisponibles.length} empleados');
    return _empleadosDisponibles;
  }

  String? get isError => _error;
  bool get isLoading => _isLoading;

  // METODO PARA DAR DE ALTA DE LA BAJA LABORAL A UN EMPLEADO.
  Future<void> activarEmpleado(int idEmpleado) async {
    try {
      _isLoading = true;
      notifyListeners();

      final empleado = getEmpleadoPorId(idEmpleado);
      if (empleado == null) {
        throw Exception('Empleado no encontrado');
      }
      final empleadoActualizado = empleado.copyWith(bajaLaboral: false);
      await empleadosRepository.actualizarEmpleado(
          empleadoActualizado.getId().toString(), empleadoActualizado);
      // ACTUALIZO LA LISTA LOCAL DE LOS EMPLEADOS.
      final index = empleados.indexWhere((e) => e.id == idEmpleado);
      if (index != -1) {
        empleados[index] = empleadoActualizado;
      }
    } catch (e) {
      _error = e.toString();
      logger.e('Error al activar empleado: $e');
      throw Exception('Error al activar empleado: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // METODO PARA AGREGAR UN NUEVO EMPLEADO.
  Future<void> addEmpleado(Empleado empleado) async {
    await empleadosRepository.agregarEmpleado(empleado);
    fetchEmpleados();
  }

  // METODO PARA AGREGAR UN NUEVO EMPLEADO.
  Future<Empleado> buscarEmpleadoPorEmail(String email) async {
    try {
      return await empleadosRepository.buscarEmpleadoPorEmail(email);
    } catch (e) {
      logger.e('Error al obtener los empleados por el email: $e');
      throw Exception('Error al obtener los empleados por el email: $e');
    }
  }

  // METODO PARA AGREGAR BUSCR EMPLEADO POR SU NOMBRE O EMAIL.
  List<Empleado> buscarEmpleados(String busqueda) {
    if (busqueda.isEmpty) return empleados;

    final busquedaLower = busqueda.toLowerCase();
    return empleados.where((empleado) {
      final nombreCompleto =
          '${empleado.nombre} ${empleado.apellidos}'.toLowerCase();
      final email = empleado.email.toLowerCase();

      return nombreCompleto.contains(busquedaLower) ||
          email.contains(busquedaLower);
    }).toList();
  }

  // METODO PARA CARGAR A LOS EMPLEADOS QUE SE LES PUEDE ASIGNAR UN SERVICIO.
  Future<List<Empleado>> cargarEmpleadosParaAsignacion() async {
    try {
      await fetchEmpleados();
      return getEmpleadosDisponibles();
    } catch (e) {
      logger.e('Error al cargar empleados: $e');
      throw Exception('Error al cargar empleados: $e');
    }
  }

  // METODO PARA CREAR UN NUEVO EMPLEADO.
  Future<Empleado> crearEmpleado(Empleado empleado) async {
    try {
      final nuevoEmpleado = await empleadosRepository.crearEmpleado(empleado);
      empleados.add(nuevoEmpleado);

      if (!(nuevoEmpleado.bajaLaboral ?? false)) {
        _empleadosDisponibles.add(nuevoEmpleado);
      }

      notifyListeners();
      return nuevoEmpleado;
    } catch (e) {
      logger.e('Error al crear un nuevo empleado: $e');
      throw Exception('Error al crear un nuevo empleado: $e');
    }
  }

// METODO PARA DAR DE ALTA A UN EMPLEADO DE LA BAJA LABORAL.
  Future<Empleado> darDeAltaEmpleado(int id) async {
    try {
      final empleadoActualizado =
          await empleadosRepository.darDeAltaEmpleado(id);

      // ACTUALIZO LA LISTA LOCAL.
      final index = empleados.indexWhere((e) => e.id == id);
      if (index != -1) {
        empleados[index] = empleadoActualizado;
      }

      final indexDisponibles =
          _empleadosDisponibles.indexWhere((e) => e.id == id);
      if (indexDisponibles == -1) {
        _empleadosDisponibles.add(empleadoActualizado);
      }

      notifyListeners();
      return empleadoActualizado;
    } catch (e) {
      logger.e('Error al dar de alta de baja laboral al empleado: $e');
      throw Exception('Error al dar de alta de baja laboral al empleado: $e');
    }
  }

// METODO PARA DAR DE BAJA LABORAL A UN EMPLEADO.
  Future<Empleado> darDeBajaEmpleado(int id) async {
    try {
      final empleadoActualizado =
          await empleadosRepository.darDeBajaEmpleado(id);

      // ACTUALIZO LA LISTA LOCAL.
      final index = empleados.indexWhere((e) => e.id == id);
      if (index != -1) {
        empleados[index] = empleadoActualizado;
      }

      _empleadosDisponibles.removeWhere((e) => e.id == id);

      notifyListeners();
      return empleadoActualizado;
    } catch (e) {
      logger.e('Error al dar de baja laboral al empleado: $e');
      throw Exception('Error al dar de baja laboral al empleado: $e');
    }
  }

  Future<void> deleteEmpleado(int id) async {
    await empleadosRepository.eliminarEmpleado(id);
    fetchEmpleados();
  }

// METODO PARA ELIMINAR A UN EMPLEADO.
  Future<void> eliminarEmpleado(int id) async {
    try {
      await empleadosRepository.eliminarEmpleado(id);

      empleados.removeWhere((empleado) => empleado.id == id);
      _empleadosDisponibles.removeWhere((empleado) => empleado.id == id);

      notifyListeners();
    } catch (e) {
      logger.e('Error al eliminar al empleado: $e');
      throw Exception('Error al eliminar al empleado: $e');
    }
  }

// METODO PARA VERIFICAR SI UN EMPLEADO NO ESTA EN BAJA LABORAL.
  bool empleadoDisponibleParaAsignacion(int idEmpleado) {
    final empleado = getEmpleadoPorId(idEmpleado);
    return empleado != null && !empleado.bajaLaboral!;
  }

// METODO PARA CARGAR TODOS LOS EMPLEADOS.
  Future<void> fetchEmpleados() async {
    empleados = await empleadosRepository.obtenerTodosLosEmpleados();
    notifyListeners();
  }

  Future<List<Empleado>> fetchListaUsuarios() async {
    return await empleadosRepository.obtenerTodosLosEmpleados();
  }

  // METODO PARA FILTRAR POR VARIOS CRITERIOS.
  List<Empleado> filtrarEmpleados({
    String? busqueda,
    bool? soloActivos,
    bool? soloAdministradores,
    bool? soloTecnicos,
  }) {
    var empleadosFiltrados = List<Empleado>.from(empleados);

    if (busqueda != null && busqueda.isNotEmpty) {
      empleadosFiltrados = buscarEmpleados(busqueda);
    }

    if (soloActivos == true) {
      empleadosFiltrados =
          empleadosFiltrados.where((e) => !e.bajaLaboral!).toList();
    }

    if (soloAdministradores == true) {
      empleadosFiltrados =
          empleadosFiltrados.where((e) => e.administrador).toList();
    }

    if (soloTecnicos == true) {
      empleadosFiltrados =
          empleadosFiltrados.where((e) => !e.administrador).toList();
    }

    return empleadosFiltrados;
  }

// METODO PARA OBTENER LOS ADMINISTRADORES QUE NO ESTAN DE BAJA LABORAL.
  List<Empleado> getAdministradoresDisponibles() {
    return getEmpleadosDisponibles()
        .where((empleado) => empleado.administrador)
        .toList();
  }

  // METODO PAR OBTENER EMPLEADO POR ID.
  Empleado? getEmpleadoPorId(int id) {
    try {
      return empleados.firstWhere((empleado) => empleado.id == id);
    } catch (e) {
      logger.e('Error al obtener al empleado por su id: $e');
      throw Exception('Error al obtener al empleado por su id: $e');
    }
  }

  // METODO PARA OBTENER LOS EMPLEADOS DISPONIBLES POR ORDEN ALFABETICO.
  List<Empleado> getEmpleadosActivosOrdenados() {
    final empleadosActivos = getEmpleadosDisponibles();
    empleadosActivos.sort((a, b) =>
        '${a.nombre} ${a.apellidos}'.compareTo('${b.nombre} ${b.apellidos}'));
    return empleadosActivos;
  }

  // METODO PARA OBTENER LOS EMPLEADOS QUE MENOS SERVICIOS ASIGNADOS TIENEN.
  Future<List<Empleado>> getEmpleadosConMenorCarga() async {
    try {
      final empleadosDisponibles = getEmpleadosDisponibles();
      empleadosDisponibles.sort((a, b) =>
          '${a.nombre} ${a.apellidos}'.compareTo('${b.nombre} ${b.apellidos}'));
      return empleadosDisponibles;
    } catch (e) {
      logger.e('Error al obtener empleados con menor carga: $e');

      throw Exception('Error al obtener empleados con menor carga: $e');
    }
  }

  // METODO PARA OBTENER LOS EMPLEADOS DISPONIBLES.
  List<Empleado> getEmpleadosDisponibles() {
    return empleados
        .where((empleado) => !empleado.bajaLaboral! && empleado.id != null)
        .toList();
  }

  // METODO PARA OBTENER LOS EMPLEADOS POR ESTADISTICAS EN JSON.
  Map<String, int> getEstadisticasEmpleados() {
    final total = empleados.length;
    final activos = empleados.where((e) => !e.bajaLaboral!).length;
    final enBaja = empleados.where((e) => e.bajaLaboral!).length;
    final administradores = empleados.where((e) => e.administrador).length;

    return {
      'total': total,
      'activos': activos,
      'enBaja': enBaja,
      'administradores': administradores,
      'tecnicos': total - administradores,
    };
  }

  // METODO PARA OBTENER LOS EMPLEADOS QUE NO SON ADMINISTRADORES.
  List<Empleado> getTecnicosDisponibles() {
    return getEmpleadosDisponibles()
        .where((empleado) => !empleado.administrador)
        .toList();
  }

  // LIMPIAR DATOS.
  void limpiarDatos() {
    empleados.clear();
    _empleadosDisponibles.clear();
    _clearError();
    notifyListeners();
  }

  // METODO PARA OBTENER EMPLEADO POR ID.
  Future<Empleado> obtenerEmpleadoPorId(int id) async {
    try {
      return await empleadosRepository.obtenerEmpleadoPorId(id);
    } catch (e) {
      logger.e('Error al obtener empleados por id: $e');
      throw Exception('Error al obtener empleados por id: $e');
    }
  }

  // METODO PARA OBTENER TODOS LOS EMPLEADOS.
  Future<void> obtenerEmpleados() async {
    _setLoading(true);
    _clearError();

    try {
      empleados = await empleadosRepository.obtenerTodosLosEmpleados();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      logger.e('Error al obtener el listado de los empleados: $e');
      throw Exception('Error al obtener el listado de los empleados: $e');
    } finally {
      _setLoading(false);
    }
  }

  // METODO PARA OBTENER TODOS LOS EMPLEADOS DISPONIBLES.
  Future<void> obtenerEmpleadosDisponibles() async {
    logger.i('=== OBTENIENDO EMPLEADOS DISPONIBLES ===');
    _setLoading(true);
    _clearError();

    try {
      _empleadosDisponibles =
          await empleadosRepository.obtenerEmpleadosDisponibles();
      for (int i = 0; i < _empleadosDisponibles.length; i++) {
        final emp = _empleadosDisponibles[i];
        logger.i('[$i] ${emp.nombre} ${emp.apellidos} (ID: ${emp.id})');
      }

      notifyListeners();
    } catch (e) {
      logger.e('Error al obtener los empleados disponibles: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
      logger.i('=== FIN OBTENER EMPLEADOS DISPONIBLES ===');
    }
  }

  // METODO PARA ACTUALIZAR EL EMPLEADO SI ESTA DISPONIBLE PARA TRABAJAR.
  Future<void> updateEmpleado(String id, Empleado empleado) async {
    await empleadosRepository.actualizarEmpleado(id, empleado);
    fetchEmpleados();
  }

  String? validarAsignacionEmpleado(int idEmpleado) {
    final empleado = getEmpleadoPorId(idEmpleado);

    if (empleado == null) {
      return 'Empleado no encontrado';
    }

    if (empleado.bajaLaboral!) {
      return 'El empleado está en baja laboral';
    }

    return null;
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // METODO PARA MANEJAR LOS ESTADOS.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
