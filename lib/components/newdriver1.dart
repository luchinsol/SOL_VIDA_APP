import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/newdriver2.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/models/pedidocardmodel.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:flutter/material.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Driver1 extends StatefulWidget {
  const Driver1({super.key});

  @override
  State<Driver1> createState() => _Driver1State();
}

class _Driver1State extends State<Driver1> {
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
  String groupedJson ="na";
  int activeOrderIndex = 0;

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
      activeOrderIndex ++;
    });
    print("get pedidos conduc");
    SharedPreferences rutaidget = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');
    int rutaid = 176;
    print("datos : ${rutaidget.getInt('rutaIDNEW')}");
    print("datos: ${iduser}");

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
        print("----pedidos lista conductor");
        print(listPedidosbyRuta);
      }
    } catch (error) {
      throw Exception("Error de consulta $error");
    }
  }

  Future<dynamic> getDetalleXUnPedido(pedidoID) async {
    print("-----detalle pedido");
    if (pedidoID != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetallePedido + pedidoID.toString()),
        headers: {"Content-type": "application/json"},
      );
      print(res.body);
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
          print(groupedJson);
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

  @override
  void initState() {
    super.initState();
    getProducts();
    getPedidosConductor();
  }

  @override
  Widget build(BuildContext context) {
     final cardpedidoProvider = Provider.of<CardpedidoProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pedidos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29)),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50)),
                child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_active,
                      size: MediaQuery.of(context).size.width / 20,
                      color: Color.fromARGB(255, 255, 255, 255),
                    )),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Driver()),
              ); // Regresa a Bienvenido
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            color: Color.fromARGB(255, 255, 255, 255),
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
                          "Cantidad de pedidos# ${cantidadpedidos}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 25,
                              color: Color.fromARGB(255, 94, 15, 184)),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 20,
                        width: MediaQuery.of(context).size.width / 3,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.red)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Informe",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.document_scanner,
                                  color: Colors.white,
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  color: Colors.grey,
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: ListView.builder(
                      itemCount: listPedidosbyRuta.length,
                      itemBuilder: (context, index) {
                        bool isActive = index == activeOrderIndex ;
                        return Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(20),
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                              color: listPedidosbyRuta[index].estado ==
                                      'en proceso'
                                  ? Color.fromARGB(255, 92, 76,
                                      237) // Color para 'en proceso'
                                  : listPedidosbyRuta[index].estado == 'pagado'
                                      ? Color.fromARGB(255, 62, 115,
                                          79) // Color para 'pagado'
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Orden ID#",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "Pago: ${listPedidosbyRuta[index].estado}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: listPedidosbyRuta[index].estado ==
                                              'en proceso'
                                          ? Color.fromARGB(255, 193, 242,
                                              207) // Color para 'en proceso'
                                          : listPedidosbyRuta[index].estado ==
                                                  'pagado'
                                              ? Color.fromARGB(255, 204, 251,
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
                                    style: TextStyle(color: Colors.white),
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
                                        MediaQuery.of(context).size.width / 19,
                                    height:
                                        MediaQuery.of(context).size.width / 19,
                                    decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Punto de entrega",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                        MediaQuery.of(context).size.width / 25,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                  "Total: S/. ${listPedidosbyRuta[index].montoTotal}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              25,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    //color: Colors.grey,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          await getDetalleXUnPedido(
                                              listPedidosbyRuta[index].id);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Container(
                                                    padding: EdgeInsets.all(22),
                                                    decoration: BoxDecoration(
                                                        //color: const Color.fromARGB(255, 124, 111, 111),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    height:
                                                        MediaQuery.of(context)
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
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      22),
                                                            ),
                                                            Text(
                                                              "${listPedidosbyRuta[index].id}",
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
                                                                  color: Colors
                                                                      .blue,
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
                                                        Container(
                                                          height: MediaQuery.of(context).size.height/5,
                                                         // color: Colors.white,
                                                          child: 
                                                             ListView.builder(
                                                            itemCount:
                                                                result.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Row(
                                                                children: [
                                                                  Text(result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 3L' ?
                                                                      result[index]['nombre_prod'].toUpperCase()+' X PQTES : ' : 
                                                                      result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 700ML' ?
                                                                      result[index]['nombre_prod'].toUpperCase()+' X PQTES : ':
                                                                      result[index]['nombre_prod'].toUpperCase() == 'BIDON 20L' ?
                                                                      result[index]['nombre_prod'].toUpperCase()+' X UND : ':
                                                                      result[index]['nombre_prod'].toUpperCase() == 'RECARGA' ?
                                                                      result[index]['nombre_prod'].toUpperCase()+' X UND : ':
                                                                      result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 7L' ?
                                                                      result[index]['nombre_prod'].toUpperCase()+' X UND : ' :
                                                                      result[index]['nombre_prod'].toUpperCase()
                                                                      ,
                                                                      style: TextStyle(fontWeight: FontWeight.w500),),
                                                                  const SizedBox(width: 10,),
                                                                  Text(
                                                                      "${result[index]['cantidad']}",
                                                                       style: TextStyle(fontWeight: FontWeight.w500),),
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
                                                  color: const Color.fromARGB(
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
                                        )),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    child: ElevatedButton(
                                      onPressed:  () {
                                        double latitudp = listPedidosbyRuta[index].latitud;
                                        double longitudp = listPedidosbyRuta[index].longitud;
                                        LatLng coordenadapedido = LatLng(latitudp,longitudp);
                                        print("coordenada pedido");
                                        print(coordenadapedido);

                                        Cardpedidomodel carta =Cardpedidomodel(
                                          id: listPedidosbyRuta[index].id,
                                         pago: listPedidosbyRuta[index].estado,
                                          direccion: listPedidosbyRuta[index].direccion,
                                           detallepedido: result,
                                            nombres: listPedidosbyRuta[index].nombre,
                                             apellidos: listPedidosbyRuta[index].apellidos,
                                              telefono: listPedidosbyRuta[index].telefono,
                                               tipo: listPedidosbyRuta[index].tipo,
                                                precio: listPedidosbyRuta[index].montoTotal,
                                                beneficiadoid:  listPedidosbyRuta[index].beneficiadoID,
                                                comentarios: listPedidosbyRuta[index].comentario);

                                        cardpedidoProvider.updateCard(carta);
                                        
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Navegacion(destination:coordenadapedido)));

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
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
