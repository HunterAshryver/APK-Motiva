import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/sensor_data.dart';

enum RobotConnState { disconnected, connecting, connected, error }

/// Centraliza toda a comunicação com o ESP32.
///
/// Uso:
///   final conn = RobotConnection();
///   conn.connect('192.168.1.50');
///   conn.sensorStream.listen((data) { ... });
///   conn.sendCommand('forward');
class RobotConnection {
  WebSocketChannel? _channel;
  StreamController<SensorData>? _sensorController;
  StreamController<RobotConnState>? _stateController;

  RobotConnState _state = RobotConnState.disconnected;
  RobotConnState get state => _state;

  Stream<SensorData> get sensorStream =>
      (_sensorController ??= StreamController<SensorData>.broadcast()).stream;

  Stream<RobotConnState> get stateStream =>
      (_stateController ??= StreamController<RobotConnState>.broadcast())
          .stream;

  /// Conecta ao ESP32 em ws://<ip>:81 (ajuste a porta se mudar no firmware)
  Future<void> connect(String ip, {int port = 81}) async {
    await disconnect();
    _setState(RobotConnState.connecting);

    try {
      final uri = Uri.parse('ws://$ip:$port');
      _channel = IOWebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (_) => _setState(RobotConnState.error),
        onDone: () => _setState(RobotConnState.disconnected),
      );

      _setState(RobotConnState.connected);
    } catch (_) {
      _setState(RobotConnState.error);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String) as Map<String, dynamic>;
      final data = SensorData.fromJson(decoded);
      _sensorController?.add(data);
    } catch (_) {
      // Mensagem não era um JSON de sensores válido; ignore com segurança.
    }
  }

  /// Envia um comando simples para o robô, ex: 'forward', 'back', 'left',
  /// 'right', 'stop'. O ESP32 deve interpretar { "cmd": "forward" }.
  void sendCommand(String cmd) {
    if (_state != RobotConnState.connected || _channel == null) return;
    _channel!.sink.add(jsonEncode({'cmd': cmd}));
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    if (_state != RobotConnState.disconnected) {
      _setState(RobotConnState.disconnected);
    }
  }

  void _setState(RobotConnState newState) {
    _state = newState;
    _stateController?.add(newState);
  }

  void dispose() {
    disconnect();
    _sensorController?.close();
    _stateController?.close();
  }
}
