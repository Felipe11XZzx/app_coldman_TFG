import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:app_coldman_sa/data/models/cita_model.dart';

  // ENUM PARA CATEGORÍAS DE ESTADO DE LA CITA.
enum EstadoInforme {

  borrador('BORRADOR', 'Programada'),
  revision('REVISION', 'En Progreso'),
  aprobado('APROBADO', 'Completada'),
  rechazado('RECHAZADO', 'Cancelada');

  const EstadoInforme(this.backendValue, this.displayName);
  
  final String backendValue;
  final String displayName;

  static EstadoInforme fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BORRADOR':
        return EstadoInforme.borrador;
      case 'REVISION':
        return EstadoInforme.revision;
      case 'APROBADO':
        return EstadoInforme.aprobado;
      case 'RECHAZADO':
        return EstadoInforme.rechazado;
      default:
        return EstadoInforme.borrador;
    }
  }

  @override
  String toString() => displayName;

}

class InformeServicio {

  final int? idInforme;
  final EstadoInforme estadoInforme;
  final String descripcionInforme;
  final String descripcionMateriales;
  final int duracionEstimada;
  final int duracionHoras;
  final String observacionesInforme;
  final double precioServicio;
  final String avanceFotos;
  final DateTime fechaCreacion;
  final int idCita;

  InformeServicio({
    this.idInforme,
    required this.estadoInforme,
    required this.descripcionInforme,
    required this.descripcionMateriales,
    required this.duracionEstimada,
    required this.duracionHoras,
    required this.observacionesInforme,
    required this.precioServicio,
    required this.avanceFotos,
    required this.fechaCreacion,
    required this.idCita
  });

   // FACTORY CONSTRUCTOR VACIO.
  factory InformeServicio.empty() {
    return InformeServicio(
      estadoInforme: EstadoInforme.borrador,
      descripcionInforme: '',
      descripcionMateriales: '',
      duracionHoras: 0,
      duracionEstimada: 0,
      precioServicio: 0.0,
      avanceFotos: '',
      observacionesInforme: '',
      fechaCreacion: DateTime.now(),
      idCita: 0,
    ); 
  }

  factory InformeServicio.fromJson(Map<String, dynamic> json) {
    return InformeServicio(
      idInforme: json['id_informe'] ?? 0,
      estadoInforme: json['estado_informe'] != null ? EstadoInforme.fromString(json['estado_informe']) : EstadoInforme.borrador,
      descripcionInforme: json['descripcion_informe'] ?? '',
      descripcionMateriales: json['descripcion_materiales'] ?? '',
      duracionHoras: json['duracion_horas'] ?? 0,
      duracionEstimada: json['duracion_estimada'] ?? 0,
      precioServicio: (json['precio_servicio'] as num?)?.toDouble() ?? 0.0,
      avanceFotos:  json['avance_fotos'] ?? '',
      observacionesInforme: json['observacion_informe'] ?? '',
      fechaCreacion: json['fecha_creacion'] != null 
      ? DateTime.tryParse(json['fecha_creacion']) ?? DateTime.timestamp() 
      : DateTime.now(),
      idCita: json['cita']?['id_cita'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "estado_informe": estadoInforme.backendValue,
      "descripcion_informe": descripcionInforme,
      "descripcion_materiales": descripcionMateriales,
      "duracion_horas": duracionHoras,
      "duracion_estimada": duracionEstimada,
      "precio_servicio": precioServicio,
      "avance_fotos": avanceFotos, 
      "observaciones_informe": observacionesInforme,
      "fecha_creacion": fechaCreacion.toIso8601String(),
      "id_cita": idCita
    };

    // AGREGAR ID SOLO SI EXISTE.
    if (idInforme != null) {
      json['id_informe'] = idInforme;
    }
    return json;
  }

  // METODO PARA REGISTRO (SIN ID).
  Map<String, dynamic> toJsonForRegistration() {
    final json = toJson();
    json.remove('id_informe');
    return json;
  }

  // COPY WITH.
  InformeServicio copyWith({
    int? idInforme,
    EstadoInforme? estadoInforme,
    String? descripcionInforme,
    String? descripcionMateriales,
    int? duracionEstimada,
    int? duracionHoras,
    String? observacionesInforme,
    double? precioServicio,
    String? avanceFotos,
    DateTime? fechaCreacion,
    int? idCita,
  }) {
    return InformeServicio(
      idInforme: idInforme ?? this.idInforme,
      estadoInforme: estadoInforme ?? this.estadoInforme,
      descripcionInforme: descripcionInforme ?? this.descripcionInforme,
      descripcionMateriales: descripcionMateriales ?? this.descripcionMateriales,
      duracionHoras: duracionHoras ?? this.duracionHoras,
      duracionEstimada: duracionEstimada ?? this.duracionEstimada,
      precioServicio: precioServicio ?? this.precioServicio,
      avanceFotos: avanceFotos ?? this.avanceFotos,
      observacionesInforme: observacionesInforme ?? this.observacionesInforme,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      idCita: idCita ?? this.idCita
    );
  }

  // GETTERS DEL MODELO DE INFORMES.
  bool get estaBorrador => estadoInforme == EstadoInforme.borrador;
  bool get estaRevision => estadoInforme == EstadoInforme.revision;
  bool get estaAprobado => estadoInforme == EstadoInforme.aprobado;
  bool get estaRechazado => estadoInforme == EstadoInforme.rechazado;
  String get estadoDisplayName => estadoInforme.displayName;

  @override
  String toString() {
    return 'Informe{id: $idInforme, estado informe: ${estadoInforme.displayName}, descripcion informe $descripcionInforme, fecha creacion, $fechaCreacion';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InformeServicio &&
        other.idInforme == idInforme &&
        other.estadoInforme == estadoInforme &&
        other.descripcionInforme == descripcionInforme &&
        other.descripcionMateriales == descripcionMateriales &&
        other.duracionHoras == duracionHoras &&
        other.duracionEstimada == duracionEstimada &&
        other.precioServicio == precioServicio &&
        other.avanceFotos == avanceFotos &&
        other.observacionesInforme == observacionesInforme &&
        other.fechaCreacion == fechaCreacion &&
        other.idCita == idCita;
  }

  @override
  int get hashCode {
    return Object.hash(
      idInforme,
      estadoInforme,
      descripcionInforme,
      descripcionMateriales,
      duracionHoras,
      duracionEstimada,
      observacionesInforme,
      fechaCreacion,
      avanceFotos,
      precioServicio,
      idCita,
    );
  }
  
}