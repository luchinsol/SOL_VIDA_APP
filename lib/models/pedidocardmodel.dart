class Cardpedidomodel{
  int? id;
  String? pago;
  String direccion;
  List<Map<String, dynamic>> detallepedido;
  String nombres;
  String apellidos;
  String telefono;
  String tipo;
  double precio;


  Cardpedidomodel({
    required this.id,
    required this.pago,
    required this.direccion,
    required this.detallepedido,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.tipo,
    required this.precio
  });
}