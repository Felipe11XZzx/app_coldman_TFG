class Cliente {

  Cliente({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.trato,
    required this.edad,
    required this.tipoLugar,
    required this.direccionDomicilio,
    required this.contrasena,
    required this.contrasena2,
    required this.fechaAlta,
    required this.imagenUsuario
  });

  factory Cliente.empty() {
    return Cliente(
      nombre: '', 
      apellidos: '', 
      email: '', 
      telefono: '', 
      trato: '', 
      edad: 0,
      contrasena: '', 
      contrasena2: '',
      direccionDomicilio: '',
      tipoLugar: '',
      fechaAlta: DateTime.now(), 
      imagenUsuario: '');
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id_cliente'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      trato: json['trato'] ?? '',
      edad: json['edad'] ?? 0,
      contrasena: json['contrasena'] ?? '',
      contrasena2: '', 
      direccionDomicilio: json['direccion_domicilio'] ?? '',
      tipoLugar: json['tipo_lugar'] ?? '',
      fechaAlta: json['fecha_alta'] != null ? DateTime.fromMillisecondsSinceEpoch(json['fecha_alta']) : DateTime.now(),
      imagenUsuario: json['imagen_usuario'] ?? '',
    );
  }

  final String apellidos;
  final String contrasena;
  final String contrasena2;
  final int edad;
  final String email;
  final String direccionDomicilio;
  final String tipoLugar;
  final DateTime fechaAlta;
  final int? id;
  final String imagenUsuario;
  final String nombre;
  final String telefono;
  final String trato;

  Cliente copyWith({
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
    String? direccionDomicilio,
    String? tipoLugar,
    DateTime? fechaAlta,
    String? imagenUsuario,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre, 
      apellidos: apellidos ?? this.apellidos, 
      email: email ?? this.email, 
      telefono: telefono ?? this.telefono, 
      trato: trato ?? this.trato, 
      edad: edad ?? this.edad, 
      contrasena: contrasena ?? this.contrasena, 
      contrasena2: contrasena2 ?? this.contrasena2, 
      direccionDomicilio: direccionDomicilio ?? this.direccionDomicilio,
      tipoLugar: tipoLugar ?? this.tipoLugar,
      fechaAlta: fechaAlta ?? this.fechaAlta, 
      imagenUsuario: imagenUsuario ?? this.imagenUsuario
    );
  }

// METODO PARA CONVERTIR EL OBJETO A JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'trato': trato,
      'edad': edad,
      'contrasena': contrasena,
      'fecha_alta': fechaAlta.toIso8601String().split('T')[0],
      'direccion_domicilio': direccionDomicilio,
      'tipo_lugar': tipoLugar,
    };

    if (id != null) {
      json['id_cliente'] = id;
    }

    if (imagenUsuario.isNotEmpty) {
      json['imagen_usuario'] = imagenUsuario;
    }

    return json;
  }

  Map<String, dynamic> toJsonForRegistration() {
    final Map<String, dynamic> json = {
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'trato': trato,
      'edad': edad,
      'contrasena': contrasena,
      'fecha_alta': fechaAlta.toIso8601String().split('T')[0],
      'direccion_domicilio': direccionDomicilio,
      'tipo_lugar': tipoLugar,
    };

    if (imagenUsuario.isNotEmpty) {
      json['imagen_usuario'] = imagenUsuario;
    }

    return json;
  }

  //METODO ESPECIFICO PARA ACTUALIZACIÓN INCLUYE ID.
  Map<String, dynamic> toJsonForUpdate() {
    if (id == null) {
      throw Exception('ID requerido para actualización');
    }

    final Map<String, dynamic> json = {
      'id_cliente': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'trato': trato,
      'edad': edad,
      'contrasena': contrasena,
      'fecha_alta': fechaAlta.toIso8601String().split('T')[0],
      'direccion_domicilio': direccionDomicilio,
      'tipo_lugar': tipoLugar,
    };

    if (imagenUsuario.isNotEmpty) {
      json['imagen_usuario'] = imagenUsuario;
    }

    return json;
  }

  // GETTERS DEL MODELO CLIENTE.
  int getId() => id!;
  String getTrato() => trato;
  String getNombre() => nombre;
  String getPass() => contrasena;
  String getImagenUsuario() => imagenUsuario;
  int getEdad() => edad;
  String getEmail() => email;
  String getApellido() => apellidos;
  DateTime getFechaAlta() => fechaAlta;
  String getTelefono() => telefono;
  
}