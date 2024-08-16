import 'package:appsol_final/models/pedidocardmodel.dart';
import 'package:flutter/material.dart';
import 'package:appsol_final/models/pedido_model.dart';

class CardpedidoProvider extends ChangeNotifier {
  // CREAS UNA INSTANCIA DE LA CLASE
  Cardpedidomodel? _pedido;

  // OBTIENES EL PEDIDO CARD
  Cardpedidomodel? get pedido => _pedido;

  // ACTUALIZAS EL VALOR DEL OBJETO Y NOTIFICAMOS A LOS RECEPTORES
  void updateCard(Cardpedidomodel newPedido) {
    _pedido = newPedido;
    notifyListeners();
  }
}
