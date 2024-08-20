import 'dart:convert';

//import 'package:appsol_final/components/stockView2.dart';
import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/newdriverstock2.dart';
import 'package:appsol_final/models/producto_simplemodel.dart';
import 'package:appsol_final/models/residuos_model.dart';
import 'package:appsol_final/provider/residuosprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Stock1 extends StatefulWidget {
  @override
  _Stock1State createState() => _Stock1State();
}

class _Stock1State extends State<Stock1> {
  // Esta lista simula los datos que podrían venir de una base de datos
  /*
  List<Map<String, dynamic>> products = [
    {'name': 'Bidón', 'current': 10, 'required': 15},
    {'name': 'Bidón 7L', 'current': 5, 'required': 10},
    {'name': 'Bot. 3Litros', 'current': 10, 'required': 15},
    {'name': 'Bot. 700ml', 'current': 5, 'required': 5},
    {'name': 'Recargas', 'current': 5, 'required': 10},
  ];*/
  late Future<List<DetallePedido>> _productosFuture;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  final String vehiculoIDpref = '1';
  String apiDetalleVehiculo = '/api/vehiculo_producto_conductor/';
  List<DetallePedido> listDetallePedido = [];
  List<Producto> listProducto = [];
  List<DetallePedido> products = [];
  bool isLoading = true;
  Map<int, int> selectedQuantities = {};
  String apiStock = '/api/vehiculo_producto_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  Map<String, int> grouped = {};
  String groupedJson = "na";
  List<Map<String, dynamic>> result = [];
  List<Pedido> listPedidosbyRuta = [];
  int activeOrderIndex = 0;
  String apiPedidosConductor = '/api/pedido_conductor/';
  int cantidadpedidos = 0;
  List<DetallePedido> detallesPedidos = [];
  Map<String, int> cantidadTotalPorProducto = {};
  String productos = '/api/products';
  List<ProductoSimple> getproducts = [];

  Map<String, dynamic> productosglobales = {};
  Map<String, dynamic> productoResiduo = {};

  // Función para sumar las cantidades de una lista de productos
  void sumarCantidades(List<Map<String, dynamic>> lista) {
    for (var i = 0; i < lista.length; i++) {
      setState(() {
        String nombreProducto = lista[i]["nombre_prod"];
        int cantidad = lista[i]["cantidad"];

        // Verificar si ya está en productosglobales, si es así sumar la cantidad
        if (productosglobales.containsKey(nombreProducto)) {
          productosglobales[nombreProducto] =
              productosglobales[nombreProducto]! + cantidad;
        } else {
          productosglobales[nombreProducto] = cantidad;
        }
      });
    }
  }

/*
  Future<List<DetallePedido>> getProductosVehiculo() async {
  if (vehiculoIDpref == 0) return [];

  try {
    var res = await http.get(
      Uri.parse(apiUrl + apiDetalleVehiculo + vehiculoIDpref.toString()),
      headers: {"Content-type": "application/json"},
    );

    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      return data.map<DetallePedido>((mapa) => DetallePedido(
        pedidoID: mapa['id'],
        productoID: mapa['producto_id'],
        productoNombre: mapa['nombre'],
        cantidadProd: mapa['stock'],
        promocionID: 0,
        promocionNombre: '',
      )).toList();
    } else {
      throw Exception('Error en la solicitud: ${res.statusCode}');
    }
  } catch (error) {
    print('Error al obtener productos: $error');
    throw error;
  }
}*/

  Future<dynamic> getPedidosConductor() async {
    setState(() {
      activeOrderIndex++;
    });
    print("get pedidos conduc");
    SharedPreferences rutaidget = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');
    int? rutaidnew = rutaidget.getInt('rutaIDNEW');
    print("datos de getpedidos : ${rutaidget.getInt('rutaIDNEW')}");
    print("datos id user: ${iduser}");

    var res = await http.get(
      Uri.parse("$apiUrl$apiPedidosConductor$rutaidnew/${iduser.toString()}"),
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

        for (var pedido in listPedidosbyRuta) {
          var detalle = await getDetalleXUnPedido(pedido.id);
          if (mounted) {
            sumarCantidades(detalle);
          }
        }
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
      print(apiUrl + apiDetallePedido + pedidoID.toString());
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          //print(data);
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
          print("ENTRANDO A PEDIDOSSSSSSSSSSSSSS");
          // print(grouped);
          // Crear la lista de resultados

          grouped.forEach((nombreProd, cantidad) {
            result.add({'nombre_prod': nombreProd, 'cantidad': cantidad});
          });
          // Convertir a JSON
          groupedJson = jsonEncode(result);

          // Imprimir el resultado
          print("IMPRIMIDA FINAL DETALLES -------------------");
          //print(groupedJson);
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
          // print("....tipo de dato de retorno ${groupedJson.runtimeType}");
          return result;
        }
      } catch (e) {
        //print('Error en la solicitud: $e');
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      //print('papas');
    }
  }

  Future<dynamic> updateStock(stock, productoID) async {
    String vehiculoIDpref = "1";
    try {
      await http.put(Uri.parse(apiUrl + apiStock + vehiculoIDpref),
          headers: {"Content-type": "application/json"},
          body: jsonEncode(
              {"stock_movil_conductor": stock, "producto_id": productoID}));
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> _confirmarAbastecimiento() async {
    bool hasInsufficientStock = false;

    setState(() {
      // Iniciar actualización de UI
    });

    for (int index = 0; index < getproducts.length; index++) {
      ProductoSimple product = getproducts[index];
      int selectedQuantity = selectedQuantities[index] ?? 0;
      int requiredQuantity = productosglobales[product.nombre] ?? 0;

      print("valores entregados------------->");
      //print(product);
      //print(selectedQuantity);
      //print(requiredQuantity);
      //print(product.id);

      if (requiredQuantity > selectedQuantity) {
        hasInsufficientStock = true;
      }

      // Actualizar el stock para cada producto
      try {

        await updateStock(selectedQuantity, product.id);
     

        // Actualizar los datos locales
       /* setState(() {
          selectedQuantities[index] = selectedQuantity;
          productosglobales[product.nombre] = selectedQuantity;
          getproducts[index] = ProductoSimple(
            id: product.id,
            nombre: product.nombre,
            precio: product.precio,
            descripcion: selectedQuantity.toString(),
          );
        });*/
      } catch (e) {
        //print("Error al actualizar el stock para ${product.nombre}: $e");
        // Puedes manejar el error aquí, por ejemplo, mostrando un mensaje al usuario
      }
    }

    if (hasInsufficientStock) {
      await _showDialog(
          'La cantidad debe ser mayor a la solicitada por los pedidos. Hay insuficiente stock en al menos un producto y se procede a actualizar.');
    } else {
      await _showDialog('Listo, prepárate para la ruta.');
    }

    // Actualización final de la UI
    setState(() {
      // Cualquier actualización adicional de la UI si es necesario
    });
  }

  Future<void> _showDialog(String message) async {
    final residuoProvider = context.watch<ResiduoProvider>();
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // El usuario debe hacer clic en el botón para cerrar el diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:const Text('OK'),
              onPressed: () {
                
                
                residuoProvider.updateResiduo(
                  ResiduosModel(
                    listaproductos: getproducts,
                     residuos: productoResiduo));
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>const Driver())); // Cierra el diálogo
              },
            ),
            TextButton(onPressed: (){
              residuoProvider.updateResiduo(
                  ResiduosModel(
                    listaproductos: getproducts,
                     residuos: productoResiduo));
              Navigator.pop(context);
            }, child:const Text("Continuar"))
          ],
        );
      },
    );
  }

/*
  Future<void> _fetchData() async {
    try {
      // Llamada a getPedidosConductor para obtener la lista de pedidos
      await getPedidosConductor();
      // Luego, por cada pedido, llama a getDetalleXUnPedido
      for (var pedido in listPedidosbyRuta) {
        await getDetalleXUnPedido(pedido.id);
      }
      // Calcula la cantidad total de pedidos
      int totalPedidos = listPedidosbyRuta.length;
      print("RUTAAAA FINAL-------------->>>>>");
      print(totalPedidos);
      // Actualiza el estado con el total de pedidos si es necesario
      setState(() {
        // Aquí puedes usar el totalPedidos según sea necesario
      });
    } catch (e) {
      print('Error al obtener datos: $e');
    }
  }
*/
  @override
  void initState() {
    super.initState();
    getProductosNew();
    //loadProducts();
    //fetchProductos();
    //cargarDatos();
    //_fetchData();
    getPedidosConductor();

    selectedQuantities = {
      for (var i = 0; i < products.length; i++) i: products[i].cantidadProd
    };
  }

  Future<dynamic> getProductosNew() async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + productos),
        headers: {"Content-type": "application/json"},
      );
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<ProductoSimple> listemp = data
            .map<ProductoSimple>((mapa) => ProductoSimple(
                  id: mapa['id'],
                  nombre: mapa['nombre'],
                  precio: mapa['precio']?.toDouble(),
                  descripcion: mapa['descripcion'],
                ))
            .toList();

        if (mounted) {
          setState(() {
            getproducts = listemp;
          });
        }
        //print("Estamos aqui-------------");
        //print(getproducts);
      } else {
        throw Exception('Error en la solicitud: ${res.statusCode}');
      }
    } catch (error) {
      throw Exception("$error");
    }
  }

  Future<void> procesarTodosLosPedidos() async {
    cantidadTotalPorProducto.clear();
    for (var pedido in listPedidosbyRuta) {
      await getDetalleXUnPedido(pedido.id);
    }
  }

  void calcularCantidadTotalPorProducto() {
    cantidadTotalPorProducto = {};
    for (var detalle in detallesPedidos) {
      cantidadTotalPorProducto[detalle.productoNombre] =
          (cantidadTotalPorProducto[detalle.productoNombre] ?? 0) +
              detalle.cantidadProd;
    }
  }

  void fetchProductos() async {
    List<DetallePedido> productos = await getProductosVehiculo();
    //print("fetch productos--------");
    //print(productos);
    setState(() {
      products = productos;
    });
  }

  Future<List<DetallePedido>> getProductosVehiculo() async {
    int vehiculoIDpref = 1;
    //if (vehiculoIDpref == 0) return [];

    try {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetalleVehiculo + vehiculoIDpref.toString()),
        headers: {"Content-type": "application/json"},
      );
      print(res);

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        return data
            .map<DetallePedido>((mapa) => DetallePedido(
                  pedidoID: mapa['id'],
                  productoID: mapa['producto_id'],
                  productoNombre: mapa['nombre'],
                  cantidadProd: mapa['stock'],
                  promocionID: 0,
                  promocionNombre: '',
                ))
            .toList();
      } else {
        throw Exception('Error en la solicitud: ${res.statusCode}');
      }
    } catch (error) {
      print('Error al obtener productos: $error');
      throw error;
    }
  }

  Future<void> loadProducts() async {
    try {
      List<DetallePedido> loadedProducts = await getProductosVehiculo();
      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (error) {
      print('Error al cargar productos: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Asegúrate de cancelar cualquier tarea asincrónica aquí
    super.dispose();
  }

  final List<DropdownMenuItem<int>> dropdownItems =
      List.generate(1000, (index) {
    return DropdownMenuItem<int>(
      value: index,
      child: Text(
        '$index',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  });
  Future<bool> _onWillPop() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    return Future.value(
        false); // Previene el comportamiento predeterminado de retroceso
  }

  @override
  Widget build(BuildContext context) {
    final residuoProvider = context.watch<ResiduoProvider>();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 93, 93, 94),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 76, 76, 77),
          toolbarHeight: MediaQuery.of(context).size.height / 18,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Driver()),
              );
            },
          ),
          title: const Text(
            'Abastecimiento - Stock',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: double.infinity),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          child: Text(
                            'Cantidades de productos para tu ruta.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width / 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 34, 53, 163),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        child: Text(
                          'Cantidades para abastecer.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width / 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                   // color: Colors.white,
                    width: MediaQuery.of(context).size.width/2.6,
                    child: const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 45),
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 30),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 34, 53, 163),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 16),
              Container(
                //color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.93,
                height: MediaQuery.of(context).size.width * 1.05,
                child: getproducts.isNotEmpty
                    ? ListView.builder(
                        itemCount: getproducts.length,
                        itemBuilder: (context, index) {
                          //print("****** ++++++ Lista de productos: $getproducts");
                          //print("--------- ******* Productos globales: $productosglobales");
                          //int cantidadTotal =
                          //   cantidadTotalPorProducto[productoNombre] ?? 0;
                          String? nombreproductoobtenido =
                              getproducts[index].nombre;

                          // print(".......<<<<");
                          //print(nombreproductoobtenido);
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 236, 210, 134),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  //color:Colors.white,
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Text(
                                    getproducts[index].nombre.toUpperCase(),
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromARGB(255, 84, 83, 83),
                                      fontFamily: 'Poppins',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // SizedBox(width: 5),
                                Container(
                                  // color: Colors.white,
                                  width:
                                      MediaQuery.of(context).size.width / 4.5,
                                  child: Text(
                                    "${productosglobales[nombreproductoobtenido] ?? '0'} ", // valor de cantidad

                                    //"Holaaa",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                //SizedBox(width: 16),
                                Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: DropdownButton<int>(
                                    value: (selectedQuantities[index] ?? 0),
                                    //?? productosglobales[nombreproductoobtenido] ?? 0
                                    items: dropdownItems,
                                    /*List.generate(1000, (index) => index)
                                        .map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(
                                          '$value',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                25,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      );
                                    }).toList(),*/
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          //print("------drop ddonw ");
                                          //print("valor seleccionado : ${newValue}");
                                          // print("-------------");
                                          selectedQuantities[index] = newValue;
                                          //Map<String, dynamic> productoResiduo = {};

                                          String nombreproductonew =
                                              getproducts[index].nombre;
                                          // MAP DE PRODCUTO = BIDON
                                          // VALOR DD - VALOR PRODUCTOGLOBAL

                                          if (productosglobales
                                              .containsKey(nombreproductonew)) {
                                            productoResiduo[nombreproductonew] =
                                                selectedQuantities[index]! -
                                                    productosglobales[
                                                        nombreproductonew];
                                          } else {
                                            // Handle the case where the key is not found
                                            productoResiduo[nombreproductonew] =
                                                selectedQuantities[index]!;
                                          }
                                        });

                                        //productosglobales[
                                        //   nombreproductoobtenido] = newValue;
                                        //productosglobales[nombreproductoobtenido] = newValue;

                                        /* getproducts[index] = ProductoSimple(
                                            id: getproducts[index].id,
                                            nombre: getproducts[index].nombre,
                                            precio: getproducts[index].precio,
                                            descripcion: newValue.toString(),
                                          );*/
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 16),
              // BOTONES
              Container(
                height: MediaQuery.of(context).size.height / 15,
                child: ElevatedButton(
                  onPressed: _confirmarAbastecimiento,
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 33, 37, 139))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //SizedBox(width: 16),
                      Text(
                        'Confirmar abastecimiento',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                      // Spacer(),
                      Icon(
                        Icons.local_shipping,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                child: ElevatedButton(
                  onPressed: () {
                    residuoProvider.updateResiduo(ResiduosModel(
                      listaproductos: getproducts,
                       residuos: productoResiduo));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Stock2()
                      ),
                    );
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 47, 47, 47))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // const SizedBox(width: 16),
                      Text(
                        'Revisión de sobrantes',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.local_drink,
                        color: Colors.white,
                      ),
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
