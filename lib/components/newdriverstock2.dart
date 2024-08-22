//import 'package:appsol_final/components/stockView.dart';
import 'package:appsol_final/components/newdriverstock1.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/models/producto_simplemodel.dart';
import 'package:appsol_final/provider/residuosprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Stock2 extends StatefulWidget {

  // List<int>resultados = [12,15,0];
  //Future<> => List<productos> products
  // lisview.buildr => products.length
  //products[index].nombre  ---> resultados[index] .
  // String nmbrepr =  products[index].nombre
  // Tex("nombre_sobrante[nmbrepr]") <-- valor
  // Map<String, int>nombre_sobrante = {"botell:5","bidon":0}

   const Stock2({super.key});
   
  

  @override
  _Stock2State createState() => _Stock2State();
}

class _Stock2State extends State<Stock2> {
  // Esta lista simula los datos que podrían venir de una base de datos
  /*
  List<Map<String, dynamic>> products = [
    {'name': 'Bidón', 'current': 5},
    {'name': 'Bidón 7L', 'current': 5},
    {'name': 'Bot. 3Litros', 'current': 5},
    {'name': 'Bot. 700ml', 'current': 0},
    {'name': 'Recargas', 'current': 5},
  ];*/
  List<int> valoresFinales = []; 
  int cantidadProductos = 0 ;
  Map<String,dynamic>residuofinal = {};

  getSobrantes()async{
   final residuoProvider = Provider.of<ResiduoProvider>(context, listen: false);
   // final datosResiduosfinales = 
    
    SharedPreferences productoResiduopref = await SharedPreferences.getInstance();
    try{
     // print("--------------------sobrantes------------");
      if(residuoProvider.residuos!=null){
        cantidadProductos =  residuoProvider.residuos!.listaproductos.length;
        //  print("----cantidad productos $cantidadProductos");
         for(var i=0;i<cantidadProductos;i++){
          
          String nombreProducto = residuoProvider.residuos!.listaproductos[i].nombre;
       //   print("nombre->$nombreProducto");
         
          setState(() {
            residuofinal[nombreProducto] = productoResiduopref.getInt(nombreProducto);//residuoProvider.residuos!.residuos[nombreProducto];
            
          });
         //  print("---resifuofinal ${residuofinal[nombreProducto]}");
         }

      }
    
     /* print("list ade producost");
      print(residuoProvider.residuos?.listaproductos);
      print("---residuos en sobrantes");
      print(residuoProvider.residuos?.residuos);
      print(residuoProvider.residuos?.residuos.length);*/
    } 
    catch(error){
      throw Exception("$error");
    }
  }
 

  @override
  void initState(){
    getSobrantes();
  //  _cargarpreferencias();
    super.initState();

  }

  Future<bool> _onWillPop() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => Stock1()));
    return Future.value(
        false); // Previene el comportamiento predeterminado de retroceso
  }

  @override
  Widget build(BuildContext context) {
    final residuoProvider = Provider.of<ResiduoProvider>(context, listen: false);
     return /*WillPopScope(
      onWillPop: _onWillPop,
      child:*/ Scaffold(
        backgroundColor: const Color.fromARGB(255, 93, 93, 94),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 76, 76, 77),
          toolbarHeight: MediaQuery.of(context).size.height / 18,
          iconTheme: const IconThemeData(color: Colors.white),
          /*leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Stock1()),
              );
            },
          ),*/
          title: const Text(
            'Abastecimiento - Stock',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white),
          ),
        ),
        body: Container(
          padding:const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //const SizedBox(height: 20),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sobrante en tu auto de la ruta anterior',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Productos',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white),
                  ),

                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 30),
                    decoration:const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Aquí empieza la lista de productos
              Container(
               // color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.93,
                height: MediaQuery.of(context).size.width * 1.05,
                child:residuoProvider.residuos != null && 
                residuofinal.isNotEmpty &&
                 residuoProvider.residuos!.listaproductos.isNotEmpty ? 
                 ListView.builder(
                  itemCount:  residuoProvider.residuos!.listaproductos.length,
                  itemBuilder: (context, index) {
                    /*  print("------------------------------//////");
                      print(residuoProvider.residuos);
                      print("-----ya pe");

                      print(residuoProvider.residuos!.listaproductos.length);
                      print(residuoProvider.residuos!.listaproductos[0]);*/

                    String nombreFinal = residuoProvider.residuos!.listaproductos[index].nombre;
                    
                    return Container(
                      margin: const EdgeInsets.only(top: 9,bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 236, 210, 134),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200,
                            child: Text(
                              residuoProvider.residuos!.listaproductos[index].nombre
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Container(
                                width: 70,
                                child: Center(
                                  child: Text(
                                    '${residuofinal[nombreFinal] ?? '0'}',
                                    style:const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                         
                        ],
                      ),
                    );
                  },
                ) : Center(child: Text("Todavía no hay sobrantes",style: TextStyle(fontSize: MediaQuery.of(context).size.width/20,fontWeight: FontWeight.bold)),),
              ),

              const SizedBox(height: 16),
            ],
          ),
        
      ),
    );
  }
}
