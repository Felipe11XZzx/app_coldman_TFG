import 'package:app_coldman_sa/providers/cita_provider.dart';
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
  final TextEditingController _duracionEstimadaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _tipoLugarController = TextEditingController();
  
  CategoriaServicio? _selectedCategoria;
  EstadoCita _estadoCita = EstadoCita.programado;
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
          '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
          'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
        ];
        
        final dias = [
          '', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
        ];
        
        final diaSemana = dias[picked.weekday];
        final nombreMes = meses[picked.month];
        
        _fechaController.text = "$diaSemana, ${picked.day} de $nombreMes de ${picked.year}";
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
        _horaController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _solicitarCita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      _showErrorDialog('Por favor seleccione fecha y hora');
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
      logger.i('Estado: ${_estadoCita.backendValue}');
      
      final nuevaCita = Cita(
        fechaHora: _selectedDateTime!,
        duracionEstimada: int.tryParse(_duracionEstimadaController.text) ?? 1,
        comentariosAdicionales: _comentariosController.text,
        estadoCita: _estadoCita,
        idCliente: widget.clienteLogueado.getId(),
        idEmpleado: 1, 
        idServicio: 1,
      );

      logger.i('JSON a enviar: ${nuevaCita.toJson()}');

      final jsonData = {
        'fecha_hora': _selectedDateTime!.toIso8601String(),
        'duracion_estimada': _duracionEstimadaController,
        'comentarios_adicionales': _comentariosController.text,
        'estado_cita': _estadoCita.backendValue,
        'cliente': {
          'id_cliente': widget.clienteLogueado.getId()
        }
      };
      
      await citaProvider.citasRepository.agregarCita(nuevaCita);
      
      _showSuccessDialog();
      _clearForm();
    } catch (e) {
      _showErrorDialog('Error al solicitar la cita: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Éxito!'),
          ],
        ),
        content: Text('La cita ha sido solicitada correctamente.\nUn administrador la revisará pronto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Color(0xFF4285F4))),
          ),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF4285F4)),
            SizedBox(width: 8),
            Text(
              'Solicitar Cita',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF4285F4)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ESTILO CARD LOGO.
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

              // INFORMACION DEL CLIENTE.
              _buildInfoField(
                label: 'Cliente',
                value: '${widget.clienteLogueado.getNombre()} ${widget.clienteLogueado.getApellido()}',
                icon: Icons.person,
              ),

              // ESTADO DE LA CITA.
              _buildInfoField(
                label: 'Estado de la Cita',
                value: _estadoCita.displayName,
                icon: Icons.info_outline,
              ),

              // FECHA SOLICITUD SERVICIO.
              _buildInputField(
                label: 'Fecha *',
                controller: _fechaController,
                readOnly: true,
                onTap: _selectDate,
                suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF4285F4)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una fecha';
                  }
                  return null;
                },
              ),

              // HORA DEL SERVICIO.
              _buildInputField(
                label: 'Hora *',
                controller: _horaController,
                readOnly: true,
                onTap: _selectTime,
                suffixIcon: Icon(Icons.access_time, color: Color(0xFF4285F4)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una hora';
                  }
                  return null;
                },
              ),

              // CATEGORIA DEL SERVICIO DE LA SOLICITUD.
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

              // DURACION ESTIMADA.
              _buildInputField(
                label: 'Duración Estimada (horas) *',
                controller: _duracionEstimadaController,
                keyboardType: TextInputType.number,
                suffixIcon: Icon(Icons.access_time, color: Color(0xFF4285F4)),
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

              // DIRECCION DE DOMICILIO.
              _buildInputField(
                label: 'Dirección del Servicio *',
                controller: _direccionController,
                maxLines: 2,
                suffixIcon: Icon(Icons.location_on, color: Color(0xFF4285F4)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la dirección';
                  }
                  return null;
                },
              ),

              // TIPO DE LUGAR.
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

              // COMENTARIOS ADICIONALES.
              _buildInputField(
                label: 'Comentarios Adicionales',
                controller: _comentariosController,
                maxLines: 3,
                suffixIcon: Icon(Icons.comment, color: Color(0xFF4285F4)),
                validator: (value) => null,
              ),

              SizedBox(height: 32),

              // BOTONES.
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
                      onPressed: _isLoading ? null : _solicitarCita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
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
            ],
          ),
        ),
      ),
    );
  }
}