import 'dart:io';
import 'package:app_coldman_sa/data/models/servicio_model.dart';
import 'package:flutter/material.dart';
import 'package:app_coldman_sa/utils/price_format.dart';

class CustomService extends StatelessWidget {

  final Servicio servicio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomService({
    super.key,
    required this.servicio,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
        ),
        title: Text(servicio.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
  
}
