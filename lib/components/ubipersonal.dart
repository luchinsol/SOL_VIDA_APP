import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:appsol_final/components/hola.dart';

const kGoogleApiKey = "AIzaSyC_DGTR1A486oAHhNG1F6LXKU1AmhjJptY";

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _ubipersonal = TextEditingController();
  LatLng _currentPosition =
      LatLng(-16.409047, -71.537451); // Coordenadas iniciales de Arequipa
  Marker? _marker;
  var nombrelugar = "Elige el nombre de tu ubicación";

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: MarkerId('currentLocation'),
      position: _currentPosition,
      draggable: true,
      onDragEnd: (newPosition) {
        _currentPosition = newPosition;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color.fromRGBO(33, 88, 254, 1),
      body: Container(
        decoration: const BoxDecoration(
          gradient:  LinearGradient(colors: [
          Color.fromRGBO(0, 106, 252, 1.000),
          Color.fromRGBO(0, 106, 252, 1.000),
                    Color.fromRGBO(0, 106, 252, 1.000),

          Colors.white,
        ], begin: Alignment.topLeft, end: Alignment.bottomCenter)
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LOGO DE SOL
                  Container(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage('lib/imagenes/nuevito.png'))),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
        
                  // TITULO
                  Container(
                    //color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Indicanos tu ubicación",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 34,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.white),
                    padding: const EdgeInsets.all(0.0),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _addressController,
                      googleAPIKey: kGoogleApiKey,
                      inputDecoration: const InputDecoration(
                        //fillColor: Colors.white,
                        //isDense: true,
        
                        hintText: "Busca tu dirección",
        
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      debounceTime: 400,
                      countries: ["pe"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        setState(() {
                          _currentPosition = LatLng(
                            double.parse(prediction.lat ?? '0'),
                            double.parse(prediction.lng ?? '0'),
                          );
                          _updateMapLocation();
                        });
                      },
                      itemClick: (Prediction prediction) {
                        _addressController.text = prediction.description ?? "";
                        _addressController.selection = TextSelection.fromPosition(
                          TextPosition(
                              offset: prediction.description?.length ?? 0),
                        );
                      },
                      seperatedBuilder: Divider(),
                      containerHorizontalPadding: 10,
                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 7),
                              Expanded(
                                  child: Text(
                                "${prediction.description ?? ""}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                        );
                      },
                      isCrossBtnShown: true,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.all(19),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition,
                          zoom: 18.0,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: _marker != null ? {_marker!} : {},
                        onCameraMove: (position) {
                          _currentPosition = position.target;
                        },
                      ),
                    ),
                  ),
                  /* Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nombra tu ubicación',
                      ),
                    ),
                  ),*/
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: const Text(
                      "Nombra tu ubicación",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                   const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 197, 197, 197),
                        borderRadius: BorderRadius.circular(20)),
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Text(
                      "${nombrelugar}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 78, 77, 77),
                          fontSize: 18),
                    )),
                  ),
                   const SizedBox(
                    height: 10-3,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: ElevatedButton(
                                onPressed: () {
                                  print("-------casaaaaaaaa....");
                                  setState(() {
                                    nombrelugar = "Casa";
                                    _nameController.text = nombrelugar;
                                  });
                                },
                                child: const Text(
                                  "Casa",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 48, 42, 246)),
                                ))),
                        Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: ElevatedButton(
                                onPressed: () {
                                  print("-------trabajo....");
                                  setState(() {
                                    nombrelugar = "Trabajo";
                                    _nameController.text = nombrelugar;
                                  });
                                },
                                child: const Text(
                                  "Trabajo",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 48, 42, 246)),
                                ))),
                        Container(
                            child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            padding: EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                5,
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Nombra tu ubicación",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 38, 70, 250),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  controller: _ubipersonal,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Nombre de ubicación',
                                                    labelStyle: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey,
                                                    ),
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.grey,
                                                    ),
                                                    hintText: 'Ej. Oficina',
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20)),
                                                    //filled: true,
                                                    //fillColor: Colors.white.withOpacity(1),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "Cancelar",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 15,
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      244,
                                                                      47,
                                                                      87)),
                                                        )),
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            nombrelugar =
                                                                _ubipersonal.text;
                                                            _nameController.text =
                                                                _ubipersonal.text;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "Si",
                                                          style: TextStyle(
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      53,
                                                                      53,
                                                                      249),
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: const Icon(
                                  Icons.add,
                                  size: 35,
                                  color: Color.fromARGB(255, 45, 69, 255),
                                )))
                      ],
                    ),
                  ),
                  const SizedBox(height: 10+5,),
                  Container(
                    decoration: BoxDecoration(
                      //color: Color.fromRGBO(58, 182, 0, 1),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Color.fromRGBO(58, 182, 0, 1))
                      ),
                      onPressed: _addLocation,
                      child: Text(
                        "Guardar Ubicación",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width/20,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateMapLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 14.0),
      ),
    );

    setState(() {
      _marker = Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentPosition,
        draggable: true,
        onDragEnd: (newPosition) {
          _currentPosition = newPosition;
        },
      );
    });
  }

  void _addLocation() {
    String name = _nameController.text;
    if (name.isNotEmpty) {
      print('Ubicación guardada: $name - $_currentPosition');
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 7,
              child: Column(
                children: [
                  const Text(
                    "Felicitaciones, tu nueva ubicación se guardó.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 38, 70, 250),
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BarraNavegacion(
                                    indice: 0,
                                    subIndice: 0,
                                  )),
                        );
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 1, 76, 138),
                            fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ),
          );
        });
  }
}
