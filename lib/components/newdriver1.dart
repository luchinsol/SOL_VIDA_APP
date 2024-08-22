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


class Driver1 extends StatefulWidget {
  const Driver1({super.key});

  @override
  State<Driver1> createState() => _Driver1State();
}

class _Driver1State extends State<Driver1> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  List<Pedido> listPedidosbyRuta = [];
  int cantidadpedidos = 0;
  List<String> nombresproductos = [];
  List<Producto> listProducto = [];
  int cantidadproducto = 0;
  List<DetallePedido> detalles = [];
  Map<String, int> grouped = {};
  List<Map<String, dynamic>> result = [];
  String groupedJson = "na";
  int activeOrderIndex = 0;

  int rutaCounter = 0;
  
  /*void _verificarContador(int rutitacontador){
    print("......verificaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    if(rutitacontador>2){
     // rutaCounter = 1;
      _showdialogconductor();
    }
  }*/

  void _showdialogconductor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: rutaCounter> 0 ? const Text('Pedido nuevo') :const Text("No hay pedido añadidos en tiempo real"),
            content:rutaCounter > 0 ? const Text('Se añadió un pedido más a tu ruta.') :const Text("Espera algún pedido."),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                   setState(() {
                    rutaCounter = 0;
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

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            id: mapa['id'],
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(), //?,
            descripcion: mapa['descripcion'],
            promoID: null,
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        setState(() {
          listProducto = tempProducto;
          //conductores = tempConductor;
        });
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    return Future.value(
        false); // Previene el comportamiento predeterminado de retroceso
  }

  Future<dynamic> getPedidosConductor() async {
    setState(() {
      activeOrderIndex++;
    });
    //print("get pedidos conduc");
    SharedPreferences rutaidget = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');
    int? rutaid = rutaidget.getInt('rutaIDNEW');
  //  print("datos ruta : ${rutaidget.getInt('rutaIDNEW')}");
    //print("datos id usuario: ${iduser}");

    var res = await http.get(
      Uri.parse("$apiUrl$apiPedidosConductor$rutaid/${iduser.toString()}"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Pedido> listTemporal = data.map<Pedido>((mapa) {
          return Pedido(
              id: mapa['id'],
              montoTotal: mapa['total']?.toDouble(),
              latitud: mapa['latitud']?.toDouble(),
              longitud: mapa['longitud']?.toDouble(),
              fecha: mapa['fecha'],
              estado: mapa['estado'],
              tipo: mapa['tipo'],
              nombre: mapa['nombre'],
              apellidos: mapa['apellidos'],
              telefono: mapa['telefono'],
              direccion: mapa['direccion'],
              tipoPago: mapa['tipo_pago'],
              beneficiadoID: mapa['beneficiado_id'],
              comentario: mapa['observacion'] ?? 'sin comentarios');
        }).toList();
        //SE SETEA EL VALOR DE PEDIDOS BY RUTA
        if (mounted) {
          setState(() {
            listPedidosbyRuta = listTemporal;
            cantidadpedidos = listPedidosbyRuta.length;
          });
        }
      //  print("----pedidos lista conductor");
       // print(listPedidosbyRuta);
      }
    } catch (error) {
      throw Exception("Error de consulta $error");
    }
  }

  Future<dynamic> getDetalleXUnPedido(pedidoID) async {
    //print("-----detalle pedido");
    if (pedidoID != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetallePedido + pedidoID.toString()),
        headers: {"Content-type": "application/json"},
      );
     // print(res.body);
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          print(data);
          List<DetallePedido> listTemporal = data.map<DetallePedido>((mapa) {
            return DetallePedido(
              pedidoID: mapa['pedido_id'],
              productoID: mapa['producto_id'],
              productoNombre: mapa['nombre_prod'],
              cantidadProd: mapa['cantidad'],
              promocionID: mapa['promocion_id'],
              promocionNombre: mapa['nombre_prom'],
            );
          }).toList();
          // print("${listTemporal.first.productoNombre}");
          // Agrupar y sumar las cantidades
          grouped = {};
          result = [];
          for (var i = 0; i < listTemporal.length; i++) {
            String nombreProd = listTemporal[i].productoNombre;
            int cantidad = listTemporal[i].cantidadProd;

            if (grouped.containsKey(nombreProd)) {
              grouped[nombreProd] = grouped[nombreProd]! + cantidad;
            } else {
              grouped[nombreProd] = cantidad;
            }
          }
          // Crear la lista de resultados

          grouped.forEach((nombreProd, cantidad) {
            result.add({'nombre_prod': nombreProd, 'cantidad': cantidad});
          });
          // Convertir a JSON
          groupedJson = jsonEncode(result);

          // Imprimir el resultado
        //  print(groupedJson);
          /*r (var i = 0; i < listProducto.length; i++) {
              if (listProducto[i].cantidad != 0) {
                var salto = '\n';
                if (productosYCantidades == '') {
                  setState(() {
                    productosYCantidades =
                        "${listProducto[i].nombre} x ${listProducto[i].cantidad.toString()} uds."
                            .toUpperCase();
                  });
                } else {
                  setState(() {
                    productosYCantidades =
                        "$productosYCantidades $salto${listProducto[i].nombre.toUpperCase()} x ${listProducto[i].cantidad.toString()} uds.";
                  });
                }
                break;
              }
            }*/
        }
      } catch (e) {
        //print('Error en la solicitud: $e');
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      //print('papas');
    }
  }

/*

 void connectToServer()  {

    socket = io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 500,
      'reconnectionDelayMax': 2000,
    });
    socket.connect();
    socket.onConnect((_) {
    //  print('Conexión establecida: CONDUCTOR');

    });
    socket.onDisconnect((_) {
    //  print('Conexión desconectada: CONDUCTOR');
    });
    socket.onConnectError((error) {

    });
    socket.onError((error) {

    });

    socket.on(
      'pedidoañadido',
      (data) {
        print("entrando--------");
        print(data);
       

          setState(() {
          rutaCounter = rutaCounter +
              1; 
        });
        
        _showdialogconductor();

        
        print("CANTIDAD TOTAL DE PEDIDOS ELIMINADOS-------------------");
        print(rutaCounter);
      },
    );
  }*/

  @override
  void initState() {
    super.initState();
    getProducts();
    getPedidosConductor();
      final socketService = SocketService();
   // socketService.connectToServer(apiUrl);
   /* if(rutaCounter>0){
      _showdialogconductor();
    }*/
    socketService.listenToEvent('pedidoañadido', (data) async {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      print("------esta es la PEDIDO AÑADIDO");
      //print(data);

     
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      //if (data['conductor_id'] == userProvider.user?.id) {
        print("entro al fi");

          setState(() {
          rutaCounter = rutaCounter +
              1; 
              print("ruta ---counter");
              print(rutaCounter);
        });
       
        //_showdialogconductor();
        // _verificarContador(rutaCounter);
         setState(() {
           rutaCounter = 1;
         });
      
     // }
    });
    
    //connectToServer();
    
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardpedidoProvider =
        Provider.of<CardpedidoProvider>(context, listen: false);
    return/* WillPopScope(
      onWillPop: _onWillPop,
      child:*/ Scaffold(
        backgroundColor: const Color.fromARGB(255, 93, 93, 94),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 76, 77),
        toolbarHeight: MediaQuery.of(context).size.height/18,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pedidos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29,color: Colors.white)),
              
              Badge(
              largeSize: 18,
              backgroundColor: rutaCounter > 0 ? const Color.fromARGB(255, 243, 33, 82) :  Color.fromARGB(255, 0, 0, 0),
              label: Text(rutaCounter.toString(),
                  style: const TextStyle(fontSize: 12)),
              child: IconButton(
                onPressed: () {
                  getPedidosConductor();
                  _showdialogconductor();
                 
                  
                },
                icon: const Icon(Icons.notifications_none,color: Colors.white,),
                color: Color.fromARGB(255, 255, 255, 255),
                iconSize: MediaQuery.of(context).size.width/13.5,
              ),
            ),
            ],
          ),
         /* leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Driver()),
              ); // Regresa a Bienvenido
            },
          ),*/
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            //color: Color.fromARGB(255, 255, 255, 255),
            child: Column(
              children: [
                // CABECERA INFORME Y NOTIFICATION
                Container(
                  // color: Colors.grey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          listPedidosbyRuta.length >0
                              ? "Cantidad de pedidos: ${cantidadpedidos}"
                              : "*",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 25,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  // color: Colors.grey,
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: listPedidosbyRuta.isNotEmpty
                      ? ListView.builder(
                          itemCount: listPedidosbyRuta.length,
                          itemBuilder: (context, index) {
                            bool isActive = index == activeOrderIndex;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              height: MediaQuery.of(context).size.height / 3.6,
                              decoration: BoxDecoration(
                                  color: listPedidosbyRuta[index].estado ==
                                          'en proceso'
                                      ? const Color.fromARGB(255, 92, 76, 237)
                                      : listPedidosbyRuta[index].estado ==
                                              'pagado'
                                          ? const Color.fromARGB(
                                              255, 62, 115, 79)
                                          : listPedidosbyRuta[index].estado ==
                                                  'entregado'
                                              ? const Color.fromARGB(255, 43, 38, 77)
                                              : listPedidosbyRuta[index]
                                                          .estado ==
                                                      'anulado'
                                                  ? Colors.pink
                                                  : const Color.fromARGB(
                                                      255, 39, 39, 39),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                     const Text(
                                        "Orden ID#",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "Pago: ${listPedidosbyRuta[index].estado}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: listPedidosbyRuta[index]
                                                      .estado ==
                                                  'en proceso'
                                              ? const Color.fromARGB(255, 193, 242,
                                                  207) // Color para 'en proceso'
                                              : listPedidosbyRuta[index]
                                                          .estado ==
                                                      'pagado'
                                                  ? const Color.fromARGB(
                                                      255,
                                                      204,
                                                      251,
                                                      18) // Color para 'pagado'
                                                  : const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255), // Color para 'anulado'
                                        ),
                                      ),
                                      Text(
                                        "${listPedidosbyRuta[index].id}",
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                19,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                19,
                                        decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "Punto de entrega",
                                        style: TextStyle(
                                          color: Colors.amber,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${listPedidosbyRuta[index].direccion}",
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                27,
                                        fontWeight: FontWeight.bold,color: Color.fromARGB(255, 186, 185, 185)),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                      "Total: S/. ${listPedidosbyRuta[index].montoTotal}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.width /
                                                8,
                                  ),
                                  Row(
                                  //  crossAxisAlignment: CrossAxisAlignment.end,
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        //color: Colors.grey,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        child:  listPedidosbyRuta[index]
                                                    .estado!='anulado' ? ElevatedButton(
                                            onPressed: () async {
                                              await getDetalleXUnPedido(
                                                  listPedidosbyRuta[index].id);
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(22),
                                                        decoration:
                                                            BoxDecoration(
                                                                //color: const Color.fromARGB(255, 124, 111, 111),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
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
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
                                                                              22),
                                                                ),
                                                                Text(
                                                                  "${listPedidosbyRuta[index].id}",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          MediaQuery.of(context).size.width /
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
                                                                      color: Colors
                                                                          .blue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              "${listPedidosbyRuta[index].nombre}",
                                                              style: TextStyle(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      28),
                                                            ),
                                                            Text(
                                                              "Teléfono: ${listPedidosbyRuta[index].telefono}",
                                                              style: TextStyle(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      28),
                                                            ),
                                                            Text(
                                                              "Tipo: ${listPedidosbyRuta[index].tipo}",
                                                              style: TextStyle(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      28),
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
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          223,
                                                                          205,
                                                                          84),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  5,
                                                              // color: Colors.white,
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    result
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Row(
                                                                    children: [
                                                                      Text(
                                                                        result[index]['nombre_prod'].toUpperCase() ==
                                                                                'BOTELLA 3L'
                                                                            ? result[index]['nombre_prod'].toUpperCase() +
                                                                                ' X PQTES : '
                                                                            : result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 700ML'
                                                                                ? result[index]['nombre_prod'].toUpperCase() + ' X PQTES : '
                                                                                : result[index]['nombre_prod'].toUpperCase() == 'BIDON 20L'
                                                                                    ? result[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                    : result[index]['nombre_prod'].toUpperCase() == 'RECARGA'
                                                                                        ? result[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                        : result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 7L'
                                                                                            ? result[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                            : result[index]['nombre_prod'].toUpperCase(),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "${result[index]['cantidad']}",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });

                                              //  cantidadproducto = 0;
                                            },
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty.all(
                                                        Colors.amber)),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Detalles",
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 0, 0, 0)),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Icon(
                                                  Icons.visibility_outlined,
                                                  color: Colors.black,
                                                )
                                              ],
                                            )):null,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        child: listPedidosbyRuta[index]
                                                    .estado!='anulado' ? ElevatedButton(
                                          onPressed: () {
                                            double latitudp =
                                                listPedidosbyRuta[index]
                                                    .latitud;
                                            double longitudp =
                                                listPedidosbyRuta[index]
                                                    .longitud;
                                            LatLng coordenadapedido =
                                                LatLng(latitudp, longitudp);
                                            print("coordenada pedido");
                                            print(coordenadapedido);

                                            Cardpedidomodel carta = Cardpedidomodel(
                                                id: listPedidosbyRuta[index].id,
                                                pago: listPedidosbyRuta[index]
                                                    .estado,
                                                direccion:
                                                    listPedidosbyRuta[index]
                                                        .direccion,
                                                detallepedido: result,
                                                nombres:
                                                    listPedidosbyRuta[index]
                                                        .nombre,
                                                apellidos:
                                                    listPedidosbyRuta[index]
                                                        .apellidos,
                                                telefono:
                                                    listPedidosbyRuta[index]
                                                        .telefono,
                                                tipo: listPedidosbyRuta[index]
                                                    .tipo,
                                                precio: listPedidosbyRuta[index]
                                                    .montoTotal,
                                                beneficiadoid:
                                                    listPedidosbyRuta[index]
                                                        .beneficiadoID,
                                                comentarios:
                                                    listPedidosbyRuta[index]
                                                        .comentario);

                                            cardpedidoProvider
                                                .updateCard(carta);

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Navegacion(
                                                            destination:
                                                                coordenadapedido)));

                                            // Cierra el diálogo después de que la navegación se complete
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 61, 69, 187)),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Iniciar ruta",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              SizedBox(width: 10),
                                              Icon(Icons.navigation_outlined,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ):null,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          })
                      : Container(
                          height: MediaQuery.of(context).size.height / 4,
                          //color: Colors.grey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_bottom_sharp,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: MediaQuery.of(context).size.width /
                                          10)
                                  .animate()
                                  .shakeY(),
                              Text(
                                "Espera tus pedidos...",
                                style: TextStyle(
                                  color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20),
                              )
                            ],
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      
    );
  }
}
