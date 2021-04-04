#include <BearSSLHelpers.h>
#include <CertStoreBearSSL.h>
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ESP8266WiFiAP.h>
#include <ESP8266WiFiGeneric.h>
#include <ESP8266WiFiGratuitous.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266WiFiScan.h>
#include <ESP8266WiFiSTA.h>
#include <ESP8266WiFiType.h>
#include <WiFiClient.h>
#include <WiFiClientSecure.h>
#include <WiFiClientSecureAxTLS.h>
#include <WiFiClientSecureBearSSL.h>
#include <WiFiServer.h>
#include <WiFiServerSecure.h>
#include <WiFiServerSecureAxTLS.h>
#include <WiFiServerSecureBearSSL.h>
#include <WiFiUdp.h>

// Stepper motor
const int enablePin = D1;
const int stepPin = D2;
const int dirPin = D3;
const int openCloseSteps = 340;

// force resistance sensor
const int frsPin = D5;
int frsValue;

// Wifi
const String ssid = "MY_SSID";
const String password = "MY_PASSWORD";
int status = WL_IDLE_STATUS;

// NodeJs server
const String host = "michasrv";
const int port = 80;
const String url = "/start";
int retry = 0;

// NodeMCU Web Server
AsyncWebServer server(80);
const String okResponse = "{ \"command\" : \"ok\" }";

void setup() {
  // stepper pins
  pinMode(enablePin, OUTPUT);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);

  pinMode(frsPin, INPUT);

  Serial.begin(9600);
  
  // vacuum bot leaves garage
  openDoor();
  delay(1500);
  closeDoor();
  
  connectWifi();

  cleaningStarted();
}

void loop() {
  Serial.println("TODO: weight sensor should close door");
  frsValue = analogRead(frsPin);
  Serial.println("Analog reading = " + frsValue);
  if (frsValue > 0) {
    closeDoor();
    delay(5000);
  }
 
  delay(500);
}

void connectWifi() {
  Serial.print("wifi status: ");
  Serial.print(status);
  Serial.print(" required: ");
  Serial.println(WL_CONNECTED);

  WiFi.mode(WIFI_STA);
  status = WiFi.begin(ssid, password);
  Serial.println("Attempting to connect to WPA " + ssid + " ...");
  if (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("WiFi Failed!");
    return;
  }
  Serial.println("connected");
}

void startAsyncServer(){
  server.on("/open", HTTP_GET, [](AsyncWebServerRequest * request) {
    Serial.println("OPEN");
    request->send_P(200, "application/json", "{ \"command\" : \"open\" }");
  });

  server.on("/close", HTTP_GET, [](AsyncWebServerRequest * request) {
    Serial.println("CLOSE");
    request->send_P(200, "application/json", "{ \"command\" : \"close\" }");
  });

  server.onNotFound([](AsyncWebServerRequest * request) {
    request->send(404, "text/plain", "Not found");
  });

  server.begin();
}

boolean cleaningStarted() {
  WiFiClient client;
  int connection;
  do
  {
    Serial.print("Connect to ");
    Serial.println(host);

    // establish TCP connection
    connection = client.connect(host, port);
    if (!connection) {
      retry++;
      Serial.println("Cannot connect");
      if (retry > 3) {
        Serial.println("Oh snap, something is wrong. Retry in a 5 seconds...");
        client.stop();
        WiFi.disconnect();
        ESP.deepSleep( 5 * 1000000);  // retry in 5 sec
      }
    }
    delay(1000);
  } while (connection != 1);

  // send request to nodejs server: cleaning started
  Serial.println("Sending request to Host: " + host +":" + port + url);

  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" +
               "Connection: close\r\n\r\n");

  unsigned long timeout = millis();
  while (client.available() == 0) {
    if (millis() - timeout > 5000) {
      Serial.println("Oh snap, something is wrong.");
      client.stop();
      WiFi.disconnect();
      return false;
    }
  }

  Serial.print("Response:\n");
  while (client.available()) {
    String line = client.readStringUntil('\r');
    Serial.println(line);
    if (line.indexOf("200 OK") != -1) {
      client.stop();
      return true;

    }
    client.stop();
    return false;
  }
}

void openDoor() {
  Serial.println("open");
  digitalWrite(dirPin, HIGH);
  for(int x = 0; x < openCloseSteps; x++)
  {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(1000);
    yield();
  }
}

void closeDoor() {
  Serial.println("close");
  digitalWrite(dirPin, LOW);
  for(int x = 0; x < openCloseSteps; x++)
  {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(1000);
    yield();
  }
}

void openDoorWaitAndClose() {
  openDoor();
  delay(15000);
  closeDoor();
}