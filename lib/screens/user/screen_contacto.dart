import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';


class ScreenContactoEmpresa extends StatefulWidget {
  const ScreenContactoEmpresa({super.key});

  @override
  _ScreenContactoEmpresaEstado createState() => _ScreenContactoEmpresaEstado();
}

class _ScreenContactoEmpresaEstado extends State<ScreenContactoEmpresa> {
  final String telefono = "637339769";
  final String email = "coldmanxxii@gmail.com";
  final String web = "https://coldmansl.com/";
  final String direccion = "Calle Monasterio de Roncesvalles, 72, local, Zaragoza 50002";
  final String googleMapsUrl = "https://www.google.es/maps/place/C.+del+Monasterio+de+Roncesvalles,+72,+50002+Zaragoza/@41.6433112,-0.8664988,14.68z/data=!4m6!3m5!1s0xd591451f172f8b5:0x92100ef9a2b88600!8m2!3d41.6432834!4d-0.8587523!16s%2Fg%2F11c5pc7n50?entry=ttu&g_ep=EgoyMDI1MDIyNC4wIKXMDSoJLDEwMjExNDUzSAFQAw%3D%3D";

  final latlng.LatLng ubicacionEmpresa = latlng.LatLng(41.6432895, -0.8636433);
  late final MapController _mapController = MapController();

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacto"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Image.asset(
                  'assets/images/logo_coldman.png',
                  width: 450,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Column(
                  children: [
                    _buildContactTile(Icons.phone, "Teléfono", telefono, "tel:$telefono"),
                    _buildContactTile(Icons.email, "Correo", email, "mailto:$email"),
                    _buildContactTile(Icons.web, "Página Web", web, web),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Text("Ubicación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: ubicacionEmpresa,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: ubicacionEmpresa,
                            width: 60,
                            height: 60,
                            child: Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: () => _launchURL(googleMapsUrl),
                icon: Icon(Icons.map),
                label: Text("Abrir en Google Maps"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: () => _launchURL(url),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
