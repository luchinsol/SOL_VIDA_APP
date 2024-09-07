import 'dart:io';

import 'package:appsol_final/components/newalmacenes.dart';
import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/components/newdriverstock1.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:appsol_final/models/pedidoinforme_model.dart';
import 'package:appsol_final/models/ruta_model.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;

class Driver extends StatefulWidget {
  const Driver({super.key});

  @override
  State<Driver> createState() => _DriverState();
}

class _DriverState extends State<Driver> {
 //late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  int idRuta = 0;
  int idconductor = 0;
  String fechacreacion = "-/-";
  String nombreauto = "-/-";

  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiLastRutaCond = '/api/rutakastcond/';
  String apiDetallePedido = '/api/detallepedido/';
  String apipedidoinforme = '/api/fecharutapedido/';
  TextEditingController _pdffecha = TextEditingController();
  List<Pedidoinforme> informegeneral = [];
  bool conectado = false;
  Color colorconectado = Colors.white;
final socketService = SocketService();
  /*Future<void> _initialize() async {
   // await getRutas();
    // await cargarPreferencias();
  }*/

  Future<void> createPdf(List<Pedidoinforme> pedidos) async {
    final pdf = pw.Document();

    // Define cuántos elementos quieres por página
    const int itemsPerPage = 4;
    final int pageCount = (pedidos.length / itemsPerPage).ceil();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

// Página 1: Solo el título
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Informe de pedidos",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(
                  child: pw.Text("${userProvider.user?.nombre}",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text("${userProvider.user?.apellidos}",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                )
              ]);
        },
      ),
    );
    for (int i = 0; i < pageCount; i++) {
      final startIndex = i * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage > pedidos.length)
          ? pedidos.length
          : startIndex + itemsPerPage;

      final pagePedidos = pedidos.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.ListView.builder(
              itemCount: pagePedidos.length,
              itemBuilder: (context, index) {
                final pedido = pagePedidos[index];
                return pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ID: ${pedido.id}'),
                      pw.Text('Ruta ID: ${pedido.ruta_id}'),
                      pw.Text('Fecha: ${pedido.fecha}'),
                      pw.Text('Tipo: ${pedido.tipo}'),
                      pw.Text('Estado: ${pedido.estado}'),
                      pw.Text('Observación: ${pedido.observacion}'),
                      pw.Text('Tipo Pago: ${pedido.tipo_pago}'),
                      pw.Divider(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }

    // Guardar el PDF o imprimirlo
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<dynamic> pedidosInforme(String fecha) async {
    //print("---------------//// pedidos informe /////------------");
    try {
      SharedPreferences userPreference = await SharedPreferences.getInstance();
      int? iduser = userPreference.getInt('userID');
      //print("usuario condctor: $iduser");
      var res = await http.post(
          Uri.parse(apiUrl + apipedidoinforme + iduser.toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"fecha_ruta": fecha}));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Pedidoinforme> tempedido = data.map<Pedidoinforme>((item) {
          return Pedidoinforme(
              id: item['id'],
              ruta_id: item['ruta_id'],
              fecha: item['fecha'],
              tipo: item['tipo'],
              estado: item['estado'],
              observacion: item['observacion'] ?? "NA",
              tipo_pago: item['tipo_pago'] ?? "NA");
        }).toList();
        if (mounted) {
          setState(() {
            informegeneral = tempedido;
          });
        }

        // print("----------inform----------");
        // print(informegeneral.length);
        // Crear PDF con los pedidos obtenidos
        await createPdf(tempedido);

        return tempedido;
      }
    } catch (error) {
      throw Exception("Error $error");
    }
  }

  /* Future<void> _createPdf(String dateStr) async {
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final picturesDirectory =
        Directory(path.join(directory.path, 'pictures', dateStr));

    if (await picturesDirectory.exists()) {
      final imageFiles = picturesDirectory
          .listSync()
          .where((item) => item is File)
          .map((item) => item as File)
          .toList();

      for (var image in imageFiles) {
        final imageFile = pw.MemoryImage(image.readAsBytesSync());
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(imageFile),
              );
            },
          ),
        );
      }

      final pdfFile =
          File(path.join(directory.path, 'pictures', 'reporte_$dateStr.pdf'));
      await pdfFile.writeAsBytes(await pdf.save());

      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'reporte_$dateStr.pdf');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF creado en ${pdfFile.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay fotos para la fecha $dateStr')),
      );
    }
  }*/

  /*
  Future<void> _createPdf(String dateStr) async {
  final pdf = pw.Document();
  final directory = await getApplicationDocumentsDirectory();
  final picturesDirectory = Directory(path.join(directory.path, 'pictures', dateStr));

  if (await picturesDirectory.exists()) {
    final imageFiles = picturesDirectory
        .listSync()
        .where((item) => item is File)
        .map((item) => item as File)
        .toList();

    if (imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay fotos para la fecha $dateStr')),
      );
      return;
    }

    for (var image in imageFiles) {
      final imageFile = pw.MemoryImage(image.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(imageFile),
            );
          },
        ),
      );
    }

    final pdfFile = File(path.join(directory.path, 'pictures', 'reporte_$dateStr.pdf'));
    await pdfFile.writeAsBytes(await pdf.save());

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_$dateStr.pdf',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF creado en ${pdfFile.path}')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No hay fotos para la fecha $dateStr')),
    );
  }
}*/

/*Future<void> _createPdf(String dateStr) async {
  // Obtener los datos de los pedidos
  List<Pedidoinforme> pedidos = await pedidosInforme(dateStr);
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  final pdf = pw.Document();
  final directory = await getApplicationDocumentsDirectory();
  final picturesDirectory = Directory(path.join(directory.path, 'pictures', dateStr));

  // Agregar la información de los pedidos al PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Informe de Pedidos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text("${userProvider.user?.nombre}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("${userProvider.user?.apellidos}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
             pw.Wrap(
                children: pedidos.map((pedido) {
                  return pw.Container(
                    width: double.infinity,
                    margin: pw.EdgeInsets.only(bottom: 10),
                    padding: pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ID: ${pedido.id}'),
                        pw.Text('Ruta ID: ${pedido.ruta_id}'),
                        pw.Text('Fecha: ${pedido.fecha}'),
                        pw.Text('Tipo: ${pedido.tipo}'),
                        pw.Text('Estado: ${pedido.estado}'),
                        pw.Text('Observación: ${pedido.observacion}'),
                        pw.Text('Tipo de Pago: ${pedido.tipo_pago}'),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    ),
  );

  // Verificar si hay fotos y agregarlas al PDF si existen
  if (await picturesDirectory.exists()) {
    final imageFiles = picturesDirectory
        .listSync()
        .where((item) => item is File)
        .map((item) => item as File)
        .toList();

    for (var image in imageFiles) {
      final imageFile = pw.MemoryImage(image.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(imageFile),
            );
          },
        ),
      );
    }
  }

  final pdfFile = File(path.join(directory.path, 'pictures', 'reporte_$dateStr.pdf'));
  await pdfFile.writeAsBytes(await pdf.save());

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'reporte_$dateStr.pdf',
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('PDF creado en ${pdfFile.path}')),
  );
}*/

 /* Future<dynamic> getRutas() async {
    //print(".......1");
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    SharedPreferences rutaidget = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');

    //print("id user");
    //print(iduser);

    //print("get ruta");

    var res = await http.get(
      Uri.parse(apiUrl + apiLastRutaCond + iduser.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        //  print("paso el estado");
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
            // print("temprutamodel id");
            // print(tempRutaModel.id);
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
  }*/

  @override
  void dispose() {
    super.dispose();
  }

/*
  void connectToServer() {
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
      // print('Conexión establecida: CONDUCTOR');
    });

    socket.onDisconnect((_) {
      // print('Conexión desconectada: CONDUCTOR');
    });

    socket.onConnectError((error) {
      // Manejar error de conexión
    });

    socket.onError((error) {
      // Manejar otros errores
    });

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
  }
*/
  @override
  void initState() {
    super.initState();
    //pedidosInforme();
    // Inicializa la localización para español
    // connectToServer();
   
    
    socketService.listenToEvent('creadoRuta', (data) async {
       print("......2.....dentro del init....");
      print("...creado de ruta ...$data");
      SharedPreferences rutaidget = await SharedPreferences.getInstance();
      // print("------esta es la RUTA");
       print(data['id']);
      rutaidget.setInt('rutaActual', data['id']);

      //final userProvider = Provider.of<UserProvider>(context, listen: false);

      /*if (data['conductor_id'] == userProvider.user?.id) {
        //print("entro al fi");
        setState(() {
          //seteo las preferncias para las demas vistas
          idRuta = data['id'];

          rutaidget.setInt('rutaIDNEW', idRuta);

          idconductor = data['conductor_id'];
          fechacreacion = data['fecha_creacion'];
        });
        // print("----datos de creado ruta");
        // print(idRuta);
        // print(idconductor);
        // print(fechacreacion);
      }*/
    });
   // _initialize();

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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 66, 209),
        toolbarHeight: MediaQuery.of(context).size.height / 18,
        iconTheme: IconThemeData(color: Colors.white),
        title: Container(
          //color: Colors.amber,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 18,
                width: MediaQuery.of(context).size.height / 18,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/imagenes/nuevito.png'))),
              ),
              const SizedBox(
                width: 19,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bienvenid@",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    "Hola,${userProvider.user?.nombre}",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 18,
                        color: Colors.white),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shadowColor: const Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Conductor",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 26),
                  ),
                  Text("${userProvider.user?.nombre}")
                ],
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
                      return AlertDialog(
                        title: Text("${userProvider.user?.nombre}"),
                        content: Text("${userProvider.user?.apellidos}"),
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
                socketService.disconnet();
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
        padding: const EdgeInsets.only(
          right: 20,
          left: 20,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.1,
          // color: Colors.grey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Container(
                //color: Colors.amber,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Container(
                      height: MediaQuery.of(context).size.height/18,
                      width: MediaQuery.of(context).size.height/18,
                      decoration:const BoxDecoration(
                        image: DecorationImage(image: AssetImage(
                          'lib/imagenes/nuevito.png'
                        ))
                      ),
                    ) ,const SizedBox(
                      width: 19,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Bienvenid@",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width/20,
                               fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Text(
                          "Hola,${userProvider.user?.nombre}",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width/18,color: Colors.white),
                        )
                      ],
                    ),
                   
                    
                  ],
                ),
              ),*/
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
              SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 4.2,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color.fromARGB(255, 66, 66, 209)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hoy ${dayName[0].toUpperCase() + dayName.substring(1)}, ${dayNumber[0].toUpperCase() + dayNumber.substring(1)} de ${monthName} ${year}",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width / 23.0),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: conectado ? colorconectado : Colors.grey,
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(conectado ? 
                                "Conectado a" : "Desconectado" ,
                                style: TextStyle(
                                    color: conectado ? Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 23.0),
                              ),
                             const SizedBox(width: 10,),
                              Container(
                                height: MediaQuery.of(context).size.height / 18,
                                width: MediaQuery.of(context).size.height / 18,
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'lib/imagenes/nuevito.png'))),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Switch(
                              value: conectado,
                              activeColor: Color.fromARGB(255, 206, 255, 176),
                              onChanged: (bool value) {
                                setState(() {
                                  conectado = value;
                                  colorconectado = Color.fromARGB(255, 86, 194, 64);
                                  //olor
                                });
                               /* if(conectado){
                                   showDialog(context: context,
                                 builder: (BuildContext context){
                                  return  AlertDialog(
                                    title: Text("Recuerda"),
                                    content: Container(
                                      height: MediaQuery.of(context).size.height/20,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                        Container(child: Row(
                                         
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width/25,
                                              height: MediaQuery.of(context).size.width/25,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                color: Colors.green
                                              ),
                                            ),
                                            Text("Revisa los almacenes más cercanos",style: TextStyle(fontWeight: FontWeight.w600),),
                                          ],
                                        )),
                                        Container(child: Row(
                                          children: [
                                             Container(
                                              width: MediaQuery.of(context).size.width/25,
                                              height: MediaQuery.of(context).size.width/25,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                color: Color.fromARGB(255, 68, 53, 224)
                                              ),
                                            ),
                                            Text("La central envía pedidos",style: TextStyle(fontWeight: FontWeight.w600),),

                                          ],
                                        )),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed:(){
                                        Navigator.pop(context);
                                      },
                                       child:const Text("OK",style: TextStyle(color: Colors.black),))
                                    ],
                                  );
                                 });
                                }*/
                               
                              }),
                             
                        ],
                      ),
                      
                    ),

                    /*const SizedBox(
                      height: 50,
                    ),*/
                    /* Center(
                      child: Column(
                        children: [
                          Icon(
                            idRuta != 0
                                ? Icons.airline_seat_recline_extra_outlined
                                : Icons.report_gmailerrorred_outlined,
                            size: MediaQuery.of(context).size.width / 10,
                            color: idRuta != 0
                                ? const Color.fromARGB(255, 39, 62, 166)
                                : const Color.fromARGB(255, 246, 47, 8),
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
                    ),*/
                    const SizedBox(
                      height: 10,
                    ),
                    /* Center(
                      child: Column(
                        children: [
                          Icon(
                            nombreauto != '-/-'
                                ? Icons.car_rental
                                : Icons.no_transfer_outlined,
                            size: MediaQuery.of(context).size.width / 10,
                            color: nombreauto != '-/-'
                                ? const Color.fromARGB(255, 39, 62, 166)
                                : const Color.fromARGB(255, 246, 47, 8),
                          ),
                          Text(
                            nombreauto != '-/-'
                                ? "Tu vehículo es el ${nombreauto}"
                                : "Espera tu unidad",
                            style: TextStyle(
                                color: nombreauto != '-/-'
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 246, 47, 8),
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )*/
                  ],
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder:(context)=>const DriverAlmacen()));
                   
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 66, 66, 209))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Almacenes cercanos",
                        style: TextStyle(
                            fontSize: 19,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      Icon(
                        Icons.storefront_sharp,
                        size: 50,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      //const SizedBox(width: 0,)
                    ],
                  ),
                ),
              ),
               SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                child:  ElevatedButton(
                  onPressed: conectado ? () {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Driver1()),
                    );*/
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Driver1()));
                  }:null,
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all( conectado ? 
                          Color.fromARGB(255, 66, 66, 209) : Colors.grey)),
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
                ) 
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Stock1()));
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(Colors.grey)), //Color.fromARGB(255, 236, 210, 134)
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Abastecer",
                        style: TextStyle(
                            fontSize: 19,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 50,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      //const SizedBox(width: 0,)
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              
              Container(
                height: MediaQuery.of(context).size.height / 15,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Informe de pedidos"),
                          content: Container(
                            height: MediaQuery.of(context).size.height / 7,
                            child: Column(
                              children: [
                                const Text("Debe ingresar la fecha"),
                                TextField(
                                  controller: _pdffecha,
                                  decoration: const InputDecoration(
                                      label: Text("Fecha"),
                                      hintText: 'AAAA-MM-DD'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  // LO SACO DEL OTRO SHOW DIALOG
                                  Navigator.pop(context);

                                  // LO INSERTO EN ESTE NUEVO

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CircularProgressIndicator(
                                              backgroundColor: Color.fromARGB(
                                                  255, 102, 28, 59),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              "Creando ...",
                                              style: TextStyle(fontSize: 15),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  // LLAMO METODO

                                  // print("------${_pdffecha.text}------");
                                  pedidosInforme(_pdffecha.text);
                                  // _createPdf(_pdffecha.text);

                                  Navigator.pop(context);
                                },
                                child: const Text("OK")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancelar"))
                          ],
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                           Colors.grey)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Informe",
                        style: TextStyle(
                            fontSize: 19,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 50,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      //const SizedBox(width: 0,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
