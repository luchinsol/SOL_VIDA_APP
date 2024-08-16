import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Cobrar extends StatefulWidget {
  const Cobrar({super.key});

  @override
  State<Cobrar> createState() => _CobrarState();
}

class _CobrarState extends State<Cobrar> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cardpedidoProvider = Provider.of<CardpedidoProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cobro",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        color: Color.fromARGB(255, 79, 87, 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Center(
                    child: Column(
              children: [
                Text(
                  "S/. ${cardpedidoProvider.pedido?.precio}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.width / 8),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Monto total",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width / 20),
                )
              ],
            ))),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width / 35,
                    width: MediaQuery.of(context).size.width / 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color.fromARGB(255, 255, 193, 7)),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Escoge el método de pago",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 20.5),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 20,
                    child: ElevatedButton(
                        onPressed: () {},
                        child:const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Pago virtual",
                              style: TextStyle(color: Colors.black),
                            ),
                             SizedBox(width: 10,),
                            Icon(Icons.camera_alt_outlined,color: Colors.purple,)
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 20,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Pago efectivo"),
                                content: Text(
                                    "El pago de S/.${cardpedidoProvider.pedido?.precio} es en forma de efectivo",
                                    style: TextStyle(fontWeight: FontWeight.w700),),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:const Center(
                                                    child: Text(
                                                        "Pago confirmado")),
                                                content: Icon(
                                                  Icons.check_circle_outline,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  color: Colors.green,
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
                                                                     const Driver1()),
                                                        );
                                                        //await update pedido a pagado
                                                      },
                                                      child: Center(
                                                          child: Text("OK"))),
                                                ],
                                              );
                                            });
                                      },
                                      child: Text("OK")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancelar"))
                                ],
                              );
                            });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Pago efectivo",
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 10,),
                          Icon(Icons.currency_exchange_outlined)
                        ],
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.green)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "¿El cliente realizó un pedido más?",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: MediaQuery.of(context).size.height / 20,
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Describre"),
                                  content: Container(
                                    height: MediaQuery.of(context).size.height /
                                        5.5,
                                    child: Column(
                                      children: [
                                        Text(
                                            "Escribe el o los productos que se agregaron al pedido"),
                                        TextField(
                                          controller: _controller,
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Ej. Compro 3 bidones adicionales'),
                                        ),
                                        const SizedBox(
                                          height: 14,
                                        ),
                                        Text("Actualiza el monto total"),
                                        TextField(
                                          controller: _controller2,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              hintText: 'S/.0.00'),
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Pedido actualizado y cancelado",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        5,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const Driver1(),
                                                            ),
                                                          );
                                                        },
                                                        child: Text("OK"))
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text("Confirmar")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancelar"))
                                  ],
                                );
                              });
                        },
                        child: Text(
                          "Aumentar monto",
                          style: TextStyle(color: Colors.black),
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
