import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/data/models/empleado_model.dart';
import 'package:app_coldman_sa/utils/images.dart';
import 'package:app_coldman_sa/utils/constants.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/utils/custom_dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ScreenGestionUsuarios extends StatefulWidget {
  const ScreenGestionUsuarios({super.key, required this.currentAdmin});
  final Empleado currentAdmin;

  @override
  _ScreenEstadoGestionUsuarios createState() => _ScreenEstadoGestionUsuarios();
}

class _ScreenEstadoGestionUsuarios extends State<ScreenGestionUsuarios> {
  Logger logger = Logger();

  void _createUser() {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final apellidosController = TextEditingController();
    final emailController = TextEditingController();
    final telefonoController = TextEditingController();
    final userController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // VARIABLES DE ESTADO.
    String selectedTitle = 'Sr.';
    String selectedCountry = 'España';
    String selectedCity = 'Madrid';
    String selectedDate = '';
    int selectedAge = 25;
    bool isAdmin = false;
    bool acceptTerms = false;
    String? imagePath;

    // MAPA DE PAISES Y CIUDADES.
    final Map<String, List<String>> countryCityMap = {
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

    void onCountryChanged(String? newCountry, StateSetter setDialogState) {
      if (newCountry != null) {
        setDialogState(() {
          selectedCountry = newCountry;
          selectedCity = countryCityMap[newCountry]!.first;
        });
      }
    }

    void showDatePicker(
        BuildContext dialogContext, StateSetter setDialogState) {
      showDialog(
        context: dialogContext,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // HEADER.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fecha de Nacimiento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(),

                // DATEPICKER.
                Expanded(
                  child: SfDateRangePicker(
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      if (args.value is DateTime) {
                        setDialogState(() {
                          selectedDate =
                              DateFormat('yyyy-MM-dd').format(args.value);
                        });
                      }
                    },
                    selectionMode: DateRangePickerSelectionMode.single,
                    initialSelectedDate: selectedDate.isNotEmpty
                        ? DateTime.parse(selectedDate)
                        : DateTime.now().subtract(Duration(days: 365 * 25)),
                    maxDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                    minDate: DateTime.now().subtract(Duration(days: 365 * 80)),
                    showActionButtons: false,
                    headerStyle: DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selectionTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectionColor: Colors.blueAccent,
                    todayHighlightColor: Colors.blueAccent.shade100,
                  ),
                ),

                // CUSTOM BUTTONS.
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedDate.isNotEmpty) {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Por favor selecciona una fecha'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
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

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text("Crear Nuevo Usuario"),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.9,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TRATMIENTO EMPLEADO.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'Sr.',
                            groupValue: selectedTitle,
                            onChanged: (value) =>
                                setDialogState(() => selectedTitle = value!),
                          ),
                          Text('Sr.'),
                          Radio<String>(
                            value: 'Sra.',
                            groupValue: selectedTitle,
                            onChanged: (value) =>
                                setDialogState(() => selectedTitle = value!),
                          ),
                          Text('Sra.'),
                        ],
                      ),

                      SizedBox(height: 15),

                      // FOTO DE PERFIL EMPLEADO
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() =>
                                imagePath = Images.getDefaultImage(isAdmin));
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: imagePath != null
                                ? Images.getImageProvider(imagePath!)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: imagePath == null
                                ? Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey[600])
                                : null,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // NOMBRE DEL EMPLEADO
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Ingrese el nombre' : null,
                      ),

                      SizedBox(height: 15),

                      // APELLIDOS DEL EMPLEADO.
                      TextFormField(
                        controller: apellidosController,
                        decoration: InputDecoration(
                          labelText: 'Apellidos *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Ingrese los apellidos' : null,
                      ),

                      SizedBox(height: 15),

                      // EMAIL DEL EMPLEADO.
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Ingrese el email';
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
                        controller: telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Ingrese el teléfono' : null,
                      ),

                      SizedBox(height: 15),

                      // Usuario
                      TextFormField(
                        controller: userController,
                        decoration: InputDecoration(
                          labelText: 'Usuario *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Ingrese un usuario' : null,
                      ),

                      SizedBox(height: 15),

                      // CONTRASEÑA EMPLEADO.
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),

                      SizedBox(height: 15),

                      // CONFIRMAR CONTRASEÑA EMPLEADO.
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Repetir Contraseña *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value != passwordController.text
                            ? 'Las contraseñas no coinciden'
                            : null,
                      ),

                      SizedBox(height: 20),

                      // PAIS DE NACIMIENTO.
                      DropdownButtonFormField<String>(
                        value: selectedCountry,
                        decoration: InputDecoration(
                          labelText: 'País de Nacimiento *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            onCountryChanged(value, setDialogState),
                        items: countryCityMap.keys
                            .map<DropdownMenuItem<String>>((String country) {
                          return DropdownMenuItem<String>(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 15),

                      // CIUDAD DE NACIMIENTO.
                      DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: InputDecoration(
                          labelText: 'Ciudad de Nacimiento *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            setDialogState(() => selectedCity = value!),
                        items: countryCityMap[selectedCountry]!
                            .map<DropdownMenuItem<String>>((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),

                      // FECHA DE NACIMIENTO.
                      Text('Fecha de Nacimiento *',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () =>
                            showDatePicker(dialogContext, setDialogState),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedDate.isEmpty
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedDate.isEmpty
                                      ? 'Seleccionar fecha de nacimiento'
                                      : DateFormat('dd/MM/yyyy')
                                          .format(DateTime.parse(selectedDate)),
                                  style: TextStyle(
                                    color: selectedDate.isEmpty
                                        ? Colors.red.shade600
                                        : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: selectedDate.isEmpty
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: selectedDate.isEmpty
                                    ? Colors.red
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // EDAD DEL EMPLEADO.
                      Text('Edad *',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      Center(
                        child: NumberPicker(
                          value: selectedAge,
                          minValue: 18,
                          maxValue: 65,
                          onChanged: (value) =>
                              setDialogState(() => selectedAge = value),
                          textStyle: TextStyle(fontSize: 14),
                          selectedTextStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                      SizedBox(height: 15),

                      // ADMINISTRADOR
                      Row(
                        children: [
                          Checkbox(
                            value: isAdmin,
                            onChanged: (value) => setDialogState(() {
                              isAdmin = value!;
                              imagePath = Images.getDefaultImage(isAdmin);
                            }),
                          ),
                          Text('¿Es administrador?'),
                        ],
                      ),

                      // TERMINOS Y CONDICIONES.
                      Row(
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            onChanged: (value) =>
                                setDialogState(() => acceptTerms = value!),
                          ),
                          Expanded(child: Text('Acepto crear este usuario *')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // VALIDACIONES DEL FORMULARIO.
                  if (!formKey.currentState!.validate()) {
                    CustomDialogs.showSnackBar(context,
                        'Por favor completa todos los campos correctamente',
                        color: Constants.errorColor);
                    return;
                  }

                  if (selectedDate.isEmpty) {
                    CustomDialogs.showSnackBar(
                        context, 'Por favor selecciona una fecha de nacimiento',
                        color: Constants.errorColor);
                    return;
                  }

                  if (!acceptTerms) {
                    CustomDialogs.showSnackBar(
                        context, 'Debes aceptar crear este usuario',
                        color: Constants.errorColor);
                    return;
                  }

                  await CustomDialogs.showLoadingSpinner(context);

                  try {
                    // CREAR NUEVO EMPLEADO CON TODOS LOS DATOS.
                    Empleado newEmployee = Empleado(
                      nombre: nombreController.text.trim(),
                      apellidos: apellidosController.text.trim(),
                      email: emailController.text.trim(),
                      telefono: telefonoController.text.trim(),
                      trato: selectedTitle,
                      edad: selectedAge,
                      contrasena: passwordController.text,
                      contrasena2: confirmPasswordController.text,
                      administrador: isAdmin,
                      bajaLaboral: false,
                      fechaNacimiento: DateTime.parse(selectedDate),
                      fechaAlta: DateTime.now(),
                      lugarNacimiento: selectedCity,
                      paisNacimiento: selectedCountry,
                      imagenUsuario:
                          imagePath ?? Images.getDefaultImage(isAdmin),
                    );

                    final empleadoProvider =
                        Provider.of<EmpleadoProvider>(context, listen: false);
                    await empleadoProvider.addEmpleado(newEmployee);

                    Navigator.pop(dialogContext);
                    setState(() {});

                    CustomDialogs.showSnackBar(
                        context, "Usuario creado correctamente",
                        color: Constants.successColor);
                  } catch (e) {
                    Navigator.pop(context); // CERRAR LOADING.
                    CustomDialogs.showSnackBar(
                        context, "Error al crear usuario: $e",
                        color: Constants.errorColor);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Crear Usuario"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editEmpleado(Empleado empleado) {
    // CONTROLLERS INICIALIZADOS CON DATOS EXISTENTES DEL EMPLEADO QUE SE SELECCIONE AL ACTUALIZAR.
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: empleado.nombre);
    final apellidosController = TextEditingController(text: empleado.apellidos);
    final emailController = TextEditingController(text: empleado.email);
    final telefonoController = TextEditingController(text: empleado.telefono);
    final passwordController = TextEditingController(text: empleado.contrasena);
    final confirmPasswordController =
        TextEditingController(text: empleado.contrasena);

    // VARIABLES DE ESTADO INICIALIZADOS CON DATOS EXISTENTES DEL EMPLEADO QUE SE SELECCIONE AL ACTUALIZAR.
    String selectedTitle = empleado.trato;
    String selectedCountry =
        empleado.paisNacimiento.isNotEmpty ? empleado.paisNacimiento : 'España';
    String selectedCity = empleado.lugarNacimiento.isNotEmpty
        ? empleado.lugarNacimiento
        : 'Madrid';
    String selectedDate =
        DateFormat('yyyy-MM-dd').format(empleado.fechaNacimiento);
    int selectedAge = empleado.edad;
    bool isAdmin = empleado.administrador;
    String? imagePath = empleado.imagenUsuario;
    Uint8List? imageBytes; // ✅ NUEVO: Para manejar bytes en web

    // MAPA DE PAISES Y CIUDADES PARA ACTUALIZAR DATOS DEL EMPLEADO.
    final Map<String, List<String>> countryCityMap = {
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

    // VERIFICAR QUE EL PAIS Y LA CIUDAD ESTAN SELECCIONADOS.
    if (!countryCityMap[selectedCountry]!.contains(selectedCity)) {
      selectedCity = countryCityMap[selectedCountry]!.first;
    }

    void onCountryChanged(String? newCountry, StateSetter setDialogState) {
      if (newCountry != null) {
        setDialogState(() {
          selectedCountry = newCountry;
          selectedCity = countryCityMap[newCountry]!.first;
        });
      }
    }

    void showDatePicker(
        BuildContext dialogContext, StateSetter setDialogState) {
      showDialog(
        context: dialogContext,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                        setDialogState(() {
                          selectedDate =
                              DateFormat('yyyy-MM-dd').format(args.value);
                        });
                      }
                    },
                    selectionMode: DateRangePickerSelectionMode.single,
                    initialSelectedDate: DateTime.parse(selectedDate),
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
                        if (selectedDate.isNotEmpty) {
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

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Consumer<ImageUploadProvider>(
              builder: (context, imageUploadProvider, child) {
            return AlertDialog(
              title: Text("Editar Usuario - ${empleado.nombre}"),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TRATAMIENTO ACTUALIZAR.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<String>(
                              value: 'Sr.',
                              groupValue: selectedTitle,
                              onChanged: (value) =>
                                  setDialogState(() => selectedTitle = value!),
                            ),
                            Text('Sr.'),
                            Radio<String>(
                              value: 'Sra.',
                              groupValue: selectedTitle,
                              onChanged: (value) =>
                                  setDialogState(() => selectedTitle = value!),
                            ),
                            Text('Sra.'),
                          ],
                        ),

                        SizedBox(height: 15),

                        if (imageUploadProvider.isUploading)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                SizedBox(width: 10),
                                Text('Subiendo imagen...'),
                              ],
                            ),
                          ),

                        if (imageUploadProvider.uploadError != null)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              imageUploadProvider.uploadError!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                        // IMAGEN EMPLEADO ACTUALIZAR.
                        Center(
                          child: GestureDetector(
                            onTap: imageUploadProvider.isUploading
                                ? null
                                : () {
                                    _showImageOptionsForEdit(setDialogState,
                                        (newImagePath, newImageBytes) {
                                      setDialogState(() {
                                        imagePath = newImagePath;
                                        imageBytes = newImageBytes;
                                      });
                                    });
                                  },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      Images.getImageProviderUnified(
                                          imagePath, imageBytes,
                                          category: 'empleados'),
                                  backgroundColor: Colors.grey[300],
                                  child:
                                      (imagePath == null && imageBytes == null)
                                          ? Icon(Icons.camera_alt,
                                              size: 40, color: Colors.grey[600])
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
                                // Edit indicator
                                if (!imageUploadProvider.isUploading)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: Icon(Icons.edit,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),

                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // NOMBRE ACTUALIZAR.
                        TextFormField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese el nombre' : null,
                        ),

                        SizedBox(height: 15),

                        // APELLIDOS ACTUALIZAR.
                        TextFormField(
                          controller: apellidosController,
                          decoration: InputDecoration(
                            labelText: 'Apellidos *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese los apellidos' : null,
                        ),

                        SizedBox(height: 15),

                        // EMAIL ACTUALIZAR.
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Ingrese el email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 15),

                        // TELEFONO ACTUALIZAR.
                        TextFormField(
                          controller: telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Teléfono *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Ingrese el teléfono' : null,
                        ),

                        SizedBox(height: 15),

                        // CONTRASEÑA ACTUALIZAR.
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),

                        SizedBox(height: 15),

                        // REPETIR CONTRASEÑA ACTUALIZAR.
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Repetir Contraseña *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value != passwordController.text
                              ? 'Las contraseñas no coinciden'
                              : null,
                        ),

                        SizedBox(height: 20),

                        // ACTUALIZAR PAIS.
                        DropdownButtonFormField<String>(
                          value: selectedCountry,
                          decoration: InputDecoration(
                            labelText: 'País de Nacimiento *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              onCountryChanged(value, setDialogState),
                          items: countryCityMap.keys
                              .map<DropdownMenuItem<String>>((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 15),

                        // ACTUALIZAR CIUDAD.
                        DropdownButtonFormField<String>(
                          value: selectedCity,
                          decoration: InputDecoration(
                            labelText: 'Ciudad de Nacimiento *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              setDialogState(() => selectedCity = value!),
                          items: countryCityMap[selectedCountry]!
                              .map<DropdownMenuItem<String>>((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20),

                        // ACTUALIZAR FECHA NACIMIENTO.
                        Text('Fecha de Nacimiento *',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () =>
                              showDatePicker(dialogContext, setDialogState),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
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
                                        .format(DateTime.parse(selectedDate)),
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

                        // ACTUALIZAR EDAD.
                        Text('Edad *',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Center(
                          child: NumberPicker(
                            value: selectedAge,
                            minValue: 18,
                            maxValue: 65,
                            onChanged: (value) =>
                                setDialogState(() => selectedAge = value),
                            textStyle: TextStyle(fontSize: 14),
                            selectedTextStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [
                            Checkbox(
                              value: isAdmin,
                              onChanged: (value) => setDialogState(() {
                                isAdmin = value!;
                                imagePath = Images.getDefaultImage(isAdmin);
                              }),
                            ),
                            Text('¿Es administrador?'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      CustomDialogs.showSnackBar(context,
                          'Por favor completa todos los campos correctamente',
                          color: Constants.errorColor);
                      return;
                    }

                    await CustomDialogs.showLoadingSpinner(context);

                    try {
                      String? finalImagePath = imagePath;

                      if (imageBytes != null) {
                        logger.i(
                            'Subiendo nueva imagen del empleado al servidor');

                        String fileName =
                            'empleado_${empleado.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

                        // ✅ USAR EL SISTEMA DE UPLOAD QUE IMPLEMENTAMOS
                        String? uploadedFileName = await imageUploadProvider
                            .uploadEmpleadoImage(imageBytes!, fileName);

                        if (uploadedFileName != null) {
                          finalImagePath = uploadedFileName;
                          logger.i(
                              'Imagen empleado subida correctamente: $uploadedFileName');
                        } else {
                          Navigator.pop(context);
                          CustomDialogs.showSnackBar(context,
                              "Error al subir la imagen: ${imageUploadProvider.uploadError ?? 'Error desconocido'}",
                              color: Constants.errorColor);
                          return;
                        }
                      }

                      // CREAR EMPLEADO EDITADO CON LOS DATOS NUEVOS DE ACTUALIZACION.
                      Empleado empleadoEditado = empleado.copyWith(
                        nombre: nombreController.text.trim(),
                        apellidos: apellidosController.text.trim(),
                        email: emailController.text.trim(),
                        telefono: telefonoController.text.trim(),
                        trato: selectedTitle,
                        edad: selectedAge,
                        contrasena: passwordController.text,
                        contrasena2: confirmPasswordController.text,
                        administrador: isAdmin,
                        fechaNacimiento: DateTime.parse(selectedDate),
                        lugarNacimiento: selectedCity,
                        paisNacimiento: selectedCountry,
                        imagenUsuario: finalImagePath,
                      );

                      final empleadoProvider =
                          Provider.of<EmpleadoProvider>(context, listen: false);
                      await empleadoProvider.updateEmpleado(
                          empleado.id.toString(), empleadoEditado);

                      Navigator.pop(dialogContext);
                      setState(() {});

                      CustomDialogs.showSnackBar(
                          context, "Usuario actualizado correctamente",
                          color: Constants.successColor);
                    } catch (e) {
                      Navigator.pop(context);
                      CustomDialogs.showSnackBar(
                          context, "Error al actualizar usuario: $e",
                          color: Constants.errorColor);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Guardar Cambios"),
                ),
              ],
            );
          });
        },
      ),
    );
  }

  // METODO PARA MOSTRAR OPCIONES DE IMAGEN
  Future<void> _showImageOptionsForEdit(Function setDialogState,
      Function(String?, Uint8List?) onImageSelected) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de galería'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGalleryForEdit(
                      setDialogState, onImageSelected);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromCameraForEdit(
                        setDialogState, onImageSelected);
                  },
                ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Imagen por defecto'),
                onTap: () {
                  Navigator.pop(context);
                  String defaultImage = Images.getDefaulCustomer();
                  onImageSelected(defaultImage, null);
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpleadoAvatar(Empleado empleado) {
    logger.e('Construyendo avatar para empleado ${empleado.id}');
    logger.e('imagenUsuario: "${empleado.imagenUsuario}"');

    bool hasImage = empleado.imagenUsuario != null &&
        empleado.imagenUsuario.isNotEmpty &&
        empleado.imagenUsuario != '' &&
        empleado.imagenUsuario != 'null';

    if (hasImage) {
      String imageUrl =
          'http://localhost:8080/api_coldman/v1/images/empleados/${empleado.imagenUsuario}';
      logger.i('URL de imagen: $imageUrl');

      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[200],
        onBackgroundImageError: (error, stackTrace) {
          logger.e('Error cargando imagen empleado ${empleado.id}: $error');
          logger.e('URL que falló: $imageUrl');
        },
        child: null,
      );
    } else {
      logger
          .i('Empleado ${empleado.id} sin imagen, mostrando ícono por defecto');
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          color: Colors.grey[600],
          size: 24,
        ),
      );
    }
  }

  // METODO PARA SELECCIONAR IMAGEN DESDE LA GALERIA.
  Future<void> _pickImageFromGalleryForEdit(Function setDialogState,
      Function(String?, Uint8List?) onImageSelected) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (kIsWeb) {
          // ✅ Para web: usar bytes
          if (file.bytes != null) {
            logger.i(
                'Imagen seleccionada en web: ${file.name}, bytes: ${file.bytes!.length}');
            onImageSelected(file.name, file.bytes);
          } else {
            logger.e('Error: file.bytes es null');
          }
        } else {
          if (file.path != null) {
            logger.i('Imagen seleccionada en móvil: ${file.path}');
            onImageSelected(file.path, null);
          } else {
            logger.e('Error: file.path es null');
          }
        }
      } else {
        logger.i('No se seleccionó ningún archivo');
      }
    } catch (e) {
      logger.e('Error al seleccionar imagen: $e');
      _showErrorMessage('Error al seleccionar imagen: $e');
    }
  }

  // METODO PARA SELECCIONAR IMAGEN DE LA CAMARA.
  Future<void> _pickImageFromCamera(
      Function setDialogState, Function(String?) onImageSelected) async {
    if (kIsWeb) {
      _showErrorMessage('La cámara no está disponible en web');
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        onImageSelected(image.path);
        setDialogState(() {});
      }
    } catch (e) {
      _showErrorMessage('Error al tomar foto: $e');
    }
  }

  // METODO PARA SELECCIONAR IMAGEN DE LA CAMARA PARA ACTUALIZAR.
  Future<void> _pickImageFromCameraForEdit(Function setDialogState,
      Function(String?, Uint8List?) onImageSelected) async {
    if (kIsWeb) {
      _showErrorMessage('La cámara no está disponible en web');
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        logger.i('Foto tomada: ${image.path}'); // Debug
        onImageSelected(image.path, null);
      }
    } catch (e) {
      logger.e('Error al tomar foto: $e'); // Debug
      _showErrorMessage('Error al tomar foto: $e');
    }
  }

  // METODO PARA SELECCIONAR IMAGEN DE LA WEB.
  Future<void> _selectImageWeb(Function setDialogState) async {
    try {
      String? imagePath;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setDialogState(() {
          imagePath = result.files.first.name;
        });
      }
    } catch (e) {
      _showErrorMessage('Error al seleccionar imagen: $e');
    }
  }

  // METODO PARA MOSTRAR MENSAJES DE ERROR.
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empleadoProvider = Provider.of<EmpleadoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: empleadoProvider.empleados.length,
        itemBuilder: (context, index) {
          if (index >= empleadoProvider.empleados.length) {
            return const SizedBox.shrink();
          }

          final empleado = empleadoProvider.empleados[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: _buildEmpleadoAvatar(empleado),
              title: Row(
                children: [
                  Text(
                      "${empleadoProvider.empleados[index].nombre} ${empleadoProvider.empleados[index].apellidos}"),
                  if (empleadoProvider.empleados[index].administrador)
                    const SizedBox(width: 4),
                  if (empleadoProvider.empleados[index].administrador)
                    Constants.adminBadge,
                ],
              ),
              subtitle: Text(
                  "${empleadoProvider.empleados[index].trato}-${empleadoProvider.empleados[index].edad} años - ${empleadoProvider.empleados[index].lugarNacimiento}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _editEmpleado(empleadoProvider.empleados[index]),
                  ),
                  IconButton(
                    icon: Icon(
                      empleadoProvider.empleados[index].bajaLaboral!
                          ? Icons.personal_injury
                          : Icons.person_sharp,
                      color: empleadoProvider.empleados[index].bajaLaboral!
                          ? Colors.red
                          : Colors.green,
                    ),
                    tooltip: empleadoProvider.empleados[index].bajaLaboral!
                        ? "Se ha cambiado la disponibilidad del empleado a baja laboral"
                        : "El empleado actualmente está disponible para trabajar",
                    onPressed: () async {
                      Empleado empleadoActual =
                          empleadoProvider.empleados[index];
                      bool nuevoEstado = !empleadoActual.bajaLaboral!;

                      Empleado empleadoActualizado =
                          empleadoActual.copyWith(bajaLaboral: nuevoEstado);

                      await empleadoProvider.updateEmpleado(
                          empleadoActual.id.toString(), empleadoActualizado);

                      CustomDialogs.showSnackBar(
                        context,
                        nuevoEstado
                            ? "Empleado marcado como de baja"
                            : "Empleado disponible",
                        color: nuevoEstado
                            ? Constants.errorColor
                            : Constants.successColor,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirm = await CustomDialogs.showConfirmDialog(
                          context: context,
                          title: "Confirmar eliminación",
                          content:
                              "¿Está seguro de eliminar a ${empleadoProvider.empleados[index].nombre}?",
                          style: Text(''));

                      if (confirm == true) {
                        await CustomDialogs.showLoadingSpinner(context);
                        empleadoProvider.deleteEmpleado(
                            empleadoProvider.empleados[index].id!);
                        setState(() {});
                        CustomDialogs.showSnackBar(
                            context, "Usuario eliminado correctamente",
                            color: Constants.successColor);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
