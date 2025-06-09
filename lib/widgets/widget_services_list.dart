import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ServicioListItem extends StatefulWidget {
  const ServicioListItem({
    super.key,
    required this.servicio,
    this.onEstadoChanged,
    this.onAsignarEmpleado,
    this.onEliminar,
    this.onTap,
    this.empleadosDisponibles = const [],
  });

  final List<Empleado> empleadosDisponibles;
  final VoidCallback? onEliminar;
  final VoidCallback? onAsignarEmpleado;
  final ValueChanged<EstadoServicio?>? onEstadoChanged;
  final VoidCallback? onTap;
  final Servicio servicio;

  @override
  State<ServicioListItem> createState() => _ServicioListItemState();
}

class _ServicioListItemState extends State<ServicioListItem> {
  final Logger _logger = Logger();

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ID Y CATEGORIA DEL SERVICIO
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                'Servicio #${widget.servicio.idServicio}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            _buildChipCategoria(),
          ],
        ),
        
        _buildChipEstadoFuncional(),
      ],
    );
  }

  Widget _buildChipCategoria() {
    final categoria = widget.servicio.categoriaServicio;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorCategoria(categoria).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColorCategoria(categoria).withOpacity(0.3)),
      ),
      child: Text(
        categoria.displayName,
        style: TextStyle(
          color: _getColorCategoria(categoria),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOMBRE DEL SERVICIO (con estilo según estado)
        Text(
          widget.servicio.nombre,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: widget.servicio.estadoServicio == EstadoServicio.cancelada
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: widget.servicio.estadoServicio == EstadoServicio.cancelada
                ? Colors.grey[600]
                : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        
        // DESCRIPCION DEL SERVICIO
        if (widget.servicio.descripcion.isNotEmpty)
          Text(
            widget.servicio.descripcion,
            style: TextStyle(
              fontSize: 14,
              color: widget.servicio.estadoServicio == EstadoServicio.cancelada
                  ? Colors.grey[500]
                  : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildDetallesServicio() {
    final bool esCancelado = widget.servicio.estadoServicio == EstadoServicio.cancelada;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esCancelado ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esCancelado ? Colors.red[200]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          if (esCancelado) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SERVICIO CANCELADO',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // DETALLES NORMALES
          Row(
            children: [
              Expanded(
                child: _buildDetalleItem(
                  icono: Icons.access_time,
                  titulo: 'Duración',
                  valor: '${widget.servicio.duracionReal ?? 0}h',
                  color: esCancelado ? Colors.grey : Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetalleItem(
                  icono: Icons.category,
                  titulo: 'Categoría',
                  valor: widget.servicio.categoriaServicio.displayName,
                  color: esCancelado ? Colors.grey : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetalleItem(
                  icono: Icons.calendar_today,
                  titulo: 'Creado',
                  valor: _formatearFecha(widget.servicio.fechaCreacion),
                  color: esCancelado ? Colors.grey : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icono, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmpleadoAsignado() {
    final tieneEmpleado = widget.servicio.tieneEmpleadoAsignado;
    final empleado = widget.servicio.empleadoAsignado;
    final bool esCancelado = widget.servicio.estadoServicio == EstadoServicio.cancelada;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esCancelado 
            ? Colors.grey[100] 
            : (tieneEmpleado ? Colors.green[50] : Colors.blue[50]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esCancelado 
              ? Colors.grey[300]! 
              : (tieneEmpleado ? Colors.green[200]! : Colors.blue[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            tieneEmpleado ? Icons.person : Icons.person_outline,
            color: esCancelado 
                ? Colors.grey[500] 
                : (tieneEmpleado ? Colors.green[600] : Colors.blue[600]),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empleado Asignado:',
                  style: TextStyle(
                    fontSize: 12,
                    color: esCancelado 
                        ? Colors.grey[500] 
                        : (tieneEmpleado ? Colors.green[600] : Colors.blue[600]),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (tieneEmpleado && empleado != null) ...[
                  Text(
                    '${empleado.nombre} ${empleado.apellidos}',
                    style: TextStyle(
                      fontSize: 14,
                      color: esCancelado ? Colors.grey[600] : Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    empleado.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: esCancelado ? Colors.grey[500] : Colors.green[600],
                    ),
                  ),
                ] else
                  Text(
                    'Sin asignar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          if (!esCancelado) ...[
            if (tieneEmpleado) ...[
              ElevatedButton.icon(
                onPressed: () => _mostrarModalAsignarEmpleado(),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Cambiar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _confirmarDesasignacion(),
                icon: const Icon(Icons.person_remove, size: 16),
                color: Colors.red[600],
                tooltip: 'Desasignar empleado',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ] else
              ElevatedButton.icon(
                onPressed: widget.onAsignarEmpleado,
                icon: const Icon(Icons.assignment_ind, size: 16),
                label: const Text('Asignar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
              ),
          ] else ...[
            // MOSTRAR INDICADOR DE CANCELADO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'CANCELADO',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final bool esCancelado = widget.servicio.estadoServicio == EstadoServicio.cancelada;
    
    return Row(
      children: [
        // UBICACION DEL SERVICIO
        if (widget.servicio.localizacionCoordenadas != null)
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: esCancelado ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Ubicación disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: esCancelado ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: Text(
              'Sin ubicación especificada',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DROPDOWN CAMBIAR ESTADO (FUNCIONAL)
            if (widget.onEstadoChanged != null && !esCancelado)
              _buildDropdownEstadoFuncional(),
            
            const SizedBox(width: 8),
            
            // BOTON ELIMINAR
            if (widget.onEliminar != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
                iconSize: 20,
                onPressed: widget.onEliminar,
                tooltip: 'Eliminar servicio',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ],
    );
  }


  IconData _getIconoEstado(EstadoServicio estado) {
  switch (estado) {
    case EstadoServicio.programada:
      return Icons.schedule_outlined;
    case EstadoServicio.progresando:
      return Icons.play_circle_outlined; 
    case EstadoServicio.completada:
      return Icons.check_circle_outlined; 
    case EstadoServicio.cancelada:
      return Icons.cancel_outlined; 
    case EstadoServicio.reprogramada:
      return Icons.update_outlined; 
    case EstadoServicio.inactivo:
      return Icons.pause_circle_outlined; 
    case EstadoServicio.archivado:
      return Icons.archive_outlined; 
    case EstadoServicio.eliminado:
      return Icons.delete_outline;
    default:
      return Icons.help_outline; 
  }
}

Color _getColorEstado(EstadoServicio estado) {
  switch (estado) {
    case EstadoServicio.programada:
      return Colors.blue; 
    case EstadoServicio.progresando:
      return Colors.orange; 
    case EstadoServicio.completada:
      return Colors.green; 
    case EstadoServicio.cancelada:
      return Colors.red; 
    case EstadoServicio.reprogramada:
      return Colors.purple;
    case EstadoServicio.inactivo:
      return Colors.grey; 
    case EstadoServicio.archivado:
      return Colors.brown;
    case EstadoServicio.eliminado:
      return Colors.red[800]!; 
    default:
      return Colors.grey; 
  }
}

Widget _buildDropdownEstadoFuncional() {
  return Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(6),
    ),
    child: DropdownButton<EstadoServicio>(
      value: widget.servicio.estadoServicio,
      underline: Container(),
      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
      isDense: true,
      items: EstadoServicio.values.map((estado) {
        final color = _getColorEstado(estado);
        final icono = _getIconoEstado(estado);
        
        return DropdownMenuItem<EstadoServicio>(
          value: estado,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                estado.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (nuevoEstado) {
        if (nuevoEstado != null && nuevoEstado != widget.servicio.estadoServicio) {
          _logger.i('Cambiando estado de ${widget.servicio.estadoServicio} a $nuevoEstado');
          widget.onEstadoChanged?.call(nuevoEstado);
        }
      },
    ),
  );
}

Widget _buildChipEstadoFuncional() {
  final estado = widget.servicio.estadoServicio;
  final color = _getColorEstado(estado);
  final icono = _getIconoEstado(estado);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          estado.displayName,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (estado == EstadoServicio.cancelada || estado == EstadoServicio.eliminado) ...[
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    ),
  );
}


  Color _getColorCategoria(CategoriaServicio categoria) {
    switch (categoria) {
      case CategoriaServicio.mantenimiento:
        return Colors.blue;
      case CategoriaServicio.instalacion:
        return Colors.green;
      case CategoriaServicio.acondicionado:
        return Colors.cyan;
      case CategoriaServicio.calderas:
        return Colors.orange;
      case CategoriaServicio.frigorificas:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  void _mostrarModalAsignarEmpleado() {
    _logger.i('Mostrando modal para asignar empleado');
  }

  Future<void> _confirmarDesasignacion() async {
    _logger.i('Confirmando desasignación de empleado');
  }

  @override
  Widget build(BuildContext context) {
    final bool esCancelado = widget.servicio.estadoServicio == EstadoServicio.cancelada;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: esCancelado ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: esCancelado 
            ? BorderSide(color: Colors.red[200]!, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: esCancelado 
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red.withOpacity(0.03),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildDescripcion(),
                const SizedBox(height: 12),
                _buildDetallesServicio(),
                const SizedBox(height: 12),
                _buildEmpleadoAsignado(),
                const SizedBox(height: 12),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}