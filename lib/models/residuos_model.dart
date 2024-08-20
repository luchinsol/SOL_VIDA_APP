import 'package:appsol_final/models/producto_simplemodel.dart';

class ResiduosModel{
  final List<ProductoSimple>listaproductos;
  final Map<String,dynamic>residuos;

  ResiduosModel({
    required this.listaproductos,
    required this.residuos
  });
}