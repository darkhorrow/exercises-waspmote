enum COMMAND {
    RED_ON, RED_OFF, GREEN_ON, GREEN_OFF
};

static const char *COMMAND_STRING[] = {
    "red on", "red off", "green on", "green off"
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

int8_t exec_command_read(char *command_buffer) {
  char* buffer_treated = strlwr(command_buffer);
  strip_extra_spaces(buffer_treated);
  
  if(!strcmp(COMMAND_STRING[RED_ON], buffer_treated)) {
    Utils.setLED(LED0, LED_ON);
    USB.println("Red LED ON");
  } else if(!strcmp(COMMAND_STRING[RED_OFF], buffer_treated)) {
    Utils.setLED(LED0, LED_OFF);
    USB.println("Red LED OFF");
  } else if(!strcmp(COMMAND_STRING[GREEN_ON], buffer_treated)) {
    Utils.setLED(LED1, LED_ON);
    USB.println("Green LED ON");
  } else if(!strcmp(COMMAND_STRING[GREEN_OFF], buffer_treated)) {
    Utils.setLED(LED1, LED_OFF);
    USB.println("Green LED OFF");
  } else {
    USB.print("Command '");
    USB.print(strlwr(command_buffer));
    USB.println("' not available.");
  }
}
