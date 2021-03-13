enum COMMAND {
    RED_ON, RED_OFF, GREEN_ON, GREEN_OFF, HELP
};

static const char *COMMAND_STRING[] = {
    "red on", "red off", "green on", "green off", "help"
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
  
  if(!strcmp(COMMAND_STRING[RED_ON], command_buffer)) {
    Utils.setLED(LED0, LED_ON);
    USB.println("Red LED ON");
  } else if(!strcmp(COMMAND_STRING[RED_OFF], command_buffer)) {
    Utils.setLED(LED0, LED_OFF);
    USB.println("Red LED OFF");
  } else if(!strcmp(COMMAND_STRING[GREEN_ON], command_buffer)) {
    Utils.setLED(LED1, LED_ON);
    USB.println("Green LED ON");
  } else if(!strcmp(COMMAND_STRING[GREEN_OFF], command_buffer)) {
    Utils.setLED(LED1, LED_OFF);
    USB.println("Green LED OFF");
  } else if(!strcmp(COMMAND_STRING[HELP], command_buffer)) {
    help();
  } else {
    USB.print("Command '"); USB.print(strlwr(command_buffer)); USB.println("' not available.");
    help();
  }
}

void help() {
  USB.println();
  USB.println("========================================================================");
  USB.println("| Available commands                                                   |");
  USB.println("========================================================================");
  USB.println("| red on\tTurns on the red LED on the Waspmote                   |");
  USB.println("| red off\tTurns off the red LED on the Waspmote                  |");
  USB.println("| green on\tTurns on the green LED on the Waspmote                 |");
  USB.println("| green off\tTurns off the red LED on the Waspmote                  |");
  USB.println("| help\t\tDisplays the allowed commands and its parameters       |");
  USB.println("========================================================================");
  USB.println();
}

