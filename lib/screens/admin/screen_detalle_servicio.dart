import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';


class ScreenDetalleServicio extends StatefulWidget {
  final Servicio servicio;

  const ScreenDetalleServicio({
    super.key,
    required this.servicio,
  });

  @override
  State<ScreenDetalleServicio> createState() => _ScreenDetalleServicioState();
}

class _ScreenDetalleServicioState extends State<ScreenDetalleServicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Servicio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITULO DEL DETALLE DEL SERVICIO.
            Text(
              widget.servicio.nombre ?? 'Sin nombre',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // INFORMACION DEL SERVICIO.
            _buildInfoCard(),
            
            const SizedBox(height: 16),
            
            // DESCRIPCION DEL SERVICIO.
            _buildDescripcionCard(),
            
            const SizedBox(height: 16),
            
            // EMPLEADO ASIGNADO.
            _buildEmpleadoCard(),
            
            const Spacer(),
            
            // BOTONES DE ACCION.
            _buildBotonesAccion(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID', '#${widget.servicio.idServicio}'),
            _buildInfoRow('Estado', widget.servicio.estadoServicio.displayName ?? 'Sin estado'),
            _buildInfoRow('Categoría', widget.servicio.categoriaServicio.displayName ?? 'Sin categoría'),
          ],
        ),
      ),
    );
  }

  Widget _buildDescripcionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.servicio.descripcion ?? 'Sin descripción',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpleadoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Empleado Asignado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.servicio.empleadoAsignado != null)
              Text(
                '${widget.servicio.empleadoAsignado!.nombre} ${widget.servicio.empleadoAsignado!.apellidos}',
                style: const TextStyle(fontSize: 16),
              )
            else
              const Text(
                'Sin asignar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // FALTA EL METODO PARA EDITAR EL DETALLE DEL SERVICIO.
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // FALTA EL METODO PARA ASIGNAR AL EMPLEADO AL DETALLE DEL SERVICIO.
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Asignar'),
          ),
        ),
      ],
    );
  }
}