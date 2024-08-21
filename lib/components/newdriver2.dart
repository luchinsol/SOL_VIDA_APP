import 'dart:math';

import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/components/newdriver3.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import '../models/producto_model.dart';

class Navegacion extends StatefulWidget {
  final LatLng destination;

  const Navegacion({super.key, required this.destination});

  @override
  State<Navegacion> createState() => _NavegacionState();
}

class _NavegacionState extends State<Navegacion> {
  List<LatLng> polypoints = [];
  String _mapStyle = '';
  GoogleMapController? _mapController;
  double _tilt = 0.0; // Variable para la inclinación del mapa

  ///variables
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  String updatedeletepedido = '/api/revertirpedidocan/';

  List<Pedido> listPedidosbyRuta = [];
  int cantidadpedidos = 0;
  List<String> nombresproductos = [];
  List<Producto> listProducto = [];
  int cantidadproducto = 0;
  List<DetallePedido> detalles = [];
  Map<String, int> grouped = {};

  String groupedJson ="na";
  String mensajedelete = "No procesa";
  int activeOrderIndex = 0;
  String motivo = "NA";
  // variables
  LatLng _currentPosition = const LatLng(-16.4014, -71.5343);
  double _currentBearing = 0.0;
  double _currentzoom = 16.0;

  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;
  int anulados = 0;
  
  void _showdialoganulados() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: anulados> 0 ? const Text('Atención se anuló el pedido',
            style: TextStyle(
              color: Colors.white
            ),) : const Text("No hay pedidos anulados",style: TextStyle(color: Colors.white),),
            content:anulados > 0 ? const Text('Se añadió un pedido más a tu ruta.',
            style: TextStyle(color: Colors.white),) :
             const Text("Continúa con tus pedidos.",style: TextStyle(color: Colors.white),),
            actions: <Widget>[
              TextButton(
                child:const Text('OK',style: TextStyle(color: Colors.white),),
                onPressed: () {
                   setState(() {
                    anulados = 0;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  Future<dynamic> anularPedido(int? idpedido, String motivo) async {
    //print("*****************************dentro de anular");
    try {
      var res = await http.delete(
          Uri.parse(apiUrl + updatedeletepedido + idpedido.toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"motivoped": "conductor: $motivo"}));

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            mensajedelete = "Pedido revertido o eliminado";
          });
        }
      }
    } catch (error) {
      throw Exception("$error");
    }
  }

 Future<void> _loadMarkerIcons() async {
    _originIcon = await BitmapDescriptor.asset(
     const ImageConfiguration(size: Size(48, 48)), // Tamaño del icono
      'lib/imagenes/carropin_final.png',
    );
    _destinationIcon = await BitmapDescriptor.asset(
     const ImageConfiguration(size: Size(48, 48)),
      'lib/imagenes/pin_casa_final.png',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadMarkerIcons();
    // getPolypoints();
    _getCurrentLocation();
    final socketService = SocketService();
    socketService.listenToEvent('pedidoanulado', (data) async {
      print("----anulando ---- pedido");
      print("dentro del evento");
SharedPreferences rutaidget = await SharedPreferences.getInstance();
   int? rutaid = rutaidget.getInt('rutaIDNEW');
   
   print(rutaid);

   if(rutaid == data['ruta_id']){
        print("---entro a ala ruta_od");
        if (context.mounted) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.red,
        title:const Text('Un pedido ha sido anulado',style: TextStyle(color: Colors.white),),
        content:const Text('Un pedido con el que estabas trabajando ha sido cancelado. Por favor, revisa tu lista de pedidos.',style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
             Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>const Driver1())); // Navega a la lista de pedidos
            },
            child:const Text('Ver Pedidos',style: TextStyle(color: Colors.white)),
          ),
          
        ],
      );
    },
  );
}

        /*showDialog(context: context,
         builder: (BuildContext context){
          return const AlertDialog(
            backgroundColor: Colors.red,
            title: Text('Atención se anuló un pedido de tu ruta. Revísalo' ));
          
          
         });*/
   }
    });
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
  
  double _toRadians(double degree) {
    return degree * pi / 180;
  }
  double _toDegrees(double radian) {
    return radian * 180 / pi;
  } 
  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = _toRadians(start.latitude);
    double lon1 = _toRadians(start.longitude);
    double lat2 = _toRadians(end.latitude);
    double lon2 = _toRadians(end.longitude);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double bearing = atan2(y, x);
    bearing = _toDegrees(bearing);
    return (bearing + 360) % 360;
  }

  Future<void> _getCurrentLocation() async {
   // print("-------------------------Llamando a current position");
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Obtener la ubicación inicial
    LocationData _locationData = await location.getLocation();
    _updatePosition(_locationData);

    // Escuchar las actualizaciones de la ubicación
    location.onLocationChanged.listen((LocationData currentLocation) {
      _updatePosition(currentLocation);
    });
  }

  void _updatePosition(LocationData locationData) {
    if (!mounted) return;

    LatLng newPosition =
        LatLng(locationData.latitude!, locationData.longitude!);

    // Calcular el bearing si hay una posición anterior
    if (_currentPosition != newPosition) {
      double newBearing = _calculateBearing(_currentPosition, newPosition);
      setState(() {
        _currentBearing = newBearing;
        _currentPosition = newPosition;
      });
    }

    // Animar la cámara a la nueva posición y orientación
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: _currentzoom,
          tilt: _tilt,
          bearing: _currentBearing,
        ),
      ),
    );

    // Actualizar los puntos de la polyline
    getPolypoints();
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('lib/imagenes/estilomapa.json');
    setState(() {
      _mapStyle = style;
    });
  }

  void getPolypoints() async {
    if (_currentPosition.latitude < -90 ||
        _currentPosition.latitude > 90 ||
        _currentPosition.longitude < -180 || 
        _currentPosition.longitude > 180 ||
        widget.destination.latitude < -90 ||
        widget.destination.latitude > 90 ||
        widget.destination.longitude < -180 ||
        widget.destination.longitude > 180) {
      //print("Las coordenadas ingresadas están fuera de rango.");
      return;
    }

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: "AIzaSyC_DGTR1A486oAHhNG1F6LXKU1AmhjJptY",
        request: PolylineRequest(
          origin: PointLatLng(
              _currentPosition.latitude, _currentPosition.longitude),
          destination: PointLatLng(
              widget.destination.latitude, widget.destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.status == "OK" && result.points.isNotEmpty) {
        setState(() {
          polypoints.clear();
          result.points.forEach((PointLatLng point) {
            polypoints.add(LatLng(point.latitude, point.longitude));
          });
        });
      } else if (result.status == "ZERO_RESULTS") {
        print("No se encontraron resultados para la ruta.");
      } else {
        print("Error al obtener la ruta: ${result.status}");
      }
    } catch (e) {
      print("Error al obtener la ruta: $e");
    }
  }

  void _tiltMap() {
    setState(() {
      _tilt = (_tilt == 0.0) ? 85.0 : 0.0;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: _currentzoom + 4,
          tilt: _tilt,
          bearing: _currentBearing,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String telefonopedido) async {
    //print("alo");
    //print(telefonopedido);
    final Uri _phoneUri = Uri(
      scheme: 'tel',
      path:
          telefonopedido, // Cambia esto al número de teléfono que quieras marcar
    );

    if (!await launchUrl(_phoneUri)) {
      throw Exception('No se pudo realizar la llamada a $_phoneUri');
    }
  }

  @override
  Widget build(BuildContext context) {
         final cardpedidoProvider = Provider.of<CardpedidoProvider>(context, listen: false);

    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 93, 93, 94),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 76, 77),
        toolbarHeight: MediaQuery.of(context).size.height/18,
       iconTheme: const IconThemeData(
        color: Colors.white
       ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Navegación",
              style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white, fontSize: 29),
            ),
             Badge(
              largeSize: 18,
              backgroundColor: anulados > 0 ? const Color.fromARGB(255, 243, 33, 82) :  Color.fromARGB(255, 0, 0, 0),
              label: Text(anulados.toString(),
                  style: const TextStyle(fontSize: 12)),
              child: IconButton(
                onPressed: () {
                  //getPedidosConductor();
                  _showdialoganulados();
                 
                  
                },
                icon: const Icon(Icons.notifications_none,color: Colors.white,),
                color: Color.fromARGB(255, 255, 255, 255),
                iconSize: MediaQuery.of(context).size.width/13.5,
              ),
            ),
            
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            height: MediaQuery.of(context).size.height / 1.22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              //color: Color.fromARGB(255, 62, 74, 98)
            ),
            child:
            GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: _currentzoom,
                target: _currentPosition,
                tilt: _tilt,
              ),
              mapType: MapType.normal,
              style: _mapStyle,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onCameraMove: (CameraPosition position) {
                _currentBearing = position.bearing; // Update the bearing
                _currentzoom = position.zoom; // Update the zoom level
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId("RUTA"),
                  points: polypoints,
                  color: Color.fromARGB(255, 163, 5, 236),
                  width: 5,
                ),
              },
              markers: {
                if (_originIcon != null)
                  Marker(
                    markerId: MarkerId("origen"),
                    position: _currentPosition,
                    icon: _originIcon!,
                    //rotation: _currentBearing - 245,
                  ),
                if (_destinationIcon != null)
                  Marker(
                    markerId: MarkerId("destino"),
                    position: widget.destination,
                    icon: _destinationIcon!,
                    //rotation: _currentBearing,
                  ),
              },
            ),
          /* GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: 14,
                target: LatLng(-16.4014, -71.5343),
                tilt: _tilt,
              ),
              mapType: MapType.normal,
              style: _mapStyle,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId("RUTA"),
                  points: polypoints,
                  color: Color.fromARGB(255, 47, 44, 144),
                  width: 5,
                ),
              },
              markers: {
                const Marker(
                  markerId: MarkerId("origen"),
                  position: LatLng(-16.3967402, -71.5418069),
                ),
                const Marker(
                  markerId: MarkerId("destino"),
                  position: LatLng(-16.4014, -71.5343),
                ),
              },
            ),*/
          ),
          Positioned(
            bottom: 206,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Color.fromARGB(255, 62, 68, 97),
              onPressed: () {
                _tiltMap();
              },
              child:const Icon(
                Icons.navigation_outlined,
                color: Colors.white,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize:
                0.1, // Tamaño inicial del widget en porcentaje de la pantalla
            minChildSize:
                0.1, // Tamaño mínimo del widget en porcentaje de la pantalla
            maxChildSize:
                0.4, // Tamaño máximo del widget en porcentaje de la pantalla
            builder: (BuildContext context, ScrollController controller) {
              return Container(
                //color: const Color.fromARGB(255, 144, 141, 141),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    color: Color.fromARGB(255, 69, 68, 123)),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Center(
                      child: Text(
                        'Detalles de entrega',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width / 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // Línea de agarre
                    Container(
                      height: 4.0,
                      width: MediaQuery.of(context).size.width / 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 108, 112, 126),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height / 3.5,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Orden ID#",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Pago: ${cardpedidoProvider.pedido?.pago}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 85, 7, 255)),
                              ),
                              Text("${cardpedidoProvider.pedido?.id}")
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 19,
                                height: MediaQuery.of(context).size.width / 19,
                                decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Punto de entrega",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 255, 61, 7),
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.warning_amber,color: Colors.white,),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text("Anular pedido",style: TextStyle(
                                                    color: Colors.white
                                                  ),),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    "La entrega del pedido se anulará",
                                                    style: TextStyle(
                                                      color:Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextField(
                                                    onChanged: (value) {
                                                      motivo =
                                                          value; // Actualiza el motivo cuando el usuario escribe
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Ingrese el motivo de la cancelación',
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return const AlertDialog(
                                                            content: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CircularProgressIndicator(
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          118,
                                                                          213,
                                                                          80),
                                                                ),
                                                                SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Text(
                                                                  "Cargando ...",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15),
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                      Navigator.pop(context);
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return const AlertDialog(
                                                            content: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CircularProgressIndicator(
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          118,
                                                                          213,
                                                                          80),
                                                                ),
                                                                SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Text(
                                                                  "Cargando ...",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15),
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      await anularPedido(
                                                          cardpedidoProvider
                                                              .pedido?.id,
                                                          motivo);
                                                      //Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Driver1()),
                                                      );
                                                    },
                                                    child: const Text(
                                                      "Continuar",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(255, 236, 253, 4)),
                                                    )),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child:const Text(
                                                      "Cancelar",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(255, 255, 255, 255)),
                                                    )),
                                              ],
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 255, 0, 0))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Anular",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30,
                                        )
                                      ],
                                    )),
                              ),
                             /* Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: const Color.fromARGB(
                                                  255, 255, 61, 7),
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.warning_amber),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text("Anular pedido"),
                                                ],
                                              ),
                                              content: const Text(
                                                "La entrega del pedido se anulará",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Driver1()),
                                                      );
                                                    },
                                                    child: Text(
                                                      "Continuar",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Cancelar",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    )),
                                              ],
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Color.fromARGB(
                                                    255, 255, 0, 0))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Anular",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30,
                                        )
                                      ],
                                    )),
                              ),*/
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "${cardpedidoProvider.pedido?.direccion}",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          Text("Total: S/. ${cardpedidoProvider.pedido?.precio}",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 30, 160),
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // DETALLES
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Container(
                                                padding: EdgeInsets.all(22),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Orden N#",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22),
                                                        ),
                                                        Text(
                                                          "${cardpedidoProvider.pedido?.id}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.blue,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Cliente",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Text("${cardpedidoProvider.pedido?.nombres}"),
                                                    Text("${cardpedidoProvider.pedido?.nombres}"),
                                                    Text("${cardpedidoProvider.pedido?.telefono}"),
                                                    Text("${cardpedidoProvider.pedido?.tipo}"),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          decoration: BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                      255,
                                                                      223,
                                                                      205,
                                                                      84),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Contenido",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Container(
                                                          height: MediaQuery.of(context).size.height/5,
                                                         // color: Colors.white,
                                                          child: 
                                                             ListView.builder(
                                                            itemCount:
                                                                cardpedidoProvider.pedido?.detallepedido.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Row(
                                                                children: [
                                                                  Text(cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'BOTELLA 3L' ?
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase()+' X PQTES : ' : 
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'BOTELLA 700ML' ?
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase()+' X PQTES : ':
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'BIDON 20L' ?
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase()+' X UND : ':
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'RECARGA' ?
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase()+' X UND : ':
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'BOTELLA 7L' ?
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase()+' X UND : ' :
                                                                      cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase()
                                                                      ,
                                                                      style: TextStyle(fontWeight: FontWeight.w500),),
                                                                  const SizedBox(width: 10,),
                                                                  Text(
                                                                      "${cardpedidoProvider.pedido?.detallepedido[index]['cantidad']}",
                                                                       style: TextStyle(fontWeight: FontWeight.w500),),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Colors.amber)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Detalles",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.visibility_outlined,
                                          color: Colors.black,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30,
                                        )
                                      ],
                                    )),
                              ),

                              // COBRAR
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Cobrar()) // Reemplaza BienvenidoScreen con tu pantalla de inicio
                                     // Asegúrate de tener un nombre de ruta que puedas usar para compararlo
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Color.fromARGB(255, 38, 111, 48)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Cobrar",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35)),
                                      const SizedBox(width: 10),
                                      Icon(Icons.attach_money_rounded,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),

                              // LLAMAR
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    //print("------llamandoooo aloooo ");
                                   // print(cardpedidoProvider.pedido!.telefono);
                                    _makePhoneCall(cardpedidoProvider.pedido!.telefono);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Color.fromARGB(255, 61, 69, 187)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Llamar",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35)),
                                      const SizedBox(width: 10),
                                      Icon(Icons.phone,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                    // Agrega más widgets aquí según lo necesites
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
