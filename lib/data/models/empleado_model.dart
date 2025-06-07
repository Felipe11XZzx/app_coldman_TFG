import 'package:app_coldman_sa/data/models/servicio_model.dart';

class Empleado {

  final bool? bajaLaboral;
  final bool administrador;
  final String apellidos;
  final String contrasena;
  final String contrasena2;
  final int edad;
  final String email;
  final DateTime fechaAlta;
  final DateTime fechaNacimiento;
  final int? id;
  final String imagenUsuario;
  final String lugarNacimiento;
  final String nombre;
  final String paisNacimiento;
  final String telefono;
  final String trato;

  Empleado({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.trato,
    required this.edad,
    required this.contrasena,
    required this.contrasena2,
    required this.administrador,
    this.bajaLaboral = false,
    required this.fechaAlta,
    required this.fechaNacimiento,
    required this.lugarNacimiento,
    required this.paisNacimiento,
    required this.imagenUsuario
  });
  factory Empleado.empty() {
    return Empleado(
      nombre: '', 
      apellidos: '', 
      email: '', 
      telefono: '', 
      trato: '', 
      edad: 0,
      contrasena: '', 
      contrasena2: '', 
      administrador: false, 
      fechaAlta: DateTime.now(), 
      fechaNacimiento: DateTime.now(),
      bajaLaboral: false,
      lugarNacimiento: '', 
      paisNacimiento: '',
      imagenUsuario: '');
  }

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id_empleado'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      trato: json['trato'] ?? '',
      edad: json['edad'] ?? 0,
      contrasena: json['contrasena'] ?? '',
      contrasena2: '', 
      administrador: json['administrador'] ?? false,
      bajaLaboral: json['baja_laboral'] ?? false,
      lugarNacimiento: json['lugar_nacimiento'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null ? DateTime.fromMillisecondsSinceEpoch(json['fecha_nacimiento']) : DateTime.now(),
      paisNacimiento: json['pais_nacimiento'] ?? '',
      fechaAlta: json['fecha_alta'] != null ? DateTime.fromMillisecondsSinceEpoch(json['fecha_alta']) : DateTime.now(),
      imagenUsuario: json['imagen_usuario'] ?? '',
    );
  }


  Empleado copyWith({
    int? id,
    String? nombre,
    String? apellidos,
    String? email,
    String? telefono,
    String? trato,
    int? edad,
    String? contrasena,
    String? contrasena2,
    bool? administrador,
    bool? bajaLaboral,
    DateTime? fechaNacimiento,
    String? lugarNacimiento,
    String? paisNacimiento,
    DateTime? fechaAlta,
    String? imagenUsuario,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre, 
      apellidos: apellidos ?? this.apellidos, 
      email: email ?? this.email, 
      telefono: telefono ?? this.telefono, 
      trato: trato ?? this.trato, 
      edad: edad ?? this.edad, 
      contrasena: contrasena ?? this.contrasena, 
      contrasena2: contrasena2 ?? this.contrasena2, 
      administrador: administrador ?? this.administrador, 
      fechaAlta: fechaAlta ?? this.fechaAlta, 
      bajaLaboral: bajaLaboral ?? this.bajaLaboral,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      lugarNacimiento: lugarNacimiento ?? this.lugarNacimiento, 
      paisNacimiento: paisNacimiento ?? this.paisNacimiento,
      imagenUsuario: imagenUsuario ?? this.imagenUsuario
    );
  }

  // GETTERS DEL MODELO EMPLEADO.
  bool getAdministrador() => administrador;
  String getApellido() => apellidos;
  bool getBajaLaboral() => bajaLaboral ?? false;
  int getEdad() => edad;
  String getEmail() => email;
  DateTime getFechaAlta() => fechaAlta;
  DateTime getFechaNacimiento() => fechaNacimiento;
  int getId() => id!;
  int getidEmpleado() => id!;
  String getImagenUsuario() => imagenUsuario;
  String getLugarNacimiento() => lugarNacimiento;
  String getNombre() => nombre;
  String getPaisNacimiento() => paisNacimiento;
  String getPass() => contrasena;
  String getTelefono() => telefono;
  String getTrato() => trato;

  // METODO PARA CONVERTIR EL OBJETO A JSON.
  Map<String, dynamic> toJson() {
    return {
      'id_empleado': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'trato': trato,
      'edad': edad,
      'contrasena': contrasena,
      'administrador': administrador,
      'baja_laboral': bajaLaboral ?? false,
      'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'lugar_nacimiento': lugarNacimiento,
      'pais_nacimiento': paisNacimiento,
      'fecha_alta': fechaAlta.toIso8601String().split('T')[0],
      'imagen_usuario': imagenUsuario,
    };
  }  
  // ESTE METODO ESPECIFICO PARA EL REGISTRO DE USUARIOS SIN PASAR EL ID.
  Map<String, dynamic> toJsonForRegistration() {
  return {
    'nombre': nombre,
    'apellidos': apellidos,
    'email': email,
    'telefono': telefono,
    'trato': trato,
    'edad': edad,
    'contrasena': contrasena,
    'administrador': administrador,
    'baja_laboral': bajaLaboral ?? false,
    'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0],
    'lugar_nacimiento': lugarNacimiento.isNotEmpty ? lugarNacimiento : null,
    'pais_nacimiento': paisNacimiento.isNotEmpty ? paisNacimiento : null,
    'fecha_alta': fechaAlta.toIso8601String().split('T')[0],
    'imagen_usuario': imagenUsuario.isNotEmpty ? imagenUsuario : null,
    };
  }
}