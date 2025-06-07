import 'dart:io';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:app_coldman_sa/utils/custom_snackbar.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class ScreenRegistro extends StatefulWidget {
  @override
  _ScreenRegistroEstado createState() => _ScreenRegistroEstado();
}

class _ScreenRegistroEstado extends State<ScreenRegistro> {
  final Map<String, List<String>> _countryCityMap = {
    'España': [
      'Madrid',
      'Barcelona',
      'Valencia',
      'Sevilla',
      'Zaragoza',
      'Málaga',
      'Murcia',
      'Palma',
      'Las Palmas',
      'Bilbao',
      'Alicante',
      'Córdoba',
      'Valladolid',
      'Vigo',
      'Gijón',
      'Granada',
      'A Coruña',
      'Vitoria',
      'Santa Cruz de Tenerife',
      'Pamplona'
    ],
    'Colombia': [
      'Bogotá',
      'Medellín',
      'Cali',
      'Barranquilla',
      'Cartagena',
      'Cúcuta',
      'Bucaramanga',
      'Pereira',
      'Santa Marta',
      'Ibagué',
      'Pasto',
      'Manizales',
      'Neiva',
      'Soledad',
      'Armenia',
      'Soacha',
      'Villavicencio',
      'Montería'
    ],
    'México': [
      'Ciudad de México',
      'Guadalajara',
      'Monterrey',
      'Puebla',
      'Tijuana',
      'León',
      'Juárez',
      'Torreón',
      'Querétaro',
      'San Luis Potosí',
      'Mérida',
      'Mexicali',
      'Aguascalientes',
      'Cuernavaca',
      'Saltillo',
      'Hermosillo'
    ],
    'Argentina': [
      'Buenos Aires',
      'Córdoba',
      'Rosario',
      'Mendoza',
      'Tucumán',
      'La Plata',
      'Mar del Plata',
      'Salta',
      'Santa Fe',
      'San Juan',
      'Resistencia',
      'Neuquén',
      'Santiago del Estero',
      'Corrientes',
      'Posadas',
      'Bahía Blanca'
    ],
    'Chile': [
      'Santiago',
      'Valparaíso',
      'Concepción',
      'La Serena',
      'Antofagasta',
      'Temuco',
      'Rancagua',
      'Talca',
      'Arica',
      'Chillán',
      'Iquique',
      'Los Ángeles',
      'Puerto Montt',
      'Calama',
      'Copiapó',
      'Osorno'
    ],
    'Perú': [
      'Lima',
      'Arequipa',
      'Trujillo',
      'Chiclayo',
      'Piura',
      'Iquitos',
      'Cusco',
      'Chimbote',
      'Huancayo',
      'Tacna',
      'Juliaca',
      'Ica',
      'Sullana',
      'Ayacucho',
      'Cajamarca',
      'Pucallpa'
    ]
  };

  Logger logger = Logger();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _userController = TextEditingController();

  int _selectedAge = 25;
  String _selectedCity = 'Madrid';
  String _selectedCountry = 'España';
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()
          .subtract(Duration(days: 365 * 25)) // 25 años atrás por defecto
      );
  String _selectedTitle = 'Sr.';
  DateTime _fechaNacimiento = DateTime.now();

  String? imagePath;
  Uint8List? imageBytes;
  bool _hasSelectedImage = false;

  bool _isAdmin = false;
  bool _acceptTerms = false;
  final _apellidosController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _onCountryChanged(String? newCountry) {
    if (newCountry != null) {
      setState(() {
        _selectedCountry = newCountry;
        _selectedCity = _countryCityMap[newCountry]!.first;
      });
    }
  }

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(args.value);
      });
    }
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar Fecha de Nacimiento'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SfDateRangePicker(
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is DateTime) {
                setState(() {
                  _selectedDate = DateFormat('yyyy-MM-dd').format(args.value);
                });
                Navigator.pop(context);
              }
            },
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: DateTime.now(),
            maxDate: DateTime.now(),
            showActionButtons: true,
            confirmText: 'Seleccionar',
            cancelText: 'Cancelar',
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser(ImageUploadProvider imageUploadProvider) async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      if (_selectedDate.isEmpty) {
        CustomSnackBar.showSnackBar(
            context, "Por favor selecciona una fecha de nacimiento",
            color: Constants.errorColor);
        return;
      }

      if (_selectedCountry.isEmpty) {
        CustomSnackBar.showSnackBar(
            context, "Por favor selecciona un país de nacimiento",
            color: Constants.errorColor);
        return;
      }

      if (_selectedCity.isEmpty) {
        CustomSnackBar.showSnackBar(
            context, "Por favor selecciona una ciudad de nacimiento",
            color: Constants.errorColor);
        return;
      }

      try {
        DateTime fechaNacimiento;
        String? finalImagePath;

        try {
          fechaNacimiento = DateTime.parse(_selectedDate);

          if (_hasSelectedImage && imageBytes != null) {
            logger.i('Subiendo imagen de empleado');

            String fileName =
                'empleado_${DateTime.now().millisecondsSinceEpoch}.jpg';

            String? uploadedFileName = await imageUploadProvider
                .uploadEmpleadoImage(imageBytes!, fileName);

            if (uploadedFileName != null) {
              finalImagePath = uploadedFileName;
              logger.i('Imagen empleado subida: $uploadedFileName');
            } else {
              bool? continueAnyway = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Error al subir imagen'),
                  content: Text('¿Deseas continuar el registro sin la imagen?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Continuar sin imagen'),
                    ),
                  ],
                ),
              );

              if (continueAnyway != true) return;
            }
          }
        } catch (e) {
          logger.e('Error parseando fecha: $_selectedDate');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fecha de nacimiento inválida')),
          );
          return;
        }

        final nuevoEmpleado = Empleado(
          nombre: _nombreController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          email: _emailController.text.trim(),
          telefono: _telefonoController.text.trim(),
          trato: _selectedTitle,
          edad: _selectedAge,
          contrasena: _passwordController.text,
          contrasena2: _confirmPasswordController.text,
          administrador: _isAdmin,
          bajaLaboral: false,
          fechaNacimiento: fechaNacimiento, // AQUI USO LA VARIABLE PARSEADA.
          fechaAlta: DateTime.now(),
          lugarNacimiento: _selectedCity,
          paisNacimiento: _selectedCountry,
          imagenUsuario: finalImagePath ?? '',
        );

        final empleadoProvider =
            Provider.of<EmpleadoProvider>(context, listen: false);
        empleadoProvider.addEmpleado(nuevoEmpleado);

        Navigator.pop(context);

        CustomSnackBar.showSnackBar(context, "Usuario registrado exitosamente",
            color: Constants.successColor);
      } catch (e) {
        logger.e('Error al crear empleado: $e');
        CustomSnackBar.showSnackBar(context, "Error al registrar usuario: $e",
            color: Constants.errorColor);
      }
    } else {
      CustomSnackBar.showSnackBar(
          context, "Por favor completa todos los campos y acepta los términos",
          color: Constants.errorColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageUploadProvider>(
        builder: (context, imageUploadProvider, child) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Registro de Empleado'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGEN EMPLEADO.
                  _buildCompactImageSection(imageUploadProvider),

                  // TRATAMIENTO EMPLEADO.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'Sr.',
                        groupValue: _selectedTitle,
                        onChanged: (value) =>
                            setState(() => _selectedTitle = value!),
                      ),
                      Text('Sr.'),
                      Radio<String>(
                        value: 'Sra.',
                        groupValue: _selectedTitle,
                        onChanged: (value) =>
                            setState(() => _selectedTitle = value!),
                      ),
                      Text('Sra.'),
                    ],
                  ),

                  SizedBox(height: 15),

                  // NOMBRE EMPLEADO.
                  TextFormField(
                    controller: _nombreController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese su nombre' : null,
                  ),

                  SizedBox(height: 15),

                  // APELLIDOS EMPLEADO.
                  TextFormField(
                    controller: _apellidosController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: 'Apellidos *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese sus apellidos' : null,
                  ),

                  SizedBox(height: 15),

                  // EMAIL EMPLEADO.
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese su email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 15),

                  // TELEFONO EMPLEADO.
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    maxLength: 12,
                    decoration: InputDecoration(
                      labelText: 'Teléfono *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Ingrese su teléfono' : null,
                  ),

                  SizedBox(height: 15),

                  // COTRASEÑA EMPLEADO.
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),

                  SizedBox(height: 15),

                  // REPETIR CONTRASEÑA EMPLEADO.
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    maxLength: 15,
                    decoration: InputDecoration(
                      labelText: 'Repetir Contraseña *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value != _passwordController.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),

                  SizedBox(height: 20),

                  // PAIS.
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: InputDecoration(
                      labelText: 'País de Nacimiento *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onCountryChanged,
                    items: _countryCityMap.keys
                        .map<DropdownMenuItem<String>>((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 15),

                  // CIUDAD.
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      labelText: 'Ciudad de Nacimiento *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        setState(() => _selectedCity = value!),
                    items: _countryCityMap[_selectedCountry]!
                        .map<DropdownMenuItem<String>>((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 20),

                  // FECHA NACIMIENTO.
                  Text('Fecha de Nacimiento *',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () => showDatePicker(),
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(_selectedDate)),
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.calendar_today,
                              color: Colors.grey.shade600, size: 20),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // EDAD.
                  Text('Edad *',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Center(
                    child: NumberPicker(
                      value: _selectedAge,
                      minValue: 18,
                      maxValue: 65,
                      onChanged: (value) =>
                          setState(() => _selectedAge = value),
                      textStyle: TextStyle(fontSize: 14),
                      selectedTextStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  SizedBox(height: 15),

                  // CHECKBOX ADMINISTRADOR.
                  Row(
                    children: [
                      Checkbox(
                        value: _isAdmin,
                        onChanged: (value) => setState(() => _isAdmin = value!),
                      ),
                      Text('¿Es administrador?'),
                    ],
                  ),

                  // TERMINOS Y CONDICIONES.
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) =>
                            setState(() => _acceptTerms = value!),
                      ),
                      Expanded(
                          child: Text('Acepto los términos y condiciones *')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: imageUploadProvider.isUploading
                ? null
                : () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: (imageUploadProvider.isUploading || !_acceptTerms)
                ? null
                : () => _registerUser(imageUploadProvider),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: imageUploadProvider.isUploading
                  ? Colors.grey
                  : Colors.blueAccent,
            ),
            child: imageUploadProvider.isUploading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text('Registrando...'),
                    ],
                  )
                : Text('Registrar'),
          ),
        ],
      );
    });
  }

  void showDatePicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha de Nacimiento',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close)),
                ],
              ),
              Divider(),
              Expanded(
                child: SfDateRangePicker(
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is DateTime) {
                      setState(() {
                        _selectedDate =
                            DateFormat('yyyy-MM-dd').format(args.value);
                      });
                    }
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: DateTime.parse(_selectedDate),
                  maxDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                  minDate: DateTime.now().subtract(Duration(days: 365 * 80)),
                  showActionButtons: false,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDate.isNotEmpty) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Confirmar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET SECCION DE IMAGEN COMPACTA PARA DIALOG.
  Widget _buildCompactImageSection(ImageUploadProvider imageUploadProvider) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: imageUploadProvider.isUploading ? null : _selectImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: _getImageProvider(),
                      backgroundColor: Colors.grey[300],
                      child: (_getImageProvider() == null)
                          ? Icon(Icons.camera_alt,
                              size: 24, color: Colors.grey[600])
                          : null,
                    ),
                    if (imageUploadProvider.isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    if (!imageUploadProvider.isUploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              _hasSelectedImage ? Icons.edit : Icons.add,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foto de Perfil',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    if (imageUploadProvider.isUploading)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                          SizedBox(width: 6),
                          Text('Procesando...', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    else if (imageUploadProvider.uploadError != null)
                      Text(
                        imageUploadProvider.uploadError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (_hasSelectedImage)
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Imagen seleccionada',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      )
                    else
                      Text(
                        'Toca para agregar foto',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // METODO PARA OBTENER ImageProvider.
  ImageProvider? _getImageProvider() {
    if (kIsWeb && imageBytes != null) {
      return MemoryImage(imageBytes!);
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('assets/')) {
        return AssetImage(imagePath!);
      } else if (!kIsWeb) {
        return FileImage(File(imagePath!));
      }
    }

    return null;
  }

  // METODO PARA SELECCIONAR IMAGEN.
  Future<void> _selectImage() async {
    try {
      final result = await Images.selectImage();
      if (result != null) {
        setState(() {
          imagePath = result['path'];
          imageBytes = result['bytes'];
          _hasSelectedImage = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al seleccionar imagen: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEmployeeRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScreenRegistro(),
    );
    logger.i('Empleado registrado correctamente.');
  }
}
