import 'package:flutter/material.dart';

/// Card simples para mostrar uma leitura de sensor.
/// Largura fixa (padrão 100) para alinhar bem dentro de um [Wrap].
class SensorTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double width;

  const SensorTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Colors.blueGrey.shade700),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
