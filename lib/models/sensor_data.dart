/// Representa todos os dados de sensores enviados pelo ESP32 via WebSocket.
///
/// Mapeamento físico dos sensores -> campos JSON:
///   5x NTC 100k (temp. dos motores) -> "motor_temp": [t1,t2,t3,t4,t5]
///   DHT22 (temp/umidade interna)    -> "dht_temp", "dht_hum"
///   INA219 #1 (bateria)             -> "batt_voltage", "batt_current"
///   DS18B20 (temp. da bateria)      -> "batt_temp"
///   (calculado no ESP32 ou no app)  -> "batt_time_left" (minutos)
///   NEO-6M V2 (GPS)                 -> "lat", "lng"
///   MPU6050 (inclinação)            -> "pitch", "roll"
///   INA219 #2 (placa solar)         -> "solar_voltage", "solar_current"
///
/// Exemplo completo de mensagem que o ESP32 deve enviar:
/// {
///   "motor_temp": [32.1, 33.4, 31.8, 30.9, 34.0],
///   "dht_temp": 28.5, "dht_hum": 55.2,
///   "batt_voltage": 12.4, "batt_current": 1.8, "batt_temp": 29.0,
///   "batt_time_left": 95,
///   "lat": -23.5505, "lng": -46.6333,
///   "pitch": 2.3, "roll": -1.1,
///   "solar_voltage": 18.2, "solar_current": 0.6
/// }
class SensorData {
  // Temperatura de cada motor (5x NTC 100k), em °C. Índice 0-4 = motor 1-5.
  final List<double?> motorTemps;

  // DHT22 - ambiente interno do robô
  final double? internalTempC;
  final double? internalHumidityPercent;

  // INA219 #1 - bateria / armazenamento de energia
  final double? batteryVoltage;
  final double? batteryCurrent;
  final double? batteryTempC; // DS18B20
  final int? batteryTimeLeftMin; // tempo estimado restante, em minutos

  // NEO-6M V2 - GPS
  final double? latitude;
  final double? longitude;

  // MPU6050 - ângulo de inclinação
  final double? pitchDeg;
  final double? rollDeg;

  // INA219 #2 - placa solar
  final double? solarVoltage;
  final double? solarCurrent;

  final DateTime receivedAt;

  SensorData({
    this.motorTemps = const [null, null, null, null, null],
    this.internalTempC,
    this.internalHumidityPercent,
    this.batteryVoltage,
    this.batteryCurrent,
    this.batteryTempC,
    this.batteryTimeLeftMin,
    this.latitude,
    this.longitude,
    this.pitchDeg,
    this.rollDeg,
    this.solarVoltage,
    this.solarCurrent,
    required this.receivedAt,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    List<double?> motors = const [null, null, null, null, null];
    final rawMotors = json['motor_temp'];
    if (rawMotors is List) {
      motors = List.generate(
        5,
        (i) => i < rawMotors.length
            ? (rawMotors[i] as num?)?.toDouble()
            : null,
      );
    }

    return SensorData(
      motorTemps: motors,
      internalTempC: (json['dht_temp'] as num?)?.toDouble(),
      internalHumidityPercent: (json['dht_hum'] as num?)?.toDouble(),
      batteryVoltage: (json['batt_voltage'] as num?)?.toDouble(),
      batteryCurrent: (json['batt_current'] as num?)?.toDouble(),
      batteryTempC: (json['batt_temp'] as num?)?.toDouble(),
      batteryTimeLeftMin: (json['batt_time_left'] as num?)?.toInt(),
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble(),
      pitchDeg: (json['pitch'] as num?)?.toDouble(),
      rollDeg: (json['roll'] as num?)?.toDouble(),
      solarVoltage: (json['solar_voltage'] as num?)?.toDouble(),
      solarCurrent: (json['solar_current'] as num?)?.toDouble(),
      receivedAt: DateTime.now(),
    );
  }
}
