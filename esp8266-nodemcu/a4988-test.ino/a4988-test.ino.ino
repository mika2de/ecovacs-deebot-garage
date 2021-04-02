// Define pin connections & motor's steps per revolution
const int enablePin = D1;
const int stepPin = D2;
const int dirPin = D3;
const int openCloseSteps = 340;

void setup()
{
  // Declare pins as Outputs
  pinMode(enablePin, OUTPUT);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);

  digitalWrite(enablePin, LOW
  );
  Serial.begin(9600);
}
void loop()
{
  // open door
  digitalWrite(dirPin, LOW);

  // Spin motor slowly
  Serial.println("open");
  for(int x = 0; x < openCloseSteps; x++)
  {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(1000);
    yield();
  }
  delay(1000); // Wait a second
  
  // close door
  digitalWrite(dirPin, HIGH);

  // Spin motor quickly
  Serial.println("close");
  for(int x = 0; x < openCloseSteps; x++)
  {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(1000);
    yield();
  }
  delay(1000); // Wait a second
}
