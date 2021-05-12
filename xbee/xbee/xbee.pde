#include <WaspXBee802.h>
#include <string.h>
#include <stdio.h> 
#include <stdlib.h>

#define RED_LED   LED0
#define GREEN_LED LED1

#define MAX_LENGTH        20
#define RECEIVER_TIMEOUT  500UL

#define ACC_THRESHOLD 1000

#define _DEBUG_COMM_

char* sleep_time = "00:00:00:60";
bool RTC_DATA = false;

char SENDER_MAC[17];

void AwaitGesture()
{
  // Check interruptions
  if (intFlag & ACC_INT)
  {
    // clear the accelerometer interrupt flag on
    // the general interrupt vector
    intFlag &= ~(ACC_INT);

    USB.println("-- ACC Interrupt received");

    USB.println("Sending data...");

    int8_t err;

    RTC.ON();
    int battery_level = (int) PWR.getBatteryLevel();
    char* message = RTC.getTime();
    char bt[2] = "";
    sprintf(bt, "%d%%\n", battery_level);
    strcat(message, "\nBattery level: ");
    strcat(message, bt);
    int ax, ay, az;

    ax = ACC.getX();
    ay = ACC.getY();
    az = ACC.getZ();

    char acc[4] = "";
    sprintf(acc, "ACC X = %d", ax);
    strcat(message, acc);
    sprintf(acc, "\tACC Y = %d", ay);
    strcat(message, acc);
    sprintf(acc, "\tACC Z = %d\n", ay);
    strcat(message, acc);

    if (err = commInit(0))
    {
      USB.println(F("Radio failed. Exiting ..."));
      exit(0);
    }
    USB.println(F("\nRadio initialized"));

    err = sendTextPacket(SENDER_MAC, message);

    commShutdown();
    
  }
  else if (intFlag & RTC_INT)
  {
    intFlag &= ~(RTC_INT);
    USB.println("-- RTC Interrupt received");

    uint8_t err;
    // Activate the XBee radio.
    // Set power level at minimum (0)
    if (err = commInit(0))
    {
      USB.println(F("Radio failed. Exiting ..."));
      exit(0);
    }
    USB.println(F("\nRadio initialized"));

    // Let's discover nearby radios
    uint32_t init_time = millis();

    err = xbee802.scanNetwork();
    if (err)
    {
      USB.print(F("(\nscanNetwork failed with error "));
      USB.println(err, DEC);
    }
    else
    {
      uint8_t n, b;
      char mac[17];

      USB.print(F("\n\nTotal radios detected after "));
      USB.printf("%u msec: ", millis() - init_time);
      USB.println(xbee802.totalScannedBrothers, DEC);

      for (n = 0; n < xbee802.totalScannedBrothers; n++)
      {
        USB.print(F("Node "));
        USB.print(n, DEC);
        USB.print(F(": "));
        USB.println(xbee802.scannedBrothers[n].NI);

        // Alternative for printing the MAC address
        mac2char(mac, &xbee802.scannedBrothers[n]);
        USB.print(F("\n\tMAC: 0x"));
        USB.print(mac);

        USB.print(F("\n\tDevice type: "));
        USB.print(xbee802.scannedBrothers[n].DT, DEC);

        USB.print(F("\n\tRSSI: "));
        USB.print(-xbee802.scannedBrothers[n].RSSI, DEC);
        USB.println(F(" dBi"));
      }
    }
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
  ACC.setIWU(ACC_THRESHOLD);
}


void loop()
{
  USB.ON();

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

    commShutdown();

    if (err == 0)
    {
      np++;
      RTC.setTime(data);
      USB.printf("Time to sleep: %s\n", sleep_time);
      USB.printf("RTC Time: %s\n", RTC.getTime());
      USB.printf("Packet received from %s\n", SENDER_MAC);
      USB.print(np);
      USB.println(F(" packets received correctly"));
      RTC_DATA = true;
    }
  }

  AwaitGesture();

  PWR.deepSleep(sleep_time, RTC_OFFSET, RTC_ALM1_MODE2, ALL_OFF);
}
