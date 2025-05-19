import 'package:app_coldman_sa/data/models/servicio_model.dart';


class InformeServicio {
  int id;
  Servicio servicio;
  int cantidad;
  double precio;

  InformeServicio({
    required this.id,
    required this.servicio,
    required this.cantidad,
    required this.precio,
  });

  factory InformeServicio.fromJson(Map<String, dynamic> json) {
    return InformeServicio(
      id: json['id'],
      servicio: Servicio.fromJson(json['producto']),
      cantidad: json['cantidad'],
      precio: json['precio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "servicio": servicio.toJson(),
      "cantidad": cantidad,
      "precio": precio,
    };
  }
}