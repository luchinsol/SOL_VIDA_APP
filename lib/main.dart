import 'dart:convert';

import 'package:appsol_final/components/conductorinit.dart';
import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/pedidoruta_provider.dart';
import 'package:appsol_final/provider/residuosprovider.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'firebase_options.dart';
import 'package:appsol_final/components/holaconductor.dart';
import 'package:upgrader/upgrader.dart';

late List<CameraDescription> camera;
//late SocketService socketService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  //print("userJson main ---------------------------------");
  //print(userJson);
  bool estalogeado = userJson != null; //false = nologeado, true = logeado
  //print("estalogeado------------------------");
  //print(estalogeado);
  var prueba = UserModel();
  //print(prueba.rolid);
  //prefs.remove('user');
  int rol = 0;
  if (estalogeado == true) {
    rol = jsonDecode(userJson!)['rolid'];
  }
  //print(rol);
  await dotenv.load(fileName: ".env");
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/

  // Inicializamos el UserProvider y cargamos el usuario
  UserProvider userProvider = UserProvider();
  await userProvider.initUser();

    // Inicializar el servicio de Socket.IO
  //SocketService();
  // Inicializamos el servicio de Socket.IO
  SocketService socketService = SocketService();

  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => PedidoProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionListProvider()),
        ChangeNotifierProvider(create: (context) => RutaProvider()),
        ChangeNotifierProvider(create: (context) => CardpedidoProvider()),
        ChangeNotifierProvider(create: (context) => ResiduoProvider()),
        ChangeNotifierProvider(create: (context) => PedidoconductorProvider()),
        Provider<SocketService>.value(value: socketService), // Proveer el SocketService aquí
      ],
      child: MyApp(estalogeado: estalogeado, rol: rol),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool estalogeado;
  final int rol;
  const MyApp({Key? key, required this.estalogeado, required this.rol})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if(estalogeado && rol ==  5){
      socketService.connectToServer();
    }
    else{
      socketService.disconnet();
    }
    return UpgradeAlert(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', ''), // Español
        ],
        //home: estalogeado && rol == 4 ? BarraNavegacion(indice: 0,subIndice: 0,) : (estalogeado && rol == 5 ? HolaConductor() :Login()),
        home: estalogeado
            ? (rol == 4
                ? const BarraNavegacion(
                    indice: 0,
                    subIndice: 0,
                  )
                : (rol == 5 ? const Driver() : const Solvida()))
            : const Solvida(),
      ),
    );
  }
}
