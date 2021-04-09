#include "ESP8266WiFi.h"
#include "ESP8266HTTPClient.h"
#include "AccelStepper.h"
#include <ESP8266WebServer.h> 

// WiFi and http server
const char* ssid = "MY_SSID";
const char* password =  "MY_WIFI_PASSWORD";
ESP8266WebServer server(80);

// Nodejs backend
const String host = "MY_NODEJS_BACKEND_SERVICE_IP";
const int port = 7080;
const String url = "/start";
WiFiClient client;

// Stepper motor
const int enablePin = D1;
const int stepPin = D2;
const int dirPin = D3;
const int openCloseSteps = 740; // steps to go from position 0 to open the door
AccelStepper stepper = AccelStepper(AccelStepper::DRIVER, stepPin, dirPin);

// force resistance sensor
const int frsPin = D5;
float frsValue;
 
void setup(){
  Serial.begin(9600);

  // stepper pins
  pinMode(enablePin, OUTPUT);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);

  pinMode(frsPin, INPUT);

  openDoorWaitAndClose();
 
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Attempting to connect to WPA ");
  Serial.println(ssid);
  if (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("WiFi Failed!");
    return;
  }
  Serial.println("connected");
 
  Serial.println(WiFi.localIP());

  server.on("/open", handleOpenDoor);
  server.on("/close", handleCloseDoor);
  server.on("/homecoming", handleHomecoming);
  server.onNotFound(handleNotFound); 
  server.begin();
  Serial.println("HTTP server started");

  wakeupBackendService();
}
 
void loop(){
  server.handleClient();
}

void handleOpenDoor(){
  server.send(200, "text/plain", "open door");
  openDoor();
}

void handleCloseDoor(){
  server.send(200, "text/plain", "close door");
  closeDoor();
}

void handleHomecoming(){
  server.send(200, "text/plain", "enter homecoming mode");
  homecoming();
}

void handleNotFound(){
  server.send(404, "text/plain", "404: oh snap");
}

void homecoming(){
  openDoor();
  do {
    frsValue = analogRead(frsPin);
    delay(500);
  } while (frsValue == 0); // wait for force resistance sensor signal, the quickly close the door before the power is turned off
  closeDoor();
}

void openDoor() {
  Serial.println("open");
  digitalWrite(enablePin, LOW); // enables a4988
  stepper.setMaxSpeed(1000.0);
  stepper.setAcceleration(2500.0);
  stepper.moveTo(openCloseSteps);
  stepper.runToPosition();
  // do not disable stepper, hold the door!
}

void closeDoor() {
  Serial.println("close");
  digitalWrite(enablePin, LOW); // enables a4988
  stepper.setSpeed(-1000.0);
  stepper.moveTo(0);
  stepper.runToPosition();
  digitalWrite(enablePin, HIGH); // disables a4988
}

void openDoorWaitAndClose() {
  openDoor();
  delay(15000); // wait 15 sec. for robot to leave parking position
  closeDoor();
}

int wakeupBackendService() {
  HTTPClient http;
  http.begin("http://"+host+":"+port+"/start");
  int httpCode = http.GET(); // send request
 
  if (httpCode > 0) {
    String payload = http.getString();
    Serial.println(payload);
  } else {
    Serial.println("error. " + httpCode);
  }
  http.end(); // close connection
}