#include "LoRaWan_APP.h"
#include "Arduino.h"
#include "softSerial.h"
#include <Wire.h>

#define timetowake 1000 * 60 * 5 // five minutes

String host_id = "distance_1"; // Change this to whatever you want!
String distance;
String voltage = "0";

#define timetosleep 300 // 300 milliseconds

static TimerEvent_t sleep;
static TimerEvent_t wakeup;
uint8_t lowpower = 1;
bool done = false;

#define RF_FREQUENCY                                868000000
#define TX_OUTPUT_POWER                             14
#define LORA_BANDWIDTH                              0
#define LORA_SPREADING_FACTOR                       8
#define LORA_CODINGRATE                             4
#define LORA_PREAMBLE_LENGTH                        8
#define LORA_SYMBOL_TIMEOUT                         0
#define LORA_FIX_LENGTH_PAYLOAD_ON                  false
#define LORA_IQ_INVERSION_ON                        false
#define RX_TIMEOUT_VALUE                            1000
#define BUFFER_SIZE                                 30

char txPacket[BUFFER_SIZE];

static RadioEvents_t RadioEvents;
void OnTxDone( void );
void OnTxTimeout( void );

softSerial softwareSerial(GPIO1 /*TX pin*/, GPIO2 /*RX pin*/);

typedef enum
{
  LOWPOWER,
  ReadVoltage,
  TX
} States_t;

States_t state;
bool sleepMode = false;
int16_t rssi, rxSize;

void setup() {

  Wire.begin();
  Serial.begin(115200);
  Serial.println( "[stup] INIT");

  sensor.begin(); // reset sensor
  delay(1000);

  rssi = 0;

  RadioEvents.TxDone = OnTxDone;
  RadioEvents.TxTimeout = OnTxTimeout;

  Radio.Init( &RadioEvents );
  Radio.SetChannel( RF_FREQUENCY );
  Radio.SetTxConfig( MODEM_LORA, TX_OUTPUT_POWER, 0, LORA_BANDWIDTH,
    LORA_SPREADING_FACTOR, LORA_CODINGRATE,
    LORA_PREAMBLE_LENGTH, LORA_FIX_LENGTH_PAYLOAD_ON,
    true, 0, 0, LORA_IQ_INVERSION_ON, 3000 );

  TimerInit( &sleep, OnSleep );
  TimerInit( &wakeup, OnWakeup );
  OnSleep();
}


uint32_t out_flag_1 = 0;
uint32_t out_flag_2 = 0;
uint32_t t1;
uint32_t t2;

void time1()
{
  out_flag_1 = 1;
  t1 = micros();
}

void time2()
{
  out_flag_2 = 1;
  t2 = micros();
}

void loop()
{
  if (lowpower)
  {
    //note that LowPower_Handler() run six times the mcu into lowpower mode;
    lowPowerHandler();
  } else if (!done) {

    // Turn on device
    pinMode(Vext, OUTPUT);
    digitalWrite(Vext, LOW);
    delay(500);

    pinMode(GPIO1, OUTPUT);
    pinMode(GPIO2, INPUT);    
    //software serial init

    softwareSerial.begin(9600);
    softwareSerial.flush();

    delay(200);
    distance = readDistance();
    distance = readDistance();
    int temperature = readTemp();
    
    Serial.println(distance);
    Serial.println(temperature);

    float temperature_f = 1.8 * temperature + 32;
    String temperature_formatted = String(temperature_f, 1);

     // Read voltage
    pinMode(VBAT_ADC_CTL, OUTPUT);
    digitalWrite(VBAT_ADC_CTL, LOW);
    float c = getBatteryVoltage();
    voltage = String(c / 1000, 4);
    pinMode(VBAT_ADC_CTL, INPUT);
    delay(100);
  
    // Send reading
    Radio.IrqProcess();

    // InfluxDB line protocol format
    String blah = "dorothy,host=" + host_id + 
    " temperature=" + temperature_formatted + 
    ",distance=" + distance +
    ",voltage=" + voltage;

    Serial.print(blah);
    Radio.Send((uint8_t *)blah.c_str(), blah.length() );
  
    delay(100);
    
    detachInterrupt(GPIO2); // prevents system hang after switching power off
     
    Wire.end();
    pinMode(Vext, OUTPUT);  
    digitalWrite(Vext, HIGH);
    delay(500);

    done = true;
    TimerSetValue( &sleep, timetosleep );
    TimerStart( &sleep );
  }
}

int readDistance()
{
  unsigned int highByte = 0;
  unsigned int lowByte = 0;
  unsigned int dist = 0;

  softwareSerial.flush();
  softwareSerial.sendByte(0X55);
  delay(500);
  if (softwareSerial.available() >= 2)
  {

    highByte = softwareSerial.read();
    lowByte = softwareSerial.read();
    dist = highByte * 256 + lowByte;          // Calculate the distance
    if ((dist > 1) && (dist < 10000))
    {
      return dist;
    }
  }
}

int readTemp()
{
  unsigned int temp = 0;
  softwareSerial.sendByte(0X50);
  delay(100);
  if (softwareSerial.available() >= 1)
  {
      temp = softwareSerial.read() - 45; // celcius
      softwareSerial.flush();
      return temp;
  }
}

void OnSleep()
{
  Serial.printf("[lowp] lowpower mode  %d ms\r\n", timetowake);
  lowpower = 1;
  
  //timetosleep ms later wake up;
  Radio.Sleep();
  TimerSetValue( &wakeup, timetowake );
  TimerStart( &wakeup );
}

void OnWakeup()
{
  Serial.printf("[wkup] wake up, %d ms later into lowpower mode.\r\n", timetosleep);
  uint32_t currentTime = TimerGetCurrentTime() / 1000;
  Serial.printf("[time] upTime: %d sec. \r\n", currentTime);

  done = false;
  lowpower = 0;
}

void OnTxDone( void )
{
  Serial.print("TX done!");
}

void OnTxTimeout( void )
{
  Serial.print("TX Timeout......");
}
