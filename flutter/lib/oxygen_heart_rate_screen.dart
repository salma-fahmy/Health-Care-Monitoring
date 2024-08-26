import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sensor_data.dart';
import 'mqtt_service.dart';

class OxygenHeartRateScreen extends StatefulWidget {
  @override
  _OxygenHeartRateScreenState createState() => _OxygenHeartRateScreenState();
}

class _OxygenHeartRateScreenState extends State<OxygenHeartRateScreen> {
  bool _measurementStarted = false; // Flag to check if the measurement has started
  bool _measurementComplete = false; // Flag to check if the measurement is complete
  String _message = 'Press "Start Measurement" and then click "OK" when ready'; // Initial message

  final MQTTService _mqttService = MQTTService(); // Create an instance of MQTTService

  @override
  void initState() {
    super.initState();
    _mqttService.connect(context); // Connect to MQTT service when the screen initializes
  }

  void _startMeasurement() {
    setState(() {
      _measurementStarted = true; // Set measurementStarted to true
      _message = 'Measurement started. Place your finger on the sensor and press "OK".'; // Update message
    });
  }

  void _confirmMeasurement() async {
    setState(() {
      _message = 'Checking for finger presence...'; // Update message while checking
    });

    // Simulate checking for finger presence
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    bool fingerDetected = Provider.of<SensorData>(context, listen: false).isIRSensorWorking;

    setState(() {
      if (fingerDetected) {
        _measurementComplete = true; // Set measurementComplete to true if finger detected
        _message = 'Measurement complete. Displaying data...'; // Update message
        // Add logic here to fetch and display sensor data
      } else {
        _message = 'Please place your finger on the sensor.'; // Update message if no finger detected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oxygen & Heart Rate'), // Set the title of the AppBar
        backgroundColor: Color(0xFFEC407A), // Set the background color of the AppBar
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/7ef40ee4725ef284f879b70745ec542b.jpg', 
            fit: BoxFit.cover, // Ensure the image covers the entire screen
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
                          color: Colors.black54, // Background color of the container
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _message, // Display the current message
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFE91E63), // Text color
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2, // Limit to 2 lines
                                overflow: TextOverflow.ellipsis, // Ellipsis if text overflows
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!_measurementStarted && !_measurementComplete)
                        ElevatedButton(
                          onPressed: _startMeasurement, // Start measurement
                          child: Text('Start Measurement'),
                        ),
                      if (_measurementStarted && !_measurementComplete)
                        ElevatedButton(
                          onPressed: _confirmMeasurement, // Confirm measurement
                          child: Text('OK'),
                        ),
                      if (_measurementComplete)
                        Flexible(
                          child: ListView(
                            children: [
                              Card(
                                margin: EdgeInsets.symmetric(vertical: 10.0), // Margin for card
                                elevation: 5, // Shadow elevation
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0), // Padding inside card
                                  title: Text(
                                    'Blood Oxygen Level', // Card title
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold, // Bold text
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${sensorData.oxygenLevel}%', // Display blood oxygen level
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green, // Text color
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.bloodtype,
                                    color: Colors.redAccent, // Icon color
                                    size: 30,
                                  ),
                                ),
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(vertical: 10.0), // Margin for card
                                elevation: 5, // Shadow elevation
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.0), // Padding inside card
                                  title: Text(
                                    'Heart Rate', // Card title
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold, // Bold text
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${sensorData.heartRate} BPM', // Display heart rate
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blueAccent, // Text color
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.favorite,
                                    color: Color(0xFFE91E63), // Icon color
                                    size: 30,
                                  ),
                                ),
                              ),
                            
                            ],
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
