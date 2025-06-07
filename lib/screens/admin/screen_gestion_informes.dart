import 'package:app_coldman_sa/widgets/widget_reports_list.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';
import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/providers/informe_provider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';


class ScreenInformes extends StatefulWidget {
  const ScreenInformes({super.key});

  @override
  _ScreenEstadoInforme createState() => _ScreenEstadoInforme();
}

class _ScreenEstadoInforme extends State<ScreenInformes> {
  Logger logger = Logger();
  EstadoInforme? _filtroEstado;
  String _busqueda = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarInformes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // METODO PARA CARGAR LOS INFORMES DE SERVICIOS EN LA SCREEN.
  Future<void> _cargarInformes() async {
    try {
      final informeProvider =
          Provider.of<InformeProvider>(context, listen: false);
      await informeProvider.cargarInformes();
    } catch (e) {
      if (mounted) {
        CustomDialogs.showSnackBar(context, "Error al cargar informes: $e",
            color: Constants.errorColor);
      }
    }
  }

  // METODO PARA ACTUALIZAR EL ESTADO DE LOS INFORMES DE SERVICIOS EN LA SCREEN.
  Future<void> _actualizarEstadoInforme(
      InformeServicio informe, EstadoInforme nuevoEstado) async {
    bool? confirmado = await CustomDialogs.showConfirmDialog(
        context: context,
        title: "Confirmar cambio de estado",
        content:
            "¿Está seguro de cambiar el estado del informe a '${nuevoEstado.displayName}'?",
        style: const Text(''));

    if (confirmado != true) return;

    CustomDialogs.showLoadingSpinner(context);

    try {
      final informeProvider =
          Provider.of<InformeProvider>(context, listen: false);
      final informeActualizado = informe.copyWith(estadoInforme: nuevoEstado);
      await informeProvider.actualizarInforme(
          informeActualizado.idInforme.toString(), informeActualizado);

      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(
          context, "Estado actualizado a '${nuevoEstado.displayName}'",
          color: Constants.successColor);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context, "Error al actualizar el informe: $e",
          color: Constants.errorColor);
    }
  }

  // METODO PARA ELIMINAR LOS INFORMES DE SERVICIOS EN LA SCREEN.
  Future<void> _eliminarInforme(InformeServicio informe) async {
    bool? confirmado = await CustomDialogs.showConfirmDialog(
        context: context,
        title: "Eliminar Informe",
        content:
            "¿Está seguro de que desea eliminar este informe? Esta acción no se puede deshacer.",
        style: const Text(''),
        confirmText: "Eliminar",
        cancelText: "Cancelar");

    if (confirmado != true) return;

    CustomDialogs.showLoadingSpinner(context);

    try {
      final informeProvider =
          Provider.of<InformeProvider>(context, listen: false);
      await informeProvider.eliminarInforme(informe.idInforme!);

      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context, "Informe eliminado correctamente",
          color: Constants.successColor);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      CustomDialogs.showSnackBar(context, "Error al eliminar el informe: $e",
          color: Constants.errorColor);
    }
  }

  // METODO PARA FILTRAR LOS INFORMES DE SERVICIO POR SU ESTADO.
  List<InformeServicio> _filtrarInformes(List<InformeServicio> informes) {
    return informes.where((informe) {
      // FILTRO POR ESTADO.
      if (_filtroEstado != null && informe.estadoInforme != _filtroEstado) {
        return false;
      }

      // Filtro por búsqueda
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        return informe.descripcionInforme
                .toLowerCase()
                .contains(busquedaLower) ||
            informe.descripcionMateriales
                .toLowerCase()
                .contains(busquedaLower) ||
            informe.observacionesInforme
                .toLowerCase()
                .contains(busquedaLower) ||
            informe.idInforme.toString().contains(busquedaLower);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Informes"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarInformes,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body: Consumer<InformeProvider>(
        builder: (context, informeProvider, child) {
          if (informeProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando informes...'),
                ],
              ),
            );
          }

          if (informeProvider.error != null) {
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
                    'Error al cargar informes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    informeProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarInformes,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final informesFiltrados = _filtrarInformes(informeProvider.informes);

          return Column(
            children: [
              // COMPONENTE CON ESTADISTICAS.
              _buildHeaderEstadisticas(informeProvider.informes),

              // BARRA DE FILTROS Y BUSQUEDA.
              _buildFiltrosYBusqueda(),

              // LISTA DE INFORMES DE SERVICIO.
              Expanded(
                child: informesFiltrados.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _cargarInformes,
                        child: ListView.builder(
                          itemCount: informesFiltrados.length,
                          itemBuilder: (context, index) {
                            final informe = informesFiltrados[index];
                            return InformeListItem(
                              informe: informe,
                              onEstadoChanged: (nuevoEstado) {
                                if (nuevoEstado != null) {
                                  _actualizarEstadoInforme(
                                      informe, nuevoEstado);
                                }
                              },
                              onEliminar: () => _eliminarInforme(informe),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/detalle-informe',
                                  arguments: informe,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/crear-informe');
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: "Crear nuevo informe",
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderEstadisticas(List<InformeServicio> informes) {
    final stats = _calcularEstadisticas(informes);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Text(
            'Total de Informes: ${stats['total']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Borradores',
                  stats['borradores'].toString(),
                  Icons.edit,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'En Revisión',
                  stats['revision'].toString(),
                  Icons.schedule,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Aprobados',
                  stats['aprobados'].toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Rechazados',
                  stats['rechazados'].toString(),
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
        color: Colors.white.withOpacity(0.2),
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
              hintText: 'Buscar informes por descripción, materiales...',
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

          // FILTRO POR ESTADO.
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Filtrar por estado:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<EstadoInforme?>(
                    value: _filtroEstado,
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text('Todos los estados'),
                    items: [
                      const DropdownMenuItem<EstadoInforme?>(
                        value: null,
                        child: Text('Todos los estados'),
                      ),
                      ...EstadoInforme.values.map((estado) {
                        return DropdownMenuItem<EstadoInforme?>(
                          value: estado,
                          child: Row(
                            children: [
                              Icon(
                                _getIconoEstado(estado),
                                size: 16,
                                color: _getColorEstado(estado),
                              ),
                              const SizedBox(width: 8),
                              Text(estado.displayName),
                            ],
                          ),
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
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No hay informes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _busqueda.isNotEmpty || _filtroEstado != null
                ? 'No se encontraron informes con los filtros aplicados'
                : 'Aún no has creado ningún informe',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/crear-informe');
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear primer informe'),
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

  // METODO PARA OBTENER LOS ICONOS EN BASE A LOS ESTADOS DEL INFORME.
  IconData _getIconoEstado(EstadoInforme estado) {
    switch (estado) {
      case EstadoInforme.borrador:
        return Icons.edit_outlined;
      case EstadoInforme.revision:
        return Icons.schedule_outlined;
      case EstadoInforme.aprobado:
        return Icons.check_circle_outlined;
      case EstadoInforme.rechazado:
        return Icons.cancel_outlined;
    }
  }

  // METODO PARA OBTENER COLORES EN BASE A LOS ESTADOS DEL INFORME.
  Color _getColorEstado(EstadoInforme estado) {
    switch (estado) {
      case EstadoInforme.borrador:
        return Colors.orange;
      case EstadoInforme.revision:
        return Colors.blue;
      case EstadoInforme.aprobado:
        return Colors.green;
      case EstadoInforme.rechazado:
        return Colors.red;
    }
  }

  Map<String, int> _calcularEstadisticas(List<InformeServicio> informes) {
    return {
      'total': informes.length,
      'borradores': informes
          .where((i) => i.estadoInforme == EstadoInforme.borrador)
          .length,
      'revision': informes
          .where((i) => i.estadoInforme == EstadoInforme.revision)
          .length,
      'aprobados': informes
          .where((i) => i.estadoInforme == EstadoInforme.aprobado)
          .length,
      'rechazados': informes
          .where((i) => i.estadoInforme == EstadoInforme.rechazado)
          .length,
    };
  }
}
