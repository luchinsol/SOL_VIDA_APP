import 'package:appsol_final/models/pedidocardmodel.dart';
import 'package:appsol_final/models/residuos_model.dart';
import 'package:flutter/material.dart';
import 'package:appsol_final/models/pedido_model.dart';

class ResiduoProvider extends ChangeNotifier {
  // CREAS UNA INSTANCIA DE LA CLASE
  ResiduosModel? _residuos;

  // OBTIENES EL PEDIDO CARD
  ResiduosModel? get residuos => _residuos;

  // ACTUALIZAS EL VALOR DEL OBJETO Y NOTIFICAMOS A LOS RECEPTORES
  void updateResiduo(ResiduosModel newResiduo) {
    _residuos = newResiduo;
    notifyListeners();
  }
}
