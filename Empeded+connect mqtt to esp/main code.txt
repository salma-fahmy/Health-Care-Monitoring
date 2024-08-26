#include <Wire.h>                       // Library for I2C communication
#include <LiquidCrystal_I2C.h>          // Library for I2C LCD
#include <OneWire.h>                    // Library for OneWire protocol
#include <DallasTemperature.h>          // Library for Dallas Temperature sensors (e.g., DS18B20)
#include <MAX30100_PulseOximeter.h>     // Library for MAX30100 Pulse Oximeter
#include <ESP32Servo.h>                 // Library for controlling servos with ESP32

// Pin Definitions
#define DS18B20_PIN 4    // Pin connected to DS18B20 temperature sensor
#define ECG_PIN 34       // Pin connected to ECG sensor (AD8232)
#define PRESSURE_PIN 35  // Pin connected to Pressure sensor (MPS20N0040D-GDF)
#define IR_SENSOR_PIN 18 // Pin connected to IR sensor for human detection
#define SERVO_PIN 26     // Pin connected to Servo motor

// Pin Definitions for LEDs and Buzzer
#define GREEN_LED_PIN 23 // Pin connected to Green LED
#define RED_LED_PIN 27   // Pin connected to Red LED
#define BUZZER_PIN 25    // Pin connected to Buzzer

// Libraries
LiquidCrystal_I2C lcd(0x27, 16, 2); // LCD I2C address (0x27) and dimensions (16x2)
PulseOximeter pox; // Object for the MAX30100 Pulse Oximeter
Servo servo;  // Object for controlling the Servo motor

// Global Variables for Display and Timing
unsigned long previousMillis = 0; // Store the time of the last sensor reading
const long interval = 5000; // Interval between sensor readings (5 seconds)

// Create OneWire and DallasTemperature objects for DS18B20
OneWire oneWire(DS18B20_PIN);
DallasTemperature sensors(&oneWire);

// Function to classify temperature readings
String classifyTemperature(float temperature) {
  if (temperature < 36.1) {
    return "Low"; // Temperature below 36.1°C is considered "Low"
  } else if (temperature > 37.2) {
    return "High"; // Temperature above 37.2°C is considered "High"
  } else {
    return "Normal"; // Temperature between 36.1°C and 37.2°C is considered "Normal"
  }
}

// Function to classify ECG readings
String classifyECG(float ecgValue) {
  if (ecgValue < 512) {
    return "Normal"; // ECG value below 512 is considered "Normal"
  } else {
    return "High"; // ECG value 512 or higher is considered "High"
  }
}

// Function to classify pressure readings
String classifyPressure(float pressureValue) {
  if (pressureValue < 500) {
    return "Normal"; // Pressure value below 500 mmHg is considered "Normal"
  } else {
    return "High"; // Pressure value 500 mmHg or higher is considered "High"
  }
}

// Function to classify SpO2 readings
String classifySpO2(float spO2Value) {
  if (spO2Value < 95) {
    return "Low"; // SpO2 value below 95% is considered "Low"
  } else {
    return "Normal"; // SpO2 value 95% or higher is considered "Normal"
  }
}

// Function to trigger an alert
void triggerAlert() {
  digitalWrite(GREEN_LED_PIN, LOW); // Turn off the Green LED
  digitalWrite(RED_LED_PIN, HIGH);  // Turn on the Red LED
  digitalWrite(BUZZER_PIN, HIGH);   // Turn on the Buzzer
  servo.write(180); // Move the servo to 180 degrees to indicate an alert

  delay(500); // Keep the Buzzer on for 500 milliseconds
  digitalWrite(BUZZER_PIN, LOW); // Turn off the Buzzer

  // Keep the servo in the alert position for 2 minutes
  delay(120000);
  servo.write(0); // Move the servo back to 0 degrees
}

// Function to display sensor data on the LCD
void displaySensorData(int mode) {
  float temperature = sensors.getTempCByIndex(0); // Read temperature from DS18B20
  float ecgValue = analogRead(ECG_PIN); // Read ECG value
  float pressureValue = analogRead(PRESSURE_PIN); // Read pressure value
  float spO2 = pox.getSpO2(); // Read SpO2 from Pulse Oximeter
  float heartRate = pox.getHeartRate(); // Read heart rate from Pulse Oximeter

  String classification;

  lcd.clear(); // Clear the LCD display

  switch (mode) {
    case 0:
      sensors.requestTemperatures(); // Request temperature reading from DS18B20
      delay(1000); // Allow time for the sensor to stabilize
      temperature = sensors.getTempCByIndex(0);
      classification = classifyTemperature(temperature); // Classify temperature
      lcd.setCursor(0, 0); // Set cursor to the first row, first column
      lcd.print("Temp: ");
      lcd.print(temperature);
      lcd.print(" C");
      lcd.setCursor(0, 1); // Set cursor to the second row, first column
      lcd.print("Class: ");
      lcd.print(classification);
      servo.write(45);  // Move the servo to 45 degrees for temperature display
      break;

    case 1:
      classification = classifyECG(ecgValue); // Classify ECG value
      lcd.setCursor(0, 0);
      lcd.print("ECG: ");
      lcd.print(ecgValue);
      lcd.setCursor(0, 1);
      lcd.print("Class: ");
      lcd.print(classification);
      servo.write(90);  // Move the servo to 90 degrees for ECG display
      break;

    case 2:
      classification = classifyPressure(pressureValue); // Classify pressure value
      lcd.setCursor(0, 0);
      lcd.print("Pressure: ");
      lcd.print(pressureValue);
      lcd.print(" mmHg");
      lcd.setCursor(0, 1);
      lcd.print("Class: ");
      lcd.print(classification);
      servo.write(135); // Move the servo to 135 degrees for pressure display
      break;

    case 3:
      classification = classifySpO2(spO2); // Classify SpO2 value
      lcd.setCursor(0, 0);
      lcd.print("SpO2: ");
      lcd.print(spO2);
      lcd.print(" %");
      lcd.setCursor(0, 1);
      lcd.print("HR: ");
      lcd.print(heartRate);
      servo.write(180); // Move the servo to 180 degrees for SpO2 display
      break;
  }
  
  // Print sensor data to Serial Monitor for debugging
  Serial.print("Displaying sensor ");
  Serial.print(mode);
  Serial.print(": ");
  Serial.println(classification);
}

// Callback function for beat detection from Pulse Oximeter
void onBeatDetected() {
  Serial.println("Beat detected!");
}

void setup() {
  Serial.begin(115200); // Initialize Serial communication for debugging

  // Initialize I2C communication for LCD and MAX30100
  Wire.begin(21, 22); // Set SDA and SCL pins for I2C
  lcd.begin(16, 2); // Initialize LCD with 16 columns and 2 rows
  lcd.backlight();  // Turn on the LCD backlight

  // Initialize DS18B20 temperature sensor
  sensors.begin();

  // Initialize sensor pins
  pinMode(IR_SENSOR_PIN, INPUT); // Set IR sensor pin as input
  pinMode(ECG_PIN, INPUT);       // Set ECG sensor pin as input
  pinMode(PRESSURE_PIN, INPUT);  // Set Pressure sensor pin as input

  // Initialize LED and Buzzer pins
  pinMode(GREEN_LED_PIN, OUTPUT); // Set Green LED pin as output
  pinMode(RED_LED_PIN, OUTPUT);   // Set Red LED pin as output
  pinMode(BUZZER_PIN, OUTPUT);    // Set Buzzer pin as output

  // Initialize servo and set it to 0 degrees
  servo.attach(SERVO_PIN); // Attach the servo to its control pin
  servo.write(0); // Move the servo to 0 degrees

  // Turn off LEDs and Buzzer initially
  digitalWrite(GREEN_LED_PIN, LOW); // Ensure Green LED is off
  digitalWrite(RED_LED_PIN, LOW);   // Ensure Red LED is off
  digitalWrite(BUZZER_PIN, LOW);    // Ensure Buzzer is off

  // Initialize Pulse Oximeter MAX30100
  if (!pox.begin()) {
    Serial.println("Failed to initialize Pulse Oximeter!"); // Print error message if initialization fails
    while (true); // Halt the program
  }

  pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA); // Set IR LED current for Pulse Oximeter
  pox.setOnBeatDetectedCallback(onBeatDetected); // Set callback function for heartbeat detection
}

void loop() {
  pox.update(); // Update Pulse Oximeter readings

  // Read IR sensor value
  bool humanDetected = digitalRead(IR_SENSOR_PIN) == LOW;

  // Check if a human is detected
  if (humanDetected) {
    unsigned long currentMillis = millis(); // Get the current time
    static int displayMode = 0; // Initialize display mode

    // Display sensor data based on the time interval
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis; // Update the time of the last reading
      displaySensorData(displayMode); // Display data for the current sensor
      displayMode = (displayMode + 1) % 4; // Cycle through sensors (0-3)
    }
  } else {
    // Display a message when no human is detected
    lcd.setCursor(0, 0);
    lcd.print("No human detected");
    lcd.setCursor(0, 1);
    lcd.print("Waiting...");
    
    // Turn off all lights and buzzer
    digitalWrite(GREEN_LED_PIN, LOW);
    digitalWrite(RED_LED_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);
    
    // Reset servo position to 0 degrees
    servo.write(0);
  }
}
