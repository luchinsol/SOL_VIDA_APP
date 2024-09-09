import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/newdriver2.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/models/pedidocardmodel.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;

class DriverAlmacen extends StatefulWidget {
  const DriverAlmacen({super.key});

  @override
  State<DriverAlmacen> createState() => _DriverAlmacenState();
}

class _DriverAlmacenState extends State<DriverAlmacen> {
  BitmapDescriptor? _originIcon;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiAlmacenes = '/api/almacenes';
  List<Marker> listalmacenes = [];

  Future<void> _loadMarkerIcons() async {
    _originIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Tamaño del icono
      'lib/imagenes/sinfondo.png',
    );
    setState(() {}); 
    // Llama a getalmacenes después de cargar el icono
    await getalmacenes();
  }

  Future<void> getalmacenes() async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + apiAlmacenes),
        headers: {"Content-type": "application/json"},
      );

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Marker> tempMarkers = (data as List).map<Marker>((data) {
          return Marker(
            markerId: MarkerId(data['nombre']),
            icon: _originIcon!,
            position: LatLng(data['latitud'], data['longitud']),
            infoWindow:InfoWindow(
              title:data['nombre'],
              snippet:'Estado: ${data['estado']} \n'
                      'Horario: ${data['horario']}'
            )
          );
        }).toList();

        if (mounted) {
          setState(() {
            listalmacenes = tempMarkers;
          });
        }
      } else {
        throw Exception('Error al cargar almacenes: ${res.statusCode}');
      }
    } catch (error) {
      throw Exception("Error $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons(); // Cargar iconos y luego almacenes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: const Text('Almacenes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 29,
            color: Color.fromARGB(255, 0, 0, 0)
          )),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height / 1,
        width: MediaQuery.of(context).size.width / 1,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(1)
        ),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(-16.39864372132805, -71.53689790470307),
            zoom: 12.5,
          ),
          markers: {
            /*if (_originIcon != null)
              Marker(
                markerId: const MarkerId("origen"),
                icon: _originIcon!,
                position: const LatLng(-16.39864372132805, -71.53689790470307),
              ),*/
            // Agrega los marcadores de almacenes utilizando el operador spread
            ...listalmacenes,
          },
        ),
      ),
    );
  }
}
