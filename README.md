# Robo App (Flutter)

App para controlar um robô e ler dados de sensores de um ESP32 (DevKit V1, 30 pinos)
via WiFi, usando WebSocket.

## Como simular sem instalar no celular

```
flutter run -d chrome
```
ou
```
flutter run -d windows
```
A aparência e o comportamento são idênticos ao celular (o Flutter desenha a própria
interface, não depende do sistema operacional) — só muda o tamanho da tela.

## Como rodar no celular

1. Instale o Flutter: https://docs.flutter.dev/get-started/install
2. Dentro desta pasta, rode:
   ```
   flutter pub get
   flutter run
   ```
   (celular conectado via USB com depuração ativada, ou um emulador)
3. Na tela do app, digite o IP local do ESP32 (ex: `192.168.1.50`) e toque em **Conectar**.
4. O ESP32 e o celular precisam estar na **mesma rede WiFi**.

## Estrutura do projeto

```
lib/
  main.dart                      -> ponto de entrada
  screens/home_screen.dart       -> tela única: conexão + sensores + controle
  services/robot_connection.dart -> toda a lógica de WebSocket
  widgets/direction_pad.dart     -> botões de direção (frente/trás/esq/dir/parar)
  widgets/sensor_tile.dart       -> card de exibição de um sensor numérico
  widgets/sensor_section.dart    -> agrupa vários sensor_tile sob um título
  widgets/location_card.dart     -> card de GPS com link "abrir no mapa"
  models/sensor_data.dart        -> modelo de TODOS os dados recebidos do ESP32
```

## Protocolo esperado (app <-> ESP32)

O app abre uma conexão WebSocket em `ws://<ip-do-esp32>:81`.

### ESP32 -> App (sensores)

Mapeamento físico dos sensores -> campos JSON:

| Sensor                          | Campo JSON                          |
|----------------------------------|--------------------------------------|
| 5x NTC 100k (temp. dos motores) | `motor_temp`: lista com 5 números   |
| DHT22 (temp/umidade interna)    | `dht_temp`, `dht_hum`               |
| INA219 #1 (bateria)             | `batt_voltage`, `batt_current`      |
| DS18B20 (temp. da bateria)      | `batt_temp`                         |
| estimativa de autonomia          | `batt_time_left` (em minutos)       |
| NEO-6M V2 (GPS)                 | `lat`, `lng`                        |
| MPU6050 (inclinação)            | `pitch`, `roll`                     |
| INA219 #2 (placa solar)         | `solar_voltage`, `solar_current`    |

Exemplo completo de mensagem que o ESP32 deve enviar:
```json
{
  "motor_temp": [32.1, 33.4, 31.8, 30.9, 34.0],
  "dht_temp": 28.5, "dht_hum": 55.2,
  "batt_voltage": 12.4, "batt_current": 1.8, "batt_temp": 29.0,
  "batt_time_left": 95,
  "lat": -23.5505, "lng": -46.6333,
  "pitch": 2.3, "roll": -1.1,
  "solar_voltage": 18.2, "solar_current": 0.6
}
```
Todos os campos são opcionais — se algum não vier, o app mostra "--" naquele
sensor em vez de quebrar. Você pode mandar só alguns campos por mensagem (ex:
só os motores a cada 200ms, e o GPS a cada 2s) se preferir economizar banda.

**Cálculo do tempo de bateria restante**: pode ser feito no próprio ESP32
(capacidade da bateria em mAh ÷ corrente de consumo atual) ou no app, se você
preferir — me avise qual abordagem prefere quando formos ao firmware.

### App -> ESP32 (comandos de controle)

Enviados ao pressionar/soltar os botões do D-pad:
```json
{ "cmd": "forward" }
{ "cmd": "back" }
{ "cmd": "left" }
{ "cmd": "right" }
{ "cmd": "stop" }
```

## Por que WebSocket na porta 81

A porta 80 fica livre para uma eventual página HTML de configuração/debug servida
pelo próprio ESP32 (`ESPAsyncWebServer`), e a 81 é dedicada ao canal de dados em
tempo real (`AsyncWebSocket`). Se usar outra porta no firmware, ajuste o parâmetro
`port` em `RobotConnection.connect()` (`services/robot_connection.dart`).

## Próximos passos sugeridos

- Trocar o D-pad por um joystick analógico (`flutter_joystick`) para controle de
  velocidade variável.
- Mostrar a localização num mapa embutido (`google_maps_flutter`), em vez de só
  abrir o Google Maps externo — requer chave de API do Google.
- Indicador visual de inclinação (uma "bolha de nível" 2D) em vez de só números
  de pitch/roll.
- Gráfico de histórico de temperatura/tensão (`fl_chart`).
- Quando o firmware do ESP32 estiver pronto, revisar juntos os nomes dos campos
  JSON para garantir que os dois lados conversam certo.
