import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:appsol_final/models/ruta_model.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Driver extends StatefulWidget {
  const Driver({super.key});

  @override
  State<Driver> createState() => _DriverState();
}

class _DriverState extends State<Driver> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  int idRuta = 0;
  int idconductor = 0;
  String fechacreacion = "-/-";
  String nombreauto = "-/-";

  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiLastRutaCond = '/api/rutakastcond/';
  String apiDetallePedido = '/api/detallepedido/';

  Future<void> _initialize() async {
    await getRutas();
    // await cargarPreferencias();
  }

  Future<dynamic> getRutas() async {
    print(".......1");
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    SharedPreferences rutaidget = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');

    print("id user");
    print(iduser);

    print("get ruta");

    var res = await http.get(
      Uri.parse(apiUrl + apiLastRutaCond + iduser.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("paso el estado");
        var data = json.decode(res.body);
        RutaModel tempRutaModel = RutaModel(
            id: data['id'],
            conductorID: data['conductor_id'],
            vehiculoID: data['vehiculo_id'],
            fechaCreacion: data['fecha_creacion'],
            nombreVehiculo: data['nombre_modelo'],
            placaVehiculo: data['placa']);
        if (mounted) {
          setState(() {
            print("temprutamodel id");
            print(tempRutaModel.id);
            idRuta = tempRutaModel.id;
            rutaidget.setInt('rutaIDNEW', idRuta);
            fechacreacion = tempRutaModel.fechaCreacion;
            nombreauto = tempRutaModel.nombreVehiculo;
          });
        }
      } else {}
    } catch (error) {
      throw Exception("$error");
    }
  }

  cargarPreferencias() async {
    print("----------2");
    SharedPreferences rutaidget = await SharedPreferences.getInstance();

    rutaidget.setInt('rutaIDNEW', idRuta);
    print("seteandooo");
    print("seteo :$idRuta");
    print(rutaidget.setInt('rutaIDNEW', idRuta));
  }

  void connectToServer() {
    print("-------------3");
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
      // print('Conexión desconectada: CONDUCTOR');
    });
    socket.onConnectError((error) {
      //print("Error de conexión $error");
    });
    socket.onError((error) {
      //print("Error de socket, $error");
    });
    //SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    socket.on(
      'creadoRuta',
      (data) async {
        SharedPreferences rutaidget = await SharedPreferences.getInstance();
        print("------esta es lA RUTA");
        print(data);
        // Usar Provider.of con listen: false
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (data['conductor_id'] == userProvider.user?.id) {
          print("entro al fi");
          setState(() {
            //seteo las preferncias para las demas vistas
            idRuta = data['id'];
 

    rutaidget.setInt('rutaIDNEW', idRuta);
            idconductor = data['conductor_id'];
            fechacreacion = data['fecha_creacion'];
          });
          print("----datos de creado ruta");
          print(idRuta);
          print(idconductor);
          print(fechacreacion);
        }
      },
    );
    /* socket.on(
      'ruteando',
      (data) {
        if (data == true) {
         // _initialize();
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
    });*/
    //  }
  }

  @override
  void initState() {
    super.initState();
    // Inicializa la localización para español
    connectToServer();
    _initialize();

    // cargarPreferencias();

    // getPedidosConductor();
    initializeDateFormatting('es_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateFormat dayFormat = DateFormat('EEEE', 'es_ES');
    String dayName = dayFormat.format(now);

    // Formateo para obtener el número del día
    DateFormat dayNumberFormat = DateFormat('d', 'es_ES');
    String dayNumber = dayNumberFormat.format(now);

    // Formateo para obtener el nombre del mes
    DateFormat monthNameFormat = DateFormat('MMMM', 'es_ES');
    String monthName = monthNameFormat.format(now);

    // Formateo para obtener el año
    DateFormat yearFormat = DateFormat('y', 'es_ES');
    String year = yearFormat.format(now);
    final userProvider = context.watch<UserProvider>();
    final rutaProvider = context.watch<RutaProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 213, 213),
      appBar: AppBar(),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        shadowColor: const Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255)),
              child: Text(
                "Menu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                "Perfil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        title: Text("Nombre:Jorge Cabrera Chivay"),
                        content: Text("Código de empleado:AAA-AAA"),
                      );
                    });
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Cerrar Sesión",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('user');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Solvida()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // color: Colors.grey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                //color: Colors.amber,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bienvenid@",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Cond# ${userProvider.user?.id}-${userProvider.user?.nombre}",
                          style: TextStyle(fontSize: 26),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 19,
                    ),
                    /* Container(
                      //height: 100,
                      //width: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 141, 141, 141)
                      ),
                      child: Text("Vehículo asignado:"),
                    )*/
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // ZONA TRABAJO
              Container(
                  height: MediaQuery.of(context).size.height / 6,
                  width: MediaQuery.of(context).size.width,
                  //padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('lib/imagenes/arequipa.jpg'))),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            stops: [
                              0.1,
                              0.8
                            ],
                            colors: [
                              Colors.black.withOpacity(.85),
                              Colors.black.withOpacity(.2)
                            ])),
                    child: const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 29.0, bottom: 9),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Zona de Trabajo",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            Text(
                              "Arequipa",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color.fromARGB(255, 153, 152, 152)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Hoy ${dayName[0].toUpperCase() + dayName.substring(1)}, ${dayNumber[0].toUpperCase() + dayNumber.substring(1)} de ${monthName} ${year}",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 51, 51, 51),
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.of(context).size.width / 28.0),
                      ),
                    ),
                    /*const SizedBox(
                      height: 50,
                    ),*/
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            idRuta != 0
                                ? Icons.airline_seat_recline_extra_outlined
                                : Icons.report_gmailerrorred_outlined,
                            size: MediaQuery.of(context).size.width / 10,
                            color: idRuta != 0
                                ? Color.fromARGB(255, 39, 62, 166)
                                : Color.fromARGB(255, 246, 47, 8),
                          ),
                          Text(
                            idRuta != 0
                                ? "Tu ruta asignada es la N° ${idRuta}"
                                : "Espera tu ruta",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            nombreauto != '-/-'
                                ? Icons.car_rental
                                : Icons.no_transfer_outlined,
                            size: MediaQuery.of(context).size.width / 10,
                            color: nombreauto != '-/-'
                                ? Color.fromARGB(255, 39, 62, 166)
                                : Color.fromARGB(255, 246, 47, 8),
                          ),
                          Text(
                            nombreauto != '-/-'
                                ? "Tu vehículo es el ${nombreauto}"
                                : "Espera tu unidad",
                            style: TextStyle(
                                color: nombreauto != '-/-'
                                    ? Color.fromARGB(255, 255, 255, 255)
                                    : Color.fromARGB(255, 246, 47, 8),
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 70,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 236, 210, 134))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Abastecer",
                        style: TextStyle(
                            fontSize: 19,
                            color: Color.fromARGB(255, 37, 37, 37)),
                      ),
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 50,
                        color: Color.fromARGB(255, 74, 74, 74),
                      ),
                      //const SizedBox(width: 0,)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Driver1()),
                    );
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 48, 36, 153))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pedidos",
                        style: TextStyle(
                            fontSize: 19,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 50,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      //const SizedBox(width: 0,)
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
