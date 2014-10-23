/*

 Super simple ethernet arduino displaying the hex encoded value from an HTTP GET request.
 Color value should be encoded in the typical RRGGGBB fashion e.g. GET /?color=FFFFFF
 
 (C) Erich Nachbar
 
 */

#include "AF_XPort.h"
#include "AFSoftSerial.h"

AFSoftSerial mySerial =  AFSoftSerial(3, 2);

#define HTTP_HEADER "HTTP/1.0 200 OK\nServer: HAL 9000\nContent-Type: text/html\n\nDone!\n"

// Output
const int redPin   = 9;   // Red LED,   connected to digital pin 9
const int greenPin = 10;  // Green LED, connected to digital pin 10
const int bluePin  = 11;  // Blue LED,  connected to digital pin 11

// Program variables
int redVal   = 255; // Variables to store the values to send to the pins
int greenVal = 1;   // Initial values are Red full, Green and Blue off
int blueVal  = 1;

// XPort constants
#define XPORT_RX        2
#define XPORT_TX        3
#define XPORT_RESET     4
#define XPORT_CTS       6
#define XPORT_RTS       0 // not used
#define XPORT_DTR       0 // not used
AF_XPort xport = AF_XPort(XPORT_RX, XPORT_TX, XPORT_RESET, XPORT_DTR, XPORT_RTS, XPORT_CTS);



int i = 0;     // Loop counter    
int wait = 10; // 50ms (.05 second) delay; shorten for faster fades

void setup()
{
  pinMode(redPin,   OUTPUT);   // sets the pins as output
  pinMode(greenPin, OUTPUT);   
  pinMode(bluePin,  OUTPUT); 
  Serial.begin(9600);  // ...set up the serial ouput on 0004 style 

  xport.begin(9600);
  xport.reset();
  

  Serial.println("XPort ready");
}

// Main program

char inByte = 0; // incoming data byte
char line[255];
int marker = 0; 

void processColor(char *line, byte &r, byte &g, byte &b);

void loop(){

  // check all this here!
  int ret = requestEthernet();

  if(ret = 200){
    byte r,g,b;
    processColor(line, r, g, b);

    digitalWrite(redPin, r);
    digitalWrite(greenPin, g);
    digitalWrite(bluePin, b);
  }  
  xport.println(HTTP_HEADER);
  xport.flush(50);
  xport.flush(200);
  xport.disconnect();

  //delay(4000);
  //pinMode(XPORT_RESET, HIGH);
  //delay(50); 
  //pinMode(XPORT_RESET, LOW);
  
}


void request_serial()
{

  if(Serial.available() > 0){
    inByte = Serial.read();
    if(inByte != 'X'){
      line[marker++] = inByte;
    } 
    else {
      // got a CR
      line[marker] = 0;
      Serial.print("got:");
      Serial.println(line);
      Serial.flush();
      marker = 0; // reset it to the beginning

      byte r,g,b;
      processColor(line, r, g, b);

      digitalWrite(redPin, r);
      digitalWrite(greenPin, g);
      digitalWrite(bluePin, b);

    }
  } 
}

int requestEthernet(){

  int read, x;

  while (1) {
    read = xport.readline_timeout(line, 128, sizeof(line));
    //Serial.println(read, DEC);   // debugging output
    if (read && (strstr(line, "color=") != NULL)){          // we got something!
      Serial.print("--------");
      Serial.println(line);
      return 200;
    } 
    if(read){
      Serial.print("XXXX");
      Serial.println(line);
    }
  }    
}


void processColor(char *line, byte &r, byte &g, byte &b){
  char *start = NULL;
  char *end = line;
  char color[100] = "FFFFFF";  // placeholder for color

  // check if there is a command we can process
  if( (start = strstr(line, "color=")) != NULL){
    Serial.print("starts: ");
    Serial.println(start);

    // this block below is pretty much useless as we always take the next 6 bytes (i.e. fixed length - end not used)
    // find end or if not possible use the entire rest of the string  
    if( (end = strstr(start, "&")) != NULL){
      Serial.print("ends: ");
      Serial.println(end);
    }


    strcpy(color, start+6);
    color[6]='\0';
    Serial.print("col: ");
    Serial.println(color);  
    Serial.flush();

    r = parseHex(color[0]) * 16 + parseHex(color[1]);
    g = parseHex(color[2]) * 16 + parseHex(color[3]);
    b = parseHex(color[4]) * 16 + parseHex(color[5]);
  }
}

// color=AAFF33X

// read a Hex value and return the byte equivalent
byte parseHex(char c) {
  if (c < '0') return 0;
  if (c <= '9') return c - '0';
  if (c < 'A') return 0;
  if (c <= 'F') return (c - 'A')+10;
}

