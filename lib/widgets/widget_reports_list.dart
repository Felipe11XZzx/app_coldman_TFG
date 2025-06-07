import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/utils/price_format.dart';

class InformeListItem extends StatefulWidget {
  final InformeServicio informe;
  final ValueChanged<EstadoInforme?>? onEstadoChanged;
  final VoidCallback? onEliminar;
  final VoidCallback? onTap;

  const InformeListItem({
    super.key,
    required this.informe,
    this.onEstadoChanged,
    this.onEliminar,
    this.onTap,
  });

  @override
  State<InformeListItem> createState() => _InformeListItemState();
}

class _InformeListItemState extends State<InformeListItem> {
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
        onLongPress: () => _mostrarOpcionesInforme(context),
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
              _buildDetallesInforme(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ID DEL INFORME.
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
            'Informe #${widget.informe.idInforme}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),

        // ESTADO DEL INFORME.
        _buildChipEstado(),
      ],
    );
  }

  Widget _buildChipEstado() {
    final estado = widget.informe.estadoInforme;
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
        // TITULO DE DESCRIPCION.
        const Text(
          'Descripción del trabajo:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),

        // DESCRIPCION DEL INFORME.
        Text(
          widget.informe.descripcionInforme.isNotEmpty
              ? widget.informe.descripcionInforme
              : 'Sin descripción',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetallesInforme() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // COLUMNA DE MATERIALES Y HORAS.
          Row(
            children: [
              Expanded(
                child: _buildDetalleItem(
                  icono: Icons.build_outlined,
                  titulo: 'Materiales',
                  valor: widget.informe.descripcionMateriales.isNotEmpty
                      ? widget.informe.descripcionMateriales
                      : 'No especificados',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              _buildDetalleItem(
                icono: Icons.access_time,
                titulo: 'Tiempo',
                valor: '${widget.informe.duracionHoras}h',
                color: Colors.orange,
              ),
            ],
          ),

          if (widget.informe.observacionesInforme.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // OBSERVACIONES DEL INFORME DE SERVICIO.
            _buildDetalleItem(
              icono: Icons.note_outlined,
              titulo: 'Observaciones',
              valor: widget.informe.observacionesInforme,
              color: Colors.purple,
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetalleItem({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color color,
    bool isFullWidth = false,
  }) {
    return isFullWidth
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icono, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icono, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // FECHA DE CREACION.
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                _formatearFecha(widget.informe.fechaCreacion),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // ACCIONES.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CAMBIAR DE ESTADO.
            if (widget.onEstadoChanged != null) _buildDropdownEstado(),

            const SizedBox(width: 8),

            // BOTON ELIMINAR.
            if (widget.onEliminar != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
                iconSize: 20,
                onPressed: widget.onEliminar,
                tooltip: 'Eliminar informe',
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
      child: DropdownButton<EstadoInforme>(
        value: widget.informe.estadoInforme,
        underline: Container(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
        isDense: true,
        items: EstadoInforme.values.map((estado) {
          return DropdownMenuItem<EstadoInforme>(
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
          if (nuevoEstado != null &&
              nuevoEstado != widget.informe.estadoInforme) {
            widget.onEstadoChanged?.call(nuevoEstado);
          }
        },
      ),
    );
  }

  void _mostrarOpcionesInforme(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
              'Opciones del Informe #${widget.informe.idInforme}',
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
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir'),
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

  // METODO PARA OBTENER LOS ICONOS BASADO EN LOS ESTADOS.
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

  // METODO PARA OBTENER LOS COLOES BASADO EN LOS ESTADOS.
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

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }
}
