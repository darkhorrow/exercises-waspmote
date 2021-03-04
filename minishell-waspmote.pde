char command_buffer[10];

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

int8_t exec_command_read() {
  if(!strcmp("red on", command_buffer)) {
    Utils.setLED(LED0, LED_ON);
  } else if(!strcmp("red off", command_buffer)) {
    Utils.setLED(LED0, LED_OFF);
  } else if(!strcmp("green on", command_buffer)) {
    Utils.setLED(LED1, LED_ON);
  } else if(!strcmp("green off", command_buffer)) {
    Utils.setLED(LED1, LED_OFF);
  } else {
    USB.print("Command ");
    USB.print(command_buffer);
    USB.println(" not available.");
  }
}

void setup() {
  USB.ON();
}


void loop() {
  read_USB_command(command_buffer, 10);
  exec_command_read();
}
