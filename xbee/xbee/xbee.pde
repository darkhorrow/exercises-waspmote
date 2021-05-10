#include <WaspXBee802.h>
#include <string.h>

#define RED_LED   LED0
#define GREEN_LED LED1

#define BROADCAST_MAC  "000000000000FFFF"
#define MY_MAC         "0013A20041C3A321"

#define MAX_LENGTH        110
#define RECEIVER_TIMEOUT  500UL

#define _DEBUG_COMM_

char* sleep_time = "00:00:00:60";
bool RTC_DATA = false;

void AwaitGesture()
{
  // Check interruptions
  if (intFlag & ACC_INT)
  {
    // clear the accelerometer interrupt flag on
    // the general interrupt vector
    intFlag &= ~(ACC_INT);

    USB.println("\t -- ACC Interrupt received");
  }
  else if (intFlag & RTC_INT)
  {
    intFlag &= ~(RTC_INT);
    USB.println("\t -- RTC Interrupt received");

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

        // This is a bad idea for printing the MAC address
        USB.print(F("\tMAC: 0x"));
        for (b = 0; b < 4; b++) USB.printf("%02X", xbee802.scannedBrothers[n].SH[b], HEX);
        for (b = 0; b < 4; b++) USB.printf("%02X", xbee802.scannedBrothers[n].SL[b], HEX);

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
  ACC.setIWU();
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

    char data[MAX_LENGTH + 1];
    char from[17];
    static uint16_t np = 0;

    while (err > 0) {
      err = receiveTextPacket(from, data, RECEIVER_TIMEOUT);
    }

    commShutdown();

    if (err == 0)
    {
      np++;
      RTC.setTime(data);
      USB.printf("Time to sleep: %s\n", sleep_time);
      USB.printf("Packet received from %s\n", from);
      USB.print(np);
      USB.println(F(" packets received correctly"));
      RTC_DATA = true;
    }
  }

  AwaitGesture();

  PWR.deepSleep(sleep_time, RTC_OFFSET, RTC_ALM1_MODE2, ALL_OFF);
}
