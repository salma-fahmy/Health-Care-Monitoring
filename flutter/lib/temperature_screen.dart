import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sensor_data.dart';
import 'mqtt_service.dart'; 

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  bool _measurementStarted = false; // Flag to indicate if measurement has started
  bool _measurementComplete = false; // Flag to indicate if measurement is complete
  String _message = 'Press "Start Measurement" and then click "OK" when ready'; // Initial message displayed to the user

  final MQTTService _mqttService = MQTTService(); // Create an instance of MQTTService

  @override
  void initState() {
    super.initState();
    _mqttService.connect(context); // Connect to MQTT service when the screen initializes
  }

  void _startMeasurement() {
    setState(() {
      _measurementStarted = true; // Set measurementStarted to true
      _message = 'Measurement started. Please place your finger on the sensor.'; // Update message
    });
  }

  void _confirmMeasurement() async {
    setState(() {
      _message = 'Checking for finger presence...'; // Update message while checking for finger presence
    });

    // Simulate checking for finger presence by waiting for MQTT data
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    bool fingerDetected = Provider.of<SensorData>(context, listen: false).isIRSensorWorking;

    setState(() {
      if (fingerDetected) {
        _measurementComplete = true; // Set measurementComplete to true if a finger is detected
        _message = 'Measurement complete. Displaying data...'; // Update message
        // Add logic here to fetch and display the sensor data
      } else {
        _message = 'Please place your finger on the sensor.'; // Update message if no finger is detected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(0xFFEC407A);

    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Sensor'), // Title of the AppBar
        backgroundColor: appBarColor, // Set AppBar color to match the home screen
        foregroundColor: Colors.white, // White color for the AppBar text
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/2af6457ba02e065d875de593be5fc4b1.jpg', 
            fit: BoxFit.cover, 
          ),
          // Text and button content
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Consumer<SensorData>(
                builder: (context, sensorData, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.black54, // Dark semi-transparent background for the message container
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info, color: Colors.white), // Icon displayed next to the message
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _message, // Display the current message
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white, // White text color
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2, // Limit text to 2 lines
                                overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!_measurementStarted && !_measurementComplete)
                        ElevatedButton(
                          onPressed: _startMeasurement, // Button to start the measurement
                          child: Text('Start Measurement'),
                        ),
                      if (_measurementStarted && !_measurementComplete)
                        ElevatedButton(
                          onPressed: _confirmMeasurement, // Button to confirm the measurement
                          child: Text('OK'),
                        ),
                      if (_measurementComplete)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black54, // Dark semi-transparent background for the result container
                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white70, // Light semi-transparent background for the result
                                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.thermostat, color: Colors.redAccent), // Icon for temperature data
                                      SizedBox(width: 10),
                                      Text(
                                        'Temperature: ${sensorData.temperature} °C', // Display temperature data
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.black, // Black text color
                                          fontWeight: FontWeight.bold, // Bold text
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                               
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
