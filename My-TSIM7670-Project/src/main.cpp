#include <Arduino.h>

// This is the main library for your board
#include <T-SIM7670G.h>

void setup() {
  // Start the serial connection to your computer
  Serial.begin(115200);
  delay(1000); // Wait a moment for the serial monitor to connect

  Serial.println("Hello from the T-SIM7670G S3!");
  Serial.println("Board setup complete. Waiting to initialize modem...");

  // In a real application, you would initialize the modem here.
  // For example:
  // setup_modem(); // This is a function you would write using the library
}

void loop() {
  // Put your main code here, to run repeatedly:
  Serial.print(".");
  delay(5000);
}