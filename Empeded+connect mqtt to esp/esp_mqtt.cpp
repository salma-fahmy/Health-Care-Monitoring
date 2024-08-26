#include <WiFi.h>  
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <MAX30100_PulseOximeter.h>
#include <ESP32Servo.h>  

// Pin Definitions
#define DS18B20_PIN 4    // DS18B20 temperature sensor pin
#define ECG_PIN 34       // ECG sensor (AD8232) pin
#define PRESSURE_PIN 35  // Pressure sensor (MPS20N0040D-GDF) pin
#define IR_SENSOR_PIN 18 // IR sensor pin for human detection
#define SERVO_PIN 26     // Servo pin
#define GREEN_LED_PIN 23 // Green LED pin
#define RED_LED_PIN 27   // Red LED pin
#define BUZZER_PIN 25    // Buzzer pin

// Libraries
LiquidCrystal_I2C lcd(0x27, 16, 2); // LCD I2C address and dimensions (16x2)
PulseOximeter pox; // Pulse Oximeter MAX30100 object
Servo servo;  // Servo control object

// WiFi credentials
char ssid[] = "";
char pass[] = "";

//---- HiveMQ Cloud Broker settings
const char* mqtt_server = ".s1.eu.hivemq.cloud";
const char* mqtt_username = "";
const char* mqtt_password = "";
const int mqtt_port = 8883;

WiFiClientSecure espClient;  
PubSubClient client(espClient);

// HiveMQ Cloud Let's Encrypt CA certificate
static const char *root_ca PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
)EOF";

unsigned long lastMsg = 0;
int value = 0;
// Global Variables for Display and Timing
unsigned long previousMillis = 0; // Store last update time
const long interval = 5000; // Interval between sensor readings (5 seconds)
OneWire oneWire(DS18B20_PIN);
DallasTemperature sensors(&oneWire);


// Function to classify readings
String classifyTemperature(float temperature) {
  if (temperature < 36.1) return "Low";
  else if (temperature > 37.2) return "High";
  else return "Normal";
}

String classifyECG(float ecgValue) {
  return (ecgValue < 512) ? "Normal" : "High";
}

String classifyPressure(float pressureValue) {
  return (pressureValue < 500) ? "Normal" : "High";
}

String classifySpO2(float spO2Value) {
  return (spO2Value < 95) ? "Low" : "Normal";
}

// Function to trigger alert
void triggerAlert() {
  digitalWrite(GREEN_LED_PIN, LOW);
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(BUZZER_PIN, HIGH);
  servo.write(180);  // Move servo to 180 degrees

  delay(500); // Buzzer alert for 500 milliseconds
  digitalWrite(BUZZER_PIN, LOW);
  
  delay(120000); // Keep servo open for 2 minutes
  servo.write(0);  // Move servo back to 0 degrees
}

// Function to display sensor data
void displaySensorData(int mode) {
  float temperature = sensors.getTempCByIndex(0);
  float ecgValue = analogRead(ECG_PIN);
  float pressureValue = analogRead(PRESSURE_PIN);
  float spO2 = pox.getSpO2();
  float heartRate = pox.getHeartRate();

  // Handle invalid readings for SpO2 and heart rate
  if (spO2 < 0 || spO2 > 100) spO2 = 0;
  if (heartRate <= 0) heartRate = 0;

  lcd.clear();
  
  String classification;

  switch (mode) {
    case 0:
      sensors.requestTemperatures();
      delay(1000);
      temperature = sensors.getTempCByIndex(0);
      classification = classifyTemperature(temperature);
      lcd.setCursor(0, 0);
      lcd.print("Temp: ");
      lcd.print(temperature);
      lcd.print(" C");
      lcd.setCursor(0, 1);
      lcd.print("Class: ");
      lcd.print(classification);
      servo.write(45);  // Move servo to 45 degrees for temperature
      client.publish("ESP32/temperature", String(temperature).c_str());
      break;

    case 1:
      classification = classifyECG(ecgValue);
      lcd.setCursor(0, 0);
      lcd.print("ECG: ");
      lcd.print(ecgValue);
      lcd.setCursor(0, 1);
      lcd.print("Class: ");
      lcd.print(classification);
      servo.write(90);  // Move servo to 90 degrees for ECG
      client.publish("ESP32/ecg", String(ecgValue).c_str());
      break;

    case 2:
      classification = classifyPressure(pressureValue);
      lcd.setCursor(0, 0);
      lcd.print("Pressure: ");
      lcd.print(pressureValue);
      lcd.print(" mmHg");
      lcd.setCursor(0, 1);
      lcd.print("Class: ");
      lcd.print(classification);
      servo.write(135); // Move servo to 135 degrees for pressure
      client.publish("ESP32/pressure", String(pressureValue).c_str());
      break;

    case 3:
      classification = classifySpO2(spO2);
      lcd.setCursor(0, 0);
      lcd.print("SpO2: ");
      lcd.print(spO2);
      lcd.print(" %");
      lcd.setCursor(0, 1);
      lcd.print("HR: ");
      lcd.print(heartRate);
      servo.write(180); // Move servo to 180 degrees for SpO2
      client.publish("ESP32/heartRate", String(heartRate).c_str());
      client.publish("ESP32/spO2", String(spO2).c_str());
      break;
  }

  // Debugging information on Serial Monitor
  Serial.print("Displaying sensor ");
  Serial.print(mode);
  Serial.print(": ");
  Serial.println(classification);
}

// Callback function for beat detection
void onBeatDetected() {
  Serial.println("Beat detected!");
}


void setup_wifi() {
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  
  String message;
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
    message += (char)payload[i];  // Store the received payload in the message string
  }
  Serial.println();

  // Control the servo based on the received MQTT message
  if (String(topic) == "servo/control") {
    int angle = message.toInt(); // Convert the message to an integer
    if (angle >= 0 && angle <= 180) { // Ensure angle is within valid range
      servo.write(angle); // Set the servo to the specified angle
      Serial.print("Servo set to angle: ");
      Serial.println(angle);
    }
  }
}


void reconnect() {
  // Loop until we’re reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection… ");
    String clientId = "ESP32Client";
    // Attempt to connect
    if (client.connect(clientId.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("connected!");
      // Once connected, publish an announcement...
      client.publish("ESP32/status", "connected"); // IMPORTANT FOR PUBLISHING DATA
        client.subscribe("servo/control"); 
    } else {
      Serial.print("failed, rc = ");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup() {
  delay(500);
  // When opening the Serial Monitor, select 9600 Baud
  Serial.begin(9600);
  delay(500);
  setup_wifi();
  espClient.setCACert(root_ca);
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  

  // Initialize I2C for LCD and MAX30100
  Wire.begin(21, 22);
  lcd.begin(16, 2);
  lcd.backlight();


  // Initialize sensors
  sensors.begin();
  pinMode(IR_SENSOR_PIN, INPUT);
  pinMode(ECG_PIN, INPUT);
  pinMode(PRESSURE_PIN, INPUT);

  // Initialize LEDs and Buzzer
  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  // Initialize servo
  servo.attach(SERVO_PIN);
  servo.write(0);

  // Initial state of LEDs and Buzzer
  digitalWrite(GREEN_LED_PIN, LOW);
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  // Initialize Pulse Oximeter
  if (!pox.begin()) {
    Serial.println("Failed to initialize Pulse Oximeter!");
    while (true);
  }
  pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);
  pox.setOnBeatDetectedCallback(onBeatDetected);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  unsigned long now = millis();
  if (now - lastMsg > 1000) {
  pox.update();

  // Human detection via IR sensor
  bool humanDetected = digitalRead(IR_SENSOR_PIN) == LOW;

      if (humanDetected) {
    unsigned long currentMillis = millis();
    static int displayMode = 0;
    client.publish("ESP32/irSensor", String(true).c_str());

    // Cycle through sensor readings
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      displaySensorData(displayMode);
      displayMode = (displayMode + 1) % 4;
    }
  } else {
    // Display when no human is detected
    lcd.setCursor(0, 0);
    lcd.print("No human detected");
    lcd.setCursor(0, 1);
    lcd.print("Waiting...");

    // Turn off LEDs, Buzzer, and reset servo
    digitalWrite(GREEN_LED_PIN, LOW);
    digitalWrite(RED_LED_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);
    servo.write(0);
  }
  }
}