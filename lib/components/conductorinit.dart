import 'package:appsol_final/components/actualizado_stock.dart';
import 'package:appsol_final/components/holaconductor2.dart';
import 'package:appsol_final/components/conductorNew/descargar.dart';
import 'package:appsol_final/models/ruta_model.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:appsol_final/components/login.dart';

class Conductorinit extends StatefulWidget {
  const Conductorinit({super.key});

  @override
  State<Conductorinit> createState() => _ConductorinitState();
}

class _ConductorinitState extends State<Conductorinit> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiLastRutaCond = '/api/rutakastcond/';
  String apiDetallePedido = '/api/detallepedido/';
  String mensaje =
      'El día de hoy todavía no te han asignado una ruta, espera un momento ;)';
  bool puedoLlamar = false;
  int numerodePedidosExpress = 0;
  int numPedidoActual = 1;
  int pedidoIDActual = 0;
  bool tengoruta = false;
  Color colorProgreso = Colors.transparent;
  Color colorBotonesAzul = const Color.fromRGBO(0, 106, 252, 1.000);
  Color colorTexto = const Color.fromARGB(255, 75, 75, 75);
  int rutaID = 0;
  int? rutaIDpref = 0;
  int? conductorIDpref = 0;
  int? finalrutaIDpref = 0;
  int? finaltotalPendiente = 0;
  double? finaltotalMonto = 0;
  double? finaltotalYape = 0;
  double? finaltotalPlin = 0;
  double? finaltotalEfectivo = 0;
  int? finaltotalEntregado = 0;
  List<int>? finalidpedidos = [];
  int? finaltotalTruncado = 0;
  DateTime fechaFinalizadoPref = DateTime.now();
  bool yaSeActualizoStockPref = false;
  bool rutaTerminadaPref = false;
  String comenzarOaqui = '¡ Comenzar !';
  int cantidad = 0;
  List<int> idpedidos = [];
  DateTime fechaHoy = DateTime.now();
  String nombreCamion = '';
  String placa = '';
  bool? descargaste = false;

  //CREAR UN FUNCION QUE LLAME EL ENDPOINT EN EL QUE SE VERIFICA QUE EL CONDUCTOR
  //TIENE UNA RUTA ASIGNADA PARA ESE DÍA
  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      DateTime fechaDateTime = DateTime.parse(fecha);
      return fechaDateTime;
    } else {
      return DateTime.now();
    }
  }

  _cargarPreferencias() async {
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    SharedPreferences actualizadoStock = await SharedPreferences.getInstance();
    SharedPreferences rutaFinalizada = await SharedPreferences.getInstance();
    SharedPreferences fechaFinalizado = await SharedPreferences.getInstance();
    SharedPreferences click = await SharedPreferences.getInstance();
    if (click.getBool('descarga') != null) {
      setState(() {
        descargaste = click.getBool('descarga');
      });
    } else {
      setState(() {
        descargaste = false;
      });
    }

    if (rutaPreference.getInt("Ruta") != null) {
      setState(() {
        rutaIDpref = rutaPreference.getInt("Ruta");
      });
    } else {
      setState(() {
        rutaIDpref = 1;
      });
    }
    if (userPreference.getInt("userID") != null) {
      setState(() {
        conductorIDpref = userPreference.getInt("userID");
      });
    } else {
      setState(() {
        conductorIDpref = 3;
      });
    }
    if (actualizadoStock.getBool("actualizado") != null) {
      if (actualizadoStock.getBool("actualizado") is bool &&
          actualizadoStock.getBool("actualizado") == true) {
        setState(() {
          yaSeActualizoStockPref = true;
        });
      } else {
        setState(() {
          yaSeActualizoStockPref = false;
        });
      }
    } else {
      setState(() {
        yaSeActualizoStockPref = false;
      });
    }
    if (rutaFinalizada.getBool("finalizado") != null) {
      if (rutaFinalizada.getBool("finalizado") is bool &&
          rutaFinalizada.getBool("finalizado") == true) {
        setState(() {
          rutaTerminadaPref = true;
        });
      } else {
        setState(() {
          rutaTerminadaPref = false;
        });
      }
    } else {
      setState(() {
        yaSeActualizoStockPref = false;
      });
    }
    if (fechaFinalizado.getString("fecha") != null) {
      //print("si hay fecha en pref-----------------------------------------");
      setState(() {
        fechaFinalizadoPref = mesyAnio(fechaFinalizado.getString("fecha"));
      });
    } else {
      //print("no hay fecha en pref--------------------------------------------");
      setState(() {
        fechaFinalizadoPref =
            DateTime.now().subtract(const Duration(hours: 50));
        ;
      });
    }
  }

  Future<void> _initialize() async {
    await _cargarPreferencias();
    await getRutas();
  }

  Future<dynamic> getRutas() async {
    var res = await http.get(
      Uri.parse(apiUrl + apiLastRutaCond + conductorIDpref.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        RutaModel tempRutaModel = RutaModel(
            id: data['id'],
            conductorID: data['conductor_id'],
            vehiculoID: data['vehiculo_id'],
            fechaCreacion: data['fecha_creacion'],
            nombreVehiculo: data['nombre_modelo'],
            placaVehiculo: data['placa']);
        DateTime fechaCreacion = DateTime.parse(tempRutaModel.fechaCreacion);
        /*print("ruta del dia-------------------------------------");
        print(fechaCreacion);
        print("id de ruta----------------------------------------------");
        print(tempRutaModel.id);*/
        if (fechaCreacion.day == fechaHoy.day &&
            fechaCreacion.month == fechaHoy.month &&
            fechaCreacion.year == fechaHoy.year) {
          //si la fecha de creacion es de hoy entonces esta es la ruta del dia!!
          SharedPreferences rutaPreference =
              await SharedPreferences.getInstance();
          SharedPreferences vehiculoPreference =
              await SharedPreferences.getInstance();
          SharedPreferences rutaFinalizada =
              await SharedPreferences.getInstance();
          setState(() {
            rutaID = tempRutaModel.id;
            nombreCamion = tempRutaModel.nombreVehiculo;
            placa = tempRutaModel.placaVehiculo;
          });
          rutaPreference.setInt("Ruta", rutaID);
          vehiculoPreference.setInt("carID", tempRutaModel.vehiculoID);
          if (fechaCreacion.day == fechaFinalizadoPref.day &&
              fechaCreacion.month == fechaFinalizadoPref.month &&
              fechaCreacion.year == fechaFinalizadoPref.year) {
            /*print("rutaID-----------------------------------------------");
            print("$rutaID, $rutaIDpref");
            print("fechaaa---------------------------------------------");
            print(fechaFinalizadoPref);*/
            if (fechaCreacion.hour == fechaFinalizadoPref.hour) {
              if (fechaCreacion.minute < fechaFinalizadoPref.minute) {
                if (descargaste == false) {
                  setState(() {
                    mensaje =
                        'La ruta Nº $rutaID ya se completó, puedes revisar el informe de la ruta';
                    comenzarOaqui = '¡ Aqui !';
                    tengoruta = true;
                  });
                }
              }
            } else if (fechaCreacion.hour < fechaFinalizadoPref.hour) {
              if (descargaste == false) {
                setState(() {
                  mensaje =
                      'La ruta Nº $rutaID ya se completó, puedes revisar el informe de la ruta';
                  comenzarOaqui = '¡ Aqui !';
                  tengoruta = true;
                });
              }
            }
            //SIGNIFICA QUE LA RUTA YA SE TERMINO HOY
          } else {
            //print("aqui------------------------------------");
            //la ruta no se ha terminado hoyyyy
            setState(() {
              descargaste = false;
              rutaTerminadaPref = false;
              rutaFinalizada.setBool("finalizado", false);
              rutaFinalizada.setBool("finalizado", rutaTerminadaPref);
              mensaje =
                  'Tu ruta hoy es la Nº $rutaID, en el vehículo $nombreCamion con placa $placa\n ¡EXITOS!';
              tengoruta = true;
            });
          }
        }
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  void connectToServer() async {
    // Reemplaza la URL con la URL de tu servidor Socket.io
    socket = io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });
    socket.connect();
    socket.onConnect((_) {
      //print('Conexión establecida: CONDUCTOR');
      // Inicia la transmisión de ubicación cuando se conecta
      //iniciarTransmisionUbicacion();
    });
    socket.onDisconnect((_) {
      //print('Conexión desconectada: CONDUCTOR');
    });
    socket.onConnectError((error) {
      //print("Error de conexión $error");
    });
    socket.onError((error) {
      //print("Error de socket, $error");
    });
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    SharedPreferences rutaFinalizada = await SharedPreferences.getInstance();

    socket.on(
      'creadoRuta',
      (data) {
        setState(() {
          rutaID = data['id'];
          rutaPreference.setInt("Ruta", rutaID);
          rutaPreference.setInt("Ruta", data['vehiculo_id']);
          mensaje = 'Tu ruta hoy es la ruta Nº $rutaID :D';
          tengoruta = true;
          rutaTerminadaPref = false;
          rutaFinalizada.setBool("finalizado", rutaTerminadaPref);
        });
      },
    );
    socket.on(
      'ruteando',
      (data) {
        if (data == true) {
          _initialize();
        }
      },
    );
    socket.on('Llama tus Pedidos :)', (data) {
      setState(() {
        puedoLlamar = true;
      });
      if (puedoLlamar == true) {
        _initialize();
      }
    });
    //  }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
    connectToServer();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    final rutaProvider = context.watch<RutaProvider>();
    conductorIDpref = userProvider.user?.id;
    finalrutaIDpref = rutaProvider.ruta?.rutaIDpref;
    finaltotalPendiente = rutaProvider.ruta?.totalPendiente;
    finaltotalMonto = rutaProvider.ruta?.totalMonto;
    finaltotalYape = rutaProvider.ruta?.totalYape;
    finaltotalPlin = rutaProvider.ruta?.totalPlin;
    finaltotalEfectivo = rutaProvider.ruta?.totalEfectivo;
    finaltotalEntregado = rutaProvider.ruta?.totalEntregado;
    finalidpedidos = rutaProvider.ruta?.idpedidos;
    finaltotalTruncado = rutaProvider.ruta?.totalTruncado;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                //color: Colors.amber,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('lib/imagenes/nuevecito.png'))),
                    ),
                    Column(
                      children: [
                        Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 56, 141, 144),
                                borderRadius: BorderRadius.circular(50)),
                            child: IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4.5,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                    child: Text(
                                                  "¿Estas seguro que deseas salir?",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: const Color.fromARGB(
                                                        255, 2, 100, 181),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                                SizedBox(
                                                  height: 50,
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            "No",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20),
                                                          )),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Login()));
                                                          },
                                                          child: Text(
                                                            "Si",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .purple,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20),
                                                          ))
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: const Icon(
                                  Icons.door_back_door_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ))),
                        Text(
                          "Cerrar sesión",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              ),

              // Bienvenido
              Container(
                //color: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenid@ ${userProvider.user?.nombre}!",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "a la Familia Sol",
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // Estado de la ruta
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tengoruta && (descargaste == false) ?
                    ElevatedButton(
                          onPressed: () {
                            if (rutaTerminadaPref) {
                                //print("idpedidos---------------------");
                                //print(finalidpedidos);
                                //SI YA TERMINO LA RUTAAAA
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Pdf(
                                          rutaID: finalrutaIDpref,
                                          pedidos: finaltotalPendiente,
                                          totalMonto: finaltotalMonto,
                                          totalYape: finaltotalYape,
                                          totalPlin: finaltotalPlin,
                                          totalEfectivo: finaltotalEfectivo,
                                          pedidosEntregados:
                                              finaltotalEntregado,
                                          idpedidos: finalidpedidos,
                                          pedidosTruncados:
                                              finaltotalTruncado,
                                        )),
                              );
                            } else {
                                //SI NO TERMINO LA RUTAAAAAA
                              if (yaSeActualizoStockPref) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HolaConductor2()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ActualizadoStock()),
                                );
                              }
                            }

                              //QUE LO LLEVE A LA VISTA DE FORMULARIO DE LLENADO DE STOCK
                          },
                          style: ButtonStyle(
                            surfaceTintColor: MaterialStateProperty.all(
                                Color.fromRGBO(83, 176, 68, 1.000)),
                            elevation: MaterialStateProperty.all(10),
                            minimumSize: MaterialStatePropertyAll(Size(
                                anchoActual * 0.28, largoActual * 0.054)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(83, 176, 68, 1.000)),
                          ),
                          child: Text(
                            comenzarOaqui,
                            style: TextStyle(
                                fontSize: largoActual * 0.021,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          )):Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 76, 163, 175),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Hoy día no tienes\nuna ruta\nasignada,\nespera tu ruta.",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        // color: const Color.fromARGB(255, 3, 118, 212),
                        borderRadius: BorderRadius.circular(20)),
                    width: 150,
                    height: 150,
                    child: Lottie.asset('lib/imagenes/camion6.json'),
                  )
                ],
              ),
              /*if (tengoruta && (descargaste == false))
                ElevatedButton(
                  onPressed: () {
                    if (rutaTerminadaPref) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Pdf(
                            rutaID: finalrutaIDpref,
                            pedidos: finaltotalPendiente,
                            totalMonto: finaltotalMonto,
                            totalYape: finaltotalYape,
                            totalPlin: finaltotalPlin,
                            totalEfectivo: finaltotalEfectivo,
                            pedidosEntregados: finaltotalEntregado,
                            idpedidos: finalidpedidos,
                            pedidosTruncados: finaltotalTruncado,
                          ),
                        ),
                      );
                    } else {
                      if (yaSeActualizoStockPref) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HolaConductor2(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActualizadoStock(),
                          ),
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    surfaceTintColor: MaterialStateProperty.all(
                        Color.fromRGBO(83, 176, 68, 1.000)),
                    elevation: MaterialStateProperty.all(10),
                    minimumSize: MaterialStatePropertyAll(
                        Size(anchoActual * 0.28, largoActual * 0.054)),
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(83, 176, 68, 1.000)),
                  ),
                  child: Text(
                    comenzarOaqui,
                    style: TextStyle(
                      fontSize: largoActual * 0.021,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),*/
            ],
          ),
        ),
      ),
    );
  }
}
