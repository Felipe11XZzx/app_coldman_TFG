import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/screens/admin/screen_lista_servicios.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/widgets/widget_services_list.dart';
import 'package:app_coldman_sa/screens/admin/screen_detalle_servicio.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ScreenServicios extends StatefulWidget {
  const ScreenServicios({super.key});

  @override
  _ScreenServiciosEstado createState() => _ScreenServiciosEstado();
}

class _ScreenServiciosEstado extends State<ScreenServicios> {
  Logger logger = Logger();
  String _busqueda = '';
  CategoriaServicio? _filtroCategoria;
  EstadoServicio? _filtroEstado;

  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosIniciales();
    });
  }

  // METODO PARA CARGAR LOS DATOS DE LOS SERVICIOS Y LOS EMPLEADOS.
  Future<void> _cargarDatosIniciales() async {
    await Future.wait([
      _cargarServicios(),
      _cargarEmpleados(),
    ]);
  }

// METODO PARA CARGAR LOS EMPLEADOS.
  Future<void> _cargarEmpleados() async {
    logger.i('=== CARGANDO EMPLEADOS ===');
    try {
      final empleadoProvider =
          Provider.of<EmpleadoProvider>(context, listen: false);
      await empleadoProvider.obtenerEmpleadosDisponibles();
    } catch (e) {
      logger.e('Error al cargar empleados: $e');
    }
    logger.i('=== FIN CARGAR EMPLEADOS ===');
  }

  Future<void> _cargarServicios() async {
    try {
      final servicioProvider =
          Provider.of<ServicioProvider>(context, listen: false);
      final empleadoProvider =
          Provider.of<EmpleadoProvider>(context, listen: false);

      // CARGAR LOS SERVICIOS Y EMPLEADOS AL MISMO TIEMPO.
      await Future.wait([
        servicioProvider.fetchServices(),
        empleadoProvider.fetchEmpleados(),
      ]);
    } catch (e) {
      if (mounted) {
        CustomDialogs.showSnackBar(context, "Error al cargar datos: $e",
            color: Constants.errorColor);
      }
    }
  }

// METODO PARA ELIMINAR LOS SERVICIOS EN LA SCREEN.
  Future<void> _eliminarServicio(Servicio servicio) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar el servicio "${servicio.nombre}"?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.errorColor,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    CustomDialogs.showLoadingSpinner(context);

    try {
      final servicioProvider =
          Provider.of<ServicioProvider>(context, listen: false);
      await servicioProvider.eliminarServicio(servicio.idServicio!);

      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(
        context,
        "Servicio '${servicio.nombre}' eliminado exitosamente",
        color: Constants.successColor,
      );

      await _cargarServicios();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      String errorMessage;

      if (e.toString().contains('HAS_DEPENDENCIES')) {
        // Extraer el mensaje específico del backend
        final regex = RegExp(r'message: ([^}]+)');
        final match = regex.firstMatch(e.toString());

        if (match != null) {
          errorMessage = match.group(1)?.replaceAll('}', '') ??
              'No se puede eliminar el servicio porque tiene citas asociadas';
        } else {
          errorMessage =
              'No se puede eliminar el servicio porque tiene citas asociadas';
        }

        // Mostrar un diálogo más informativo para este caso específico
        _mostrarDialogoErrorDependencias(servicio, errorMessage);
        return;
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      CustomDialogs.showSnackBar(
        context,
        "Error al eliminar servicio: $errorMessage",
        color: Constants.errorColor,
      );
    }
  }

  // METODO PARA ACTUALIZAR EL ESTADO DEL SERVICIO.
  Future<void> _actualizarEstadoServicio(
      Servicio servicio, EstadoServicio nuevoEstado) async {
    bool? confirmado = await CustomDialogs.showConfirmDialog(
        context: context,
        title: "Confirmar cambio de estado",
        content:
            "¿Está seguro de cambiar el estado del servicio a '${nuevoEstado.displayName}'?",
        style: const Text(''));

    if (confirmado != true) return;

    CustomDialogs.showLoadingSpinner(context);

    try {
      final servicioProvider =
          Provider.of<ServicioProvider>(context, listen: false);
      final servicioActualizado =
          servicio.copyWith(estadoServicio: nuevoEstado);
      await servicioProvider.updateEstadoServicio(servicioActualizado.idServicio!, nuevoEstado.displayName);

      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(
          context, "Estado actualizado a '${nuevoEstado.displayName}'",
          color: Constants.successColor);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context, "Error al actualizar el servicio: $e",
          color: Constants.errorColor);
    }
  }

// METODO PARA ASIGNAR EMPLEADO AL SERVICIO EN LA SCREEN.
  Future<void> _asignarEmpleadoAServicio(
      Servicio servicio, Empleado empleado) async {
    CustomDialogs.showLoadingSpinner(context);

    try {
      final servicioProvider =
          Provider.of<ServicioProvider>(context, listen: false);

      // LLAMO AL BACKEND PAR ASIGNAR EL EMPLEADO.
      final servicioActualizado =
          await servicioProvider.asignarEmpleadoAServicio(
              servicio.getIdServicio(), empleado.getidEmpleado());

      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context,
          "Servicio asignado exitosamente a ${empleado.nombre} ${empleado.apellidos}",
          color: Constants.successColor);

      await _cargarServicios();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context,
          "Error al asignar empleado: ${e.toString().replaceAll('Exception: ', '')}",
          color: Constants.errorColor);
    }
  }

// METODO PARA QUITAR EL EMPLEADO DEL SERVICIO.
  Future<void> _desasignarEmpleadoDeServicio(Servicio servicio) async {
    CustomDialogs.showLoadingSpinner(context);

    try {
      final servicioProvider =
          Provider.of<ServicioProvider>(context, listen: false);

      await servicioProvider.desasignarEmpleadoDeServicio(servicio.idServicio!);

      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(
          context, "Empleado desasignado del servicio exitosamente",
          color: Constants.successColor);

      await _cargarServicios();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context,
          "Error al desasignar empleado: ${e.toString().replaceAll('Exception: ', '')}",
          color: Constants.errorColor);
    }
  }

  // METODO PARA FILTRAR POR LOS SERVICIOS.
  List<Servicio> _filtrarServicios(List<Servicio> servicios) {
    return servicios.where((servicio) {
      if (_filtroEstado != null && servicio.estadoServicio != _filtroEstado) {
        return false;
      }

      if (_filtroCategoria != null &&
          servicio.categoriaServicio != _filtroCategoria) {
        return false;
      }

      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        return servicio.nombre.toLowerCase().contains(busquedaLower) ||
            servicio.descripcion.toLowerCase().contains(busquedaLower) ||
            servicio.idServicio.toString().contains(busquedaLower);
      }

      return true;
    }).toList();
  }

  Widget _buildHeaderEstadisticas(
      List<Servicio> servicios, List<Empleado> empleados) {
    final stats = _calcularEstadisticas(servicios);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Color.fromARGB(255, 101, 141, 206),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de Servicios: ${stats['total']}',
                      style: const TextStyle(
                        color: Colors.white,
                        backgroundColor: Color.fromARGB(255, 101, 141, 206),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Empleados disponibles: ${empleados.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.assignment,
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenListaServicios(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Programados',
                  stats['programados'].toString(),
                  Icons.schedule,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'En Progreso',
                  stats['progresando'].toString(),
                  Icons.play_circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Completados',
                  stats['completados'].toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Cancelados',
                  stats['cancelados'].toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 43, 92, 170),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosYBusqueda() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // BARRA DE BUSQUEDA.
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar servicios por nombre, descripción...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busqueda.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _busqueda = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // FILTROS DE LA SCREEN.
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey),
              const SizedBox(width: 8),

              // FILTRO POR ESTADO.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<EstadoServicio?>(
                        value: _filtroEstado,
                        isExpanded: true,
                        underline: Container(),
                        hint: const Text('Todos'),
                        items: [
                          const DropdownMenuItem<EstadoServicio?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...EstadoServicio.values.map((estado) {
                            return DropdownMenuItem<EstadoServicio?>(
                              value: estado,
                              child: Text(estado.displayName,
                                  style: TextStyle(fontSize: 12)),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filtroEstado = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // FILTRO POR CATEGORIA.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categoría:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<CategoriaServicio?>(
                        value: _filtroCategoria,
                        isExpanded: true,
                        underline: Container(),
                        hint: const Text('Todas'),
                        items: [
                          const DropdownMenuItem<CategoriaServicio?>(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ...CategoriaServicio.values.map((categoria) {
                            return DropdownMenuItem<CategoriaServicio?>(
                              value: categoria,
                              child: Text(categoria.displayName,
                                  style: TextStyle(fontSize: 12)),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filtroCategoria = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No hay servicios',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _busqueda.isNotEmpty ||
                    _filtroEstado != null ||
                    _filtroCategoria != null
                ? 'No se encontraron servicios con los filtros aplicados'
                : 'Aún no has creado ningún servicio',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/crear-servicio');
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear primer servicio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

// METODO PARA ASIGNAR EL EMPLEADO MEDIANTE MODAL.
  void _mostrarModalAsignarEmpleado(Servicio servicio) {
    logger.i('=== ABRIENDO MODAL ASIGNAR EMPLEADO ===');
    logger.i('Servicio ID: ${servicio.idServicio}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<EmpleadoProvider>(
          builder: (context, empleadoProvider, child) {
            if (empleadoProvider.isLoading) {
              return Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final empleadosDisponibles = empleadoProvider.empleadosDisponibles;
            logger.i(
                'empleados disponibles asignado: ${empleadosDisponibles.length}');

            if (empleadosDisponibles.isEmpty) {
              logger.e('Lista vacia mensaje de error');
              return Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay empleados disponibles',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'DEBUG: Lista empleadosDisponibles está vacía',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            logger.i(
                'Construyendo lista con ${empleadosDisponibles.length} empleados');

            for (int i = 0; i < empleadosDisponibles.length; i++) {
              final emp = empleadosDisponibles[i];
              logger.i(
                  'Empleado para modal [$i]: ${emp.nombre} ${emp.apellidos}');
            }

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // MODAL.
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TITULO.
                  Text(
                    'Asignar Empleado al Servicio #${servicio.idServicio}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LISTA DE EMPLEADOS.
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: empleadosDisponibles.length,
                      itemBuilder: (context, index) {
                        final empleado = empleadosDisponibles[index];
                        logger.i(
                            'Construyendo ListTile $index: ${empleado.nombre}');

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(empleado.nombre
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'E'),
                          ),
                          title:
                              Text('${empleado.nombre} ${empleado.apellidos}'),
                          subtitle: Text(empleado.email ?? 'Sin email'),
                          onTap: () {
                            logger
                                .i('Empleado seleccionado: ${empleado.nombre}');
                            Navigator.pop(context);
                            _asignarEmpleadoAServicio(servicio, empleado);
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoErrorDependencias(Servicio servicio, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('No se puede eliminar'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'El servicio "${servicio.nombre}" no puede ser eliminado.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(mensaje),
              SizedBox(height: 16),
              Text(
                'Opciones disponibles:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('• Cancelar o completar las citas asociadas'),
              Text('• Cambiar el estado del servicio'),
              Text('• Contactar con el administrador'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Opcionalmente, navegar a la gestión de citas relacionadas
                // _navegarAGestionCitas(servicio);
              },
              child: const Text('Ver citas'),
            ),
          ],
        );
      },
    );
  }

// METODO PARA NAVEGAR A LA SCREEN DE DETALLE SERVICIO.
  void _navegarADetalleServicio(Servicio servicio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenDetalleServicio(servicio: servicio),
      ),
    );
  }

  Map<String, int> _calcularEstadisticas(List<Servicio> servicios) {
    return {
      'total': servicios.length,
      'programados': servicios
          .where((s) => s.estadoServicio == EstadoServicio.programada)
          .length,
      'progresando': servicios
          .where((s) => s.estadoServicio == EstadoServicio.progresando)
          .length,
      'completados': servicios
          .where((s) => s.estadoServicio == EstadoServicio.completada)
          .length,
      'cancelados': servicios
          .where((s) => s.estadoServicio == EstadoServicio.cancelada)
          .length,
      'reprogramados': servicios
          .where((s) => s.estadoServicio == EstadoServicio.reprogramada)
          .length,
    };
  }

  void _exportarServicios() {
    CustomDialogs.showSnackBar(
      context,
      "Función de exportación en desarrollo",
      color: Colors.blue,
    );
  }

  void _mostrarEstadisticas() {
    CustomDialogs.showSnackBar(
      context,
      "Estadísticas detalladas en desarrollo",
      color: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Servicios"),
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarServicios,
            tooltip: "Actualizar",
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportarServicios();
                  break;
                case 'stats':
                  _mostrarEstadisticas();
                  break;
                case 'empleados':
                  Navigator.pushNamed(context, '/empleados');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'empleados',
                child: Row(
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 8),
                    Text('Gestionar Empleados'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Exportar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Estadísticas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<ServicioProvider, EmpleadoProvider>(
        builder: (context, servicioProvider, empleadoProvider, child) {
          if (servicioProvider.isLoading || empleadoProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando servicios y empleados...'),
                ],
              ),
            );
          }

          if (servicioProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar servicios',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    servicioProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarServicios,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final serviciosFiltrados =
              _filtrarServicios(servicioProvider.todosMenosEliminados);
          final empleadosDisponibles =
              empleadoProvider.empleados.where((e) => !e.bajaLaboral!).toList();

          return Column(
            children: [
              // NAVBAR DE ESTADISTICAS.
              _buildHeaderEstadisticas(
                  servicioProvider.todosMenosEliminados, empleadosDisponibles),

              // BARRA DE FILTROS Y BUSQUEDA.
              _buildFiltrosYBusqueda(),

              // LISTA DE SERVICIOS.
              Expanded(
                child: serviciosFiltrados.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _cargarServicios,
                        child: ListView.builder(
                          itemCount: serviciosFiltrados.length,
                          itemBuilder: (context, index) {
                            final servicio = serviciosFiltrados[index];
                            return ServicioListItem(
                              servicio: servicio,
                              onTap: () => _navegarADetalleServicio(servicio),
                              onEliminar: () => _eliminarServicio(servicio),
                              onAsignarEmpleado: () =>
                                  _mostrarModalAsignarEmpleado(servicio),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
