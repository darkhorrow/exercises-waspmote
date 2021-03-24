/*
   ------------------------------------------------------------
   This program is a variation of the ReadingBatTempTime. Here 
   the mote undergoes a DEEP "sleep" instead of making an 
   active delay loop.
   ------------------------------------------------------------
 */
   
void setup()
{
  // Init USB, needed for printing to the
  // serial monitor console
  USB.ON();
  USB.println("\nUSB OK");
  
  // Power up RTC and initialize I2C bus 
  USB.println("Init RTC"); 
  RTC.ON(); 
  
  // Set time and date
  // Format is yy:mm:dd:dw:hh:mm:ss
  // dw: day of the week. Sunday is equal to 1, 
  //                      Monday must be equal to 2.
  RTC.setTime("13:02:08:06:18:00:00");
  
  // Clean the state (not necessary)
  USB.OFF();

  // Enable interruption: Inertial Wake Up
  ACC.ON();
  ACC.setIWU();
}

void loop()
{
  // Note: it is important to allocate space for timestr as 
  // the pointer returned by RTC.getTime() is volatile.
  char timestr[31];
  static uint16_t cycle = 0;
  
  // Re-init modules
  // This is necessary if we use ALL_OFF in PWR.deepSleep
  USB.ON(); 
  
  // Print cycle  
  USB.print(F("Cycle: "));
  USB.println(cycle,DEC);
  
  // Get date and time
  // We make a secure copy
  // snprintf(timestr,sizeof(timestr),"%s", RTC.getTime());
  strncpy(timestr,RTC.getTime(),sizeof(timestr));
  USB.print(F("Current time: "));
  USB.println(timestr);
  
  // Show the remaining battery level
  USB.print(F("\tBattery Level: "));
  USB.print(PWR.getBatteryLevel(),DEC);
  USB.println(" %");
  
  // Get temperature 
  USB.print(F("\tTemperature: ")); 
  USB.print(RTC.getTemperature()); 
  USB.println(F(" C\n"));
  
  cycle++;
  
  // Switch all modules off and deep sleep for twenty seconds
  PWR.deepSleep("00:00:00:20", RTC_OFFSET, RTC_ALM1_MODE2, ALL_OFF);
 
}
