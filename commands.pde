enum COMMAND {
    RED_ON,
    RED_OFF,
    GREEN_ON,
    GREEN_OFF,
    RED_BLINK, 
    GREEN_BLINK, 
    HELP,
    OPEN_D_PIN,
    CLOSE_D_PIN,
    FREE_MEMORY,
    READ_EEPROM,
    WRITE_EEPROM,
    RTC_GET_DATETIME,
    RTC_SET_DATETIME
};

static const char *COMMAND_STRING[] = {
    "red on", 
    "red off", 
    "green on", 
    "green off", 
    "red blink", 
    "green blink", 
    "help", 
    "open digital pin", 
    "close digital pin",
    "memory available", 
    "read eeprom",
    "write eeprom",
    "get datetime",
    "set datetime"
};

int digitalPins[] = {DIGITAL1, DIGITAL2, DIGITAL3, DIGITAL4, DIGITAL5, DIGITAL6, DIGITAL7, DIGITAL8};

void read_USB_command(char *term, size_t msz) {
  int8_t sz = 0;
  unsigned long init = millis();
  
  while(sz < msz){
    while ((USB.available() > 0) && (sz < msz)) {
      term[sz++] = USB.read();
      init = millis();
    }
    if (sz && ((millis() - init) > 50UL)) break;
  }
  term[sz] = 0;
}

void exec_command_read(char *command_buffer) {
  strip_extra_spaces(strlwr(command_buffer));

  if(!strcmp("", command_buffer)) return;
  
  if(!strcmp(COMMAND_STRING[RED_ON], command_buffer)) {
    Utils.setLED(LED0, LED_ON);
    USB.println("Red LED ON");
    return;
  } else if(!strcmp(COMMAND_STRING[RED_OFF], command_buffer)) {
    Utils.setLED(LED0, LED_OFF);
    USB.println("Red LED OFF");
    return;
  } else if(!strcmp(COMMAND_STRING[GREEN_ON], command_buffer)) {
    Utils.setLED(LED1, LED_ON);
    USB.println("Green LED ON");
    return;
  } else if(!strcmp(COMMAND_STRING[GREEN_OFF], command_buffer)) {
    Utils.setLED(LED1, LED_OFF);
    USB.println("Green LED OFF");
    return;
  } else if(!strcmp(COMMAND_STRING[HELP], command_buffer)) {
    help();
    return;
  } else if(!strcmp(COMMAND_STRING[OPEN_D_PIN], command_buffer)) {
    openDigitalPin();
    return;
  } else if(!strcmp(COMMAND_STRING[CLOSE_D_PIN], command_buffer)) {
    closeDigitalPin();
    return;
  } else if(!strcmp(COMMAND_STRING[RED_BLINK], command_buffer)) {
    blinkLed(LED0);
    return;
  } else if(!strcmp(COMMAND_STRING[GREEN_BLINK], command_buffer)) {
    blinkLed(LED1);
    return;
  } else if(!strcmp(COMMAND_STRING[FREE_MEMORY], command_buffer)) {
    USB.print("Current free memory: "); USB.print(freeMemory()); USB.println(" bytes");
    return;
  } else if(!strcmp(COMMAND_STRING[READ_EEPROM], command_buffer)) {
    readEEPROM();
    return;
  } else if(!strcmp(COMMAND_STRING[WRITE_EEPROM], command_buffer)) {
    writeEEPROM();
    return;
  } else if(!strcmp(COMMAND_STRING[RTC_GET_DATETIME], command_buffer)) {
    USB.print("RTC datetime: "); USB.println(RTC.getTime());
    return;
  } else if(!strcmp(COMMAND_STRING[RTC_SET_DATETIME], command_buffer)) {
    setDateTime();
    return;
  } else {
    USB.print("Command '"); USB.print(strlwr(command_buffer)); USB.println("' not available.");
    help();
  }
}

char* read_command_param(char *command_buffer) {
  strip_extra_spaces(strlwr(command_buffer));
  return command_buffer;
}

void help() {
  USB.println();
  USB.println("================================================================================");
  USB.println("| Available commands                                                           |");
  USB.println("================================================================================");
  USB.println("| red on\t\tTurns on the red LED on the Waspmote                   |");
  USB.println("| red off\t\tTurns off the red LED on the Waspmote                  |");
  USB.println("| red blink\t\tBlink the red LED on the Waspmote for the period       |");
  USB.println("|          \t\tand repetitions specified                              |");
  USB.println("================================================================================");
  USB.println("| green on\t\tTurns on the green LED on the Waspmote                 |");
  USB.println("| green off\t\tTurns off the red LED on the Waspmote                  |");
  USB.println("| green blink\t\tBlink the green LED on the Waspmote for the period     |");
  USB.println("|            \t\tand repetitions specified                              |");
  USB.println("================================================================================");
  USB.println("| open digital pin\tTurns on the digital pin [1 - 8] on the Waspmote       |");
  USB.println("| close digital pin\tTurns off the digital pin [1 - 8] on the Waspmote      |");
  USB.println("================================================================================");
  USB.println("| read eeprom\t\tRead an uint8_t value in a specific EEPROM position    |");
  USB.println("| write eeprom\t\tWrite an uint8_t value in a specific EEPROM position   |");
  USB.println("================================================================================");
  USB.println("| memory available\tDisplays the free memory available                     |");
  USB.println("| help\t\t\tDisplays the allowed commands and its parameters       |");
  USB.println("================================================================================");
  USB.println();
}

void openDigitalPin() {
  USB.println("Which pin do you want to open? [1 - 8]");
  
  int pin = 0;

  while(pin <= 0) {
    pin = atoi(get_command_param(command_buffer));

    if(pin <= 0) {
      USB.println("Not a valid number");
      USB.println("Which pin do you want to open? [1 - 8]");
    }
  }

  digitalWrite(digitalPins[pin - 1], HIGH);
  USB.print("Oppened pin "); USB.println(pin);
}

void closeDigitalPin() {
  USB.println("Which pin do you want to close? [1 - 8]");
  
  int pin = 0;

  while(pin <= 0 || pin > 8) {
    pin = atoi(get_command_param(command_buffer));

    if(pin <= 0 || pin > 8) {
      USB.println("Not a valid number");
      USB.println("Which pin do you want to close? [1 - 8]");
    }
  }

  digitalWrite(digitalPins[pin - 1], LOW);
  USB.print("Closed pin "); USB.println(pin);
}

void blinkLed(int led) {
  USB.println("Which is the blinking period? [in milliseconds]");

  int period = 0;
  int repetitions = 0;

  while(period <= 0) {
    period = atoi(get_command_param(command_buffer));

    if(period <= 0) {
      USB.println("Not a valid number");
      USB.println("Which is the blinking period? [in milliseconds]");
    }
  }

  USB.println("How many repitions will be done?");

  while(repetitions <= 0) {
    repetitions = atoi(get_command_param(command_buffer));

    if(repetitions <= 0) {
      USB.println("Not a valid number");
      USB.println("How many repitions will be done?");
    }
  }

  USB.println("Blinking...");

  boolean isLedOn = Utils.getLED(led);
  led == LED0 ? Utils.blinkRedLED(period, repetitions) : Utils.blinkGreenLED(period, repetitions);
  if(isLedOn) Utils.setLED(led, LED_ON);
}

void readEEPROM() {
  USB.println("Which is the address position to read? [1024 - 4096]");

  int address = 0;

  while(address < 1024 || address > 4096) {
    address = atoi(get_command_param(command_buffer));

    if(address < 1024 || address > 4096) {
      USB.println("Not a valid number");
      USB.println("Which is the address position to read? [1024 - 4096]");
    }
  }

  USB.print("EEPROM address="); USB.print(address); USB.print(" content="); USB.println(Utils.readEEPROM(address), DEC);
}

void writeEEPROM() {
  USB.println("Which is the address position to write? [1024 - 4096]");

  int address = 0;
  uint8_t value;

  while(address < 1024 || address > 4096) {
    address = atoi(get_command_param(command_buffer));

    if(address < 1024 || address > 4096) {
      USB.println("Not a valid number");
      USB.println("Which is the address position to write? [1024 - 4096]");
    }
  }

  USB.println("Which is the value to store? [any uint8_t value]");
  
  value = atoi(get_command_param(command_buffer));

  Utils.writeEEPROM(address, value);
  USB.print("EEPROM address="); USB.print(address); USB.print(" content="); USB.println(Utils.readEEPROM(address), DEC);
}

void setDateTime() {
  USB.println("Insert new day [i.e 3 or 03]");
  
  int day = 0;
  int month = 0;
  int year = 0; 
  int hour = -1;
  int minute = -1;
  int second = -1;

  while(day <= 0 || day > 31) {
    day = atoi(get_command_param(command_buffer));

    if(day <= 0 || day > 31) {
      USB.println("Not a valid day");
      USB.println("Insert new day [i.e 3 or 03]");
    }
  }

  USB.println("Insert new month [i.e 3 or 03]");

  while(month <= 0 || month > 12) {
    month = atoi(get_command_param(command_buffer));

    if(month <= 0 || month > 12) {
      USB.println("Not a valid month");
      USB.println("Insert new month [i.e 3 or 03]");
    }
  }

  USB.println("Insert new year [i.e 21]");

  while(year <= 0 || year > 99) {
    year = atoi(get_command_param(command_buffer));

    if(year <= 0 || year > 99) {
      USB.println("Not a valid year");
      USB.println("Insert new year [i.e 21]");
    }
  }

  USB.println("Insert new hour [i.e 21]");

  while(hour <= -1 || hour > 23) {
    hour = atoi(get_command_param(command_buffer));

    if(hour <= -1 || hour > 23) {
      USB.println("Not a valid hour");
      USB.println("Insert new hour [i.e 21]");
    }
  }

  USB.println("Insert new minute [i.e 21]");

  while(minute <= -1 || minute > 59) {
    minute = atoi(get_command_param(command_buffer));

    if(minute <= -1 || minute > 59) {
      USB.println("Not a valid minute");
      USB.println("Insert new minute [i.e 21]");
    }
  }

  USB.println("Insert new second [i.e 21]");

  while(second <= -1 || second > 59) {
    second = atoi(get_command_param(command_buffer));

    if(second <= -1 || second > 59) {
      USB.println("Not a valid second");
      USB.println("Insert new second [i.e 21]");
    }
  }

  char datetime[14];

  sprintf(datetime, "%02u:%02u:%02u:%02u:%02u:%02u:%02u", year, month, day, RTC.dow(year, month, day), hour, minute, second);
  RTC.setTime(datetime);

  USB.print("RTC datetime: "); USB.println(RTC.getTime());
}


