import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:appsol_final/components/navegador.dart';

class Prefinal extends StatefulWidget {
  const Prefinal({super.key});

  @override
  State<Prefinal> createState() => _PrefinalState();
}

class _PrefinalState extends State<Prefinal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
        },
      
          child: Stack(
            children: [
              // IMAGEN ABAJO
              Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('lib/imagenes/aguamarina2.png'))),
              ),

              // FILTRO
              /*Positioned.fill(
                child: Container(
                  color: const Color.fromARGB(255, 60, 125, 210)
                      .withOpacity(0.5), // Color semitransparente
                ),
              ),*/

              Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width/2.3,
                      height: MediaQuery.of(context).size.height/5,
                      decoration: const BoxDecoration(
                       // color: Colors.grey,
                          image: DecorationImage(
                              image: AssetImage('lib/imagenes/nuevito.png'))),
                    ),
                    const SizedBox(
                      height: 29,
                    ),
                    const Text(
                      "¡Gracias\npor permitirnos llevar vida\na tu hogar!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                  image: AssetImage(
                                      'lib/imagenes/bodegoncito.jpg'),
                                  fit: BoxFit.cover)),
                        ),

                        // ESPACIO ENTRE CONTAINER
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.amber,
                              image: const DecorationImage(
                                  image: AssetImage('lib/imagenes/lavando.jpg'),
                                  fit: BoxFit.cover)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Center(
                      child: Text(
                        "Muy pronto\nla Familia Sol, llegará con nuevos\nproductos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    /* Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            
                            const SizedBox(
                              height: 20,
                            ),
                           
                          ],
                        ),*/

                        const SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Container(
                        width: 300,
                        height: 60,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BarraNavegacion(
                                          indice: 0,
                                          subIndice: 0,
                                        )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            child: const Text(
                              "Regresar al menu",
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 77, 255, 1)),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        
      ),
    );
  }
}
