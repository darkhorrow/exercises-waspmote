#define SINE_STEP 0.01
#define SINE_MEAN_PWM 127

#define BUFFER_LENGTH 25

#define MAX_MILLIVOLTS 3300
#define MAX_AD_SAMPLE_VALUE 1023

#define AD_PIN ANALOG3
#define AD_RECORDING_TIME 300000 // milliseconds

#define AD_SAMPLE_FILE "samples.txt"
#define AD_SAMPLE_FILE_HEADER_INFO "# data format:\n# time voltage\n# (msecs) (mvolts)"

#define THE_LED LED1
#define MIN_PWM_VALUE 0
#define MAX_PWM_VALUE 255
#define INCREMENT 0
#define DECREMENT 1

unsigned long g_startingTime;
char g_pStrBuffer[BUFFER_LENGTH];

unsigned char g_ledState;
unsigned char g_pwmValue;
unsigned char g_pwmState;

void print_card_info()
{
  SD.print_disk_info();
  SD.getDiskSize();
  USB.println(F("\n---------    SD card info    ---------"));
  USB.println(SD.buffer);
  USB.print(F("Disk size: "));
  USB.print(SD.diskSize); USB.println(F(" bytes"));
  USB.println(F("Contents at root directory:"));
  SD.ls(LS_R|LS_DATE|LS_SIZE);
  USB.println(F("\n---------    SD card info    ---------"));
}

void starting()
{
  USB.println("\n--------- starting recording ---------");
  USB.println("genAnalog: generates and samples and analog generated signal");
  USB.print("recording time: "); USB.print(AD_RECORDING_TIME,DEC); USB.println(" msecs.");
  USB.print("AD pin: "); USB.println(AD_PIN,DEC);  
  USB.print("recording file \""); USB.print(AD_SAMPLE_FILE); USB.println("\"");
  USB.print("free memory: "); USB.print(freeMemory(),DEC); USB.println(" bytes");
  USB.println("--------- starting recording ---------");
   
  if(SD.isFile(AD_SAMPLE_FILE)==1) SD.del(AD_SAMPLE_FILE);
  SD.create(AD_SAMPLE_FILE);
  SD.appendln(AD_SAMPLE_FILE,AD_SAMPLE_FILE_HEADER_INFO);
}

void finishing()
{
  USB.println(F("--------- finishing recording --------"));
  print_card_info();
  SD.OFF();
}

void takeADSample(
  unsigned long& sampleTime,
  unsigned long& sample, 
  unsigned long& milliVolts,
  unsigned char adPin
)
{
  sampleTime=millis()-g_startingTime;
  sample=analogRead(adPin);
  milliVolts=(sample)*MAX_MILLIVOLTS/MAX_AD_SAMPLE_VALUE;
}

void printADSample(
  unsigned long sampleTime,
  unsigned long sample, 
  unsigned long milliVolts
)
{
  USB.print("AD sample: "); USB.print(milliVolts,DEC);
  USB.print(" mV ("); USB.print(sample,DEC); 
  USB.print(") t="); USB.print(sampleTime,DEC); USB.println(" ms.");
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

unsigned char nextPWMValue(unsigned char value,unsigned char& the_state)
{
  return (
    (the_state==INCREMENT)? 
      ((value==MAX_PWM_VALUE)? (the_state=DECREMENT, value-1): value+1):
      ((value==MIN_PWM_VALUE)? (the_state=INCREMENT, value+1): value-1)
  );
}

double nextSineValue(double value)
{
  return sin(value)*SINE_MEAN_PWM+SINE_MEAN_PWM;
}

unsigned char updateLed(unsigned char the_led,unsigned char the_state)
{ Utils.setLED(the_led,the_state); return ((the_state==LED_ON)? LED_OFF: LED_ON); }

void setup()
{
  // initialize global variables
  g_startingTime=millis();
  
  g_ledState=LED_ON;
  g_pwmValue=MIN_PWM_VALUE;
  g_pwmState=INCREMENT;
  
  // initialize USB
  USB.ON();
  
  // initialize SD
  SD.ON();
  if(SD.flag)
  {
    USB.println(F("[ERROR] cannot initialize SD!"));
    USB.print(F("[ERROR] error code: ")); USB.println(SD.flag);
    exit(0);
  }
 
  if(!SD.isSD())
  {  
    USB.println(F("[ERROR] no card in SD slot!"));
    exit(0);
  }
   
  pinMode(DIGITAL1,OUTPUT);  

  print_card_info();
  
  starting();
}

void loop()
{  
  g_ledState=updateLed(THE_LED,g_ledState);
  
  static double value = 0.0;
  
  unsigned long sampleTime, sample, milliVolts;
  analogWrite(DIGITAL1,g_pwmValue);
  g_pwmValue=nextSineValue(value);
  takeADSample(sampleTime,sample,milliVolts,AD_PIN);
  printADSample(sampleTime,sample,milliVolts);
  saveADSample(AD_SAMPLE_FILE,sampleTime,milliVolts);
  
  value +=0.01;
  
  if(sampleTime>AD_RECORDING_TIME) { finishing(); exit(0); }
}


