
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/models/informe_model.dart';

class Servicio {
  int id;
  String nombre;
  String descripcion;
  double precio;
  Empleado empleado;
  String estado;
  List<InformeServicio> informe;
  String imagenServicio;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    required this.informe,
    required this.precio,
    required this.empleado,
    required this.imagenServicio,
  });

  factory Servicio.empty() {
    return Servicio(
      id: 0, 
      nombre: '', 
      descripcion: '', 
      estado: '', 
      informe: [], 
      precio: 0, 
      empleado: Empleado.empty(), 
      imagenServicio: 'imagenServicio'
      );
  }

  Servicio copyWith({
    int ?id,
    String ?nombre,
    String ?descripcion,
    double ?precio,
    Empleado ?empleado,
    String ?estado,
    List<InformeServicio> ?informe,
    String ?imagenServicio,
  }) {
    return Servicio(
      id: id ?? this.id, 
      nombre: nombre ?? this.nombre, 
      descripcion: descripcion ?? this.descripcion, 
      estado: estado ?? this.estado, 
      informe: informe ?? this.informe, 
      precio: precio ?? this.precio, 
      empleado: empleado ?? this.empleado, 
      imagenServicio: imagenServicio ?? this.imagenServicio
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'estado': estado,
      'informe': informe.map((e) => e.toJson()).toList(),
      'empleado': empleado.toJson(),
      'imagen': imagenServicio,
    };
  }
  
  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      estado: json['estado'] as String,
      informe: (json['informe'] as List)
          .map((e) => InformeServicio.fromJson(e))
          .toList(),
      empleado: Empleado.fromJson(json['empleado']),
      precio: (json['precio'] as num).toDouble(),
      imagenServicio: json['imagen'] as String,
    );
  }

  @override
  String toString() {
    return 'Servicio{id: $id, empleado: $empleado, nombre: $nombre, descripcion: $descripcion, estado: $estado, precio: $precio, imagen: $imagenServicio}';
  } 
}