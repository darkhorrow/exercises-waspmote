void strip_extra_spaces(char* str) {
  int i, x;
  for(i=x=0; str[i]; ++i)
    if(!isspace(str[i]) || (i > 0 && !isspace(str[i-1])))
      str[x++] = str[i];
  if(str[x-1] == ' ') {
    str[x-1] = '\0';
  } else {
    str[x] = '\0';
  }
}

char* get_command_param(char* command_buffer) {
  char* param;
  bool noParamPassed = true;
  
  while(noParamPassed) {
    read_USB_command(command_buffer, BUFFER_SIZE);
    param = read_command_param(command_buffer);

    if (param && !param[0]) {
      continue;
    }

    noParamPassed = false;
  }

  USB.print("> "); USB.println(param);

  return param;
}

