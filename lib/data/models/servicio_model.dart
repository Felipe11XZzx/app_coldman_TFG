import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_coldman_sa/data/models/cita_model.dart'; 

// ENUM PARA CATEGORÍAS DE SERVICIO
enum CategoriaServicio {

  mantenimiento('MANTENIMIENTO', 'Mantenimiento'),
  instalacion('INSTALACION', 'Instalacion Maquinaria'),
  acondicionado('ACONDICIONADO', 'Aire Acondicionado'),
  calderas('CALDERAS', 'Calderas'),
  frigorificas('FRIGORIFICAS', 'Camaras Frigorificas');

  const CategoriaServicio(this.backendValue, this.displayName);
  
  final String backendValue;
  final String displayName;

  static CategoriaServicio fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MANTENIMIENTO':
        return CategoriaServicio.mantenimiento;
      case 'INSTALACION':
        return CategoriaServicio.instalacion;
      case 'ACONDICIONADO':
        return CategoriaServicio.acondicionado;
      case 'CALDERAS':
        return CategoriaServicio.calderas;
      case 'FRIGORIFICAS':
        return CategoriaServicio.frigorificas;
      default:
        return CategoriaServicio.instalacion;
    }
  }

  @override
  String toString() => displayName;

}

// ENUM PARA CATEGORÍAS DEL ESTADO DEL SERVICIO.
enum EstadoServicio {

  programada('PROGRAMADA', 'Programada'),
  progresando('PROGRESANDO', 'Progresando'),
  completada('COMPLETADA', 'Completada'),
  cancelada('CANCELADA', 'Cancelada'),
  reprogramada('REPROGRAMADA', 'Reprogramada');

  const EstadoServicio(this.backendValue, this.displayName);
  
  final String backendValue;
  final String displayName;

  static EstadoServicio fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PROGRAMADA':
        return EstadoServicio.programada;
      case 'PROGRESANDO':
        return EstadoServicio.progresando;
      case 'COMPLETADA':
        return EstadoServicio.completada;
      case 'CANCELADA':
        return EstadoServicio.cancelada;
      case 'REPROGRAMADA':
        return EstadoServicio.reprogramada;
      default:
        return EstadoServicio.programada;
    }
  }

  @override
  String toString() => displayName;

}

// CLASE AUXILIAR PARA COORDENADAS
class Coordenada {

  final double lat;
  final double lng;

  const Coordenada({
    required this.lat,
    required this.lng,
  });

  // CONVERTIR DESDE LatLng DE GOOGLE MAPS.
  factory Coordenada.fromLatLng(LatLng latLng) {
    return Coordenada(
      lat: latLng.latitude,
      lng: latLng.longitude,
    );
  }

  // CONVERTIR A LatLng PARA GOOGLE MAPS.
  LatLng toLatLng() {
    return LatLng(lat, lng);
  }

  // DESDE JSON
  factory Coordenada.fromJson(Map<String, dynamic> json) {
    return Coordenada(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  // A JSON
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() => 'Coordenada(lat: $lat, lng: $lng)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coordenada && other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;

}

// MODELO PRINCIPAL DE SERVICIO
class Servicio {

  final int? idServicio;
  final String nombre;
  final String descripcion;
  final CategoriaServicio categoriaServicio;
  final EstadoServicio estadoServicio;
  final Coordenada? localizacionCoordenadas;
  final DateTime fechaCreacion;
  final Empleado? empleadoAsignado;
  final int? duracionReal;
  final DateTime? fechaInicioServicio;
  final DateTime? fechaFinServicio;


  const Servicio({
    this.idServicio,
    required this.nombre,
    required this.descripcion,
    required this.categoriaServicio,
    required this.estadoServicio,
    this.localizacionCoordenadas,
    required this.fechaCreacion,
    this.empleadoAsignado,
    required this.duracionReal,
    required this.fechaInicioServicio,
    required this.fechaFinServicio
  });

  // FACTORY CONSTRUCTOR VACIO.
  factory Servicio.empty() {
    return Servicio(
      nombre: '',
      descripcion: '',
      categoriaServicio: CategoriaServicio.instalacion,
      estadoServicio: EstadoServicio.programada,
      fechaCreacion: DateTime.now(),
      empleadoAsignado: null,
      duracionReal: 0,
      fechaInicioServicio: DateTime.timestamp(),
      fechaFinServicio: DateTime.timestamp(),
    );
  }

  // DESDE JSON DEL BACKEND
  factory Servicio.fromJson(Map<String, dynamic> json) {
    // MANEJAR COORDENADAS DESDE EL BACKEND.
    Coordenada? coordenadas;
    if (json['localizacion_coordenada'] != null) {
      try {
        if (json['localizacion_coordenada'] is String) {
          // SI VIENE COMO JSON STRING DESDE EL BACKEND.
          final coordenadasJson = json['localizacion_coordenada'] as String;
          final coordenadasMap = _parseCoordinatesFromJson(coordenadasJson);
          if (coordenadasMap != null) {
            coordenadas = Coordenada.fromJson(coordenadasMap);
          }
        } else if (json['localizacion_coordenada'] is Map) {
          // SI VIENE COMO MAP DIRECTAMENTE.
          coordenadas = Coordenada.fromJson(json['localizacion_coordenada']);
        }
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
      }
    }

    // VERIFICACION SI LAS COORDENAS VIENEN POR SEPARADO ("LATITUD Y LONGITUD").
    if (coordenadas == null && json['latitud'] != null && json['longitud'] != null) {
      coordenadas = Coordenada(
        lat: (json['latitud'] as num).toDouble(),
        lng: (json['longitud'] as num).toDouble(),
      );
    }

    return Servicio(
      idServicio: json['id_servicio'],
      nombre: json['nombre_servicio'] ?? '',
      descripcion: json['descripcion_servicio'] ?? '',
      categoriaServicio: json['categoria_servicio'] != null
          ? CategoriaServicio.fromString(json['categoria_servicio'])
          : CategoriaServicio.instalacion,
      localizacionCoordenadas: coordenadas,
      estadoServicio: json['estado_servicio'] != null
          ? EstadoServicio.fromString(json['estado_servicio'])
          : EstadoServicio.programada,
      fechaCreacion: _parseArrayToDateTime(json['fecha_creacion']),
      empleadoAsignado: json['empleado_asignado'] != null
        ? Empleado.fromJson(json['empleado_asignado'])
        : null,
      duracionReal: json['duracion_real'],
        fechaInicioServicio: json['fecha_incio_servicio'] != null 
          ? DateTime.parse(json['fecha_incio_servicio'].toString()) 
          : null,
      fechaFinServicio: json['fecha_fin_servicio'] != null 
          ? DateTime.parse(json['fecha_fin_servicio'].toString()) 
          : null,
    );
  }

  // A JSON PARA EL BACKEND
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nombre_servicio': nombre,
      'descripcion_servicio': descripcion,
      'categoria_servicio': categoriaServicio.backendValue,
      'estado_servicio': estadoServicio.backendValue,
      "duracion_real": duracionReal,
      'fecha_creacion_servicio': fechaCreacion.toIso8601String(),
      'fecha_inicio_servicio': fechaCreacion.toIso8601String(),
      'fecha_fin_servicio': fechaCreacion.toIso8601String()

    };

    // AGREGAR ID SOLO SI EXISTE.
    if (idServicio != null) {
      json['id_servicio'] = idServicio;
    }

    // AGREGAR COORDENADAS EN EL FORMATO QUE SE ESPERA EN EL BACKEND.
    if (localizacionCoordenadas != null) {
      json['localizacion_coordenada'] = localizacionCoordenadas!.toJson();
    }

    if (empleadoAsignado != null) {
      json['empleado_asignado'] = empleadoAsignado!.toJson();
    }

    return json;
  }

  // METODO PARA REGISTRO (SIN ID).
  Map<String, dynamic> toJsonForRegistration() {
    final json = toJson();
    json.remove('id_servicio');
    return json;
  }

  // COPY WITH.
  Servicio copyWith({
    int? idServicio,
    String? nombre,
    String? descripcion,
    CategoriaServicio? categoriaServicio,
    EstadoServicio? estadoServicio,
    Coordenada? localizacionCoordenadas,
    DateTime? fechaCreacion,
    Empleado? empleadoAsignado,
    int? duracionReal,
    DateTime? fechaInicioServicio,
    DateTime? fechaFinServicio,

  }) {
    return Servicio(
      idServicio: idServicio ?? this.idServicio,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaServicio: categoriaServicio ?? this.categoriaServicio,
      localizacionCoordenadas: localizacionCoordenadas ?? this.localizacionCoordenadas,
      estadoServicio: estadoServicio ?? this.estadoServicio,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      empleadoAsignado: empleadoAsignado ?? this.empleadoAsignado,
      duracionReal: duracionReal ?? this.duracionReal,
      fechaInicioServicio: fechaInicioServicio ?? this.fechaInicioServicio,
      fechaFinServicio: fechaFinServicio ?? this.fechaFinServicio
    );
  }

  // Función helper para convertir array a DateTime
static DateTime _parseArrayToDateTime(dynamic dateArray) {
  try {
    if (dateArray is List && dateArray.length >= 3) {
      int year = dateArray[0];
      int month = dateArray[1];
      int day = dateArray[2];
      int hour = dateArray.length > 3 ? dateArray[3] : 0;
      int minute = dateArray.length > 4 ? dateArray[4] : 0;
      int second = dateArray.length > 5 ? dateArray[5] : 0;
      
      return DateTime(year, month, day, hour, minute, second);
    }
  } catch (e) {
    debugPrint('Error parsing date array: $e');
  }
  
  return DateTime.now();
}

  // GETTERS DEL MODELO DE SERVICIOS.
  bool get tieneCoordenadas => localizacionCoordenadas != null;
  bool get esMantemiento => categoriaServicio == CategoriaServicio.mantenimiento;
  bool get esInstalacion => categoriaServicio == CategoriaServicio.instalacion;
  bool get esAcondicionado => categoriaServicio == CategoriaServicio.acondicionado;
  bool get esCaldera => categoriaServicio == CategoriaServicio.calderas;
  bool get esFrigorifica => categoriaServicio == CategoriaServicio.frigorificas;
  LatLng? get coordenadasLatLng => localizacionCoordenadas?.toLatLng();
  String get categoriaDisplayName => categoriaServicio.displayName;
  bool get tieneEmpleadoAsignado => empleadoAsignado != null;
  String get nombreEmpleadoAsignado => empleadoAsignado != null ? '${empleadoAsignado!.nombre} ${empleadoAsignado!.apellidos}' : 'Sin asignar';
  bool get puedeSerAsignado => estadoServicio == EstadoServicio.programada && !tieneEmpleadoAsignado;
  bool get estaEnProgreso => estadoServicio == EstadoServicio.progresando;
  bool get estaCompletado => estadoServicio == EstadoServicio.completada;
  int getIdServicio() => idServicio!;


  @override
  String toString() {
    return 'Servicio{id: $idServicio, nombre: $nombre, estado: ${estadoServicio.displayName}, empleado: $nombreEmpleadoAsignado}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Servicio &&
        other.idServicio == idServicio &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.categoriaServicio == categoriaServicio &&
        other.localizacionCoordenadas == localizacionCoordenadas &&
        other.estadoServicio == estadoServicio &&
        other.empleadoAsignado == empleadoAsignado &&
        other.duracionReal == duracionReal &&
        other.fechaCreacion == fechaCreacion &&
        other.fechaInicioServicio == fechaInicioServicio &&
        other.fechaFinServicio == fechaFinServicio;
  }

  @override
  int get hashCode {
    return Object.hash(
      idServicio,
      nombre,
      descripcion,
      categoriaServicio,
      localizacionCoordenadas,
      estadoServicio,
      empleadoAsignado,
      duracionReal,
      fechaCreacion,
      fechaInicioServicio,
      fechaFinServicio
    );
  }
}

// FUNCION AUXILIAR PARA PARSEAR COORDENADAS JSON.
Map<String, dynamic>? _parseCoordinatesFromJson(String jsonString) {
  try {
    // PARSEO SIMPLE PARA COORDENADAS CON LATITUD Y LONGITUD EN JSON {"lat": 41.6488, "lng": -0.8891}
    final RegExp latRegex = RegExp(r'"lat"\s*:\s*([+-]?\d*\.?\d+)');
    final RegExp lngRegex = RegExp(r'"lng"\s*:\s*([+-]?\d*\.?\d+)');
    
    final latMatch = latRegex.firstMatch(jsonString);
    final lngMatch = lngRegex.firstMatch(jsonString);
    
    if (latMatch != null && lngMatch != null) {
      return {
        'lat': double.parse(latMatch.group(1)!),
        'lng': double.parse(lngMatch.group(1)!),
      };
    }
  } catch (e) {
    debugPrint('Error parsing coordinates JSON: $e');
  }
  return null;
  
}