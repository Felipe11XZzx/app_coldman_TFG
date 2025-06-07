import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';


class WebConfig {

  static Logger logger = Logger();

  static void configurarParaWeb() {
    if (kIsWeb) {
      _configurarCORS();

      // OBTENER EL PUERTO ACTUAL.
      String puerto = html.window.location.port;
      String? host = html.window.location.hostname;

      logger.i('Aplicación ejecutándose en: $host:$puerto');

      // CONFUGURAR URL.
      _configurarURLBase(host!, puerto);
    }
  }

  // METODO PARA CONFIGURAR EL SERVER DE JS.
  static void _configurarCORS() {
    if (html.window.location.hostname == 'localhost' ||
        html.window.location.hostname == '127.0.0.1') {
      logger.i('Configurando CORS para desarrollo...');
    }
  }

  // METODO PARA CONFIGURAR LA URL POR DEFECTO.
  static void _configurarURLBase(String host, String puerto) {
    String baseUrl = 'http://$host${puerto.isNotEmpty ? ":$puerto" : ""}';
    logger.i('URL base configurada: $baseUrl');
    html.window.localStorage['app_base_url'] = baseUrl;
  }

  // METODO PARA OBTENER LA URL BASE DE LA WEB.
  static String? obtenerURLBase() {
    if (kIsWeb) {
      return html.window.localStorage['app_base_url'];
    }
    return null;
  }

  static bool esModoDesarrollo() {
    if (kIsWeb) {
      String? hostname = html.window.location.hostname;
      return hostname == 'localhost' || hostname == '127.0.0.1';
    }
    return kDebugMode;
  }
}
