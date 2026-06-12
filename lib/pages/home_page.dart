import 'package:flutter/material.dart';
import '../db/mongo_database.dart';
import '../models/videojuego.dart';
import 'form_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State {
  late Future> videojuegosFuture;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    videojuegosFuture = MongoDatabase.getVideojuegos();
  }

  Future refrescar() async {
    setState(() {
      cargarDatos();
    });
  }

  Future eliminar(String id) async {
    await MongoDatabase.deleteVideojuego(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro eliminado')),
    );
    refrescar();
  }

  void confirmarEliminar(Videojuego item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar ${item.titulo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              eliminar(item.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videojuegos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPage()),
          );
          refrescar();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder>(
        future: videojuegosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No hay registros'));
          }
          return RefreshIndicator(
            onRefresh: refrescar,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network(
                      item.imagen,
                      width: 60,
                      errorBuilder: (_, __, ___) => const Icon(Icons.videogame_asset),
                    ),
                    title: Text(item.titulo),
                    subtitle: Text('${item.plataforma} | Stock: ${item.stock} | \$${item.precio}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailPage(videojuego: item)),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FormPage(videojuego: item)),
                            );
                            refrescar();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => confirmarEliminar(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}