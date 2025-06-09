import 'package:app_coldman_sa/data/models/cita_model.dart';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/data/models/informe_model.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// MODELO DE CITA.
class Cita {
  final int? id;
  final DateTime fechaHora;
  final int duracionEstimada;
  final String comentariosAdicionales;
  final EstadoCita estadoCita;
  final int idCliente;
  final int? idEmpleado;
  final int? idServicio;
  final List<InformeServicio> informes;

  const Cita({
    this.id,
    required this.fechaHora,
    required this.duracionEstimada,
    required this.comentariosAdicionales,
    required this.estadoCita,
    required this.idCliente,
    this.idEmpleado,
    this.idServicio,
    this.informes = const [],
  });

  // FACTORY CONSTRUCTOR VACIO
  factory Cita.empty() {
    return Cita(
      fechaHora: DateTime.now(),
      duracionEstimada: 0,
      comentariosAdicionales: '',
      estadoCita: EstadoCita.programado,
      idCliente: 0,
      idEmpleado: 0,
      idServicio: 0,
      informes: [],
    );
  }

  // DESDE JSON DEL BACKEND
  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id_cita'],
      fechaHora: json['fecha_hora'] != null
          ? _parseDateTimeFromBackend(json['fecha_hora'])
          : DateTime.now(),
      duracionEstimada: json['duracion_estimada'] ?? 0,
      comentariosAdicionales: json['comentarios_adicionales'] ?? '',
      estadoCita: json['estado_cita'] != null
          ? EstadoCita.fromString(json['estado_cita'])
          : EstadoCita.programado,
      idCliente: json['cliente']?['id_cliente'] ?? 0,
      informes: json['informes'] != null
          ? (json['informes'] as List)
              .map((item) => InformeServicio.fromJson(item))
              .toList()
          : [],
    );
  }

  // MÉTODO HELPER para parsear fechas
  static DateTime _parseDateTimeFromBackend(dynamic dateValue) {
    try {
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      debugPrint('Error parsing date in Cita: $e, value: $dateValue');
    }
    return DateTime.now();
  }

  // GETTERS DEL MODELO DE LA CITA.
  bool get estaCancelada => estadoCita == EstadoCita.cancelada;
  bool get estaCompletada => estadoCita == EstadoCita.completada;
  String get estadoDisplayName => estadoCita.displayName;
  bool get estaProgramado => estadoCita == EstadoCita.programado;
  bool get estaProgresando => estadoCita == EstadoCita.progresando;
  bool get estaReprogramada => estadoCita == EstadoCita.reprogramada;

  // COPY WITH
  Cita copyWith({
    int? id,
    DateTime? fechaHora,
    int? duracionEstimada,
    String? comentariosAdicionales,
    EstadoCita? estadoCita,
    int? idCliente,
    int? idEmpleado,
    int? idServicio,
    List<InformeServicio>? informes,
  }) {
    return Cita(
      id: id ?? this.id,
      fechaHora: fechaHora ?? this.fechaHora,
      duracionEstimada: duracionEstimada ?? this.duracionEstimada,
      comentariosAdicionales:
          comentariosAdicionales ?? this.comentariosAdicionales,
      estadoCita: estadoCita ?? this.estadoCita,
      idCliente: idCliente ?? this.idCliente,
      idEmpleado: idEmpleado ?? this.idEmpleado,
      idServicio: idServicio ?? this.idServicio,
      informes: informes ?? this.informes,
    );
  }

  // A JSON PARA EL BACKEND
  Map<String, dynamic> toJson() {
    return {
      'fecha_hora': fechaHora.toIso8601String(),
      'duracion_estimada': duracionEstimada,
      'comentarios_adicionales': comentariosAdicionales,
      'estado_cita': estadoCita.backendValue,
      'id_cliente': idCliente,
      'id_empleado': idEmpleado ?? 1,
      'id_servicio': idServicio ?? 1,
    };
  }

  @override
  String toString() {
    return 'Cita{id: $id, duracionEstimada: $duracionEstimada, estado cita: ${estadoCita.displayName}}';
  }
}

// ENUM PARA CATEGORÍAS DE ESTADO DE LA CITA.
enum EstadoCita {
  programado('PROGRAMADO', 'Programada'),
  progresando('PROGRESANDO', 'Progresando'),
  completada('COMPLETADA', 'Completada'),
  cancelada('CANCELADA', 'Cancelada'),
  reprogramada('REPROGRAMADA', 'Reprogramada');

  final String backendValue;

  final String displayName;
  const EstadoCita(this.backendValue, this.displayName);

  @override
  String toString() => displayName;

  static EstadoCita fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PROGRAMADO':
        return EstadoCita.programado;
      case 'PROGRESANDO':
        return EstadoCita.progresando;
      case 'COMPLETADA':
        return EstadoCita.completada;
      case 'CANCELADA':
        return EstadoCita.cancelada;
      case 'REPROGRAMADA':
        return EstadoCita.reprogramada;
      default:
        return EstadoCita.programado;
    }
  }
}
