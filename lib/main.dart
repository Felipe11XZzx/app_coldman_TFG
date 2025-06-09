import 'package:app_coldman_sa/providers/cliente_provider.dart';
import 'package:app_coldman_sa/screens/admin/screen_crear_servicio.dart';
import 'package:app_coldman_sa/screens/admin/screen_gestion_informes.dart';
import 'package:app_coldman_sa/web_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/providers/informe_provider.dart';
import 'package:app_coldman_sa/providers/empleado_provider.dart';
import 'package:app_coldman_sa/providers/servicio_provider.dart';
import 'package:app_coldman_sa/providers/cita_provider.dart';
import 'package:app_coldman_sa/providers/imagenes_provider.dart';
import 'package:app_coldman_sa/providers/servicio_cita_provider.dart';
import 'package:app_coldman_sa/screens/login/screen_inicio_sesion.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 


void main() {
  if (kIsWeb) {
    WebConfig.configurarParaWeb();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ImageUploadProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => EmpleadoProvider()..fetchEmpleados()
        ),
        ChangeNotifierProvider(
          create: (context) => ClienteProvider()..fetchClientes()
        ),
        ChangeNotifierProvider(
          create: (context) => CitaProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ServicioProvider()..fetchServices()
        ),
        ChangeNotifierProvider(
          create: (context) => InformeProvider()..fetchInformesServicios()
        ),

        // PROVIDER UNIFICADO PARA RELACION ENTRE LA CITA Y EL SERVICIO DE LA EMPRESA.
        ChangeNotifierProxyProvider2<CitaProvider, ServicioProvider, ServicioCitaProvider>
          (create: (context) => ServicioCitaProvider(
            Provider.of<CitaProvider>(context, listen: false), 
            Provider.of<ServicioProvider>(context, listen: false), 
            ),
            update: (context, citaProvider, servicioProvider, previous) =>
              previous ?? ServicioCitaProvider(citaProvider, servicioProvider),  
          )
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
      // RUTAS PARA LAS SCREENS Y COMUNICACION DE FUNCIONALIDADES.
      routes: {
        'crear-servicio': (context) => ScreenCrearServicio(),
        'crear-informe': (context) => ScreenInformes(),
        'detalle-informe' : (context) => ScreenInformes(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es', 'ES'),
      ],
    );
  }
}
