import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;


class Empleado {
  final int id;
  final String nombre;
  final String apellidos;
  final String telefono;
  final String email;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.email,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: _parseToInt(json['id_empleado']) ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  String get nombreCompleto => '$nombre $apellidos';
}

class ServicioCompleto {
  final int idServicio;
  final String nombreServicio;
  final String descripcionServicio;
  final String categoriaServicio;
  final String estadoServicio;
  final int? empleadoAsignado;
  final dynamic localizacionCoordenada;
  final int? duracionReal;
  final int? fechaInicioServicio;
  final int? fechaFinServicio;

  final int? idCita;
  final int? fechaHoraCita;
  final int? duracionEstimada;
  final String? comentariosAdicionales;
  final String? estadoCita;
  final String? nombreClienteCompleto;
  final String? nombreEmpleadoAsignado;

  ServicioCompleto({
    required this.idServicio,
    required this.nombreServicio,
    required this.descripcionServicio,
    required this.categoriaServicio,
    required this.estadoServicio,
    this.empleadoAsignado,
    this.localizacionCoordenada,
    this.duracionReal,
    this.fechaInicioServicio,
    this.fechaFinServicio,
    this.idCita,
    this.fechaHoraCita,
    this.duracionEstimada,
    this.comentariosAdicionales,
    this.estadoCita,
    this.nombreClienteCompleto,
    this.nombreEmpleadoAsignado,
  });

  factory ServicioCompleto.fromJson(Map<String, dynamic> json) {
    final cita = json['cita'] as Map<String, dynamic>?;

    return ServicioCompleto(
      idServicio: _parseToInt(json['id_servicio']) ?? 0,
      nombreServicio: json['nombre_servicio']?.toString() ?? '',
      descripcionServicio: json['descripcion_servicio']?.toString() ?? '',
      categoriaServicio: json['categoria_servicio']?.toString() ?? '',
      estadoServicio: json['estado_servicio']?.toString() ?? '',
      empleadoAsignado: _parseToInt(json['empleado_asignado']),
      localizacionCoordenada: json['localizacion_coordenada'],
      duracionReal: _parseToInt(json['duracion_real']),
      fechaInicioServicio: _parseToInt(json['fecha_incio_servicio']),
      fechaFinServicio: _parseToInt(json['fecha_fin_servicio']),
    );
  }

  ServicioCompleto copyWith({
    int? idServicio,
    String? nombreServicio,
    String? descripcionServicio,
    String? categoriaServicio,
    String? estadoServicio,
    int? empleadoAsignado,
    dynamic localizacionCoordenada,
    int? duracionReal,
    int? fechaInicioServicio,
    int? fechaFinServicio,
    int? idCita,
    int? fechaHoraCita,
    int? duracionEstimada,
    String? comentariosAdicionales,
    String? estadoCita,
    String? nombreClienteCompleto,
    String? nombreEmpleadoAsignado,
  }) {
    return ServicioCompleto(
      idServicio: idServicio ?? this.idServicio,
      nombreServicio: nombreServicio ?? this.nombreServicio,
      descripcionServicio: descripcionServicio ?? this.descripcionServicio,
      categoriaServicio: categoriaServicio ?? this.categoriaServicio,
      estadoServicio: estadoServicio ?? this.estadoServicio,
      empleadoAsignado: empleadoAsignado ?? this.empleadoAsignado,
      localizacionCoordenada:
          localizacionCoordenada ?? this.localizacionCoordenada,
      duracionReal: duracionReal ?? this.duracionReal,
      fechaInicioServicio: fechaInicioServicio ?? this.fechaInicioServicio,
      fechaFinServicio: fechaFinServicio ?? this.fechaFinServicio,
      idCita: idCita ?? this.idCita,
      fechaHoraCita: fechaHoraCita ?? this.fechaHoraCita,
      duracionEstimada: duracionEstimada ?? this.duracionEstimada,
      comentariosAdicionales:
          comentariosAdicionales ?? this.comentariosAdicionales,
      estadoCita: estadoCita ?? this.estadoCita,
      nombreClienteCompleto:
          nombreClienteCompleto ?? this.nombreClienteCompleto,
      nombreEmpleadoAsignado:
          nombreEmpleadoAsignado ?? this.nombreEmpleadoAsignado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_servicio': idServicio,
      'nombre_servicio': nombreServicio,
      'descripcion_servicio': descripcionServicio,
      'categoria_servicio': categoriaServicio,
      'estado_servicio': estadoServicio,
      'empleado_asignado': empleadoAsignado,
      'localizacion_coordenada': localizacionCoordenada,
      'duracion_real': duracionReal,
      'fecha_incio_servicio': fechaInicioServicio,
      'fecha_fin_servicio': fechaFinServicio,
      'id_cita': idCita,
      'fecha_hora_cita': fechaHoraCita,
      'duracion_estimada': duracionEstimada,
      'comentarios_adicionales': comentariosAdicionales,
      'estado_cita': estadoCita,
      'nombre_cliente_completo': nombreClienteCompleto,
      'nombre_empleado_asignado': nombreEmpleadoAsignado,
    };
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  DateTime? get fechaHoraDateTime {
    if (fechaHoraCita != null) {
      return DateTime.fromMillisecondsSinceEpoch(fechaHoraCita!);
    }
    return null;
  }

  String get fechaHoraFormateada {
    final fecha = fechaHoraDateTime;
    if (fecha != null) {
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    }
    return 'No especificada';
  }
}

class ScreenPruebaServicio extends StatefulWidget {
  final int servicioId;

  const ScreenPruebaServicio({Key? key, required this.servicioId})
      : super(key: key);

  @override
  _ScreenEstadoPruebaServicio createState() => _ScreenEstadoPruebaServicio();
}

class _ScreenEstadoPruebaServicio extends State<ScreenPruebaServicio> {

  bool _cargandoUbicacion = false;
  final TextEditingController _comentariosController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _direccionEspecificaController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Variables del servicio
  ServicioCompleto? _servicioActual;
  List<Empleado> _empleados = [];
  Empleado? _empleadoAsignado;
  bool _cargandoDatos = true;

  late Dio _dio;

  GoogleMapController? _mapController;
  Set<Marker> _marcadores = {};
  Set<Circle> _circulos = {};
  Timer? _searchTimer;
  Timer? _debounceTimer;

  // Ubicaciones y configuración del mapa
  LatLng _ubicacionZaragoza = LatLng(41.6488, -0.8891);
  LatLng? _ubicacionSeleccionada;
  bool _mostrandoRutaOptimizada = false;

  // Estados del mapa
  bool _mapaInicializado = false;
  bool _ubicacionConfirmada = false;
  MapType _tipoMapa = MapType.normal;
  double _zoomActual = 14.0;

  List<String> _sugerenciasDireccion = [];
  bool _mostrandoSugerencias = false;
  String _ultimaBusqueda = '';

  @override
  void initState() {
    super.initState();
    _initializeDio();
    _inicializarMapaAvanzado();
    _cargarDatosIniciales();
  }

  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = 'http://localhost:8080/api_coldman/v1';
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _direccionEspecificaController.dispose();
    _comentariosController.dispose();
    _mapController?.dispose();
    _searchTimer?.cancel();
    _debounceTimer?.cancel();
    _dio.close();
    super.dispose();
  }

  void _inicializarMapaAvanzado() {
    debugPrint('=== INICIALIZANDO MAPA AVANZADO COLDMAN ===');

    _agregarMarcadorZaragoza();
    _agregarCirculoAreaServicio();
  }

  void _agregarMarcadorZaragoza() {
    _marcadores.add(
      Marker(
        markerId: MarkerId('zaragoza_centro'),
        position: _ubicacionZaragoza,
        infoWindow: InfoWindow(
          title: 'Zaragoza Centro',
          snippet: 'Área principal de servicio COLDMAN',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  void _agregarCirculoAreaServicio() {
    _circulos.add(
      Circle(
        circleId: CircleId('area_servicio_coldman'),
        center: _ubicacionZaragoza,
        radius: 25000,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 2,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    debugPrint('=== MAPA GOOGLE CREADO ===');
    _mapController = controller;

    setState(() {
      _mapaInicializado = true;
    });

    if (_servicioActual?.localizacionCoordenada != null) {
      _cargarCoordenadasExistentes();
    } else {
      _centrarMapaEnZaragoza();
    }
  }

  void _centrarMapaEnZaragoza() {
    if (_mapController != null) {
      debugPrint('Centrando mapa en Zaragoza');
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _ubicacionZaragoza,
            zoom: _zoomActual,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    }
  }

  void _seleccionarUbicacionEnMapa(LatLng ubicacion) async {
    debugPrint('=== 🎯 CLICK EN MAPA DETECTADO ===');
    debugPrint('Coordenadas: ${ubicacion.latitude}, ${ubicacion.longitude}');

    setState(() {
      _ubicacionSeleccionada = ubicacion;
      _ubicacionConfirmada = true;
      _cargandoUbicacion = true;
    });

    try {
      String direccionReal =
          await _obtenerDireccionDeCoordenadasNominatim(ubicacion);

      setState(() {
        _direccionEspecificaController.text = direccionReal;

        // LIMPIAR Y AGREGAR MARCADOR NUEVO
        _marcadores.clear();
        _agregarMarcadorZaragoza();
        _marcadores.add(
          Marker(
            markerId: MarkerId('ubicacion_manual_persistente'),
            position: ubicacion,
            infoWindow: InfoWindow(
              title: 'Ubicación marcada manualmente',
              snippet: direccionReal,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      });

      _agregarDireccionAComentarios(
          'Ubicación marcada manualmente: $direccionReal');
      _mostrarMensajeExito('📍 Ubicación marcada manualmente');
    } catch (e) {
      debugPrint('Error obteniendo dirección manual: $e');

      setState(() {
        String coordenadas =
            'Lat: ${ubicacion.latitude.toStringAsFixed(4)}, Lng: ${ubicacion.longitude.toStringAsFixed(4)}';
        _direccionEspecificaController.text = 'Ubicación manual - $coordenadas';

        _marcadores.clear();
        _agregarMarcadorZaragoza();

        _marcadores.add(
          Marker(
            markerId: MarkerId('ubicacion_coordenadas_persistente'),
            position: ubicacion,
            infoWindow: InfoWindow(
              title: 'Ubicación manual',
              snippet: coordenadas,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      });

      _agregarDireccionAComentarios(
          'Ubicación marcada manualmente: ${ubicacion.latitude.toStringAsFixed(4)}, ${ubicacion.longitude.toStringAsFixed(4)}');
    } finally {
      setState(() {
        _cargandoUbicacion = false;
      });
    }
  }

  // ACTUALIZAR MAPA CON UBICACIÓN ENCONTRADA (USANDO TU LÓGICA)
  Future<void> _actualizarMapaConUbicacion(
      LatLng coordenadas, String direccion) async {
    try {
      setState(() {
        _ubicacionSeleccionada = coordenadas;
        _ubicacionConfirmada = true;

        // ACTUALIZAR CAMPO DE DIRECCIÓN
        _direccionEspecificaController.text = direccion;

        // ACTUALIZAR MARCADOR
        _marcadores.clear();
        _agregarMarcadorZaragoza();

        _marcadores.add(
          Marker(
            markerId: MarkerId('ubicacion_encontrada'),
            position: coordenadas,
            infoWindow: InfoWindow(
              title: 'Ubicación del servicio',
              snippet: direccion,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );
      });

      // ANIMACIÓN DE LA CÁMARA
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(coordenadas, 16.0),
        );
      }

      // AGREGAR AUTOMÁTICAMENTE A COMENTARIOS
      _agregarDireccionAComentarios('Dirección del servicio: $direccion');
    } catch (e) {
      debugPrint('Error actualizando mapa: $e');
    }
  }

  void _verificarAreaDeServicio(LatLng posicion) {
    double distancia = _calcularDistancia(_ubicacionZaragoza, posicion);

    if (distancia > 25) {
      _mostrarAdvertenciaAreaServicio();
    }
  }

  double _calcularDistancia(LatLng punto1, LatLng punto2) {
    double deltaLat =
        (punto2.latitude - punto1.latitude) * 111.32; 
    double deltaLng = (punto2.longitude - punto1.longitude) *
        111.32 *
        (math.cos(punto1.latitude * math.pi / 180));

    return math.sqrt(deltaLat * deltaLat + deltaLng * deltaLng);
  }

  void _mostrarAdvertenciaAreaServicio() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Esta ubicación está fuera del área de servicio habitual de Aragón'),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _buscarDireccionAvanzada(String direccion) async {
    direccion = direccion.trim();

    if (direccion.isEmpty ||
        direccion.length < 3 ||
        direccion == _ultimaBusqueda) {
      debugPrint('Dirección muy corta o vacía: "$direccion"');
      return;
    }

    _ultimaBusqueda = direccion;

    debugPrint('=== BUSQUEDA AVANZADA DE DIRECCION COLDMAN ===');
    debugPrint('Buscando: "$direccion"');

    setState(() {
      _cargandoUbicacion = true;
      _mostrandoSugerencias = false;
    });

    String direccionOriginal = direccion;

    try {
      LatLng? coordenadas = await _buscarConGeocodingNativo(direccionOriginal);

      if (coordenadas != null &&
          _estaEnAragon(coordenadas.latitude, coordenadas.longitude)) {
        debugPrint('✅ Encontrado exacto en Aragón');
        await _procesarUbicacionEncontrada(coordenadas, direccionOriginal);
        _mostrarMensajeExito('Ubicación encontrada exactamente');
        return;
      }

      List<String> aproximacionesAragon =
          _generarAproximacionesProgresivas(direccionOriginal);

      for (String aproximacion in aproximacionesAragon) {
        coordenadas = await _buscarConGeocodingNativo(aproximacion);

        if (coordenadas != null &&
            _estaEnAragon(coordenadas.latitude, coordenadas.longitude)) {
          debugPrint('Encontrado con aproximación: $aproximacion');
          await _manejarResultadoAproximado(
              coordenadas, aproximacion, direccionOriginal);
          return;
        }

        await Future.delayed(Duration(milliseconds: 250));
      }

      coordenadas = await _buscarConNominatimAragon(direccionOriginal);

      if (coordenadas != null &&
          _estaEnAragon(coordenadas.latitude, coordenadas.longitude)) {
        debugPrint('Encontrado con Nominatim Aragón');
        String direccionFormateada =
            await _obtenerDireccionDeCoordenadasNominatim(coordenadas);
        await _manejarResultadoAproximado(
            coordenadas, direccionFormateada, direccionOriginal);
        return;
      }

      await _manejarDireccionNoEncontradaAragon(direccionOriginal);
    } catch (e) {
      debugPrint('💥 Error en búsqueda avanzada: $e');
      await _manejarDireccionNoEncontradaAragon(direccionOriginal);
    } finally {
      setState(() {
        _cargandoUbicacion = false;
      });
    }
  }

  Future<LatLng?> _buscarConGeocodingNativo(String direccion) async {
    try {
      List<String> variaciones = [
        direccion,
        '$direccion, Zaragoza, España',
        '$direccion, Aragón, España',
        '$direccion, España',
      ];

      for (String variacion in variaciones) {
        try {
          List<Location> locations = await locationFromAddress(variacion);
          if (locations.isNotEmpty) {
            LatLng coordenadas =
                LatLng(locations.first.latitude, locations.first.longitude);

            if (coordenadas.latitude > 35.0 &&
                coordenadas.latitude < 45.0 &&
                coordenadas.longitude > -10.0 &&
                coordenadas.longitude < 5.0) {
              return coordenadas;
            }
          }
        } catch (e) {
          continue;
        }

        await Future.delayed(Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Error en geocoding nativo: $e');
    }
    return null;
  }

  bool _estaEnAragon(double lat, double lng) {
    return lat >= 39.8 && lat <= 42.8 && lng >= -2.0 && lng <= 0.8;
  }

  List<String> _generarAproximacionesProgresivas(String direccionOriginal) {
    List<String> aproximaciones = [];
    String direccion = direccionOriginal.toLowerCase().trim();

    debugPrint(
        'Generando aproximaciones progresivas para: $direccionOriginal');

    String sinPisos = _quitarSoloPisos(direccionOriginal);
    if (sinPisos != direccionOriginal) {
      aproximaciones.addAll([
        '$sinPisos, Zaragoza',
        '$sinPisos, Huesca',
        '$sinPisos, Teruel',
        sinPisos,
      ]);
    }

    String sinNumeros = _quitarNumerosYPisos(direccionOriginal);
    if (sinNumeros != sinPisos && sinNumeros != direccionOriginal) {
      aproximaciones.addAll([
        '$sinNumeros, Zaragoza',
        '$sinNumeros, Huesca',
        '$sinNumeros, Teruel',
        sinNumeros,
      ]);
    }

    if (direccion.contains('alfonso i') || direccion.contains('alfonso 1')) {
      aproximaciones.addAll([
        'Calle Alfonso I el Batallador, Zaragoza',
        'Calle Alfonso I, Zaragoza',
        'Alfonso I, Zaragoza',
      ]);
    }

    if (direccion.contains('independencia')) {
      aproximaciones.addAll([
        'Paseo de la Independencia, Zaragoza',
        'Paseo Independencia, Zaragoza',
        'Independencia, Zaragoza',
      ]);
    }

    return aproximaciones.toSet().toList();
  }

  String _quitarSoloPisos(String direccionOriginal) {
    String direccion = direccionOriginal;

    List<String> patronesPisos = [
      r',\s*\d+[ºª°]\s*[A-Za-z]?$',
      r',\s*\d+\s+(derecha|dcha|izquierda|izda|centro)$',
      r',\s*(bajo|entresuelo|ático|principal)(\s+[A-Za-z])?$',
    ];

    for (String patron in patronesPisos) {
      direccion =
          direccion.replaceAll(RegExp(patron, caseSensitive: false), '');
    }

    return direccion.trim();
  }

  String _quitarNumerosYPisos(String direccionOriginal) {
    String direccion = _quitarSoloPisos(direccionOriginal);
    direccion = direccion.replaceAll(RegExp(r',\s*\d+\s*$'), '');
    return direccion.trim();
  }

  Future<LatLng?> _buscarConNominatimAragon(String direccionOriginal) async {
    try {
      List<String> consultasAragon =
          _generarConsultasEspecificasAragon(direccionOriginal);

      for (String consulta in consultasAragon) {
        try {
          String encodedQuery = Uri.encodeComponent(consulta);
          String url = 'https://nominatim.openstreetmap.org/search?'
              'q=$encodedQuery&'
              'format=json&'
              'limit=3&'
              'countrycodes=es&'
              'addressdetails=1&'
              'bounded=1&'
              'viewbox=-2.0,43.0,1.0,39.5&'
              'accept-language=es';

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'COLDMAN-App/1.0',
              'Accept': 'application/json',
            },
          ).timeout(Duration(seconds: 6));

          if (response.statusCode == 200) {
            List<dynamic> results = json.decode(response.body);

            if (results.isNotEmpty) {
              for (var resultado in results) {
                double lat = double.parse(resultado['lat'].toString());
                double lon = double.parse(resultado['lon'].toString());

                if (_estaEnAragon(lat, lon)) {
                  debugPrint('✅ Nominatim Aragón encontró: $consulta');
                  return LatLng(lat, lon);
                }
              }
            }
          }
        } catch (e) {
          continue;
        }

        await Future.delayed(Duration(milliseconds: 800));
      }
    } catch (e) {
      debugPrint('Error en Nominatim Aragón: $e');
    }
    return null;
  }

  List<String> _generarConsultasEspecificasAragon(String direccionOriginal) {
    List<String> consultas = [];
    String direccionBase = _extraerDireccionBase(direccionOriginal);

    consultas.addAll([
      '$direccionBase, Zaragoza, Aragón, España',
      '$direccionBase, Zaragoza, España',
      '$direccionBase Zaragoza',
      '$direccionBase, Huesca, Aragón, España',
      '$direccionBase, Huesca, España',
      '$direccionBase Huesca',
      '$direccionBase, Teruel, Aragón, España',
      '$direccionBase, Teruel, España',
      '$direccionBase Teruel',
    ]);

    return consultas;
  }

  String _extraerDireccionBase(String direccionCompleta) {
    String direccion = direccionCompleta;

    List<String> patronesPisos = [
      r',\s*\d+[ºª°]\s*[A-Za-z]?$',
      r',\s*\d+\s+(derecha|izquierda|centro)$',
      r',\s*(bajo|entresuelo|ático|principal)$',
      r',\s*\d+[ºª°]\s*$',
    ];

    for (String patron in patronesPisos) {
      direccion =
          direccion.replaceAll(RegExp(patron, caseSensitive: false), '');
    }

    return direccion.trim();
  }

  Future<void> _procesarUbicacionEncontrada(
      LatLng ubicacion, String direccionUsada) async {
    debugPrint('✅ Ubicación encontrada con: $direccionUsada');

    setState(() {
      _ubicacionSeleccionada = ubicacion;
      _ubicacionConfirmada = true;
      _direccionEspecificaController.text = direccionUsada;
    });

    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: ubicacion,
            zoom: 17.0,
            tilt: 45.0,
          ),
        ),
      );
    }

    _agregarMarcadorServicio(ubicacion, direccionUsada);
    _agregarDireccionAComentarios('Dirección del servicio: $direccionUsada');
  }

  void _agregarMarcadorServicio(LatLng ubicacion, String direccion) {
    debugPrint(
        '🎯 Agregando marcador de servicio en: ${ubicacion.latitude}, ${ubicacion.longitude}');

    setState(() {
      _marcadores.clear();
      _agregarMarcadorZaragoza();

      _marcadores.add(
        Marker(
          markerId: MarkerId('ubicacion_encontrada'),
          position: ubicacion,
          infoWindow: InfoWindow(
            title: 'Ubicación del servicio',
            snippet: direccion,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });

    debugPrint('Marcador de servicio agregado correctamente');
  }

  Future<void> _manejarResultadoAproximado(LatLng coordenadas,
      String direccionEncontrada, String direccionOriginal) async {
    try {
      await _procesarUbicacionEncontrada(coordenadas, direccionEncontrada);
      _agregarDireccionOriginalAComentarios(
          direccionOriginal, direccionEncontrada);
      _mostrarMensajeAproximacion('Ubicación aproximada encontrada');

      debugPrint('Resultado limpio:');
      debugPrint('→ En barra: $direccionEncontrada');
      debugPrint('→ En comentarios: $direccionOriginal');
    } catch (e) {
      debugPrint('Error manejando resultado aproximado: $e');
    }
  }

  void _agregarDireccionOriginalAComentarios(
      String direccionOriginal, String direccionEncontrada) {
    String comentarioActual = _comentariosController.text;
    String comentarioNuevo =
        'Dirección específica original: $direccionOriginal';

    if (!comentarioActual.contains(comentarioNuevo)) {
      if (comentarioActual.isEmpty) {
        _comentariosController.text = comentarioNuevo;
      } else {
        _comentariosController.text = '$comentarioActual\n$comentarioNuevo';
      }
    }
  }

  Future<void> _manejarDireccionNoEncontradaAragon(
      String direccionOriginal) async {
    LatLng zaragozaCentro = LatLng(41.6488, -0.8891);
    await _actualizarMapaConUbicacionPersistente(
        zaragozaCentro, 'Zaragoza, Aragón');

    _agregarDireccionAComentarios(
        'Dirección no encontrada automáticamente: $direccionOriginal');
    _mostrarMensajeInfo(
        '📍 Ubicación centrada en Zaragoza. Ajusta manualmente si es necesario.');

    debugPrint(
        '📝 Dirección "$direccionOriginal" agregada a comentarios (no encontrada en Aragón)');
  }

  Future<void> _actualizarMapaConUbicacionPersistente(
      LatLng coordenadas, String direccion) async {
    try {
      setState(() {
        _ubicacionSeleccionada = coordenadas;
        _ubicacionConfirmada = true;
        _direccionEspecificaController.text = direccion;

        _marcadores.removeWhere(
            (marker) => marker.markerId.value.startsWith('servicio_'));

        _marcadores.add(
          Marker(
            markerId: MarkerId('servicio_ubicacion_persistente'),
            position: coordenadas,
            infoWindow: InfoWindow(
              title: 'Ubicación del servicio',
              snippet: direccion,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            onTap: () {
              debugPrint('Marcador persistente - Ubicación confirmada');
            },
          ),
        );
      });

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(coordenadas, 16.0),
        );
      }

      debugPrint(
          '🎯 Marcador persistente colocado en: ${coordenadas.latitude}, ${coordenadas.longitude}');
    } catch (e) {
      debugPrint('Error actualizando mapa persistente: $e');
    }
  }

  Future<String> _obtenerDireccionDeCoordenadasNominatim(
      LatLng coordenadas) async {
    try {
      String url = 'https://nominatim.openstreetmap.org/reverse?'
          'lat=${coordenadas.latitude}&'
          'lon=${coordenadas.longitude}&'
          'format=json&'
          'addressdetails=1&'
          'accept-language=es';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'COLDMAN-App/1.0',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 8));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['address'] != null) {
          Map<String, dynamic> address = data['address'];

          List<String> partes = [];

          if (address['house_number'] != null && address['road'] != null) {
            partes.add('${address['road']} ${address['house_number']}');
          } else if (address['road'] != null) {
            partes.add(address['road']);
          }

          if (address['city'] != null) {
            partes.add(address['city']);
          } else if (address['town'] != null) {
            partes.add(address['town']);
          } else if (address['village'] != null) {
            partes.add(address['village']);
          }

          if (address['state'] != null) {
            partes.add(address['state']);
          }

          String direccionFormateada = partes.join(', ');
          return direccionFormateada.isNotEmpty
              ? direccionFormateada
              : data['display_name'];
        }
      }
    } catch (e) {
      debugPrint('Error en reverse geocoding: $e');
    }
    return 'Zaragoza, España - Lat: ${coordenadas.latitude.toStringAsFixed(4)}, Lng: ${coordenadas.longitude.toStringAsFixed(4)}';
  }

  void _agregarDireccionAComentarios(String nuevaDireccion) {
    String comentarioActual = _comentariosController.text;

    if (!comentarioActual.contains(nuevaDireccion)) {
      if (comentarioActual.isEmpty) {
        _comentariosController.text = nuevaDireccion;
      } else {
        _comentariosController.text = '$comentarioActual\n$nuevaDireccion';
      }
    }
  }

  void _cambiarTipoMapa() {
    setState(() {
      switch (_tipoMapa) {
        case MapType.normal:
          _tipoMapa = MapType.satellite;
          break;
        case MapType.satellite:
          _tipoMapa = MapType.hybrid;
          break;
        case MapType.hybrid:
          _tipoMapa = MapType.terrain;
          break;
        case MapType.terrain:
          _tipoMapa = MapType.normal;
          break;
        case MapType.none:
          _tipoMapa = MapType.none;
      }
    });

    String tipoTexto = _tipoMapa.toString().split('.').last;
    _mostrarMensajeInfo('Mapa cambiado a: ${tipoTexto.toUpperCase()}');
  }

  void _centrarEnUbicacionActual() {
    _centrarMapaEnZaragoza();
    _mostrarMensajeInfo('🎯 Centrado en área de servicio');
  }

  void _acercarMapa() {
    if (_mapController != null && _zoomActual < 20) {
      setState(() {
        _zoomActual += 1;
      });

      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _ubicacionSeleccionada ?? _ubicacionZaragoza,
            zoom: _zoomActual,
          ),
        ),
      );
    }
  }

  void _alejarMapa() {
    if (_mapController != null && _zoomActual > 10) {
      setState(() {
        _zoomActual -= 1;
      });

      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _ubicacionSeleccionada ?? _ubicacionZaragoza,
            zoom: _zoomActual,
          ),
        ),
      );
    }
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() {
      _cargandoDatos = true;
    });

    try {
      await Future.wait([
        _cargarServicioCompleto(),
        _cargarEmpleados(),
      ]);

      _prellenarCampos();
    } catch (e) {
      _mostrarMensajeError('Error al cargar datos: $e');
    } finally {
      setState(() {
        _cargandoDatos = false;
      });
    }
  }

  Future<void> _cargarServicioCompleto() async {
    try {
      final response = await _dio.get('/servicios');

      if (response.statusCode == 200) {
        final List<dynamic> servicios = response.data;

        final servicioEncontrado = servicios.firstWhere(
          (servicio) => servicio['id_servicio'] == widget.servicioId,
          orElse: () => null,
        );

        if (servicioEncontrado != null) {
          setState(() {
            _servicioActual = ServicioCompleto.fromJson(servicioEncontrado);
          });
        } else {
          _mostrarMensajeError(
              'No se encontró el servicio con ID ${widget.servicioId}');
        }
      }
    } on DioException catch (e) {
      debugPrint('Error Dio cargando servicio: ${e.message}');
      _mostrarMensajeError('Error de conexión: ${e.message}');
    } catch (e) {
      debugPrint('Error general cargando servicio completo: $e');
      _mostrarMensajeError('Error inesperado: $e');
    }
  }

  Future<void> _cargarEmpleados() async {
    try {
      final response = await _dio.get('/empleados');

      if (response.statusCode == 200) {
        final List<dynamic> empleadosData = response.data;
        setState(() {
          _empleados =
              empleadosData.map((json) => Empleado.fromJson(json)).toList();

          if (_servicioActual?.empleadoAsignado != null) {
            final empleadosEncontrados = _empleados.where(
              (emp) => emp.id == _servicioActual!.empleadoAsignado,
            );
            _empleadoAsignado = empleadosEncontrados.isNotEmpty
                ? empleadosEncontrados.first
                : null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando empleados: $e');
    }
  }

  void _prellenarCampos() {
    if (_servicioActual != null) {
      String comentarios = _servicioActual?.comentariosAdicionales ?? '';

      RegExp direccionRegex = RegExp(r'Dirección: (.+?)(?:\n|$)');
      Match? match = direccionRegex.firstMatch(comentarios);
      if (match != null) {
        _direccionController.text = match.group(1) ?? '';
        _direccionEspecificaController.text = match.group(1) ?? '';
      }

      if (_servicioActual?.localizacionCoordenada != null) {
        _cargarCoordenadasExistentes();
      }
    }
  }

  void _cargarCoordenadasExistentes() {
    String coordenadas = _servicioActual!.localizacionCoordenada!;
    List<String> partes = coordenadas.split(',');
    if (partes.length == 2) {
      double lat = double.tryParse(partes[0]) ?? _ubicacionZaragoza.latitude;
      double lng = double.tryParse(partes[1]) ?? _ubicacionZaragoza.longitude;

      LatLng ubicacion = LatLng(lat, lng);
      _seleccionarUbicacionEnMapa(ubicacion);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: ubicacion, zoom: 16.0),
          ),
        );
      }
    }
  }

  Future<void> _actualizarServicio() async {
    if (_servicioActual == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String direccionCompleta = _direccionController.text;
      if (_direccionEspecificaController.text.isNotEmpty) {
        direccionCompleta = _direccionEspecificaController.text;
      }

      String comentariosActualizados =
          _construirComentariosActualizados(direccionCompleta);

      final coordenadasCorrectas = _ubicacionSeleccionada != null
          ? {
              'lat': _ubicacionSeleccionada!.latitude,
              'lng': _ubicacionSeleccionada!.longitude,
            }
          : null;

      final servicioActualizado = _servicioActual!.copyWith(
        empleadoAsignado: _empleadoAsignado?.id,
        localizacionCoordenada: coordenadasCorrectas,
        descripcionServicio: comentariosActualizados,
        estadoServicio: 'PROGRESANDO',
      );

      final Map<String, dynamic> datosActualizados =
          servicioActualizado.toJson();

      final response = await _dio.put('/servicios/${widget.servicioId}',
          data: datosActualizados);

      if (response.statusCode == 200) {
        _mostrarMensajeExito('Servicio asignado correctamente');
        Navigator.pop(context, true);
      } else {
        _mostrarMensajeError('Error al actualizar el servicio');
      }
    } catch (e) {
      _mostrarMensajeError('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _construirComentariosActualizados(String direccionCompleta) {
    String comentarios = _servicioActual?.descripcionServicio ?? '';

    comentarios += '\n\n--- INFORMACIÓN DE ASIGNACIÓN ---\n';
    comentarios += 'Dirección específica: $direccionCompleta\n';

    if (_comentariosController.text.isNotEmpty) {
      comentarios +=
          'Indicaciones adicionales: ${_comentariosController.text}\n';
    }

    if (_empleadoAsignado != null) {
      comentarios +=
          'Empleado asignado: ${_empleadoAsignado!.nombreCompleto}\n';
    }

    if (_ubicacionSeleccionada != null) {
      comentarios +=
          'Coordenadas: ${_ubicacionSeleccionada!.latitude}, ${_ubicacionSeleccionada!.longitude}\n';
    }

    comentarios +=
        'Fecha de asignación: ${DateTime.now().toString().split(' ')[0]}';

    return comentarios;
  }

  void _confirmarSolicitud() {
    if (_formKey.currentState?.validate() ?? false) {
      _actualizarServicio();
    }
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
                child: Text(mensaje,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _mostrarMensajeAproximacion(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
                child: Text(mensaje,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _mostrarMensajeInfo(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
                child: Text(mensaje, style: TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.blue[600],
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildMapWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ubicación en el Mapa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              _buildMapControls(),
            ],
          ),
          SizedBox(height: 8),

          // Estado de la ubicación
          if (_ubicacionConfirmada)
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ubicación confirmada en el mapa',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Zoom: ${_zoomActual.toInt()}x',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // MAPA PRINCIPAL - SIN WIDGETS ENCIMA QUE BLOQUEEN CLICKS
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      setState(() {
                        _mapaInicializado = true;
                      });

                      if (_servicioActual?.localizacionCoordenada != null) {
                        _cargarCoordenadasExistentes();
                      } else {
                        _centrarMapaEnZaragoza();
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: _ubicacionZaragoza,
                      zoom: _zoomActual,
                    ),
                    markers: _marcadores,
                    circles: _circulos,
                    onTap: _seleccionarUbicacionEnMapa,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    trafficEnabled: false,
                    buildingsEnabled: true,
                    indoorViewEnabled: true,
                    mapType: _tipoMapa,
                    onCameraMove: (CameraPosition position) {
                      _zoomActual = position.zoom;
                    },
                  ),

                  // INDICADOR DE CARGA - SOLO CUANDO ESTÁ CARGANDO
                  if (_cargandoUbicacion)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Buscando ubicación...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),

          // CONTROLES DEL MAPA DEBAJO (NO ENCIMA) PARA NO BLOQUEAR CLICKS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMapControlButton(
                label: 'Normal',
                icon: Icons.map,
                isActive: _tipoMapa == MapType.normal,
                onPressed: () {
                  setState(() {
                    _tipoMapa = MapType.normal;
                  });
                  _mostrarMensajeInfo('Vista: Normal');
                },
              ),
              _buildMapControlButton(
                label: 'Satélite',
                icon: Icons.satellite,
                isActive: _tipoMapa == MapType.satellite,
                onPressed: () {
                  setState(() {
                    _tipoMapa = MapType.satellite;
                  });
                  _mostrarMensajeInfo('Vista: Satélite');
                },
              ),
              _buildMapControlButton(
                label: 'Centrar',
                icon: Icons.my_location,
                isActive: false,
                onPressed: _centrarMapaEnZaragoza,
              ),
            ],
          ),

          SizedBox(height: 8),

          _buildMapInfo(),

          if (_ubicacionSeleccionada != null)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : Colors.blue[700],
          ),
          label: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : Colors.blue[700],
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.blue[700] : Colors.blue[50],
            elevation: isActive ? 3 : 1,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _mapaInicializado ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _mapaInicializado ? Icons.check_circle : Icons.refresh,
                size: 12,
                color:
                    _mapaInicializado ? Colors.green[600] : Colors.orange[600],
              ),
              SizedBox(width: 4),
              Text(
                _mapaInicializado ? 'Listo' : 'Cargando...',
                style: TextStyle(
                  fontSize: 10,
                  color: _mapaInicializado
                      ? Colors.green[600]
                      : Colors.orange[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildMapInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Instrucciones del Mapa',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Toca en el mapa para marcar la ubicación exacta del servicio\n'
            '• Arrastra el marcador rojo para ajustar la posición\n'
            '• El círculo azul indica el área de cobertura de COLDMAN\n'
            '• Usa los controles para cambiar la vista y hacer zoom',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue[700],
              height: 1.3,
            ),
          ),
          if (_ubicacionSeleccionada != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordenadas seleccionadas:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Lat: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Lng: ${_ubicacionSeleccionada!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDireccionFields() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dirección del Servicio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),

          if (_direccionController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dirección registrada del cliente:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _direccionController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _direccionEspecificaController,
                  decoration: InputDecoration(
                    labelText: 'Dirección específica (piso, puerta, etc.)',
                    hintText: 'Ej: Calle Alfonso I, 25, 2º B',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon:
                        Icon(Icons.location_on, color: Colors.blue[400]),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_cargandoUbicacion)
                          Container(
                            width: 20,
                            height: 20,
                            margin: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.blue[600]),
                            onPressed: () {
                              String direccion =
                                  _direccionEspecificaController.text.trim();
                              if (direccion.length > 3) {
                                _buscarDireccionAvanzada(direccion);
                              } else {
                                _mostrarMensajeError(
                                    'Por favor ingresa al menos 4 caracteres para buscar');
                              }
                            },
                            tooltip: 'Buscar en mapa',
                          ),
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _direccionEspecificaController.clear();
                            setState(() {
                              _mostrandoSugerencias = false;
                              _ubicacionSeleccionada = null;
                              _ubicacionConfirmada = false;
                              _marcadores.removeWhere((marker) => marker
                                  .markerId.value
                                  .startsWith('servicio_'));
                            });
                          },
                          tooltip: 'Limpiar',
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (value) {
                    if (_debounceTimer != null) {
                      _debounceTimer!.cancel();
                    }

                    if (value.trim().length > 3) {
                      _debounceTimer = Timer(Duration(milliseconds: 2000), () {
                        _buscarDireccionAvanzada(value.trim());
                      });
                    } else {
                      setState(() {
                        _mostrandoSugerencias = false;
                        _sugerenciasDireccion.clear();
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la dirección específica';
                    }
                    return null;
                  },
                ),

                // Sugerencias de direcciones
                if (_mostrandoSugerencias && _sugerenciasDireccion.isNotEmpty)
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxHeight: 150),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sugerenciasDireccion.length,
                      itemBuilder: (context, index) {
                        final sugerencia = _sugerenciasDireccion[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          title: Text(
                            sugerencia,
                            style: TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            _direccionEspecificaController.text = sugerencia;
                            setState(() {
                              _mostrandoSugerencias = false;
                            });
                            _buscarDireccionAvanzada(sugerencia);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Botones de acción rápida
          Wrap(
            spacing: 8,
            children: [
              _buildQuickActionChip(
                label: 'Centrar en Zaragoza',
                icon: Icons.location_city,
                onPressed: _centrarMapaEnZaragoza,
              ),
              if (_ubicacionSeleccionada != null)
                _buildQuickActionChip(
                  label: 'Limpiar ubicación',
                  icon: Icons.clear_all,
                  onPressed: () {
                    setState(() {
                      _ubicacionSeleccionada = null;
                      _ubicacionConfirmada = false;
                      _marcadores.removeWhere((marker) =>
                          marker.markerId.value.startsWith('servicio_'));
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
      onPressed: onPressed,
      backgroundColor: Colors.blue[50],
      side: BorderSide(color: Colors.blue[200]!),
    );
  }

  // ===== WIDGETS EXISTENTES ADAPTADOS =====

  Widget _buildInfoServicio() {
    if (_servicioActual == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center, color: Colors.blue[800], size: 20),
              SizedBox(width: 8),
              Text(
                'Información del Servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow('ID Servicio', '${_servicioActual!.idServicio}'),
          _buildInfoRow('Categoría', _servicioActual!.categoriaServicio),
          _buildInfoRow('Estado', _servicioActual!.estadoServicio),
          if (_servicioActual!.fechaHoraFormateada != 'No especificada')
            _buildInfoRow(
                'Fecha programada', _servicioActual!.fechaHoraFormateada),
          if (_servicioActual!.duracionEstimada != null)
            _buildInfoRow(
                'Duración estimada', '${_servicioActual!.duracionEstimada}h'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteInfo() {
    if (_servicioActual?.nombreClienteCompleto == null)
      return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.orange[800], size: 20),
              SizedBox(width: 8),
              Text(
                'Cliente del Servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _servicioActual!.nombreClienteCompleto!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
          SizedBox(height: 8),
          if (_servicioActual!.estadoCita != null)
            _buildClienteInfoRow(
                Icons.event, 'Estado de cita: ${_servicioActual!.estadoCita}'),
          if (_servicioActual!.comentariosAdicionales != null)
            _buildClienteInfoRow(Icons.comment,
                'Comentarios: ${_servicioActual!.comentariosAdicionales}'),
        ],
      ),
    );
  }

  Widget _buildClienteInfoRow(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange[700]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpleadoDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Empleado Asignado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Empleado>(
                value: _empleadoAsignado,
                hint: Text(
                  'Seleccionar empleado',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.green[800]),
                isExpanded: true,
                items: _empleados.map((Empleado empleado) {
                  return DropdownMenuItem<Empleado>(
                    value: empleado,
                    child: Text(
                      '${empleado.nombreCompleto} - ${empleado.telefono}',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (Empleado? nuevoEmpleado) {
                  setState(() {
                    _empleadoAsignado = nuevoEmpleado;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComentariosField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicaciones Adicionales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: TextFormField(
              controller: _comentariosController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Indicaciones para el técnico:\n• Cómo acceder al lugar\n• Códigos de entrada\n• Horarios especiales\n• Observaciones importantes...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmarButton() {
    return Container(
      margin: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _confirmarSolicitud,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Asignando servicio...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in, size: 24, color: Colors.white,),
                    SizedBox(width: 8),
                    Text(
                      'Confirmar Asignación de Servicio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF3B82F6),
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Asignar Servicio',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_servicioActual != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${_servicioActual!.idServicio}',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormTitle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment, color: Colors.blue[800], size: 32),
          SizedBox(height: 8),
          Text(
            'Asignación y Configuración del Servicio',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Completa la información para finalizar la asignación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: _buildAppBar(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Cargando información del servicio...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: _buildAppBar(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo_coldman.png',
                width: 300,
                height: 80,
                fit: BoxFit.contain,
              ),
              _buildFormTitle(),
              _buildInfoServicio(),
              _buildClienteInfo(),
              _buildEmpleadoDropdown(),
              _buildDireccionFields(),
              _buildMapWidget(),
              _buildComentariosField(),
              SizedBox(height: 24),
              _buildConfirmarButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _esUbicacionExacta(
    String direccionOriginal, LatLng coordenadas) async {
  try {
    List<Location> locations = await locationFromAddress(direccionOriginal);

    if (locations.isNotEmpty) {
      LatLng exacta =
          LatLng(locations.first.latitude, locations.first.longitude);

      double diferencia = (exacta.latitude - coordenadas.latitude).abs() +
          (exacta.longitude - coordenadas.longitude).abs();

      return diferencia < 0.001;
    }
  } catch (e) {
    // Si hay error, asumo que no es exacta.
  }
  return false;
}
