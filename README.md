

**Project Overview: Health Care Monitor**

The Health Care Monitor project is an IoT-based system designed to monitor various health parameters and manage medication dispensing through a mobile application built with Flutter. The system utilizes multiple sensors connected to an ESP32 microcontroller, which communicates with a Flutter application via MQTT using the HiveMQ Cloud.

 Sensors and Components:
1. **IR Sensor**: This sensor detects the presence of a finger to ensure accurate measurements. It acts as a preliminary check before taking any health readings.
  
2. **ECG Heart Rate Monitor (AD8232)**: This sensor measures the electrical activity of the heart, providing real-time ECG data to monitor heart rate.

3. **Pressure Sensor (MPS20N0040D-GDF 0-40KPa)**: This sensor is used to measure air pressure in the lungs, helping monitor respiratory functions.

4. **Waterproof Temperature Sensor (DS18B20)**: This sensor measures body temperature accurately, providing essential data for health monitoring.

5. **Pulse Oximeter and Heart Rate Sensor (MAX30100)**: This sensor measures blood oxygen levels (SpO2) and heart rate, crucial for monitoring cardiovascular health.

System Functionality:
- The system begins by using the IR sensor to detect if a finger is placed correctly. Once detected, it proceeds to take readings from the ECG, pressure, temperature, and MAX30100 sensors. These readings are then sent to the ESP32 microcontroller.
  
- The ESP32 processes the sensor data and transmits it to the mobile application via MQTT. The Flutter application, which is designed with a girly theme featuring various shades of pink, displays these readings to the user.

- The application includes a login feature, allowing users to access and view their health data after signing in. Additionally, the app has a feature to control a servo motor connected to the ESP32. The servo is used to open or close a medication container based on commands sent from the app. When the user sends an "open" command, the servo opens the container, and when a "close" command is sent, the servo securely closes the container.

Communication and Integration:
- The ESP32 microcontroller is integrated with all sensors and the servo motor, making it the central hub for data collection and communication.
  
- MQTT is used as the communication protocol between the ESP32 and the Flutter app. The HiveMQ Cloud broker is utilized to manage the MQTT communication, ensuring secure and reliable data transmission.

- The Flutter application not only displays sensor data but also allows users to control the servo motor for medication management, ensuring that the correct dosage is dispensed at the right time.

Conclusion:
The Health Care Monitor project provides a comprehensive solution for monitoring key health metrics and managing medication through a user-friendly mobile application. By leveraging IoT technology, the system enhances the accuracy and efficiency of health monitoring, making it a valuable tool for personal healthcare management.
