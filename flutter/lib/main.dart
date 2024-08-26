import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'heart_rate_screen.dart';
import 'temperature_screen.dart';
import 'pressure_screen.dart';
import 'oxygen_heart_rate_screen.dart';
import 'firebase_options.dart';
import 'mqtt_service.dart';
import 'sensor_data.dart';
import 'send_servo.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the specified options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(HealthCareMonitorApp());
}

class HealthCareMonitorApp extends StatelessWidget {
  // Create an instance of MQTTService
  final MQTTService _mqttService = MQTTService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provide SensorData to the widget tree
      create: (_) => SensorData(),
      child: Builder(
        builder: (context) {
          // Connect to the MQTT broker when the app is built
          _mqttService.connect(context);

          return MaterialApp(
            debugShowCheckedModeBanner: false, // Hide the debug banner
            theme: ThemeData(
              primarySwatch: Colors.pink, // Set the primary color to pink
              textTheme: GoogleFonts.poppinsTextTheme(
                // Apply Google Fonts Poppins to the text theme
                Theme.of(context).textTheme.apply(
                    bodyColor: Colors.pink[800],
                    displayColor: Colors.pink[800]),
              ),
            ),
            initialRoute: '/', // Set the initial route
            routes: {
              '/': (context) => MainScreen(), // Route for the main screen
              '/login': (context) =>
                  LoginScreen(), // Route for the login screen
              '/home': (context) => HomeScreen(), // Route for the home screen
              '/ecgHeartRate': (context) =>
                  HeartRateScreen(), // Route for the ECG heart rate screen
              '/temperature': (context) =>
                  TemperatureScreen(), // Route for the temperature screen
              '/pressure': (context) =>
                  PressureScreen(), // Route for the pressure screen
              '/oxygenHeartRate': (context) =>
                  OxygenHeartRateScreen(), // Route for the oxygen heart rate screen
              '/sendServo': (context) =>
                  SendServoScreen(), // Route for the send servo screen
              '/chat': (context) => ChatScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image for the main screen
          Image.asset(
            'assets/images/pills-medical-supplies-around-paper-sheet.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome text
                Text(
                  'Welcome to Health Care Monitor',
                  style: TextStyle(
                    fontSize: 24, // Set font size
                    color: Colors.white, // Set text color to white
                    fontWeight: FontWeight.bold, // Set font weight to bold
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 20), // Space between the text and the button
                // Get Started button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/login'); // Navigate to the login screen
                  },
                  child: Text('Get Started'), // Button text
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
