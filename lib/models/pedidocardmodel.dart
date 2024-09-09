class Cardpedidomodel{
  int? id;
  String? estado;
  String direccion;
  List<Map<String, dynamic>> detallepedido;
  String nombres;
  String apellidos;
  String telefono;
  String tipo;
  double precio;
  int? beneficiadoid;
  String comentarios;


  Cardpedidomodel({
    required this.id,
    required this.estado,
    required this.direccion,
    required this.detallepedido,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.tipo,
    required this.precio,
    required this.beneficiadoid,
    required this.comentarios
  });
}