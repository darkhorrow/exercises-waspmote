#define BUFFER_SIZE 100
char command_buffer[BUFFER_SIZE];

void setup() {
  USB.ON();
  pinMode(DIGITAL1, OUTPUT);
  pinMode(DIGITAL2, OUTPUT);
  pinMode(DIGITAL3, OUTPUT);
  pinMode(DIGITAL4, OUTPUT);
  pinMode(DIGITAL5, OUTPUT);
  pinMode(DIGITAL6, OUTPUT);
  pinMode(DIGITAL7, OUTPUT);
  pinMode(DIGITAL8, OUTPUT);
  help();
}

void loop() {
  read_USB_command(command_buffer, BUFFER_SIZE);
  exec_command_read(command_buffer);
}

