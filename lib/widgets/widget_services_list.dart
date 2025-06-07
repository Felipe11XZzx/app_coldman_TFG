import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/utils/price_format.dart';

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
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ID Y CATEGORIA DEL SERVICIO.
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
        
        // ESTADO DEL SERVICIO.
        _buildChipEstado(),
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

  Widget _buildChipEstado() {
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
        ],
      ),
    );
  }

  Widget _buildDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOMBRE DEL SERVICIO.
        Text(
          widget.servicio.nombre,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        
        // DESCRIPCION DEL SERVICIO.
        if (widget.servicio.descripcion.isNotEmpty)
          Text(
            widget.servicio.descripcion,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildDetallesServicio() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDetalleItem(
              icono: Icons.access_time,
              titulo: 'Descripción',
              valor: '${widget.servicio.descripcion} Descripción',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetalleItem(
              icono: Icons.euro,
              titulo: 'Precio',
              valor: '${widget.servicio.descripcion} Descripción',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDetalleItem(
              icono: Icons.calendar_today,
              titulo: 'Creado',
              valor: _formatearFecha(widget.servicio.fechaCreacion),
              color: Colors.orange,
            ),
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
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tieneEmpleado ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tieneEmpleado ? Colors.green[200]! : Colors.blue[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            tieneEmpleado ? Icons.person : Icons.person_outline,
            color: tieneEmpleado ? Colors.green[600] : Colors.blue[600],
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
                    color: tieneEmpleado ? Colors.green[600] : Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (tieneEmpleado && empleado != null) ...[
                  Text(
                    '${empleado.nombre} ${empleado.apellidos}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    empleado.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
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
          // BOTONES SEGUN EL ESTADO.
          if (tieneEmpleado) ...[
            // BOTON PARA CAMBIAR DE EMPLEADO.
            ElevatedButton.icon(
              onPressed: () => _mostrarModalAsignarEmpleado(),
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: const Text(
                'Cambiar',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
              ),
            ),
            const SizedBox(width: 8),
            // BOTON PARA QUITAR EL EMPLEADO.
            IconButton(
              onPressed: () => _confirmarDesasignacion(),
              icon: const Icon(Icons.person_remove, size: 16),
              color: Colors.red[600],
              tooltip: 'Desasignar empleado',
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ] else
            // BOTON PARA ASIGNAR EL EMPLEADO.
            ElevatedButton.icon(
              onPressed: widget.onAsignarEmpleado,
              icon: const Icon(Icons.assignment_ind, size: 16),
              label: const Text(
                'Asignar',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // UBICACION DEL SERVICIO.
        if (widget.servicio.localizacionCoordenadas != null)
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Ubicación disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
        
        // Acciones
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DROPDWON CAMBIAR DEL ESTADO.
            if (widget.onEstadoChanged != null)
              _buildDropdownEstado(),
            
            const SizedBox(width: 8),
            
            // BOTON ELIMINAR.
            if (widget.onEliminar != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
                iconSize: 20,
                onPressed: widget.onEliminar,
                tooltip: 'Eliminar servicio',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownEstado() {
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
          return DropdownMenuItem<EstadoServicio>(
            value: estado,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconoEstado(estado),
                  size: 14,
                  color: _getColorEstado(estado),
                ),
                const SizedBox(width: 6),
                Text(
                  estado.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getColorEstado(estado),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (nuevoEstado) {
          if (nuevoEstado != null && nuevoEstado != widget.servicio.estadoServicio) {
            widget.onEstadoChanged?.call(nuevoEstado);
          }
        },
      ),
    );
  }

  void _mostrarModalAsignarEmpleado() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
                'Asignar Empleado al Servicio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                widget.servicio.nombre,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // LISTA DE EMPLEADOS.
              Expanded(
                child: widget.empleadosDisponibles.isEmpty
                    ? _buildEmptyEmpleadosState()
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: widget.empleadosDisponibles.length,
                        itemBuilder: (context, index) {
                          final empleado = widget.empleadosDisponibles[index];
                          return _buildEmpleadoItem(empleado);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpleadoItem(Empleado empleado) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: empleado.bajaLaboral! 
              ? Colors.red[100] 
              : Colors.green[100],
          child: Icon(
            Icons.person,
            color: empleado.bajaLaboral! 
                ? Colors.red[600] 
                : Colors.green[600],
          ),
        ),
        title: Text(
          '${empleado.nombre} ${empleado.apellidos}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: empleado.bajaLaboral! ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(empleado.email),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  empleado.bajaLaboral! ? Icons.person_off : Icons.person,
                  size: 14,
                  color: empleado.bajaLaboral! ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  empleado.bajaLaboral! ? 'En baja laboral' : 'Disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: empleado.bajaLaboral! ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (empleado.administrador) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: empleado.bajaLaboral!
              ? null 
              : () {
                  Navigator.pop(context);
                  _confirmarAsignacion(empleado);
                },
          child: const Text(
            'Asignar',
            style: TextStyle(fontSize: 12),
          ),
        ),
        enabled: !empleado.bajaLaboral!,
      ),
    );
  }

  Widget _buildEmptyEmpleadosState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay empleados disponibles',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega empleados para poder asignar servicios',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarAsignacion(Empleado empleado) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Asignación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Está seguro de asignar este servicio a:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    radius: 16,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${empleado.nombre} ${empleado.apellidos}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          empleado.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      widget.onAsignarEmpleado?.call;
    }
  }

  Future<void> _confirmarDesasignacion() async {
    final empleado = widget.servicio.empleadoAsignado;
    if (empleado == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desasignación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Está seguro de desasignar este empleado?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[100],
                    radius: 16,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${empleado.nombre} ${empleado.apellidos}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          empleado.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El servicio quedará sin asignar y volverá al estado "Programada".',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      widget.onAsignarEmpleado?.call;
    }

  showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(16),
    ),
  ),
  builder: (context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          'Opciones del Servicio #${widget.servicio.idServicio}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // OPCIONES.
        ListTile(
          leading: const Icon(Icons.visibility),
          title: const Text('Ver detalles'),
          onTap: () {
            Navigator.pop(context);
            widget.onTap?.call();
          },
        ),
        ListTile(
          leading: const Icon(Icons.assignment_ind),
          title: const Text('Asignar empleado'),
          onTap: () {
            Navigator.pop(context);
            _mostrarModalAsignarEmpleado();
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Editar'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Ver ubicación'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            Navigator.pop(context);
            widget.onEliminar?.call();
          },
        ),
        
        SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

  void _mostrarOpcionesServicio(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            'Opciones del Servicio #${widget.servicio.idServicio}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // OPCIONES.
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver detalles'),
            onTap: () {
              Navigator.pop(context);
              widget.onTap?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind),
            title: const Text('Asignar empleado'),
            onTap: () {
              Navigator.pop(context);
              _mostrarModalAsignarEmpleado();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Ver ubicación'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onEliminar?.call();
            },
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

  // METODO PARA OBTENER LOS ICONOS BASADO EN ESTADO DEL SERVICIO.
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
    }
  }

  // METODO PARA OBTENER LOS COLORES BASADO EN ESTADO DEL SERVICIO.
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
    }
  }

  // METODO PARA OBTENER LOS COLORES BASADO EN LA CATEGORIA DEL SERVICIO.
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
    }
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _mostrarOpcionesServicio(context),
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}
