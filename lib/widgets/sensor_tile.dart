import 'package:flutter/material.dart';

class SensorTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? borderColor;

  const SensorTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: borderColor ?? const Color(0xFF5D00FF),
            width: 2.8,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 28, color: borderColor ?? const Color(0xFF5D00FF)),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
