import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sensor_data.dart';
import 'mqtt_service.dart'; 

class IRSensor {
  final BuildContext context;

  IRSensor(this.context);

  Future<bool> checkFingerPresence() async {
    // Access SensorData to get the IR sensor status
    final sensorData = Provider.of<SensorData>(context, listen: false);
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    return sensorData.isIRSensorWorking; // Use the status from SensorData
  }
}

class HeartRateScreen extends StatefulWidget {
  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  bool _measurementStarted = false;
  bool _measurementComplete = false;
  String _message = 'Press the sensor now and then click OK';

  final MQTTService _mqttService = MQTTService(); // Create an instance of MQTTService

  @override
  void initState() {
    super.initState();
    _mqttService.connect(context); // Connect to MQTT service when the screen initializes
  }

  // Method to start the measurement process
  void _startMeasurement() {
    setState(() {
      _measurementStarted = true;
      _message = 'Measurement started. Please place your finger on the sensor.';
    });
  }

  // Method to confirm the measurement and check for finger presence
  void _confirmMeasurement() async {
    setState(() {
      _message = 'Checking for finger presence...';
    });

    final IRSensor _irSensor = IRSensor(context); // Create IRSensor here
    bool fingerDetected = await _irSensor.checkFingerPresence();

    setState(() {
      if (fingerDetected) {
        _measurementComplete = true;
        _message = 'Measurement complete. Displaying data...';
        // Add logic here to fetch and display sensor data
      } else {
        _measurementComplete = false; // Ensure measurementComplete is set to false
        _message = 'Please place your finger on the sensor.'; // Update message
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(0xFFE91E63); // Change app bar color

    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Rate Sensor'),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/62b5830d24595f7285fdde78d0b177ce.jpg',
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
                                      Icon(Icons.favorite, color: Colors.redAccent), // Icon for heart rate data
                                      SizedBox(width: 10),
                                      Text(
                                        'Heart Rate: ${sensorData.ecg} BPM', // Display heart rate data
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
