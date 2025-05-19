import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:flutter/material.dart';

// IMPORTS DE LA APLICACION FINAL DE VENTA DE PRODUCTOS COLDMAN.
/*
import 'package:frontend_flutter/data/models/order.dart';
import 'package:frontend_flutter/data/models/product.dart';
import 'package:frontend_flutter/utils/images.dart';
import 'package:frontend_flutter/utils/constants.dart';
import 'package:frontend_flutter/utils/priceformat.dart';
import 'package:frontend_flutter/data/repositories/productorepository.dart';
*/

// IMPORTS DE LA APLICACION REFACTRORIZADA DE COLDMAN.
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/utils/price_format.dart';
import 'package:app_coldman_sa/data/repositories/servicio_repository.dart';


class ServicioListItem extends StatefulWidget {
  final Servicio servicio;
  final ValueChanged<String?>? onEstadoChanged;

  const ServicioListItem({
    super.key,
    required this.servicio,
    this.onEstadoChanged,
  });

  @override
  _ServicioListItemEstado createState() => _ServicioListItemEstado();
}

class _ServicioListItemEstado extends State<ServicioListItem> {

  late Future<List<Servicio>> futureServicios;

  @override
  void initState() {
    super.initState();
    futureServicios = ServicioRepository().getServices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Servicio>>(
      future: futureServicios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error al cargar los productos",
              style: TextStyle(
                fontSize: 16,
                color: Colors.red
              ),
            ),
          );
        }
        List<Servicio> servicios = snapshot.data ?? [];

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pedido: ${widget.servicio.id}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Usuario: ${widget.servicio.empleado.nombre}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...widget.servicio.informe.map((detalle) {
                  final servicio = servicios.firstWhere(
                    (p) => p.id == detalle.servicio.id,
                    orElse: () => Servicio(
                      id: detalle.servicio.id,
                      nombre: 'Producto desconocido',
                      descripcion: '',
                      imagenServicio: '',
                      precio: 0.0, 
                      estado: '', 
                      informe: [], 
                      empleado: Empleado(
                        id: 0,
                        nombre: 'Empleado desconocido',
                        email: '',
                        contrasena: '',
                        contrasena2: '',
                        telefono: '', 
                        apellido: '', 
                        trato: '', 
                        edad: 18, 
                        imagenUsuario: '',
                        bloqueado: false, 
                        administrador: false, 
                        fechaAlta: DateTime.now(),
                        lugarNacimiento: '',
                      ),
                      
                    ),
                  );
                  return buildServicioItem(servicio, detalle.cantidad);
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: ${PriceFormat.formatPrice(widget.servicio.precio)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (widget.onEstadoChanged != null)
                      buildEstadoDropdown()
                    else
                      buildEstadoText(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildServicioItem(Servicio servicio, int cantidad) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Image(
              image: Images.getImageProvider(servicio.imagenServicio),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicio.nombre),
                Text("Cantidad: $cantidad"),
                Text("Precio unitario: ${PriceFormat.formatPrice(servicio.precio)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEstadoDropdown() {
    List<String> estadosValidos = Constants.estadoIconos.keys.toList();
    String estadoActual = estadosValidos.contains(widget.servicio.estado)
      ? widget.servicio.estado
      : estadosValidos.first;
    return DropdownButton<String>(
      value: estadoActual,
      items: estadosValidos.map((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Constants.estadoIconos[estado],
                color: Constants.estadoColores[estado],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                estado,
                style: TextStyle(color: Constants.estadoColores[estado]),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: widget.onEstadoChanged,
    );
  }

  Widget buildEstadoText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Constants.estadoIconos[widget.servicio.estado],
          color: Constants.estadoColores[widget.servicio.estado],
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          widget.servicio.estado,
          style: TextStyle(
            color: Constants.estadoColores[widget.servicio.estado],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
