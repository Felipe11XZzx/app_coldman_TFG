
class Cliente {
  final int id;
  final String trato;
  final String nombre;
  final String contrasena;
  final String contrasena2;
  final String imagenPath;
  final int edad;
  final String lugarNacimiento;
  final bool administrador;
  final bool bloqueado;

  Cliente({
    required this.id,
    required this.trato,
    required this.nombre,
    required this.contrasena,
    required this.contrasena2,
    required this.imagenPath,
    required this.edad,
    required this.lugarNacimiento,
    this.administrador = false,
    this.bloqueado = false,
  });

  

  factory Cliente.empty() {
    return Cliente(
      id:0,
      trato: '',
      nombre: '',
      contrasena: '',
      contrasena2: '',
      imagenPath: '',
      edad: 0,
      lugarNacimiento: '',
      administrador: true,
      bloqueado: false,
    );
  }

  Cliente copyWith ({
    int? id,
    String? trato,
    String? nombre,
    String? contrasena,
    String? contrasena2,
    String? imagenPath,
    int? edad,
    String? lugarNacimiento,
    bool? administrador,
    bool? bloqueado,
  }) {
    return Cliente(
      id: id ?? this.id,
      trato: trato ?? this.trato,
      nombre: nombre ?? this.nombre,
      contrasena: contrasena ?? this.contrasena,
      contrasena2: contrasena2 ?? this.contrasena2,
      imagenPath: imagenPath ?? this.imagenPath,
      edad: edad ?? this.edad,
      lugarNacimiento:lugarNacimiento ?? this.lugarNacimiento,
      administrador: administrador ?? this.administrador,
      bloqueado: bloqueado ?? this.bloqueado,
    );
  }


  @override
  String toString() {
    return 'User(id: $id, trato: $trato, nombre: $nombre, edad: $edad, imagen: $imagenPath, lugarNacimiento: $lugarNacimiento, administrador: $administrador, bloqueado: $bloqueado)';
  }

  int getId() => id;
  String getTrato() =>trato;
  String getNombre() => nombre;
  String getPass() => contrasena;
  String getImagePath() => imagenPath;
  int getEdad() => edad;
  String getLugarNacimiento() => lugarNacimiento;
  bool getAdministrador() => administrador;
  bool getBloqueado() => bloqueado;
  
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      trato: json['trato'] ?? '',
      nombre: json['nombre'] ?? '',
      contrasena: json['contrasena'] ?? '',
      contrasena2: json['contrasena2'] ?? '',
      imagenPath: json['imagenPath'] ?? '',
      edad: json['edad'] ?? 0,
      lugarNacimiento: json['lugarNacimiento'] ?? '',
      administrador: json['administrador'] ?? false,
      bloqueado: json['bloqueado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "trato": trato,
      "nombre": nombre,
      "contrasena": contrasena,
      "contrasena2": contrasena2,
      "imagenPath": imagenPath,
      "edad": edad,
      "lugarNacimiento": lugarNacimiento,
      "administrador": administrador,
      "bloqueado": bloqueado,
    };
  }

}
