import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ScreenAsignarServicio extends StatefulWidget {
  @override
  _ScreenEstadoAsignarServicio createState() => _ScreenEstadoAsignarServicio();
}

// VERIFICAR SI LA UBICACIÓN ENCONTRADA ES EXACTA.
Future<bool> _esUbicacionExacta(
    String direccionOriginal, LatLng coordenadas) async {
  try {
    LatLng? exacta = await locationFromAddress(direccionOriginal).then(
        (locations) => locations.isNotEmpty
            ? LatLng(locations.first.latitude, locations.first.longitude)
            : null);

    if (exacta != null) {
      double diferencia = (exacta.latitude - coordenadas.latitude).abs() +
          (exacta.longitude - coordenadas.longitude).abs();
      return diferencia < 0.001; // MUY PEQUEÑA DIFERENCIA = EXACTA.
    }
  } catch (e) {
    // SI DA ERROR, ASUMIMOS QUE NO ES EXACTA.
  }
  return false;
}

class _ScreenEstadoAsignarServicio extends State<ScreenAsignarServicio> {
  // VARIABLES Y CONTROLLERS PARA LA SOLICITUD DEL SERVICIO ("FORMULARIO").
  bool _cargandoUbicacion = false;
  final TextEditingController _comentariosController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay _horaSeleccionada = TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  double _latitude = 41.6488;
  double _longitude = -0.8891;
  String? _tipoServicioSeleccionado;

  // VARIABLES DEL MAPA.
  GoogleMapController? _mapController;
  Set<Marker> _marcadores = {};
  List<String> _mensajes = [];
  Timer? _searchTimer;

  // LISTA DE TIPOS DE SERVICIOS.
  final List<String> _tiposServicios = [
    'Mantenimiento de Aire Acondicionado',
    'Instalación de Aire Acondicionado',
    'Reparación de Aire Acondicionado',
    'Climatización Industrial',
    'Limpieza de Ductos',
    'Revisión Técnica',
    'Servicio de Emergencia',
  ];

  LatLng _ubicacionActual = LatLng(41.6488, -0.8891);
  LatLng? _ubicacionSeleccionada;

  @override
  void dispose() {
    _direccionController.dispose();
    _comentariosController.dispose();
    _mapController?.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _centrarMapaEnZaragoza();
  }

  Future<void> buscarDireccionMejorada() async {
    if (_direccionController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    String busquedaOriginal = _direccionController.text.trim();
  }

  // APP BAR.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.blue[600]),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Solicitar Cita',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPanelBusqueda() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                hintText:
                    'Buscar dirección o lugar (ej: Hospital veterinario valvet)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => (),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => (),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Buscar'),
          ),
        ],
      ),
    );
  }

  // WIDGET PARA COMENTARIOS ADICIONALES DE LA DIRECION DEL SERVICIO, ETC.
  Widget _buildCampoComentarios() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _comentariosController,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: 'Comentarios adicionales para la cita',
          hintText:
              'Agrega detalles específicos, especificaciones adicionales del trabajo o información relevante...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  // LOGO COLDMAN.
  Widget _buildLogo() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: 'COLD', style: TextStyle(color: Colors.blue[600])),
                  TextSpan(
                      text: 'MAN', style: TextStyle(color: Colors.blue[800])),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pro Industrial y Climatización',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TITULO DEL FORMULARIO.
  Widget _buildFormTitle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(
        'Formulario agenda de cita\nTipo de Servicio',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  // DROPDOWN TIPO DE SERVICIO.
  Widget _buildTipoServicioDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Servicio',
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
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.lightBlue[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipoServicioSeleccionado,
              hint: Text(
                'Mantenimiento de Aire Acondicionado',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue[800]),
              isExpanded: true,
              items: _tiposServicios.map((String servicio) {
                return DropdownMenuItem<String>(
                  value: servicio,
                  child: Text(
                    servicio,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? nuevoValor) {
                setState(() {
                  _tipoServicioSeleccionado = nuevoValor;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // CAMPO DIRECCIÓN CON BÚSQUEDA.
  Widget _buildDireccionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dirección de Domicilio',
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
            controller: _direccionController,
            decoration: InputDecoration(
              hintText: 'Buscar direcciones en Aragón',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.lightBlue[400]),
              suffixIcon: _cargandoUbicacion
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(Icons.location_city, color: Colors.blue[600]),
                      onPressed: _centrarMapaEnZaragoza,
                      tooltip: 'Centrar en Zaragoza',
                    ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (value) {
              if (_searchTimer != null) {
                _searchTimer!.cancel();
              }
              _searchTimer = Timer(Duration(milliseconds: 1500), () {
                _buscarDireccion(value);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una dirección';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // MAPA INTERACTIVO GOOGLE CLOUD PLATFORM.
  Widget _buildMapWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _ubicacionActual,
            zoom: 14.0,
          ),
          markers: _marcadores,
          onTap: _seleccionarUbicacionEnMapa,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          compassEnabled: true,
          trafficEnabled: false,
          buildingsEnabled: true,
          indoorViewEnabled: true,
          mapType: MapType.normal,
        ),
      ),
    );
  }

  // SELECTOR DE FECHA Y HORA.
  Widget _buildFechaYHoraSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de la Cita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () => _seleccionarFecha(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightBlue[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.blue[800], size: 20),
                    SizedBox(width: 8),
                    Text(
                      _formatearFecha(_fechaSeleccionada),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.blue[800]),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Hora de la Cita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () => _seleccionarHora(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightBlue[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue[800], size: 20),
                    SizedBox(width: 8),
                    Text(
                      _formatearHora(_horaSeleccionada),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.blue[800]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // CAMPO COMENTARIOS.
  Widget _buildComentariosField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comentarios adicionales para la cita',
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
                  'Agrega detalles específicos, especificaciones adicionales del trabajo o información relevante...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // BOTON CONFIRMAR SERVICIO.
  Widget _buildConfirmarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _confirmarSolicitud,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          'Confirmar solicitud de cita',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // FUNCIONES DE FECHA Y HORA.
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaElegida != null && fechaElegida != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaElegida != null && horaElegida != _horaSeleccionada) {
      setState(() {
        _horaSeleccionada = horaElegida;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  // FUNCIONES DEL MAPA Y BARRA DE BUSQUEDA PARA LAS DIRECCIONES.
  void _centrarMapaEnZaragoza() {
    setState(() {
      _cargandoUbicacion = true;
    });

    try {
      LatLng zaragozaCentro = LatLng(41.6488, -0.8891);

      setState(() {
        _ubicacionActual = zaragozaCentro;
        _ubicacionSeleccionada = zaragozaCentro;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(zaragozaCentro),
        );
      }

      _agregarMarcador(zaragozaCentro);
      _obtenerDescripcionDeCoordenadas(zaragozaCentro);
    } catch (e) {
      _mostrarMensaje('Error centrando mapa: $e', Colors.red);
    } finally {
      setState(() {
        _cargandoUbicacion = false;
      });
    }
  }

  void _agregarMarcador(LatLng ubicacion) {
    setState(() {
      _marcadores.clear();
      _marcadores.add(
        Marker(
          markerId: MarkerId('ubicacion_seleccionada'),
          position: ubicacion,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Ubicación del Servicio',
            snippet:
                'Lat: ${ubicacion.latitude.toStringAsFixed(4)}, Lng: ${ubicacion.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    });
  }

  // BUSQUEDA EXACTA BASICA.
  Future<LatLng?> _buscarExacta(String direccion) async {
    try {
      List<Location> locations = await locationFromAddress(direccion);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      // SILENCIOSO - NO MOSTRAR ERROR.
    }
    return null;
  }

  // GENERAR VARIACIONES PARA BUSCAR NEGOCIOS.
  List<String> _generarVariacionesParaNegocios(String busquedaOriginal) {
    List<String> variaciones = [];
    String busqueda = busquedaOriginal.toLowerCase();

    // AGREGAR UBICACIONES ESPECÍFICAS SI NO LAS TIENE.
    List<String> ciudades = ['zaragoza', 'huesca', 'teruel', 'aragón'];

    // METODO 1: BÚSQUEDA ORIGINAL + CIUDAD.
    for (String ciudad in ciudades) {
      if (!busqueda.contains(ciudad)) {
        variaciones.add('$busquedaOriginal, $ciudad, España');
        variaciones.add('$busquedaOriginal $ciudad');
      }
    }

    // METODO 2: SI ES UN NEGOCIO ESPECÍFICO, AGREGAR TÉRMINOS GENÉRICOS.
    if (busqueda.contains('hospital') || busqueda.contains('veterinario')) {
      variaciones.add('$busquedaOriginal, Zaragoza, España');
      variaciones.add(
          'veterinario ${busqueda.replaceAll('hospital veterinario', '')} zaragoza');
    }

    if (busqueda.contains('bar') || busqueda.contains('restaurante')) {
      variaciones.add('$busquedaOriginal, Zaragoza, España');
      variaciones.add('restaurante ${busqueda.replaceAll('bar', '')} zaragoza');
    }

    // METODO 3: REMOVER PALABRAS COMUNES QUE PUEDEN INTERFERIR.
    String busquedaLimpia = busqueda
        .replaceAll('la ', '')
        .replaceAll('el ', '')
        .replaceAll('de ', '')
        .replaceAll('del ', '');

    if (busquedaLimpia != busqueda) {
      variaciones.add('$busquedaLimpia, Zaragoza, España');
    }

    return variaciones;
  }

  // SISTEMA DE APROXIMACION DE LOCALIZACIONES O DIRECCIONES.
  String? _generarAproximacion(String direccionCompleta) {
    // PATRONES PARA REMOVER INFORMACIÓN ESPECÍFICA DE DIRECCIONES.
    String direccionAproximada = direccionCompleta;

    // REMOVER NUMEROS DE PISO Y LETRAS: ", 1º", ", 2º A", ", BAJO", ETC.
    RegExp patronPiso = RegExp(
        r',\s*\d+[oº]\s*[A-Za-z]?|,\s*(bajo|entresuelo|ático|principal|izquierda|derecha)(\s+[A-Za-z])?',
        caseSensitive: false);
    direccionAproximada = direccionAproximada.replaceAll(patronPiso, '');

    // PARA DIRECCIONES CON MULTIPLES COMAS, MANTENER SOLO CALLE Y CIUDAD.
    List<String> partes =
        direccionAproximada.split(',').map((e) => e.trim()).toList();

    if (partes.length >= 3) {
      // "EJEMPLO DE DESTRUCTURACION AVENIDA DE ARAGÓN, 34, JACA, 1º B"
      // -> ["AVENIDA DE ARAGÓN", "34", "JACA", "1º B"].
      // RESULTADO: "AVENIDA DE ARAGÓN, JACA".
      return '${partes[0]}, ${partes[partes.length - 2]}';
    } else if (partes.length == 2) {
      // "CALLE MAYOR, 25" -> "CALLE MAYOR".
      return partes[0];
    }
    return direccionAproximada.trim();
  }

  Future<void> _manejarDireccionNoEncontrada(String direccionOriginal) async {
    // CENTRAR MAPA EN ZARAGOZA AUTOMATICAMENTE.
    LatLng zaragozaCentro = LatLng(41.6488, -0.8891);
    await _actualizarMapaConUbicacion(zaragozaCentro, 'Zaragoza, España');

    // AGREGAR DIRECCION ORIGINAL A COMENTARIOS AUTOMÁTICAMENTE.
    _agregarDireccionAComentarios(
        'Dirección no encontrada automáticamente: $direccionOriginal');

    // MOSTRAR MENSAJE AMIGABLE.
    _mostrarMensajeInfo(
        '📍 Ubicación centrada en Zaragoza. Usa el mapa para ajustar la ubicación exacta.');

    debugPrint(
        '📝 Dirección "$direccionOriginal" agregada a comentarios automáticamente');
  }

  Future<void> _manejarDireccionNoEncontradaAragon(
      String direccionOriginal) async {
    // CENTRAR MAPA EN ZARAGOZA AUTOMATICAMENTE.
    LatLng zaragozaCentro = LatLng(41.6488, -0.8891);
    await _actualizarMapaConUbicacionPersistente(
        zaragozaCentro, 'Zaragoza, Aragón');

    // AGREGAR A COMENTARIOS AUTOMATICAMENTE.
    _agregarDireccionAComentarios(
        'Dirección no encontrada automáticamente: $direccionOriginal');

    // MENSAJE AMIGABLE.
    _mostrarMensajeInfo(
        '📍 Ubicación centrada en Zaragoza. Ajusta manualmente si es necesario.');

    debugPrint(
        '📝 Dirección "$direccionOriginal" agregada a comentarios (no encontrada en Aragón)');
  }

// VERIFICACION PARA DIRECCIONES DENTRO DE LA COMUNIDAD DE ARAGON.
  bool _estaEnAragon(double lat, double lng) {
    // Coordenadas más precisas de Aragón
    return lat >= 39.8 && lat <= 42.8 && lng >= -2.0 && lng <= 0.8;
  }

  void _seleccionarUbicacionEnMapa(LatLng ubicacion) async {
    setState(() {
      _ubicacionSeleccionada = ubicacion;
      _cargandoUbicacion = true;
    });

    try {
      String direccionReal =
          await _obtenerDireccionDeCoordenadasNominatim(ubicacion);

      // MARCADOR PERSISTENTE MANUAL.
      setState(() {
        _direccionController.text = direccionReal;
        _ubicacionActual = ubicacion;
        _latitude = ubicacion.latitude;
        _longitude = ubicacion.longitude;

        // MARCADOR MANUAL PERSISTENTE.
        _marcadores.clear();
        _marcadores.add(
          Marker(
            markerId: MarkerId('ubicacion_manual_persistente'),
            position: ubicacion,
            infoWindow: InfoWindow(
              title: 'Ubicación marcada manualmente',
              snippet: direccionReal,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
        _direccionController.text = 'Ubicación manual - $coordenadas';
        _ubicacionActual = ubicacion;
        _latitude = ubicacion.latitude;
        _longitude = ubicacion.longitude;

        _marcadores.clear();
        _marcadores.add(
          Marker(
            markerId: MarkerId('ubicacion_coordenadas_persistente'),
            position: ubicacion,
            infoWindow: InfoWindow(
              title: 'Ubicación manual',
              snippet: coordenadas,
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

// METODO PRINCIPAL DE BUSQUEDA DE DIRECCIONES DE DOMICILIOS.
  Future<void> _buscarDireccion(String direccion) async {
    if (direccion.trim().isEmpty) return;

    setState(() {
      _cargandoUbicacion = true;
    });

    String direccionOriginal = direccion.trim();

    try {
      debugPrint('🔍 Búsqueda limpia para: $direccionOriginal');

      // METODO 1. INTENTAR BUSQUEDA EXACTA PRIMERO.
      LatLng? coordenadas = await _buscarConGeocodingNativo(direccionOriginal);

      if (coordenadas != null &&
          _estaEnAragon(coordenadas.latitude, coordenadas.longitude)) {
        debugPrint('✅ Encontrado exacto en Aragón');
        await _actualizarMapaConUbicacionPersistente(
            coordenadas, direccionOriginal);
        _mostrarMensajeExito('✅ Ubicación encontrada exactamente');
        _agregarDireccionAComentarios(
            'Dirección del servicio: $direccionOriginal');
        return;
      }

      // METODO 2. APROXIMACIONES PROGRESIVAS PARA ARAGON.
      List<String> aproximacionesAragon =
          _generarAproximacionesProgresivas(direccionOriginal);

      for (String aproximacion in aproximacionesAragon) {
        coordenadas = await _buscarConGeocodingNativo(aproximacion);

        if (coordenadas != null &&
            _estaEnAragon(coordenadas.latitude, coordenadas.longitude)) {
          debugPrint('✅ Encontrado con aproximación: $aproximacion');

          //AQUI SEPARO EL CONTENIDO ENCONTRADO DEL QUE NO SE ENCUENTRA PARA AGREGARLO
          // A LOS COMENTARIOS ADICIONALES.
          await _manejarResultadoAproximado(
              coordenadas, aproximacion, direccionOriginal);
          return;
        }

        await Future.delayed(Duration(milliseconds: 250));
      }

      // METODO 3. NOMINATIM "OPENSTEERTMAP API" ESPECIFICO PARA ARAGON.
      coordenadas = await _buscarConNominatimAragon(direccionOriginal);

      if (coordenadas != null &&
          _estaEnAragon(coordenadas.latitude, coordenadas.longitude)) {
        debugPrint('✅ Encontrado con Nominatim Aragón');
        String direccionFormateada =
            await _obtenerDireccionDeCoordenadasNominatim(coordenadas);
        await _manejarResultadoAproximado(
            coordenadas, direccionFormateada, direccionOriginal);
        return;
      }

      // METODO 4. DIRECCION NO ENCONTRADA.
      await _manejarDireccionNoEncontradaAragon(direccionOriginal);
    } catch (e) {
      debugPrint('💥 Error: $e');
      await _manejarDireccionNoEncontradaAragon(direccionOriginal);
    } finally {
      setState(() {
        _cargandoUbicacion = false;
      });
    }
  }

// METODO PARA MANEJAR EL RESULTADO DE LA BUSQUEDA APROXIMADO.
  Future<void> _manejarResultadoAproximado(LatLng coordenadas,
      String direccionEncontrada, String direccionOriginal) async {
    try {
      // 1. ACTUALIZAR LA BARRA DE BUSQUEDA CON LA PARTE DE LA DIRECCION QUE SE ENCONTRO.
      await _actualizarMapaConUbicacionPersistente(
          coordenadas, direccionEncontrada);

      // 2️. AGREGAR A COMENTARIO LA DIRECCION ORIGINAL COMPLETA.
      _agregarDireccionOriginalAComentarios(
          direccionOriginal, direccionEncontrada);

      // 3. MOSTRAR MENSAJE ADECUADO DE LOG.
      _mostrarMensajeAproximacion('📍 Ubicación aproximada encontrada');

      debugPrint('Resultado limpio:');
      debugPrint('→ En barra: $direccionEncontrada');
      debugPrint('→ En comentarios: $direccionOriginal');
    } catch (e) {
      debugPrint('Error manejando resultado aproximado: $e');
    }
  }

// AGREGAR DIRECCION ORIGINAL A COMENTARIOS.
  void _agregarDireccionOriginalAComentarios(
      String direccionOriginal, String direccionEncontrada) {
    String comentarioActual = _comentariosController.text;

    // FORMATO LIMPIO Y PROFESIONAL.
    String comentarioNuevo =
        'Dirección específica original: $direccionOriginal';

    // EVITAR COMENTARIOS DUPLICADOS.
    if (!comentarioActual.contains(comentarioNuevo)) {
      if (comentarioActual.isEmpty) {
        _comentariosController.text = comentarioNuevo;
      } else {
        _comentariosController.text = '$comentarioActual\n$comentarioNuevo';
      }

      _mostrarMensajeInfo('📝 Dirección específica agregada a comentarios');
    }
  }

// APROXIMACIONES PROGRESIVAS INTELIGENTES.
  List<String> _generarAproximacionesProgresivas(String direccionOriginal) {
    List<String> aproximaciones = [];
    String direccion = direccionOriginal.toLowerCase().trim();

    debugPrint(
        '🏗️ Generando aproximaciones progresivas para: $direccionOriginal');

    // APROXIMACIÓN GRADUAL - QUITAR ELEMENTOS PROGRESIVAMENTE.

    // 1. QUITAR SOLO INFORMACION DE PISOS/LETRAS.
    String sinPisos = _quitarSoloPisos(direccionOriginal);
    if (sinPisos != direccionOriginal) {
      aproximaciones.addAll([
        '$sinPisos, Zaragoza',
        '$sinPisos, Huesca',
        '$sinPisos, Teruel',
        sinPisos,
      ]);
    }

    // 2. QUITAR NUMEROS TAMBIEN.
    String sinNumeros = _quitarNumerosYPisos(direccionOriginal);
    if (sinNumeros != sinPisos && sinNumeros != direccionOriginal) {
      aproximaciones.addAll([
        '$sinNumeros, Zaragoza',
        '$sinNumeros, Huesca',
        '$sinNumeros, Teruel',
        sinNumeros,
      ]);
    }

    // APROXIMACIONES ESPECiFICAS PARA CALLES CONOCIDAS.
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

    if (direccion.contains('don jaime') || direccion.contains('jaime i')) {
      aproximaciones.addAll([
        'Calle Don Jaime I, Zaragoza',
        'Don Jaime I, Zaragoza',
      ]);
    }

    if (direccion.contains('pilar')) {
      aproximaciones.addAll([
        'Plaza del Pilar, Zaragoza',
        'Plaza Pilar, Zaragoza',
      ]);
    }

    if (direccion.contains('manifestacion') ||
        direccion.contains('manifestación')) {
      aproximaciones.addAll([
        'Calle Manifestación, Zaragoza',
        'Manifestación, Zaragoza',
      ]);
    }

    if (direccion.contains('sagasta')) {
      aproximaciones.addAll([
        'Paseo de Sagasta, Zaragoza',
        'Paseo Sagasta, Zaragoza',
        'Sagasta, Zaragoza',
      ]);
    }

    if (direccion.contains('coso')) {
      aproximaciones.addAll([
        'Calle del Coso, Zaragoza',
        'Calle Coso, Zaragoza',
        'El Coso, Zaragoza',
      ]);
    }

    if (direccion.contains('españa') || direccion.contains('espana')) {
      aproximaciones.addAll([
        'Plaza de España, Zaragoza',
        'Plaza España, Zaragoza',
      ]);
    }

    if (direccion.contains('predicadores')) {
      aproximaciones.addAll([
        'Calle Predicadores, Zaragoza',
        'Predicadores, Zaragoza',
      ]);
    }

    // APROXIMACIONES PARA HUESCA.
    if (_esCalleDeHuesca(direccion)) {
      String direccionBase = _quitarSoloPisos(direccionOriginal);
      aproximaciones.addAll([
        '$direccionBase, Huesca',
        '$direccionBase, Huesca, Aragón',
      ]);
    }

    // APROXIMACIONES PARA TERUEL.
    if (_esCalleDeTeruel(direccion)) {
      String direccionBase = _quitarSoloPisos(direccionOriginal);
      aproximaciones.addAll([
        '$direccionBase, Teruel',
        '$direccionBase, Teruel, Aragón',
      ]);
    }

    // APROXIMACIONES PARA PUEBLOS DE ARAGoN.
    List<String> pueblosAragon = [
      'Barbastro',
      'Calatayud',
      'Alcañiz',
      'Jaca',
      'Ejea de los Caballeros',
      'Monzón',
      'Tarazona',
      'Caspe',
      'Fraga',
      'Binéfar'
    ];

    for (String pueblo in pueblosAragon) {
      if (direccion.contains(pueblo.toLowerCase())) {
        String direccionLimpia =
            _quitarSoloPisos(direccionOriginal.replaceAll(pueblo, '').trim());
        if (direccionLimpia.isNotEmpty) {
          aproximaciones.addAll([
            '$direccionLimpia, $pueblo',
            '$direccionLimpia, $pueblo, Aragón',
          ]);
        }
      }
    }

    // ELIMINAR DUPLICADOS MANTENIENDO ORDEN.
    return aproximaciones.toSet().toList();
  }

// QUITAR SOLO PISOS Y LETRAS (MANTENER NuMEROS PRINCIPALES).
  String _quitarSoloPisos(String direccionOriginal) {
    String direccion = direccionOriginal;

    // PATRONES ESPECIFICOS PARA PISOS.
    List<String> patronesPisos = [
      r',\s*\d+[ºª°]\s*[A-Za-z]?$', // ", 2º A".
      r',\s*\d+\s+(derecha|dcha|izquierda|izda|centro)$', // ", 2 DERECHA"
      r',\s*(bajo|entresuelo|ático|principal)(\s+[A-Za-z])?$', // ", BAJO B"
    ];

    for (String patron in patronesPisos) {
      direccion =
          direccion.replaceAll(RegExp(patron, caseSensitive: false), '');
    }

    return direccion.trim();
  }

// QUITAR NUMEROS Y PISOS (DEJAR SOLO NOMBRE DE CALLE).
  String _quitarNumerosYPisos(String direccionOriginal) {
    String direccion = _quitarSoloPisos(direccionOriginal);

    // QUITAR NUMEROS AL FINAL.
    direccion = direccion.replaceAll(RegExp(r',\s*\d+\s*$'), '');

    return direccion.trim();
  }

// GEOCODING NATIVO (FUNCIONA BIEN).
  Future<LatLng?> _buscarConGeocodingNativo(String direccion) async {
    try {
      // INTENTAR CON DIFERENTES VARIACIONES.
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

            // VERIFICAR QUE ESTE EN ARAGON (FILTRO BASICO).
            if (coordenadas.latitude > 35.0 &&
                coordenadas.latitude < 45.0 &&
                coordenadas.longitude > -10.0 &&
                coordenadas.longitude < 5.0) {
              debugPrint('✅ Geocoding encontró: $variacion');
              return coordenadas;
            }
          }
        } catch (e) {
          continue; // PROBAR SIGUIENTE VARIACION.
        }

        await Future.delayed(
            Duration(milliseconds: 200)); // EVITAR RATE LIMITING.
      }
    } catch (e) {
      debugPrint('Error en geocoding nativo: $e');
    }
    return null;
  }

// NOMINATIM MEJORADO VARIANTE DE GOOGLE API PLACES (PARA LUGARES ESPECÍFICOS).
  Future<LatLng?> _buscarConNominatimMejorado(String direccion) async {
    try {
      List<String> consultas = _generarConsultasNominatim(direccion);

      for (String consulta in consultas) {
        try {
          String encodedQuery = Uri.encodeComponent(consulta);
          String url = 'https://nominatim.openstreetmap.org/search?'
              'q=$encodedQuery&'
              'format=json&'
              'limit=5&'
              'countrycodes=es&'
              'addressdetails=1&'
              'extratags=1&'
              'accept-language=es';

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'COLDMAN-App/1.0',
              'Accept': 'application/json',
            },
          ).timeout(Duration(seconds: 10));

          if (response.statusCode == 200) {
            List<dynamic> results = json.decode(response.body);

            if (results.isNotEmpty) {
              // TOMAR EL PRIMER RESULTADO VALIDO.
              var resultado = results[0];
              double lat = double.parse(resultado['lat'].toString());
              double lon = double.parse(resultado['lon'].toString());

              // VERIFICAR QUE ESTAMOS EN EL PAIS.
              if (lat > 35.0 && lat < 45.0 && lon > -10.0 && lon < 5.0) {
                debugPrint('✅ Nominatim encontró: $consulta');
                return LatLng(lat, lon);
              }
            }
          }
        } catch (e) {
          debugPrint('Error con consulta: $consulta');
          continue;
        }

        await Future.delayed(
            Duration(milliseconds: 1000)); // RESPETAR RATE LIMIT.
      }
    } catch (e) {
      debugPrint('Error en Nominatim: $e');
    }
    return null;
  }

// NOMINATIM ESPECIFICO PARA ARAGON.
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
              'viewbox=-2.0,43.0,1.0,39.5&' // BOUNDING BOX ESPECIFICO DE ARAGON.
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
              // BUSCAR ESPECIFICAMENTE EN ARAGON.
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

// GENERAR CONSULTAS PARA NOMINATIM.
  List<String> _generarConsultasNominatim(String direccionOriginal) {
    List<String> consultas = [];
    String direccion = direccionOriginal.toLowerCase().trim();

    // CONSULTA ORIGINAL.
    consultas.add(direccionOriginal);

    // VARIACIONES CON UBICACIONES.
    consultas.addAll([
      '$direccionOriginal Zaragoza',
      '$direccionOriginal Zaragoza España',
      '$direccionOriginal Aragón España',
      '$direccionOriginal España',
    ]);

    // PARA NEGOCIOS ESPECIFICOS.
    if (direccion.contains('hospital') || direccion.contains('veterinario')) {
      consultas.addAll([
        '$direccionOriginal veterinario Zaragoza',
        '$direccionOriginal clínica Zaragoza',
        '$direccionOriginal hospital Zaragoza',
      ]);
    }

    if (direccion.contains('bar') || direccion.contains('restaurante')) {
      consultas.addAll([
        '$direccionOriginal bar Zaragoza',
        '$direccionOriginal restaurante Zaragoza',
      ]);
    }

    // PARA PARQUES Y LUGARES PUBLICOS.
    if (direccion.contains('parque') || direccion.contains('plaza')) {
      consultas.addAll([
        '$direccionOriginal Zaragoza park',
        '$direccionOriginal Zaragoza square',
      ]);
    }

    return consultas;
  }

// CONSULTAS ESPECIFICAS PARA ARAGON.
  List<String> _generarConsultasEspecificasAragon(String direccionOriginal) {
    List<String> consultas = [];
    String direccionBase = _extraerDireccionBase(direccionOriginal);

    // ESPECIFICAS PARA ZARAGOZA.
    consultas.addAll([
      '$direccionBase, Zaragoza, Aragón, España',
      '$direccionBase, Zaragoza, España',
      '$direccionBase Zaragoza',
    ]);

    // ESPECIFICAS PARA HUESCA.
    consultas.addAll([
      '$direccionBase, Huesca, Aragón, España',
      '$direccionBase, Huesca, España',
      '$direccionBase Huesca',
    ]);

    // ESPECIFICAS PARA TERUEL.
    consultas.addAll([
      '$direccionBase, Teruel, Aragón, España',
      '$direccionBase, Teruel, España',
      '$direccionBase Teruel',
    ]);

    return consultas;
  }

  String _extraerDireccionBase(String direccionCompleta) {
    String direccion = direccionCompleta;

    // PATRONES ESPECIFICOS PARA LIMPIAR PISOS.
    List<String> patronesPisos = [
      r',\s*\d+[ºª°]\s*[A-Za-z]?$', // ", 2º A"
      r',\s*\d+\s+(derecha|izquierda|centro)$', // ", 2 DERECHA"
      r',\s*(bajo|entresuelo|ático|principal)$', // ", BAJO"
      r',\s*\d+[ºª°]\s*$', // ", 1º"
    ];

    for (String patron in patronesPisos) {
      direccion =
          direccion.replaceAll(RegExp(patron, caseSensitive: false), '');
    }

    return direccion.trim();
  }

// VERIFICACIONES ESPECÍFICAS PARA CIUDADES.
  bool _esCalleDeHuesca(String direccion) {
    List<String> callesHuesca = [
      'coso alto',
      'martinez de velasco',
      'pirineos'
    ];
    return callesHuesca.any((calle) => direccion.contains(calle));
  }

  bool _esCalleDeTeruel(String direccion) {
    List<String> callesTeruel = [
      'torico',
      'amantes',
      'sagunto',
      'temprado',
      'yague'
    ];
    return callesTeruel.any((calle) => direccion.contains(calle));
  }

// APROXIMACIÓN SIMPLE DE LA DIRECCION DE BUSQEUDA.
  String _generarAproximacionSimple(String direccionOriginal) {
    String direccion = direccionOriginal.trim();

    // REMOVER INFORMACIÓN DE PISO/PUERTA.
    RegExp patronPiso = RegExp(
        r',?\s*\d+[oº°]\s*[A-Za-z]?|,?\s*(bajo|entresuelo|ático|principal|izquierda|derecha)(\s+[A-Za-z])?',
        caseSensitive: false);
    direccion = direccion.replaceAll(patronPiso, '');

    // PARA DIRECCIONES COMPLEJAS, SIMPLIFICAR.
    if (direccion.contains(',')) {
      List<String> partes = direccion.split(',').map((e) => e.trim()).toList();
      if (partes.length >= 3) {
        // "AVENIDA DE ARAGÓN, 34, JACA, 1º B" → "AVENIDA DE ARAGÓN, JACA".
        direccion = '${partes[0]}, ${partes[partes.length - 2]}';
      }
    }

    return direccion.trim();
  }

// ACTUALIZAR MAPA CON UBICACION ENCONTRADA.
  Future<void> _actualizarMapaConUbicacion(
      LatLng coordenadas, String direccion) async {
    try {
      setState(() {
        _ubicacionActual = coordenadas;
        _ubicacionSeleccionada = coordenadas;
        _latitude = coordenadas.latitude;
        _longitude = coordenadas.longitude;

        // ACTUALIZAR CAMPO DE DIRECCION.
        _direccionController.text = direccion;

        // ACTUALIZAR MARCADOR.
        _marcadores.clear();
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

      // DARLE ANIMACION A LA CAMARA O MAPA DE GOOGLE MAPS.
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(coordenadas, 16.0),
        );
      }

      // AGREGAR AUTOMATICAMENTE A COMENTARIOS.
      _agregarDireccionAComentarios('Dirección del servicio: $direccion');
    } catch (e) {
      debugPrint('Error actualizando mapa: $e');
    }
  }

// ACTUALIZAR MAPA CON MARCADOR PERSISTENTE.
  Future<void> _actualizarMapaConUbicacionPersistente(
      LatLng coordenadas, String direccion) async {
    try {
      setState(() {
        _ubicacionActual = coordenadas;
        _ubicacionSeleccionada = coordenadas;
        _latitude = coordenadas.latitude;
        _longitude = coordenadas.longitude;

        // ACTUALIZAR CAMPO DE DIRECCION.
        _direccionController.text = direccion;

        // MARCADOR PERSISTENTE - NO SE QUITA AUTOMATICAMENTE.
        _marcadores.clear();
        _marcadores.add(
          Marker(
            markerId: MarkerId('ubicacion_servicio_persistente'),
            position: coordenadas,
            infoWindow: InfoWindow(
              title: 'Ubicación del servicio',
              snippet: direccion,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            // MARCADOR FIJO - NO SE ELIMINARÁ AUTOMATICAMENTE.
            onTap: () {
              debugPrint('Marcador persistente - Ubicación confirmada');
            },
          ),
        );
      });

      // DARLE ANIMACION A LA CAMARA O MAPA DE GOOGLE MAPS SOLO UNA VEZ.
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

// CONVERTIR COORDENADAS A DIRECCION REAL.
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

          // CONSTRUIR DIRECCION LEGIBLE.
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

// AGREGAR DIRECCION A COMENTARIOS.
  void _agregarDireccionAComentarios(String nuevaDireccion) {
    String comentarioActual = _comentariosController.text;

    // EVITAR DUPLICADOS.
    if (!comentarioActual.contains(nuevaDireccion)) {
      if (comentarioActual.isEmpty) {
        _comentariosController.text = nuevaDireccion;
      } else {
        _comentariosController.text = '$comentarioActual\n$nuevaDireccion';
      }

      _mostrarMensajeInfo('📝 Dirección agregada a comentarios');
    }
  }

// METODOS DE MENSAJES DE INFORMACION.
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

  Widget _buildPanelMensajes() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView.builder(
        itemCount: _mensajes.length,
        itemBuilder: (context, index) {
          String mensaje = _mensajes[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColorMensaje(mensaje).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getColorMensaje(mensaje).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconoMensaje(mensaje),
                  color: _getColorMensaje(mensaje),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mensaje,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getColorMensaje(mensaje),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// SISTEMA DE GEOCODING CON NOMINATIM ACTUALIZAR MAPA Y IU.
  Future<void> _actualizarUbicacionEncontrada(
      LatLng coordenadas, String direccionOriginal) async {
    try {
      // ACTUALIZAR POSICION DEL MAPA.
      setState(() {
        _ubicacionActual = coordenadas;
        _latitude = coordenadas.latitude;
        _longitude = coordenadas.longitude;
      });

      // ACTUALIZAR MARCADOR EN EL MAPA.
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(coordenadas, 16.0),
        );

        // AGREGAR MARCADOR AL MAPA.
        setState(() {
          _marcadores.clear();
          _marcadores.add(
            Marker(
              markerId: MarkerId('ubicacion_seleccionada'),
              position: coordenadas,
              infoWindow: InfoWindow(
                title: 'Ubicación del servicio',
                snippet: direccionOriginal,
              ),
            ),
          );
        });
      }

      _mostrarMensajeExito('✅ Ubicación encontrada');
    } catch (e) {
      debugPrint('Error actualizando ubicación: $e');
    }
  }

  String _preprocesarDireccion(String direccionOriginal) {
    String direccion = direccionOriginal.trim();

    // 1. NORMALIZAR ABREVIACIONES
    Map<String, String> normalizaciones = {
      r'\bc\/\s*': 'calle ',
      r'\bav\.\s*': 'avenida ',
      r'\bav\b\s*': 'avenida ',
      r'\bpl\.\s*': 'plaza ',
      r'\bps\.\s*': 'paseo ',
      r'\bgr\.\s*': 'grupo ',
    };

    String direccionNormalizada = direccion;
    for (String patron in normalizaciones.keys) {
      direccionNormalizada = direccionNormalizada.replaceAll(
          RegExp(patron, caseSensitive: false), normalizaciones[patron]!);
    }

    // 2. LIMPIAR INFORMACION DE PISO/PUERTA.
    List<String> patronesLimpieza = [
      r',\s*\d+\s*[º°ª]\s*[A-Z]?\s*$',
      r',\s*piso\s*\d+.*$',
      r',\s*portal\s*[A-Z0-9]+.*$',
      r',\s*escalera\s*[A-Z0-9]+.*$',
      r',\s*bloque\s*[A-Z0-9]+.*$',
      r',\s*edificio\s*[^,]*$',
      r',\s*(bajo|entresuelo).*$',
    ];

    String direccionLimpia = direccionNormalizada;
    for (String patron in patronesLimpieza) {
      direccionLimpia =
          direccionLimpia.replaceAll(RegExp(patron, caseSensitive: false), '');
    }

    // 3. LIMPIAR ESPACIOS.
    direccionLimpia = direccionLimpia
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .replaceAll(RegExp(r'^,|,$'), '');

    return direccionLimpia;
  }

  void _agregarAComentarios(String direccionOriginal) {
    String comentarioActual = _comentariosController.text;
    String nuevaDireccion = 'Dirección específica: $direccionOriginal';

    if (comentarioActual.isEmpty) {
      _comentariosController.text = nuevaDireccion;
    } else {
      _comentariosController.text = '$comentarioActual\n$nuevaDireccion';
    }
  }

  /* METODO EXPERIMENTAL PARA UTILIZAR LA API DE PLACES DE GOOGLE CLOUD.
  Future<bool> _buscarConGooglePlaces(String direccion) async {
    try {
      debugPrint('🏢 Google Places API no configurada');
      return false;
      
      /* IMPLEMENTACIÓN FUTURA SI HABILITAS PLACES API:
      String apiKey = 'TU_API_KEY_AQUI';
      String encodedQuery = Uri.encodeComponent('$direccion, Aragón, España');
      String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
          'query=$encodedQuery&'
          'key=$apiKey&'
          'region=es&'
          'language=es';
          
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          var place = data['results'][0];
          double lat = place['geometry']['location']['lat'];
          double lng = place['geometry']['location']['lng'];
          
          if (_estaEnAragon(lat, lng)) {
            LatLng ubicacion = LatLng(lat, lng);
            await _moverMapaYActualizar(ubicacion);
            _direccionController.text = place['formatted_address'];
            _mostrarMensaje('✅ Encontrado con Google Places', Colors.green);
            return true;
          }
        }
      }
      */
    } catch (e) {
      debugPrint('💥 Error en Google Places: $e');
      return false;
    }
  }
  */

  void _mostrarMensajeInteligente(String direccionOriginal) {
    String mensaje;
    Color color;

    if (RegExp(r'\d+.*[A-Z].*\d+.*[a-z]', caseSensitive: false)
        .hasMatch(direccionOriginal)) {
      mensaje =
          '💡 Dirección con piso/puerta detectada. Intenta solo con calle y número: "${_preprocesarDireccion(direccionOriginal)}"';
      color = Colors.blue;
    } else if (direccionOriginal.length < 8) {
      mensaje =
          '🔍 Dirección muy corta. Intenta con más detalles: "Calle [nombre], [ciudad]"';
      color = Colors.orange;
    } else {
      mensaje =
          '❌ No se encontró "$direccionOriginal" en Aragón. Verifica la ortografía o usa el mapa.';
      color = Colors.red;
    }

    _mostrarMensaje(mensaje, color);
    _centrarMapaEnZaragoza();
  }

  bool _estaEnZaragoza(double lat, double lng) {
    return lat >= 41.55 && lat <= 41.75 && lng >= -1.05 && lng <= -0.75;
  }

  bool _estaEnHuesca(double lat, double lng) {
    return lat >= 42.10 && lat <= 42.20 && lng >= -0.45 && lng <= -0.35;
  }

  bool _estaEnTeruel(double lat, double lng) {
    return lat >= 40.30 && lat <= 40.40 && lng >= -1.15 && lng <= -1.05;
  }

  String _formatearDireccionNominatim(Map<String, dynamic> result) {
    Map<String, dynamic> address = result['address'] ?? {};

    List<String> partesDireccion = [];

    if (address['house_number'] != null) {
      partesDireccion.add(address['house_number']);
    }
    if (address['road'] != null) {
      partesDireccion.add(address['road']);
    } else if (address['pedestrian'] != null) {
      partesDireccion.add(address['pedestrian']);
    }

    if (address['city'] != null) {
      partesDireccion.add(address['city']);
    } else if (address['town'] != null) {
      partesDireccion.add(address['town']);
    } else if (address['village'] != null) {
      partesDireccion.add(address['village']);
    }

    if (address['province'] != null) {
      partesDireccion.add(address['province']);
    } else if (address['state'] != null) {
      partesDireccion.add(address['state']);
    }

    if (address['country'] != null && address['country'] == 'España') {
      partesDireccion.add('España');
    }

    String direccionFinal = partesDireccion.join(', ');
    return direccionFinal.isNotEmpty
        ? direccionFinal
        : result['display_name'] ?? 'Ubicación en Aragón';
  }

  Future<void> _moverMapaYActualizar(LatLng ubicacion) async {
    setState(() {
      _ubicacionSeleccionada = ubicacion;
    });

    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: ubicacion,
            zoom: 16.0,
            bearing: 0.0,
            tilt: 0.0,
          ),
        ),
      );
    }

    _agregarMarcador(ubicacion);
    _obtenerDescripcionDeCoordenadas(ubicacion);
  }

  Future<void> _obtenerDescripcionDeCoordenadas(LatLng ubicacion) async {
    try {
      String coordenadas =
          'Lat: ${ubicacion.latitude.toStringAsFixed(4)}, Lng: ${ubicacion.longitude.toStringAsFixed(4)}';

      String descripcion;
      if (_estaEnZaragoza(ubicacion.latitude, ubicacion.longitude)) {
        descripcion = 'Zaragoza, España - $coordenadas';
      } else if (_estaEnHuesca(ubicacion.latitude, ubicacion.longitude)) {
        descripcion = 'Huesca, España - $coordenadas';
      } else if (_estaEnTeruel(ubicacion.latitude, ubicacion.longitude)) {
        descripcion = 'Teruel, España - $coordenadas';
      } else {
        descripcion = 'Aragón, España - $coordenadas';
      }

      setState(() {
        _direccionController.text = descripcion;
      });

      debugPrint('✅ Descripción generada: ${_direccionController.text}');
    } catch (e) {
      debugPrint('⚠️ Error generando descripción: $e');
      String coordenadas =
          'Lat: ${ubicacion.latitude.toStringAsFixed(4)}, Lng: ${ubicacion.longitude.toStringAsFixed(4)}';
      _direccionController.text = 'Ubicación en Aragón - $coordenadas';
    }
  }

  // NORMALIZACION COMPLETA DE DIRECCIONES.
  String _normalizarDireccionEspanola(String direccionOriginal) {
    String direccion = direccionOriginal.toLowerCase().trim();

    // TIPOS DE VIAS COMPLETAS.
    Map<String, String> tiposVias = {
      // CALLES Y SIMILARES.
      r'\bc\/\s*': 'calle ',
      r'\bc\.\s*': 'calle ',
      r'\bcl\.\s*': 'calle ',
      r'\bcalle\s+de\s+la\s+': 'calle ',
      r'\bcalle\s+del\s+': 'calle ',
      r'\bcalle\s+de\s+': 'calle ',

      // AVENIDAS.
      r'\bav\.\s*': 'avenida ',
      r'\bav\b\s*': 'avenida ',
      r'\bavda\.\s*': 'avenida ',
      r'\bavda\b\s*': 'avenida ',
      r'\bavenida\s+de\s+la\s+': 'avenida ',
      r'\bavenida\s+del\s+': 'avenida ',
      r'\bavenida\s+de\s+': 'avenida ',

      // PLAZAS.
      r'\bpl\.\s*': 'plaza ',
      r'\bplaza\s+de\s+la\s+': 'plaza ',
      r'\bplaza\s+del\s+': 'plaza ',
      r'\bplaza\s+de\s+': 'plaza ',

      // PASEOS.
      r'\bps\.\s*': 'paseo ',
      r'\bpº\.\s*': 'paseo ',
      r'\bpaseo\s+de\s+la\s+': 'paseo ',
      r'\bpaseo\s+del\s+': 'paseo ',
      r'\bpaseo\s+de\s+': 'paseo ',

      // RONDAS.
      r'\brda\.\s*': 'ronda ',
      r'\bronda\s+de\s+': 'ronda ',

      // GLORIETAS.
      r'\bglorieta\s+de\s+': 'glorieta ',
      r'\bglta\.\s*': 'glorieta ',

      // TRAVESIAS.
      r'\btravesia\s+de\s+': 'travesia ',
      r'\btrv\.\s*': 'travesia ',
      r'\btrav\.\s*': 'travesia ',

      // CAMINOS.
      r'\bcamino\s+de\s+': 'camino ',
      r'\bcno\.\s*': 'camino ',

      // CARRETERAS.
      r'\bcarretera\s+de\s+': 'carretera ',
      r'\bctra\.\s*': 'carretera ',
      r'\bcrta\.\s*': 'carretera ',

      // OTROS TIPOS ESPECIFICOS.
      r'\brambla\s+de\s+': 'rambla ',
      r'\bcosta\s+de\s+': 'costa ',
      r'\bcuesta\s+de\s+': 'cuesta ',
      r'\bprolongacion\s+de\s+': 'prolongacion ',
      r'\bprolongación\s+de\s+': 'prolongacion ',
      r'\bvia\s+de\s+': 'via ',
      r'\bvía\s+de\s+': 'via ',
      r'\bautovia\s+de\s+': 'autovia ',
      r'\bautopista\s+de\s+': 'autopista ',
      r'\bpuente\s+de\s+': 'puente ',
      r'\bmuelle\s+de\s+': 'muelle ',
      r'\bmalecón\s+de\s+': 'malecon ',
      r'\balameda\s+de\s+': 'alameda ',
      r'\bparque\s+de\s+': 'parque ',
      r'\bjardin\s+de\s+': 'jardin ',
      r'\bjardín\s+de\s+': 'jardin ',
      r'\bgrupo\s+': 'grupo ',
      r'\bbarrio\s+': 'barrio ',
      r'\burbanizacion\s+': 'urbanizacion ',
      r'\burbanización\s+': 'urbanizacion ',
      r'\bcolonia\s+': 'colonia ',
      r'\bconjunto\s+': 'conjunto ',
      r'\bresidencial\s+': 'residencial ',
    };

    String direccionNormalizada = direccion;

    // APLICAR NORMALIZACIONES.
    for (String patron in tiposVias.keys) {
      direccionNormalizada = direccionNormalizada.replaceAll(
          RegExp(patron, caseSensitive: false), tiposVias[patron]!);
    }

    // NORMALIZAR CARACTERES ESPECIALES.
    direccionNormalizada = direccionNormalizada
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c')
        .replaceAll('ü', 'u');

    // LIMPIAR ESPACIOS MuLTIPLES.
    direccionNormalizada =
        direccionNormalizada.replaceAll(RegExp(r'\s+'), ' ').trim();

    return direccionNormalizada;
  }

  Future<LatLng?> _buscarConNominatimEspanol(String direccionOriginal) async {
    try {
      List<String> consultasEspanolas =
          _generarConsultasEspanolas(direccionOriginal);

      for (String consulta in consultasEspanolas) {
        try {
          String encodedQuery = Uri.encodeComponent(consulta);
          String url = 'https://nominatim.openstreetmap.org/search?'
              'q=$encodedQuery&'
              'format=json&'
              'limit=10&'
              'countrycodes=es&'
              'addressdetails=1&'
              'extratags=1&'
              'accept-language=es&'
              'bounded=1&'
              'viewbox=-9.3,43.8,3.3,36.0'; // BOUNDING BOX DE ESPAÑA.

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'COLDMAN-App/1.0',
              'Accept': 'application/json',
              'Accept-Language': 'es,en;q=0.9',
            },
          ).timeout(Duration(seconds: 8));

          if (response.statusCode == 200) {
            List<dynamic> results = json.decode(response.body);

            if (results.isNotEmpty) {
              var mejorResultado =
                  _seleccionarMejorResultadoEspanol(results, direccionOriginal);

              if (mejorResultado != null) {
                double lat = double.parse(mejorResultado['lat'].toString());
                double lon = double.parse(mejorResultado['lon'].toString());

                if (_estaEnEspana(lat, lon)) {
                  debugPrint('✅ Nominatim español encontró: $consulta');
                  return LatLng(lat, lon);
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error con consulta española: $consulta');
          continue;
        }

        await Future.delayed(Duration(milliseconds: 800));
      }
    } catch (e) {
      debugPrint('Error en Nominatim español: $e');
    }
    return null;
  }

// GENERAR CONSULTAS ESPECiFICAS PARA ESPAÑA.
  List<String> _generarConsultasEspanolas(String direccionOriginal) {
    List<String> consultas = [];
    String direccion = direccionOriginal.toLowerCase().trim();

    // CONSULTA ORIGINAL.
    consultas.add(direccionOriginal);

    // NORMALIZACIONES ESPAÑOLAS.
    String direccionNormalizada =
        _normalizarDireccionEspanola(direccionOriginal);
    consultas.add(direccionNormalizada);

    // VARIACIONES POR REGIONES ESPAÑOLAS.
    List<String> regionesAragon = ['Zaragoza', 'Huesca', 'Teruel', 'Aragón'];

    for (String region in regionesAragon) {
      if (!direccion.contains(region.toLowerCase())) {
        consultas.addAll([
          '$direccionOriginal, $region',
          '$direccionOriginal, $region, España',
          '$direccionNormalizada, $region',
          '$direccionNormalizada, $region, España',
        ]);
      }
    }

    // VARIACIONES ESPECIFICAS PARA TIPOS DE VIAS.
    if (direccion.contains('calle') || direccion.contains('c/')) {
      consultas.addAll([
        direccion.replaceAll('calle', 'c/'),
        direccion.replaceAll('c/', 'calle'),
      ]);
    }

    if (direccion.contains('avenida') || direccion.contains('av')) {
      consultas.addAll([
        direccion.replaceAll('avenida', 'av'),
        direccion.replaceAll('av', 'avenida'),
      ]);
    }

    if (direccion.contains('plaza') || direccion.contains('pl')) {
      consultas.addAll([
        direccion.replaceAll('plaza', 'pl'),
        direccion.replaceAll('pl', 'plaza'),
      ]);
    }

    // PARA NEGOCIOS Y LUGARES ESPECIFICOS.
    if (direccion.contains('hospital') ||
        direccion.contains('centro de salud')) {
      consultas.addAll([
        '$direccionOriginal hospital Zaragoza',
        '$direccionOriginal centro medico Aragón',
      ]);
    }

    if (direccion.contains('bar') ||
        direccion.contains('restaurante') ||
        direccion.contains('café')) {
      consultas.addAll([
        '$direccionOriginal restaurante Zaragoza',
        '$direccionOriginal bar Aragón',
      ]);
    }

    if (direccion.contains('parque') || direccion.contains('jardin')) {
      consultas.addAll([
        '$direccionOriginal park Zaragoza',
        '$direccionOriginal jardín Aragón',
      ]);
    }

    return consultas.toSet().toList(); // ELIMINAR DUPLICADOS.
  }

// SELECCIONAR MEJOR RESULTADO PARA ESPAÑA.
  Map<String, dynamic>? _seleccionarMejorResultadoEspanol(
      List<dynamic> resultados, String direccionBuscada) {
    if (resultados.isEmpty) return null;

    List<Map<String, dynamic>> resultadosConScore = [];
    String direccionLower = direccionBuscada.toLowerCase();

    for (var resultado in resultados) {
      double score = 0.0;
      String displayName =
          resultado['display_name']?.toString().toLowerCase() ?? '';
      Map<String, dynamic> address = resultado['address'] ?? {};

      // PRIORIZAR POR TIPO DE LUGAR.
      String type = resultado['type']?.toString() ?? '';
      String clase = resultado['class']?.toString() ?? '';

      // SCORING ESPECÍFICO PARA ESPAÑA.
      if (type == 'house' || type == 'building')
        score += 20;
      else if (type == 'road' || type == 'residential')
        score += 15;
      else if (type == 'neighbourhood' || type == 'suburb')
        score += 10;
      else if (clase == 'place')
        score += 12;
      else if (clase == 'amenity') score += 8;

      // BONUS POR ESTAR EN ARAGON.
      if (address['state']?.toString().toLowerCase().contains('aragón') ==
              true ||
          address['state']?.toString().toLowerCase().contains('aragon') ==
              true) {
        score += 15;
      }

      // BONUS POR CIUDADES ESPECIFICAS.
      String city = address['city']?.toString().toLowerCase() ?? '';
      if (city.contains('zaragoza'))
        score += 10;
      else if (city.contains('huesca'))
        score += 8;
      else if (city.contains('teruel')) score += 8;

      // COINCIDENCIAS DE PALABRAS.
      List<String> palabrasBuscadas =
          direccionLower.split(' ').where((p) => p.length > 2).toList();
      int coincidencias = 0;

      for (String palabra in palabrasBuscadas) {
        if (displayName.contains(palabra)) {
          coincidencias++;
          score += 5;
        }
      }

      double importance =
          double.tryParse(resultado['importance']?.toString() ?? '0') ?? 0;
      score += importance * 10;

      resultadosConScore.add({
        'resultado': resultado,
        'score': score,
        'coincidencias': coincidencias,
      });
    }

    // ORDENAR POR SCORE.
    resultadosConScore.sort((a, b) => b['score'].compareTo(a['score']));

    return resultadosConScore.first['resultado'];
  }

// APROXIMACIONES COMPLETAS PARA TODA ESPAÑA.
  List<String> _generarAproximacionesCompletasEspana(String direccionOriginal) {
    List<String> aproximaciones = [];
    String direccion = direccionOriginal.toLowerCase().trim();

    debugPrint(
        '🧠 Generando aproximaciones españolas para: $direccionOriginal');

    /// 1. LIMPIEZA AVANZADA DE DIRECCIONES ESPAÑOLAS.
    String direccionLimpia =
        _limpiarDireccionEspanolaAvanzada(direccionOriginal);
    if (direccionLimpia != direccionOriginal) {
      aproximaciones.addAll([
        direccionLimpia,
        '$direccionLimpia, Zaragoza',
        '$direccionLimpia, Aragón, España',
      ]);
    }

    // 2. APROXIMACIONES POR PARTES.
    List<String> partes =
        direccionOriginal.split(',').map((e) => e.trim()).toList();

    if (partes.length >= 2) {
      // COMBINACIONES INTELIGENTES.
      aproximaciones.addAll([
        '${partes[0]}, Zaragoza',
        '${partes[0]}, Aragón',
        partes[0], // SOLO PRIMERA PARTE.
      ]);

      if (partes.length >= 3) {
        aproximaciones.addAll([
          '${partes[0]}, ${partes[1]}, Zaragoza',
          '${partes[0]} ${partes[1]}, Zaragoza',
        ]);
      }
    }

    // APROXIMACIONES ESPECIFICAS POR TIPO DE VIA.
    if (direccion.contains('calle')) {
      String sinNumero = direccion.replaceAll(RegExp(r'\d+'), '').trim();
      aproximaciones.addAll([
        '$sinNumero, Zaragoza',
        sinNumero.replaceAll('calle', 'c/'),
      ]);
    }

    if (direccion.contains('avenida')) {
      String sinNumero = direccion.replaceAll(RegExp(r'\d+'), '').trim();
      aproximaciones.addAll([
        '$sinNumero, Zaragoza',
        sinNumero.replaceAll('avenida', 'av'),
      ]);
    }

    // APROXIMACIONES REGIONALES.
    aproximaciones.addAll([
      '$direccionOriginal, Zaragoza, España',
      '$direccionOriginal, Huesca, España',
      '$direccionOriginal, Teruel, España',
      '$direccionOriginal, Aragón, España',
      '$direccionOriginal, España',
    ]);

    // ELIMINAR DUPLICADOS.
    return aproximaciones.toSet().toList();
  }

// PATRONES ESPAÑOLES ESPECIFICOS PARA LIMPIAR.
  String _limpiarDireccionEspanolaAvanzada(String direccionOriginal) {
    String direccion = direccionOriginal;

    // PATRONES ESPAÑOLES ESPECÍFICOS PARA LIMPIAR.
    List<String> patronesEspanoles = [
      // PISOS CON PALABRAS ESPAÑOLAS ESPECIFICAS.
      r',\s*\d+[ºª°]?\s*(derecha|dcha|izquierda|izda|centro|ctr)',
      // PLANTAS Y NIVELES.
      r',\s*(planta|pta)\s*\d+',
      r',\s*(nivel|nvl)\s*\d+',
      // PORTALES ESPECIFICOS.
      r',\s*(portal|ptal|puerta|pta)\s*[A-Z0-9]+',
      // ESCALERAS ESPAÑOLAS.
      r',\s*(escalera|esc|escl)\s*[A-Z0-9]+',
      // BLOQUES Y EDIFICIOS.
      r',\s*(bloque|blq|edif|edificio)\s*[A-Z0-9]+',
      // TIPOS DE VIVIENDA ESPAÑOLES.
      r',\s*(bajo|bjo|entresuelo|entlo|ático|atic|sobreatico)',
      // URBANIZACIONES.
      r',\s*(urbanización|urb|residencial|resid)\s*[^,]*',
      // NUMEROS FINALES PROBLEMATICOS.
      r',\s*\d+\s*$',
    ];

    for (String patron in patronesEspanoles) {
      direccion =
          direccion.replaceAll(RegExp(patron, caseSensitive: false), '');
    }

    // LIMPIAR ESPACIOS Y COMAS.
    direccion = direccion
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r',\s*,'), ',')
        .replaceAll(RegExp(r'^,|,$'), '')
        .trim();

    return direccion;
  }

// VERIFICAR SI ESTÁ EN ESPAÑA.
  bool _estaEnEspana(double lat, double lng) {
    // COORDENADAS DE ESPAÑA (INCLUYENDO ISLAS).
    return (lat >= 35.0 && lat <= 44.0 && lng >= -9.5 && lng <= 3.5) ||
        (lat >= 27.5 &&
            lat <= 29.5 &&
            lng >= -18.5 &&
            lng <= -13.0); // LATITUD Y LONGITUD DE ISLAS CANARIAS.
  }

  void _mostrarMensaje(String mensaje, [Color? color]) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconoMensaje(mensaje),
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? _getColorMensaje(mensaje),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  IconData _getIconoMensaje(String mensaje) {
    if (mensaje.contains('✅') || mensaje.contains('📍'))
      return Icons.check_circle;
    if (mensaje.contains('❌') || mensaje.contains('💥')) return Icons.error;
    if (mensaje.contains('📝')) return Icons.note_add;
    return Icons.info;
  }

  Color _getColorMensaje(String mensaje) {
    if (mensaje.contains('✅') || mensaje.contains('📍'))
      return Colors.green[600]!;
    if (mensaje.contains('❌') || mensaje.contains('💥'))
      return Colors.red[600]!;
    if (mensaje.contains('📝')) return Colors.blue[600]!;
    return Colors.grey[600]!;
  }

  void _confirmarSolicitud() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('🎉 Solicitud Enviada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalles de la cita:'),
                SizedBox(height: 8),
                Text(
                    '• Servicio: ${_tipoServicioSeleccionado ?? "Mantenimiento de Aire Acondicionado"}'),
                Text(
                    '• Fecha: ${_formatearFecha(_fechaSeleccionada)} a las ${_formatearHora(_horaSeleccionada)}'),
                Text('• Dirección: ${_direccionController.text}'),
                if (_comentariosController.text.isNotEmpty)
                  Text('• Comentarios: ${_comentariosController.text}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(),
              SizedBox(height: 24),
              _buildFormTitle(),
              SizedBox(height: 24),
              _buildTipoServicioDropdown(),
              SizedBox(height: 20),
              _buildDireccionField(),
              SizedBox(height: 20),
              _buildMapWidget(),
              SizedBox(height: 20),
              _buildFechaYHoraSelector(),
              SizedBox(height: 20),
              _buildComentariosField(),
              SizedBox(height: 32),
              _buildConfirmarButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
