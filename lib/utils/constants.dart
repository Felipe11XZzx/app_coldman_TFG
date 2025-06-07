import 'package:flutter/material.dart';

class Constants {
  
  static const Color primaryColor = Colors.blue;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color headerDrawer = Colors.blueGrey;
  static const Color infoColor = Colors.blue;

  static const Icon adminBadge = Icon(
    Icons.verified,
    color: Colors.blue,
    size: 16,
  );

  static const Map<String, IconData> estadoIconos = {
    "Pedido": Icons.shopping_cart,
    "En Producción": Icons.engineering,
    "En Reparto": Icons.local_shipping,
    "Entregado": Icons.check_circle,
  };

  static const Map<String, Color> estadoColores = {
    "Pedido": Colors.blue,
    "En Producción": Colors.orange,
    "En Reparto": Colors.purple,
    "Entregado": Colors.green,
  };

  static const List<String> capitales = [
    'A Coruña', 'Albacete', 'Alicante', 'Almería', 'Ávila', 'Badajoz', 'Barcelona', 'Bilbao', 'Burgos',
    'Cáceres', 'Cádiz', 'Castellón', 'Ciudad Real', 'Córdoba', 'Cuenca', 'Girona', 'Granada', 'Guadalajara',
    'Huelva', 'Huesca', 'Jaén', 'La Rioja', 'Las Palmas', 'León', 'Lleida', 'Lugo', 'Madrid', 'Málaga',
    'Murcia', 'Ourense', 'Oviedo', 'Palencia', 'Pamplona', 'Pontevedra', 'Salamanca', 'San Sebastián',
    'Santander', 'Segovia', 'Sevilla', 'Soria', 'Tarragona', 'Teruel', 'Toledo', 'Valencia', 'Valladolid',
    'Vitoria', 'Zamora', 'Zaragoza'
  ];

  static const String appName = "Mi Aplicación";
  static const String errorGenerico = "Ha ocurrido un error";
  static const String confirmacionGuardar = "¿Desea guardar los cambios?";
  static const String confirmacionEliminar = "¿Está seguro de eliminar?";

}
