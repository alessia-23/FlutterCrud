class Videojuego {
  final String id;
  final String titulo;
  final String plataforma;
  final double precio;
  final int stock;
  final String imagen;
  final String descripcion;

  Videojuego({
    required this.id,
    required this.titulo,
    required this.plataforma,
    required this.precio,
    required this.stock,
    required this.imagen,
    required this.descripcion,
  });

  factory Videojuego.fromMap(Map map) {
    return Videojuego(
      id: map['_id'].toString(),
      titulo: map['titulo'] ?? '',
      plataforma: map['plataforma'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      imagen: map['imagen'] ?? '',
      descripcion: map['descripcion'] ?? '',
    );
  }

  Map toMap() {
    return {
      '_id': id,
      'titulo': titulo,
      'plataforma': plataforma,
      'precio': precio,
      'stock': stock,
      'imagen': imagen,
      'descripcion': descripcion,
    };
  }
}
