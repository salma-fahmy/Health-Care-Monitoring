import 'package:flutter/material.dart';
import 'mqtt_service.dart'; // Import the MQTTService class
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const Color primaryPink = Color(0xFFE91E63);
const Color secondaryPink = Color(0xFFC2185B);
const Color lightPink = Color(0xFFF8BBD0); // Light pink color

class SendServoScreen extends StatefulWidget {
  @override
  _SendServoScreenState createState() => _SendServoScreenState();
}

class _SendServoScreenState extends State<SendServoScreen> {
  final MQTTService mqttService = MQTTService(); // Instance of the MQTTService
  final String topic =
      'servo/control'; // Predefined topic for the servo control

  @override
  void initState() {
    super.initState();
    mqttService.connect(
        context); // Connect to the MQTT broker when the screen initializes
  }

  // Function to publish a message to the MQTT topic
  void _publishMessage(String message) {
    final builder = MqttClientPayloadBuilder(); // Create a payload builder
    builder.addString(message); // Add message to the payload

    mqttService.client.publishMessage(
      topic, // Use the predefined topic
      MqttQos.atMostOnce, // Quality of service level for the message
      builder.payload!, // Payload for the message
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medicine',
          style: TextStyle(
            color: Colors.white, // Title color
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryPink, // AppBar background color
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(
                  context, '/home'); // Navigate to home screen
            },
            icon: Icon(Icons.home, color: Colors.white), // Home icon color
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/f09756aac5ddaee1a7f86c8b70d7a247.jpg'), // Background image
            fit: BoxFit.cover, // Fit the image to cover the entire container
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0), // Padding around the content
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Spacer(), // Add this Spacer to push the buttons upwards
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink, // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Button shape
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30), // Button padding
                    ),
                    onPressed: () {
                      _publishMessage('OPEN'); // Publish 'OPEN' message
                    },
                    child: Text('OPEN',
                        style: TextStyle(color: Colors.white)), // Button text
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink, // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Button shape
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30), // Button padding
                    ),
                    onPressed: () {
                      _publishMessage('CLOSE'); // Publish 'CLOSE' message
                    },child: Text('CLOSE',
                        style: TextStyle(color: Colors.white)), // Button text
                  ),
                ],
              ),
              SizedBox(height: 50), // Add this SizedBox to add space below the buttons
            ],
          ),
        ),
      ),
    );
  }
}
