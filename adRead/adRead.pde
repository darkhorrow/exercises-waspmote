#define BUFFER_LENGTH 25

#define MAX_MILLIVOLTS 3300
#define MAX_AD_SAMPLE_VALUE 1023

#define AD_PIN ANALOG3
#define AD_PSEUDO_PERIOD 1000 // milliseconds

#define AD_SAMPLE_FILE "samples.txt"
#define AD_SAMPLE_FILE_HEADER_INFO "# data format:\n# time voltage\n# (msecs) (mvolts)"

#define BUFFER_SIZE 100

#define N 20

char command_buffer[BUFFER_SIZE];

unsigned char g_justStarted;
unsigned long g_startingTime;
char g_pStrBuffer[BUFFER_LENGTH];

void setup()
{
  // initialize global variables
  g_startingTime=millis();
  g_justStarted=1;
  
  // initialize USB module
  USB.ON();
  
  // switch on 5V sensor output  
  PWR.setSensorPower(SENS_5V,SENS_ON);
  
  // initialize SD
  SD.ON();

  if(!SD.isSD())
  {
    USB.println(F("[ERROR] SD is not present!"));
  }
}

void loop()
{
  if(g_justStarted) { g_justStarted=0; starting(); }
  
  unsigned long sampleTime, sample, milliVolts;  

  read_USB_command(command_buffer, BUFFER_SIZE);

  if(!strcmp("measure", command_buffer)) {
    USB.println("Measuring...");
    for(int i = 0; i < N; i++) {
      USB.print("Sample "); USB.println(i);
      takeADSample(&sampleTime,&sample,&milliVolts,AD_PIN);
      printADSample(sampleTime,sample,milliVolts);
      saveADSample(AD_SAMPLE_FILE,sampleTime,milliVolts);
      delay(AD_PSEUDO_PERIOD);
    }
    memset(command_buffer, 0, sizeof command_buffer);
    USB.println("Measuring finished.");
  }
  
  if(!strcmp("end", command_buffer)) {
    USB.println("Program ended");
    exit(0);
  }
}

void starting()
{
  USB.println(F("\n--------- recording info ---------"));
  USB.println(F("adRead: this program records AD samples"));
  USB.print(F("pseudo sampling period: ")); USB.print(AD_PSEUDO_PERIOD,DEC); USB.println(F(" msecs."));
  USB.print(F("recording times: ")); USB.print(N); USB.println(F(" msecs."));
  USB.print(F("AD pin: ")); USB.println(AD_PIN,DEC);  
  USB.print(F("recording file \"")); USB.print(AD_SAMPLE_FILE); USB.println(F("\""));
  USB.print(F("free memory: ")); USB.print(freeMemory(),DEC); USB.println(F(" bytes"));
  USB.println(F("--------- recording info ---------"));
   
  if(SD.isFile(AD_SAMPLE_FILE)) SD.del(AD_SAMPLE_FILE);
  SD.create(AD_SAMPLE_FILE);
  SD.appendln(AD_SAMPLE_FILE,AD_SAMPLE_FILE_HEADER_INFO);
}

void finishing()
{
  USB.println(F("--------- finishing recording --------"));
  USB.println(F("SD contents (SD.ls()):"));
  SD.ls(LS_R);
  USB.println(F("--------- finishing recording --------"));
}

void takeADSample(
  unsigned long* pSampleTime,
  unsigned long* pSample, 
  unsigned long* pMilliVolts,
  unsigned char adPin
)
{
  *pSampleTime=millis()-g_startingTime;
  *pSample=analogRead(adPin);
  *pMilliVolts=(*pSample)*MAX_MILLIVOLTS/MAX_AD_SAMPLE_VALUE;
  USB.print(F("AD sample: ")); USB.print(pSample,DEC);
}

void printADSample(
  unsigned long sampleTime,
  unsigned long sample, 
  unsigned long milliVolts
)
{
  USB.print(F("AD sample: ")); USB.print(milliVolts,DEC);
  USB.print(F(" mV (")); USB.print(sample,DEC); 
  USB.print(F(") t=")); USB.print(sampleTime,DEC); USB.println(F(" ms."));
}

void saveADSample(
  const char* pFile,
  unsigned long sampleTime,
  unsigned long milliVolts
)
{
  snprintf(g_pStrBuffer,BUFFER_LENGTH-1,"%lu %lu",sampleTime,milliVolts);
  SD.appendln(pFile,g_pStrBuffer);
}

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
