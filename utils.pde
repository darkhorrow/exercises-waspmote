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

