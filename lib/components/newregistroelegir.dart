import 'package:appsol_final/components/newregistroconductor.dart';
import 'package:appsol_final/components/responsiveUI/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:appsol_final/components/preregistro.dart';

class Registroelegir extends StatefulWidget {
  const Registroelegir({super.key});

  @override
  State<Registroelegir> createState() => _RegistroelegirState();
}

class _RegistroelegirState extends State<Registroelegir> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget pantalla(String tama, double ancho, double alto, double texto1) {
    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.asset(
            'lib/imagenes/aguamarina2.png', // Asegúrate de tener la imagen en la carpeta assets y agregarla en pubspec.yaml
            fit: BoxFit.cover,
          ),
        ),
        //Text("${tama} ${MediaQuery.of(context).size.width}}"),
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(texto1),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Elija de que modo quiere registrarse',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 19.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 65,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            height: MediaQuery.of(context).size.height / 19,
                            child: ElevatedButton(
                                onPressed: () {
                                 /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Registroconductor()),
                                  );*/
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 131, 132, 133),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18))),
                                child: Text(
                                  "Conductor: Pronto",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255)),
                                )),
                          ).animate().fade(delay: 0.9.ms).slideY(),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            height: MediaQuery.of(context).size.height / 19,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Formucli()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18))),
                                child: Text(
                                  "Cliente",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              15,
                                      color:
                                          const Color.fromRGBO(0, 77, 255, 1),
                                      fontWeight: FontWeight.bold),
                                )),
                          ).animate().fade(delay: 0.9.ms).slideY(),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= Breakpoint.xsmall) {
            return pantalla("XS", 100, 85, 10);
          } else if (constraints.maxWidth <= Breakpoint.avgsmall) {
            return pantalla("avS", 110, 100, 13.0);
          } else if (constraints.maxWidth <= Breakpoint.small) {
            return pantalla("S", 140, 140, 18); // PUNTO CLAVE
          } else if (constraints.maxWidth <= Breakpoint.avgmedium) {
            return pantalla("avM", 160, 160, 18);
          } else if (constraints.maxWidth <= Breakpoint.medium) {
            return pantalla("M", 220, 180, 18);
          } else if (constraints.maxWidth <= Breakpoint.avglarg) {
            return pantalla("avL", 220, 200, 18);
          } else if (constraints.maxWidth <= Breakpoint.large) {
            return pantalla("L", 220, 220, 18);
          } else if (constraints.maxWidth <= Breakpoint.avgxlarge) {
            return pantalla("avXL", 240, 240, 18);
          } else {
            return pantalla("XL", 260, 260, 18);
          }
        },
      ),
    );
  }
}
