import 'package:flutter/material.dart';

class Pedidoinforme{
  int? id;
  int? ruta_id;
  double subtotal;
  double descuento;
  double total;
  String fecha;
  String tipo;
  String estado;
  String observacion;
  String tipo_pago;

  Pedidoinforme({
    required this.id,
    required this.ruta_id,
    this.subtotal = 0.0,
    this.descuento = 0.0,
    this.total = 0.0,
    required this.fecha,
    required this.tipo,
    required this.estado,
    required this.observacion,
    required this.tipo_pago
  });
}