import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sensor_data.dart';
import '../services/robot_connection.dart';
import '../widgets/direction_pad.dart';
import '../widgets/location_card.dart';
import '../widgets/sensor_section.dart';
import '../widgets/sensor_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ipController = TextEditingController();
  final _connection = RobotConnection();

  RobotConnState _connState = RobotConnState.disconnected;
  SensorData? _d; // última leitura de sensores

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
    _connection.stateStream.listen((s) => setState(() => _connState = s));
    _connection.sensorStream.listen((data) => setState(() => _d = data));
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString('robot_ip') ?? '192.168.1.50';
  }

  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('robot_ip', ip);
    await _connection.connect(ip);
  }

  @override
  void dispose() {
    _connection.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (_connState) {
      case RobotConnState.connected:
        return Colors.green;
      case RobotConnState.connecting:
        return Colors.orange;
      case RobotConnState.error:
        return Colors.red;
      case RobotConnState.disconnected:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (_connState) {
      case RobotConnState.connected:
        return 'Conectado';
      case RobotConnState.connecting:
        return 'Conectando...';
      case RobotConnState.error:
        return 'Erro de conexão';
      case RobotConnState.disconnected:
        return 'Desconectado';
    }
  }

  String _fmt(double? v, {int decimals = 1, String suffix = ''}) {
    if (v == null) return '--';
    return '${v.toStringAsFixed(decimals)}$suffix';
  }

  String _fmtTime(int? minutes) {
    if (minutes == null) return '--';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m}min' : '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final connected = _connState == RobotConnState.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('Controle do Robô')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Conexão ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP do ESP32',
                        hintText: 'ex: 192.168.1.50',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: connected ? _connection.disconnect : _connect,
                    child: Text(connected ? 'Desconectar' : 'Conectar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_statusLabel),
                ],
              ),
              const SizedBox(height: 24),

              // --- Motores ---
              SensorSection(
                title: 'TEMPERATURA DOS MOTORES',
                icon: Icons.settings,
                children: List.generate(5, (i) {
                  final temps = _d?.motorTemps ?? const [null, null, null, null, null];
                  return SensorTile(
                    label: 'Motor ${i + 1}',
                    value: _fmt(temps[i], suffix: '°C'),
                    icon: Icons.thermostat,
                  );
                }),
              ),

              // --- Ambiente interno (DHT22) ---
              SensorSection(
                title: 'AMBIENTE INTERNO',
                icon: Icons.home,
                children: [
                  SensorTile(
                    label: 'Temp. interna',
                    value: _fmt(_d?.internalTempC, suffix: '°C'),
                    icon: Icons.thermostat,
                  ),
                  SensorTile(
                    label: 'Umidade',
                    value: _fmt(_d?.internalHumidityPercent, suffix: '%'),
                    icon: Icons.water_drop,
                  ),
                ],
              ),

              // --- Bateria ---
              SensorSection(
                title: 'BATERIA',
                icon: Icons.battery_full,
                children: [
                  SensorTile(
                    label: 'Tensão',
                    value: _fmt(_d?.batteryVoltage, suffix: 'V'),
                    icon: Icons.bolt,
                  ),
                  SensorTile(
                    label: 'Corrente',
                    value: _fmt(_d?.batteryCurrent, suffix: 'A'),
                    icon: Icons.electric_bolt,
                  ),
                  SensorTile(
                    label: 'Temp. bateria',
                    value: _fmt(_d?.batteryTempC, suffix: '°C'),
                    icon: Icons.thermostat,
                  ),
                  SensorTile(
                    label: 'Tempo restante',
                    value: _fmtTime(_d?.batteryTimeLeftMin),
                    icon: Icons.timer,
                    width: 110,
                  ),
                ],
              ),

              // --- Energia solar ---
              SensorSection(
                title: 'PLACA SOLAR',
                icon: Icons.wb_sunny,
                children: [
                  SensorTile(
                    label: 'Tensão',
                    value: _fmt(_d?.solarVoltage, suffix: 'V'),
                    icon: Icons.bolt,
                  ),
                  SensorTile(
                    label: 'Corrente',
                    value: _fmt(_d?.solarCurrent, suffix: 'A'),
                    icon: Icons.electric_bolt,
                  ),
                ],
              ),

              // --- Inclinação ---
              SensorSection(
                title: 'INCLINAÇÃO',
                icon: Icons.architecture,
                children: [
                  SensorTile(
                    label: 'Pitch',
                    value: _fmt(_d?.pitchDeg, suffix: '°'),
                    icon: Icons.rotate_left,
                  ),
                  SensorTile(
                    label: 'Roll',
                    value: _fmt(_d?.rollDeg, suffix: '°'),
                    icon: Icons.rotate_right,
                  ),
                ],
              ),

              // --- Localização ---
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map, size: 18, color: Colors.blueGrey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'LOCALIZAÇÃO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LocationCard(latitude: _d?.latitude, longitude: _d?.longitude),
                  ],
                ),
              ),

              // --- Controle ---
              Center(
                child: Opacity(
                  opacity: connected ? 1.0 : 0.4,
                  child: IgnorePointer(
                    ignoring: !connected,
                    child: DirectionPad(
                      onCommand: (cmd) => _connection.sendCommand(cmd),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
