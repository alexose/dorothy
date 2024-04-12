#include "LoRaWan_APP.h"
#include "Arduino.h"
#include "softSerial.h"
#include <DHT.h>
#define DHTPIN GPIO2 // Digital pin connected to the DHT sensor
#define DHTTYPE DHT22

String host_id = "temperature_1"; // Change this to whatever you want!
String voltage = "0";

DHT dht(DHTPIN, DHTTYPE);

#define timetosleep 300
#define timetowake 1000 * 60 * 10 // Every 10 minutes

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

  
  Serial.begin(115200);
  Serial.println( "[stup] INIT");
  pinMode(GPIO2, INPUT_PULLUP);
  delay(100);
  dht.begin(); // reset sensor
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
    lowPowerHandler();
  } else if (!done) {
  
    pinMode(GPIO2, INPUT_PULLUP);
    delay(100);

    // Turn on device
    pinMode(Vext, OUTPUT);
    digitalWrite(Vext, LOW);
    delay(1000);

    dht.begin(); // reset sensor
    delay(2000);

    float h = dht.readHumidity();
    float t = dht.readTemperature(true); // Fahrenheit = true

     // Read voltage
    pinMode(VBAT_ADC_CTL, OUTPUT);
    digitalWrite(VBAT_ADC_CTL, LOW);
    float c = getBatteryVoltage();
    voltage = String(c / 1000, 4);
    pinMode(VBAT_ADC_CTL, INPUT);
    delay(100);

    Serial.print(dht.readHumidity());
    Serial.print(dht.readTemperature(true));
  
    // Send reading
    Radio.IrqProcess();

    // InfluxDB line protocol format
    String blah = "dorothy,host=" + host_id + 
    " temperature=" + String(t) + 
    ",humidity=" + String(h) +
    ",voltage=" + voltage;

    Serial.print(blah);

    Radio.Send((uint8_t *)blah.c_str(), blah.length() );
  
    delay(100);
     
    // Turn off device via https://github.com/HelTecAutomation/CubeCell-Arduino/issues/35
    pinMode(Vext, OUTPUT);  
    digitalWrite(Vext, HIGH);
    delay(500);

    done = true;
    TimerSetValue( &sleep, timetosleep );
    TimerStart( &sleep );
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