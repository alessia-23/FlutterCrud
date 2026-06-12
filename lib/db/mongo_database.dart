
import 'package:mongo_dart/mongo_dart.dart';
import '../models/videojuego.dart';

class MongoDatabase {
  static Db? _db;
  static DbCollection? _collection;

  // Reemplazar usuario, clave y cluster.
  static const String connectionString =
    'mongodb+srv://alessiaperez_db_user:rxeoYCqdXNV4JFRS@cluster0.9uajrxr.mongodb.net/clase_flutter?retryWrites=true&w=majority&appName=Cluster0';

  static Future connect() async {
    _db = await Db.create(connectionString);
    await _db!.open();
    _collection = _db!.collection('videojuegos');
  }

  static Future> getVideojuegos() async {
    final data = await _collection!.find().toList();
    return data.map((item) => Videojuego.fromMap(item)).toList();
  }

  static Future insertVideojuego(Videojuego videojuego) async {
    await _collection!.insertOne(videojuego.toMap());
  }

  static Future updateVideojuego(Videojuego videojuego) async {
    await _collection!.updateOne(
      where.eq('_id', videojuego.id),
      modify
          .set('titulo', videojuego.titulo)
          .set('plataforma', videojuego.plataforma)
          .set('precio', videojuego.precio)
          .set('stock', videojuego.stock)
          .set('imagen', videojuego.imagen)
          .set('descripcion', videojuego.descripcion),
    );
  }

  static Future deleteVideojuego(String id) async {
    await _collection!.deleteOne(where.eq('_id', id));
  }
}