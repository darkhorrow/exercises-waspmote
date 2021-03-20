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
    FREE_MEMORY
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
    "memory available"
};

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

  digitalWrite(pin, HIGH);
  USB.print("Oppened pin "); USB.println(pin);
}

void closeDigitalPin() {
  USB.println("Which pin do you want to close? [1 - 8]");
  
  int pin = 0;

  while(pin <= 0) {
    pin = atoi(get_command_param(command_buffer));

    if(pin <= 0) {
      USB.println("Not a valid number");
      USB.println("Which pin do you want to close? [1 - 8]");
    }
  }

  digitalWrite(pin, LOW);
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



