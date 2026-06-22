import 'package:flutter/material.dart';

/// D-pad de controle direcional. Mantém pressionado para mover,
/// solta para parar — comportamento mais seguro para um robô físico.
class DirectionPad extends StatelessWidget {
  final void Function(String command) onCommand;

  const DirectionPad({super.key, required this.onCommand});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _padButton(Icons.keyboard_arrow_up, 'forward'),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _padButton(Icons.keyboard_arrow_left, 'left'),
            const SizedBox(width: 24),
            _stopButton(),
            const SizedBox(width: 24),
            _padButton(Icons.keyboard_arrow_right, 'right'),
          ],
        ),
        const SizedBox(height: 8),
        _padButton(Icons.keyboard_arrow_down, 'back'),
      ],
    );
  }

  Widget _padButton(IconData icon, String command) {
    return GestureDetector(
      onTapDown: (_) => onCommand(command),
      onTapUp: (_) => onCommand('stop'),
      onTapCancel: () => onCommand('stop'),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _stopButton() {
    return GestureDetector(
      onTap: () => onCommand('stop'),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.stop, color: Colors.white, size: 32),
      ),
    );
  }
}
