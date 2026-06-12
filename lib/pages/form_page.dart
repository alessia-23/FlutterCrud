import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/mongo_database.dart';
import '../models/videojuego.dart';

class FormPage extends StatefulWidget {
  final Videojuego? videojuego;
  const FormPage({super.key, this.videojuego});

  @override
  State createState() => _FormPageState();
}

class _FormPageState extends State {
  final _formKey = GlobalKey();
  final tituloCtrl = TextEditingController();
  final plataformaCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final imagenCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  bool guardando = false;

  @override
  void initState() {
    super.initState();
    final item = widget.videojuego;
    if (item != null) {
      tituloCtrl.text = item.titulo;
      plataformaCtrl.text = item.plataforma;
      precioCtrl.text = item.precio.toString();
      stockCtrl.text = item.stock.toString();
      imagenCtrl.text = item.imagen;
      descripcionCtrl.text = item.descripcion;
    }
  }

  Future guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => guardando = true);

    final videojuego = Videojuego(
      id: widget.videojuego?.id ?? const Uuid().v4(),
      titulo: tituloCtrl.text,
      plataforma: plataformaCtrl.text,
      precio: double.tryParse(precioCtrl.text) ?? 0,
      stock: int.tryParse(stockCtrl.text) ?? 0,
      imagen: imagenCtrl.text,
      descripcion: descripcionCtrl.text,
    );

    if (widget.videojuego == null) {
      await MongoDatabase.insertVideojuego(videojuego);
    } else {
      await MongoDatabase.updateVideojuego(videojuego);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget campo(TextEditingController ctrl, String label, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.videojuego != null;
    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar videojuego' : 'Nuevo videojuego')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              campo(tituloCtrl, 'Título'),
              campo(plataformaCtrl, 'Plataforma'),
              campo(precioCtrl, 'Precio', type: TextInputType.number),
              campo(stockCtrl, 'Stock', type: TextInputType.number),
              campo(imagenCtrl, 'URL de imagen'),
              campo(descripcionCtrl, 'Descripción'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: guardando ? null : guardar,
                  icon: const Icon(Icons.save),
                  label: Text(guardando ? 'Guardando...' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}