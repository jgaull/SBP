#include <SPI.h>
#include <ble.h>
 
#define GYRO_PIN      A0

float gyroVoltage = 5;         //Gyro is running at 5V
float gyroZeroVoltage = 1.35;   //Gyro is zeroed at 2.5V
float gyroSensitivity = 0.67;  //Our example gyro is 7mV/deg/sec
float pollingFrequency = 100;

void setup()
{
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();
  
  Serial.begin(9600);

  ble_begin();
}

void loop()
{
  uint16_t value = analogRead(GYRO_PIN);
  
  ble_write(0x0A);
  ble_write(value >> 8);
  ble_write(value);
  
  // Allow BLE Shield to send/receive data
  ble_do_events();
  
  // If data is ready
  /*while(ble_available())
  {
    Serial.println("Inside!");
    // read out command and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();
    
    //Serial.println("data0: " + data0);
    //Serial.println("data1: " + data1);
    //Serial.println("data2: " + data2);
    
    if (data0 == 0x01)  // Command is to control digital out pin
    {
      //Serial.println("Control Digital Out Pin");
      if (data1 == 0x01)
        digitalWrite(DIGITAL_OUT_PIN, HIGH);
      else
        digitalWrite(DIGITAL_OUT_PIN, LOW);
    }
    else if (data0 == 0xA0) // Command is to enable analog in reading
    {
      //Serial.println("Control Analog In Pin");
      if (data1 == 0x01)
        analog_enabled = true;
      else
        analog_enabled = false;
    }
    else if (data0 == 0x02) // Command is to control PWM pin
    {
      //Serial.println("Control PWM Pin");
      analogWrite(PWM_PIN, data1);
    }
  }
  
  if (analog_enabled)  // if analog reading enabled
  {
    // Read and send out
    uint16_t value = analogRead(ANALOG_IN_PIN); 
    ble_write(0x0B);
    ble_write(value >> 8);
    ble_write(value);
    Serial.println("Value: " + value);
  }
  
  // If digital in changes, report the state
  if (digitalRead(DIGITAL_IN_PIN) != old_state)
  {
    old_state = digitalRead(DIGITAL_IN_PIN);
    
    if (digitalRead(DIGITAL_IN_PIN) == HIGH)
    {
      ble_write(0x0A);
      ble_write(0x01);
      ble_write(0x00);    
    }
    else
    {
      ble_write(0x0A);
      ble_write(0x00);
      ble_write(0x00);
    }
  }
  
  if (!ble_connected())
  {
    analog_enabled = false;
    digitalWrite(DIGITAL_OUT_PIN, LOW);
  }*/ 
}



