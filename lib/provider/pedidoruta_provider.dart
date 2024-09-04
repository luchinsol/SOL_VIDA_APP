import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

int activeOrderIndex = 0;

class PedidoconductorProvider extends ChangeNotifier {
  List<Pedido> listPedidos = [];
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';

  List<Pedido> get pedidos => listPedidos;

  Future<void> getPedidosConductor() async {
    /*  SharedPreferences rutaidget = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');*/
    int? rutaid = 16; // Cambia esto si es necesario

    var res = await http.get(
      Uri.parse("$apiUrl$apiPedidosConductor$rutaid}"),
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

        listPedidos = listTemporal;  
        notifyListeners();
      }
    } catch (error) {
      throw Exception("Error de consulta $error");
    }
  }

  void setPedidos(List<Pedido> pedidos) {
    listPedidos = pedidos;
    notifyListeners();
  }

  void rechazarPedidos(int pedidosId) {
    listPedidos.removeWhere((pedido) => pedido.id == pedidosId);
    notifyListeners();
  }


}
