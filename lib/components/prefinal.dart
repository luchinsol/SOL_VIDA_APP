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
      body: Stack(
        children: [
          // IMAGEN ABAJO
          Positioned(
              child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('lib/imagenes/lavando.jpg'))),
          )),

          // FILTRO
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 60, 125, 210)
                  .withOpacity(0.5), // Color semitransparente
            ),
          ),

          Container(
            
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 100,
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('lib/imagenes/nuevecito.png'))),
                ),
                const Text(
                  "Gracias",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "por llevar vida a tu hogar.",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                  image: AssetImage('lib/imagenes/bodegoncito.jpg'),
                                  fit: BoxFit.cover)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Muy pronto",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "la Familia Sol",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "llegará con nuevos",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "productos",
                         style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),

                    // ESPACIO ENTRE CONTAINER
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 320,
                      width: 160,
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
                Center(
                  child: Container(
                    width: 300,
                    height: 60,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const BarraNavegacion(
                                                  indice: 0,
                                                  subIndice: 0,
                                                )),
                                      );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: const Text(
                          "Menu",
                          style: TextStyle(fontSize: 25, color: Colors.black),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
