#include <WaspXBee802.h>
#include <string.h>
#include <stdio.h> 
#include <stdlib.h>

#define RED_LED   LED0
#define GREEN_LED LED1

#define MAX_LENGTH        1024
#define RECEIVER_TIMEOUT  500UL

#define ACC_THRESHOLD 1000

#define _DEBUG_COMM_

char* sleep_time = "00:00:00:60";
bool RTC_DATA = false;

char SENDER_MAC[17];

void SendData() {
  USB.println("Sending data...");

  int8_t err;

  RTC.ON();
  int battery_level = (int) PWR.getBatteryLevel();
  char message[MAX_LENGTH]; 
  int ax, ay, az;

  ax = ACC.getX();
  ay = ACC.getY();
  az = ACC.getZ();

  snprintf(message, MAX_LENGTH, "%s\nBattery level: %d%%\nACC X: %d\tACC Y:%d\tACC Z: %d\n", RTC.getTime(), battery_level, ax, ay, az);

  if (err = commInit(0))
  {
    USB.println(F("Radio failed. Exiting ..."));
    exit(0);
  }
  USB.println(F("\nRadio initialized"));

  err = sendTextPacket(SENDER_MAC, message);
}

void AwaitGesture()
{
  // Check interruptions 
  if (intFlag & ACC_INT)
  {
    // clear the accelerometer interrupt flag on
    // the general interrupt vector
    intFlag &= ~(ACC_INT);

    USB.println("-- ACC Interrupt received");
    
    SendData();
  }
  else if (intFlag & RTC_INT)
  {
    intFlag &= ~(RTC_INT);
    USB.println("-- RTC Interrupt received");

    SendData();
  }
}

void setup()
{
  int8_t err;
  uint16_t stime;

  USB.ON();

  // Power up RTC and initialize I2C bus
  USB.println("Init RTC");
  RTC.ON();

  USB.OFF();

  // Enable interruption: Inertial Wake Up
  ACC.ON();
}


void loop()
{
  USB.ON();
  ACC.setIWU(ACC_THRESHOLD);

  uint8_t err;

  if (!RTC_DATA) {
    if (err = commInit(0))
    {
      USB.println(F("Radio failed. Exiting ..."));
      exit(0);
    }
    USB.println(F("\nRadio initialized"));

    err = 1;

    char data[MAX_LENGTH+1];
    static uint16_t np = 0;

    while (err > 0) {
      err = receiveTextPacket(SENDER_MAC, data, RECEIVER_TIMEOUT);
      
      delay(500);
    }

    if (err == 0)
    {
      np++;
      RTC.setTime(data);
      USB.printf("Time to sleep: %s\n", sleep_time);
      USB.printf("RTC Time: %s\n", RTC.getTime());
      USB.printf("Packet received from %s\n", SENDER_MAC);
      USB.print(np); USB.println(F(" packets received correctly"));
      RTC_DATA = true;
    }
  }
  
  AwaitGesture();

  PWR.deepSleep(sleep_time, RTC_OFFSET, RTC_ALM1_MODE2, ALL_OFF);
}
