import 'package:flutter/material.dart';



// IMPORTS DE LA APLICACION ANTERIOR DE VENTA DE PRODUCTOS DE CLIMATIZACION.

/*
import 'package:frontend_flutter/providers/pedidoprovider.dart';
import 'package:frontend_flutter/providers/usuarioprovider.dart';
import 'package:frontend_flutter/providers/productoprovider.dart';
import 'package:provider/provider.dart';
import 'screens/login/pantallaprincipal.dart';
*/

// IMPORTS DE LA APLICACION REFACTORIZADA DE COLDMAN S.A.
import 'package:app_coldman_sa/providers/informe_provider.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';
import 'package:app_coldman_sa/screens/login/screen_inicio_sesion.dart';
import 'package:provider/provider.dart';



void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => EmpleadoProvider()..fetchEmpleados()
        ),
        ChangeNotifierProvider(
          create: (context) => ServicioProvider()..fetchServices()
        ),
        ChangeNotifierProvider(
          create: (context) => InformeProvider()..fetchInformesServicios()
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Final Coldman S.A',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 33, 150, 243)),
        useMaterial3: true,
      ),
      home: const ScreenInicioSesion(title: 'Pantalla principal'),
    );
  }
}
