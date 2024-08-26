import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'sensor_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MQTTService {
  final client = MqttServerClient(
      'e4f0aeebb2244c6ea01ecbb3efe907da.s1.eu.hivemq.cloud', '');

  void connect(BuildContext context) async {
    client.port = 8883;
    client.secure = true;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('FlutterClient')
        .authenticateAs('myIOTdevice', '123456789Sf')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('MQTT Connection Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Subscribe to topics
    client.subscribe('ESP32/temperature', MqttQos.atMostOnce);
    client.subscribe('ESP32/ecg', MqttQos.atMostOnce);
    client.subscribe('ESP32/pressure', MqttQos.atMostOnce);
    client.subscribe('ESP32/oxygen', MqttQos.atMostOnce);
    client.subscribe('ESP32/heartRate', MqttQos.atMostOnce);
    client.subscribe('ESP32/irSensor', MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      switch (c[0].topic) {
        case 'ESP32/temperature':
          Provider.of<SensorData>(context, listen: false)
              .updateTemperature(double.parse(pt));
          break;
        case 'ESP32/ecg':
          Provider.of<SensorData>(context, listen: false)
              .updateECG(double.parse(pt));
          break;
        case 'ESP32/pressure':
          Provider.of<SensorData>(context, listen: false)
              .updatePressure(double.parse(pt));
          break;
        case 'ESP32/oxygen':
          Provider.of<SensorData>(context, listen: false)
              .setOxygenLevel(double.parse(pt));
          break;
        case 'ESP32/heartRate':
          Provider.of<SensorData>(context, listen: false)
              .setHeartRate(int.parse(pt));
          break;
        case 'ESP32/irSensor':
          Provider.of<SensorData>(context, listen: false)
              .setIRSensorStatus(pt == 'true');
          break;
      }
    });
  }

  void onConnected() {
    print('Connected');
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}