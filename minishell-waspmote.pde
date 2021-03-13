#define BUFFER_SIZE 100
char command_buffer[BUFFER_SIZE];

void setup() {
  USB.ON();
}

void loop() {
  read_USB_command(command_buffer, BUFFER_SIZE);
  exec_command_read(command_buffer);
}
