// lib/screens/customer/screen_solicitar_cita.dart
import 'package:app_coldman_sa/providers/cita_provider.dart';
import 'package:app_coldman_sa/providers/servicio_cita_provider.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:app_coldman_sa/data/models/cita_model.dart';
import 'package:app_coldman_sa/data/models/cliente_model.dart';
import 'package:app_coldman_sa/data/models/servicio_model.dart';

class ScreenSolicitarCita extends StatefulWidget {
  final Cliente clienteLogueado;

  const ScreenSolicitarCita({
    super.key,
    required this.clienteLogueado,
  });

  @override
  _ScreenSolicitarCitaState createState() => _ScreenSolicitarCitaState();
}

class _ScreenSolicitarCitaState extends State<ScreenSolicitarCita> {
  Logger logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _comentariosController = TextEditingController();
  final TextEditingController _duracionEstimadaController =
      TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoLugarController = TextEditingController();
  final EstadoCita _estadoCita = EstadoCita.programado;

  CategoriaServicio? _selectedCategoria;
  bool _isLoading = false;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _initializeClienteData();
  }

  void _initializeClienteData() {
    _direccionController.text = widget.clienteLogueado.direccionDomicilio;
    _tipoLugarController.text = widget.clienteLogueado.tipoLugar;
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _comentariosController.dispose();
    _duracionEstimadaController.dispose();
    _direccionController.dispose();
    _tipoLugarController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF4285F4),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime?.hour ?? 0,
          _selectedDateTime?.minute ?? 0,
        );

        final meses = [
          '',
          'enero',
          'febrero',
          'marzo',
          'abril',
          'mayo',
          'junio',
          'julio',
          'agosto',
          'septiembre',
          'octubre',
          'noviembre',
          'diciembre'
        ];

        final dias = [
          '',
          'lunes',
          'martes',
          'miércoles',
          'jueves',
          'viernes',
          'sábado',
          'domingo'
        ];

        final diaSemana = dias[picked.weekday];
        final nombreMes = meses[picked.month];

        _fechaController.text =
            "$diaSemana, ${picked.day} de $nombreMes de ${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF4285F4),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime?.year ?? DateTime.now().year,
          _selectedDateTime?.month ?? DateTime.now().month,
          _selectedDateTime?.day ?? DateTime.now().day,
          picked.hour,
          picked.minute,
        );
        _horaController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _solicitarCita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      _showErrorDialog('Por favor seleccione fecha y hora');
      return;
    }

    if (_selectedCategoria == null) {
      _showErrorDialog('Por favor seleccione una categoría de servicio');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final citaProvider = Provider.of<CitaProvider>(context, listen: false);

      logger.i('Cliente ID: ${widget.clienteLogueado.getId()}');
      logger.i('Fecha/Hora: $_selectedDateTime');
      logger.i('Duración: ${_duracionEstimadaController.text} horas');
      logger.i('Categoría: ${_selectedCategoria!.displayName}');

      String comentariosCompletos = _buildComentariosConCategoria();

      final nuevaCita = Cita(
        fechaHora: _selectedDateTime!,
        duracionEstimada: int.tryParse(_duracionEstimadaController.text) ?? 1,
        comentariosAdicionales: comentariosCompletos,
        estadoCita: _estadoCita,
        idCliente: widget.clienteLogueado.getId(),
        idEmpleado: 1,
        idServicio:
            999, // ID FICTICIO PARA SINCRONIZARLO CON EL BACKEND.
      );

      logger.i('JSON a enviar: ${nuevaCita.toJson()}');
      await citaProvider.citasRepository.agregarCita(nuevaCita);

      final resultado = {
        'cita': nuevaCita,
        'servicio':
            _crearServicioSimulado(), 
      };

      _showSuccessDialog(resultado);
      _clearForm();
    } catch (e) {
      logger.e('Error al solicitar cita: $e');
      _showErrorDialog('Error al solicitar la cita: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildComentariosConCategoria() {
    String comentarios = '';

    comentarios += 'Categoría: ${_selectedCategoria!.displayName}\n';

    if (_direccionController.text.isNotEmpty) {
      comentarios += 'Dirección: ${_direccionController.text}\n';
    }

    if (_tipoLugarController.text.isNotEmpty) {
      comentarios += 'Tipo de lugar: ${_tipoLugarController.text}\n';
    }

    if (_comentariosController.text.isNotEmpty) {
      comentarios += 'Comentarios adicionales: ${_comentariosController.text}';
    }

    return comentarios.trim();
  }

  Servicio _crearServicioSimulado() {
    return Servicio(
      idServicio: 0, // ID temporal
      nombre: 'Servicio ${_selectedCategoria!.displayName}',
      descripcion: 'Servicio solicitado por el cliente',
      categoriaServicio: _selectedCategoria!,
      estadoServicio: EstadoServicio.programada,
      fechaCreacion: DateTime.now(),
      duracionReal: int.tryParse(_duracionEstimadaController.text) ?? 1,
      fechaInicioServicio: _selectedDateTime,
      fechaFinServicio: _selectedDateTime?.add(
          Duration(hours: int.tryParse(_duracionEstimadaController.text) ?? 1)),
    );
  }

  void _clearForm() {
    _fechaController.clear();
    _horaController.clear();
    _comentariosController.clear();
    _duracionEstimadaController.clear();
    setState(() {
      _selectedCategoria = null;
      _selectedDateTime = null;
    });
    _initializeClienteData();
  }

  void _showSuccessDialog(Map<String, dynamic> resultado) {
    final cita = resultado['cita'];
    final servicio = resultado['servicio'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Cita Solicitada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu cita ha sido registrada exitosamente.'),
            SizedBox(height: 16),
            Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('ID Cita: ${cita.id ?? "Pendiente de asignación"}'),
            Text('ID Servicio: ${servicio.idServicio}'),
            Text('Categoría: ${_selectedCategoria?.displayName ?? "Categoría seleccionada"}'),
            Text('Fecha: ${_fechaController.text}'),
            Text('Hora: ${_horaController.text}'),
            SizedBox(height: 16),
            Container(
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
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 16),
                      SizedBox(width: 4),
                      Text('Próximos pasos:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700])),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('1. Un administrador revisará tu solicitud',
                      style: TextStyle(fontSize: 12)),
                  Text('2. Se te asignará un técnico especializado',
                      style: TextStyle(fontSize: 12)),
                  Text('3. Recibirás confirmación del servicio',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text('Entendido', style: TextStyle(color: Color(0xFF4285F4))),
          ),
        ],
      ),
    );
    Widget buildComentariosField() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dirección e Indicaciones Específicas',
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
            child: Column(
              children: [
                // Campo para dirección específica
                TextFormField(
                  controller: _comentariosController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Ejemplo: Calle Mompeon Motos 6, 2º B, Zaragoza',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    labelText: 'Dirección completa con piso/puerta',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                // Campo para indicaciones adicionales
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Indicaciones para llegar: "Segundo edificio a la derecha, portero automático, tocar el botón 2B"',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    labelText: 'Indicaciones específicas de acceso',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Ejemplos de indicaciones útiles
          Container(
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
                    Icon(Icons.lightbulb_outline,
                        color: Colors.blue[700], size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Ejemplos de indicaciones útiles:',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '• Número de piso, puerta o local específico\n'
                  '• Puntos de referencia (junto al banco, frente al parque)\n'
                  '• Códigos de acceso o portero automático\n'
                  '• Horarios de acceso restringido\n'
                  '• Observaciones sobre parking o acceso',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Color(0xFF4285F4))),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) getDisplayName,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(getDisplayName(item)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4285F4).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Color(0xFF4285F4)),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4285F4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicioCitaProvider>(
      builder: (context, servicioProvider, child) {
        return Scaffold(
          backgroundColor: Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Solicitar Cita',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor:Color(0xFF3B82F6),
            elevation: 2,
            iconTheme: IconThemeData(color: Color(0xFF3B82F6)),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LOGO
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 32),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_coldman.png',
                        width: 300,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // INFORMACIÓN DEL CLIENTE
                  _buildInfoField(
                    label: 'Cliente',
                    value:
                        '${widget.clienteLogueado.getNombre()} ${widget.clienteLogueado.getApellido()}',
                    icon: Icons.person,
                  ),

                  // FECHA
                  _buildInputField(
                    label: 'Fecha *',
                    controller: _fechaController,
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon:
                        Icon(Icons.calendar_today, color: Color(0xFF4285F4)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione una fecha';
                      }
                      return null;
                    },
                  ),

                  // HORA
                  _buildInputField(
                    label: 'Hora *',
                    controller: _horaController,
                    readOnly: true,
                    onTap: _selectTime,
                    suffixIcon:
                        Icon(Icons.access_time, color: Color(0xFF4285F4)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione una hora';
                      }
                      return null;
                    },
                  ),

                  // CATEGORÍA DE SERVICIO
                  _buildDropdownField<CategoriaServicio>(
                    label: 'Categoría de Servicio *',
                    value: _selectedCategoria,
                    items: CategoriaServicio.values,
                    getDisplayName: (categoria) => categoria.displayName,
                    onChanged: (categoria) {
                      setState(() {
                        _selectedCategoria = categoria;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor seleccione una categoría';
                      }
                      return null;
                    },
                  ),

                  // DURACIÓN ESTIMADA
                  _buildInputField(
                    label: 'Duración Estimada (horas) *',
                    controller: _duracionEstimadaController,
                    keyboardType: TextInputType.number,
                    suffixIcon:
                        Icon(Icons.access_time, color: Color(0xFF4285F4)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la duración estimada';
                      }
                      final duracion = int.tryParse(value);
                      if (duracion == null || duracion <= 0) {
                        return 'Por favor ingrese un número entero mayor a 0';
                      }
                      if (duracion > 24) {
                        return 'La duración no puede ser mayor a 24 horas';
                      }
                      return null;
                    },
                  ),

                  // DIRECCIÓN DEL SERVICIO
                  _buildInputField(
                    label: 'Dirección del Servicio *',
                    controller: _direccionController,
                    maxLines: 2,
                    suffixIcon:
                        Icon(Icons.location_on, color: Color(0xFF4285F4)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la dirección';
                      }
                      return null;
                    },
                  ),

                  // TIPO DE LUGAR
                  _buildInputField(
                    label: 'Tipo de Lugar *',
                    controller: _tipoLugarController,
                    suffixIcon: Icon(Icons.business, color: Color(0xFF4285F4)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el tipo de lugar';
                      }
                      return null;
                    },
                  ),

                  // COMENTARIOS ADICIONALES
                  _buildInputField(
                    label: 'Comentarios Adicionales',
                    controller: _comentariosController,
                    maxLines: 3,
                    suffixIcon: Icon(Icons.comment, color: Color(0xFF4285F4)),
                    validator: (value) => null,
                  ),

                  SizedBox(height: 32),

                  // BOTONES
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black54,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_isLoading || servicioProvider.isLoading)
                              ? null
                              : _solicitarCita,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4285F4),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: (_isLoading || servicioProvider.isLoading)
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Solicitar Cita',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  // MOSTRAR ERROR SI EXISTE
                  if (servicioProvider.error != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[700], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              servicioProvider.error!,
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
