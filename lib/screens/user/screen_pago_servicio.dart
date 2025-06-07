import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';


class ScreenPagoServicio extends StatefulWidget {
  
  final Empleado empleado;
  const ScreenPagoServicio({super.key, required this.empleado});

  @override
  _ScreenEstadoPagoServicio createState() => _ScreenEstadoPagoServicio();

}

class _ScreenEstadoPagoServicio extends State<ScreenPagoServicio> {
  late ServicioProvider servicioProvider;
  Map<int, int> cantidades = {};

  @override
  void initState() {
    super.initState();
    servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
    servicioProvider.fetchServices();
  }

  double calcularTotal() {
    double total = 0;
    for (var servicio in servicioProvider.servicios) {
      int cantidad = cantidades[servicio.idServicio] ?? 0;
      if (cantidad > 0) {
        total += cantidad;
      }  
    }
    return total;
  }
  
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

/*
  void incrementarCantidad(Servicio servicio) {
    setState(() {
      int cantidadActual = cantidades[servicio.id] ?? 0;
      if (cantidadActual < servicio.stock) {
        cantidades[producto.id] = cantidadActual + 1;
      } else {
        SnaksBar.showSnackBar(
          context, "No hay suficiente stock disponible",
          color: Constants.warningColor
        );
      }
    });
  }
*/

/*
  void decrementarCantidad(Product producto) {
    setState(() {
      int cantidadActual = cantidades[producto.id] ?? 0;
      if (cantidadActual > 0) {
        cantidades[producto.id] = cantidadActual - 1;
      }
    });
  }

  */


/*
  bool validarStock() {
    for (var servicios in servicioProvider.servicios) {
      int cantidad = cantidades[servicios.id] ?? 0;
      if (cantidad > servicios.) {
        CustomSnackBar.showSnackBar(
          context, "${producto.nombre}: No hay suficiente stock. Stock disponible: ${producto.stock}",
          color: Constants.errorColor
        );
        return false;
      }
    }
    return true;
  }

*/


/*
  void realizarCompra() {
    bool hayProductos = cantidades.values.any((cantidad) => cantidad > 0);
    if (!hayProductos) {
      CustomSnackBar.showSnackBar(
        context, "Seleccione al menos un producto",
        color: Constants.warningColor
      );
      return;
    }

    if (!validarStock()) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double total = calcularTotal();
        return AlertDialog(
          title: const Text("Confirmar Compra"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Resumen del pedido:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 8),
                ...productoProvider.productos.map((producto) {
                  int cantidad = cantidades[producto.id] ?? 0;
                  if (cantidad > 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                          "${producto.nombre}: $cantidad x ${PriceFormat.formatPrice(producto.precio)}"
                        ),
                    );
                  }
                  return const SizedBox.shrink();
                }).whereType<Padding>(),
                const Divider(),
                Text(
                  "Total: ${PriceFormat.formatPrice(total)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                confirmarCompra();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 15),
              ),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  void confirmarCompra() async {
    if (cantidades.isEmpty || !cantidades.values.any((cantidad) => cantidad > 0)) {
      SnaksBar.showSnackBar(
        context, "Seleccione al menos un producto",
        color: Constants.warningColor
      );
      return;
    }

    if (!validarStock()) return;

    List<DetallePedido> detallesPedido = [];
    for (var producto in productoProvider.productos) {
      int cantidad = cantidades[producto.id] ?? 0;
      if (cantidad > 0) {
        if (cantidad <= producto.stock) {
          detallesPedido.add(DetallePedido(
            id: 0,
            producto: producto,
            cantidad: cantidad,
            precio: producto.precio
          ));


          producto.stock -= cantidad;
          await productoProvider.updateProducto(producto.id.toString(), producto);
        } else {
          SnaksBar.showSnackBar(
            context, "Error: Stock insuficiente para ${producto.nombre}",
            color: Constants.errorColor
          );
          return;
        }
      }
    }

    Order pedido = Order(
      id: 0,
      total: calcularTotal(),
      estado: "Pedido",
      usuario: widget.usuario,
      detalles: detallesPedido
    );

    print("JSON del pedido a enviar: ${jsonEncode(pedido.toJson())}");

    try {
      final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
      await pedidoProvider.addPedido(pedido);

      SnaksBar.showSnackBar(
        context, "Compra realizada con éxito",
        color: Constants.successColor
      );

      setState(() {
        cantidades.clear();
      });
    } catch (e) {
      SnaksBar.showSnackBar(
        context, "Error al procesar la compra",
        color: Constants.errorColor
      );
    }
  }

 @override
  Widget build(BuildContext context) {


    return Consumer<ProductoProvider>(
      builder: (context, provider, child) {
        if (provider.productos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  if (provider.productos.isEmpty)
                    const Center(
                      child: Text(
                        "No hay productos disponibles",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  else
                    ...provider.productos.map((producto) {
                      int currentQuantity = cantidades[producto.id] ?? 0;
                      return ProductListItem(
                        producto: producto,
                        cantidad: currentQuantity,
                        onIncrement: () => incrementarCantidad(producto),
                        onDecrement: () => decrementarCantidad(producto),
                      );
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 150,
              right: 150,
              child: ElevatedButton(
                onPressed: realizarCompra,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontSize: 15),
                ),
                child: const Text("Realizar Compra"),
              ),
            ),
          ],
        );
      },
    );
  }*/
}