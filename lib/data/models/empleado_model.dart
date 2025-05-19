
class Empleado {
  final int? id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String trato;
  final int edad;
  final String contrasena;
  final String contrasena2;
  final bool ?bloqueado;
  final bool administrador;
  final bool ?bajaLaboral;
  final String lugarNacimiento;
  final DateTime fechaAlta;
  final String imagenUsuario;

  Empleado({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.trato,
    required this.edad,
    required this.contrasena,
    required this.contrasena2,
    required this.bloqueado,
    required this.administrador,
    this.bajaLaboral = false,
    required this.fechaAlta,
    required this.lugarNacimiento,
    required this.imagenUsuario
  });

  factory Empleado.empty() {
    return Empleado(
      nombre: '', 
      apellido: '', 
      email: '', 
      telefono: '', 
      trato: '', 
      edad: 0,
      contrasena: '', 
      contrasena2: '', 
      bloqueado: false, 
      administrador: false, 
      fechaAlta: DateTime.now(), 
      lugarNacimiento: '', 
      imagenUsuario: '');
  }

  Empleado copyWith ({
    int? id,
    String ?nombre,
    String ?apellido,
    String ?email,
    String ?telefono,
    String ?trato,
    int ?edad,
    String ?contrasena,
    String ?contrasena2,
    bool ?bloqueado,
    bool ?administrador,
    bool ?bajaLaboral,
    String ?lugarNacimiento,
    DateTime ?fechaAlta,
    String ?imagenUsuario,
  }) {
    return Empleado(
      nombre: nombre ?? this.nombre, 
      apellido: apellido ?? this.apellido, 
      email: email ?? this.email, 
      telefono: telefono ?? this.telefono, 
      trato: trato ?? this.trato, 
      edad: edad ?? this.edad, 
      contrasena: contrasena ?? this.contrasena, 
      contrasena2: contrasena2 ?? this.contrasena2, 
      bloqueado: bloqueado ?? this.bloqueado, 
      administrador: administrador ?? this.administrador, 
      fechaAlta: fechaAlta ?? this.fechaAlta, 
      lugarNacimiento: lugarNacimiento ?? this.lugarNacimiento, 
      imagenUsuario: imagenUsuario ?? this.imagenUsuario);
  }

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      trato: json['trato'] ?? '',
      edad: json['edad'] ?? 0,
      contrasena: json['contrasena'] ?? '',
      contrasena2: json['contrasena2'] ?? '',
      bloqueado: json['bloqueado'] ?? false,
      administrador: json['administrador'] ?? false,
      bajaLaboral: json['bajaLaboral'] ?? false,
      lugarNacimiento: json['lugarNacimiento'] ?? '',
      fechaAlta: DateTime.parse(json['fechaAlta']),
      imagenUsuario: json['imagenUsuario'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'trato': trato,
      'telefono': telefono,
      'edad': edad,
      'contrasena': contrasena,
      'contrasena2': contrasena2,
      'bloqueado': bloqueado,
      'administrador': administrador,
      'bajaLaboral': bajaLaboral,
      'lugarNacimiento': lugarNacimiento,
      'fechaAlta': fechaAlta.toIso8601String(),
      'imagenUsuario': imagenUsuario,
    };
  }

  int getId() => id!;
  String getTrato() =>trato;
  String getNombre() => nombre;
  String getPass() => contrasena;
  String getImagenUsuario() => imagenUsuario;
  int getEdad() => edad;
  String getLugarNacimiento() => lugarNacimiento;
  bool getAdministrador() => administrador;
  bool getBloqueado() => bloqueado!;

}