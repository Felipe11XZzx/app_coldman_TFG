import 'package:app_coldman_sa/screens/admin/screen_servicio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ListaServiciosItem {
  ListaServiciosItem({
    required this.idServicio,
    required this.nombreServicio,
    required this.descripcionServicio,
    required this.categoriaServicio,
    required this.estadoServicio,
    required this.fechaCreacion,
    this.clienteNombre,
    this.empleadoNombre,
    this.idCita,
  });

  factory ListaServiciosItem.fromJson(Map<String, dynamic> json) {
    final cita = json['cita'] as Map<String, dynamic>?;

    return ListaServiciosItem(
      idServicio: json['id_servicio'] ?? 0,
      nombreServicio: json['nombre_servicio'] ?? '',
      descripcionServicio: json['descripcion_servicio'] ?? '',
      categoriaServicio: json['categoria_servicio'] ?? '',
      estadoServicio: json['estado_servicio'] ?? '',
      fechaCreacion: json['fecha_creacion_servicio']?.toString() ?? '',
      clienteNombre: cita?['nombreClienteCompleto'],
      empleadoNombre: cita?['nombreEmpleadoAsignado'],
      idCita: cita?['id_cita'],
    );
  }

  final String categoriaServicio;
  final String? clienteNombre;
  final String descripcionServicio;
  final String? empleadoNombre;
  final String estadoServicio;
  final String fechaCreacion;
  final int? idCita;
  final int idServicio;
  final String nombreServicio;

  bool get necesitaAsignacion {
    return (estadoServicio == 'PENDIENTE' || estadoServicio == 'PROGRAMADO') &&
        (empleadoNombre == null || empleadoNombre == 'Sin asignar');
  }
}

class ScreenListaServicios extends StatefulWidget {
  const ScreenListaServicios({super.key});

  @override
  _ScreenEstadoListaServicios createState() => _ScreenEstadoListaServicios();
}

class _ScreenEstadoListaServicios extends State<ScreenListaServicios> {
  Logger logger = Logger();

  String _busqueda = '';
  late Dio _dio;
  final List<String> _estadosDisponibles = [
    'PENDIENTES',
    'TODOS',
    'PROGRAMADO',
    'EN PROGRESO',
    'COMPLETADO',
    'CANCELADA'
  ];

  String _filtroEstado = 'PENDIENTES';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<ListaServiciosItem> _servicios = [];
  List<ListaServiciosItem> _serviciosFiltrados = [];

  @override
  void dispose() {
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeDio();
    _cargarServicios();
    _searchController.addListener(() {
      setState(() {
        _busqueda = _searchController.text;
      });
      _filtrarServicios();
    });
  }

  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = 'http://localhost:8080/api_coldman/v1';
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<void> _cargarServicios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      logger.i('=== CARGANDO SERVICIOS PARA ASIGNAR ===');
      final response = await _dio.get('/servicios');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _servicios =
              data.map((json) => ListaServiciosItem.fromJson(json)).toList();
          _serviciosFiltrados = _servicios;
        });
        _filtrarServicios();
        logger.i('Servicios cargados: ${_servicios.length}');
      } else {
        _mostrarError('Error al cargar servicios');
      }
    } on DioException catch (e) {
      logger.e('Error Dio cargando servicios: ${e.message}');
      _mostrarError('Error de conexión: ${e.message}');
    } catch (e) {
      logger.e('Error general cargando servicios: $e');
      _mostrarError('Error inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      logger.i('=== FIN CARGAR SERVICIOS ===');
    }
  }

  List<ListaServiciosItem> _filtrarServicios() {
    List<ListaServiciosItem> serviciosFiltrados = _servicios.where((servicio) {
      // Filtro por búsqueda
      bool matchesSearch = true;
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        matchesSearch = servicio.nombreServicio
                .toLowerCase()
                .contains(busquedaLower) ||
            servicio.descripcionServicio
                .toLowerCase()
                .contains(busquedaLower) ||
            servicio.idServicio.toString().contains(busquedaLower) ||
            (servicio.clienteNombre?.toLowerCase().contains(busquedaLower) ??
                false);
      }

      // Filtro por estado
      bool matchesEstado = true;
      if (_filtroEstado == 'PENDIENTES') {
        matchesEstado = servicio.necesitaAsignacion;
      } else if (_filtroEstado != 'TODOS') {
        matchesEstado = servicio.estadoServicio == _filtroEstado;
      }

      return matchesSearch && matchesEstado;
    }).toList();

    setState(() {
      _serviciosFiltrados = serviciosFiltrados;
    });

    return serviciosFiltrados;
  }

  void _navegarAAsignarServicio(ListaServiciosItem servicio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScreenPruebaServicio(servicioId: servicio.idServicio),
      ),
    ).then((result) {
      if (result == true) {
        _cargarServicios();
      }
    });
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'PROGRAMADO':
        return Colors.blue;
      case 'EN_PROGRESO':
        return Colors.green;
      case 'COMPLETADO':
        return Colors.grey;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Icons.schedule;
      case 'PROGRAMADO':
        return Icons.event;
      case 'EN_PROGRESO':
        return Icons.work;
      case 'COMPLETADO':
        return Icons.check_circle;
      case 'CANCELADA':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildServicioAvatar(ListaServiciosItem servicio) {
    return CircleAvatar(
      backgroundColor:
          _getEstadoColor(servicio.estadoServicio).withOpacity(0.2),
      child: Icon(
        _getEstadoIcon(servicio.estadoServicio),
        color: _getEstadoColor(servicio.estadoServicio),
        size: 24,
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEstadoColor(estado),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNecesitaAsignacionBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'NECESITA ASIGNACIÓN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar servicios...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _busqueda.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _busqueda = '';
                    });
                    _filtrarServicios();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _estadosDisponibles.map((estado) {
          bool isSelected = _filtroEstado == estado;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(estado),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filtroEstado = estado;
                });
                _filtrarServicios();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[800] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3B82F6),
        title: const Text("Seleccionar Servicio para Asignar",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarServicios,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _serviciosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              _filtroEstado == 'PENDIENTES'
                                  ? 'No hay servicios pendientes de asignar'
                                  : 'No se encontraron servicios',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Intenta cambiar los filtros de búsqueda',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarServicios,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _serviciosFiltrados.length,
                          itemBuilder: (context, index) {
                            if (index >= _serviciosFiltrados.length) {
                              return const SizedBox.shrink();
                            }

                            final servicio = _serviciosFiltrados[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              elevation: servicio.necesitaAsignacion ? 3 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: servicio.necesitaAsignacion
                                    ? BorderSide(color: Colors.orange, width: 2)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                leading: _buildServicioAvatar(servicio),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        servicio.nombreServicio,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    _buildEstadoBadge(servicio.estadoServicio),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ID: ${servicio.idServicio} - ${servicio.categoriaServicio}",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    if (servicio.clienteNombre != null)
                                      Text(
                                        "Cliente: ${servicio.clienteNombre}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    Text(
                                      "Empleado: ${servicio.empleadoNombre ?? 'Sin asignar'}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            (servicio.empleadoNombre == null ||
                                                    servicio.empleadoNombre ==
                                                        'Sin asignar')
                                                ? Colors.orange[700]
                                                : null,
                                        fontWeight:
                                            (servicio.empleadoNombre == null ||
                                                    servicio.empleadoNombre ==
                                                        'Sin asignar')
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    if (servicio.necesitaAsignacion)
                                      Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: _buildNecesitaAsignacionBadge(),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.assignment,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          _navegarAAsignarServicio(servicio),
                                      tooltip: 'Asignar servicio',
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                                onTap: () => _navegarAAsignarServicio(servicio),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
