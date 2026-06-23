import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sensor_data.dart';
import '../services/robot_connection.dart';
import '../widgets/direction_pad.dart';
import '../widgets/sensor_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ipController = TextEditingController();
  final _connection = RobotConnection();

  RobotConnState _connState = RobotConnState.disconnected;
  SensorData? _sensorData;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  final Color anilMotiva = const Color(0xFF5D00FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedIp();

    _connection.stateStream.listen((s) => setState(() => _connState = s));
    _connection.sensorStream.listen((data) {
      setState(() => _sensorData = data);
      _updateMapMarker(data);
    });
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString('robot_ip') ?? '192.168.4.1';
  }

  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('robot_ip', ip);
    await _connection.connect(ip);
  }

  void _updateMapMarker(SensorData data) {
    if (data.latitude == null || data.longitude == null) return;

    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('robot'),
        position: LatLng(data.latitude!, data.longitude!),
        infoWindow:
            const InfoWindow(title: 'Robô Motiva', snippet: 'Posição Atual'),
      ));
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(data.latitude!, data.longitude!), 17),
    );
  }

  Color _getBorderColor(double? value,
      {double warning = 70, double critical = 85}) {
    if (value == null) return Colors.grey;
    if (value >= critical) return Colors.redAccent;
    if (value >= warning) return Colors.orangeAccent;
    return Colors.greenAccent;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motiva Robô'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.sensors), text: 'Dados'),
            Tab(icon: Icon(Icons.gamepad), text: 'Controle'),
            Tab(icon: Icon(Icons.map), text: 'Localização'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ==================== ABA 1 - DADOS ====================
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildConnectionBar(),
                const SizedBox(height: 20),
                _buildSection('Temperatura dos Motores', Icons.settings, [
                  for (int i = 0; i < 5; i++)
                    SensorTile(
                      label: 'Motor ${i + 1}',
                      value: _fmt(_sensorData?.motorTemps[i], suffix: '°C'),
                      icon: Icons.thermostat,
                      borderColor: _getBorderColor(_sensorData?.motorTemps[i]),
                    ),
                ]),
                _buildSection('Ambiente Interno', Icons.home, [
                  SensorTile(
                      label: 'Temperatura',
                      value: _fmt(_sensorData?.internalTempC, suffix: '°C'),
                      icon: Icons.thermostat,
                      borderColor: Colors.cyan),
                  SensorTile(
                      label: 'Umidade',
                      value: _fmt(_sensorData?.internalHumidityPercent,
                          suffix: '%'),
                      icon: Icons.water_drop,
                      borderColor: Colors.blue),
                ]),
                _buildSection('Bateria', Icons.battery_full, [
                  SensorTile(
                      label: 'Tensão',
                      value: _fmt(_sensorData?.batteryVoltage, suffix: 'V'),
                      icon: Icons.bolt,
                      borderColor: _getBorderColor(_sensorData?.batteryVoltage,
                          warning: 12.2, critical: 11.5)),
                  SensorTile(
                      label: 'Corrente',
                      value: _fmt(_sensorData?.batteryCurrent, suffix: 'A'),
                      icon: Icons.electric_bolt,
                      borderColor: Colors.orange),
                  SensorTile(
                      label: 'Tempo Restante',
                      value: _fmtTime(_sensorData?.batteryTimeLeftMin),
                      icon: Icons.timer,
                      borderColor: Colors.greenAccent),
                ]),
              ],
            ),
          ),

          // ==================== ABA 2 - CONTROLE + VÍDEO ====================
          Column(
            children: [
              const SizedBox(height: 20),
              _buildConnectionBar(),
              const SizedBox(height: 30),
              DirectionPad(onCommand: (cmd) => _connection.sendCommand(cmd)),
              const SizedBox(height: 30),
              const Text("📹 Vídeo ESP-CAM",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Stream de Vídeo\n(Adicionar WebView ou Image aqui)",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ==================== ABA 3 - MAPA ====================
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-23.5505, -46.6333),
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'IP do ESP32',
              hintText: 'ex: 192.168.4.1',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _connState == RobotConnState.connected
              ? _connection.disconnect
              : _connect,
          child: Text(_connState == RobotConnState.connected
              ? 'Desconectar'
              : 'Conectar'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: anilMotiva),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: children),
        const SizedBox(height: 24),
      ],
    );
  }
}
