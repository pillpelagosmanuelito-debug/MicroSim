import 'package:flutter/material.dart';

import '../model/arquitectura_catalog.dart';

class FichaDetalleScreen extends StatelessWidget {
  const FichaDetalleScreen({super.key, required this.ficha});
  final FichaArquitectura ficha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ficha.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(ficha.explicacion, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text('Datos clave', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...ficha.datosClave.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(d)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
