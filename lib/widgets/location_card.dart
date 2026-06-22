import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card de localização: mostra lat/lng e permite abrir no Google Maps.
class LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const LocationCard({super.key, this.latitude, this.longitude});

  bool get _hasFix => latitude != null && longitude != null;

  Future<void> _openInMaps() async {
    if (!_hasFix) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blueGrey.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _hasFix
                    ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
                    : 'Sem sinal de GPS',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (_hasFix)
              TextButton(
                onPressed: _openInMaps,
                child: const Text('Abrir no mapa'),
              ),
          ],
        ),
      ),
    );
  }
}
