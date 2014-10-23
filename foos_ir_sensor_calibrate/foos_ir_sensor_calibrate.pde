int analogPin = 0;     

int val = 0;           // variable to store the value read
int baseline = 0;           // var to store the determined baseline at startup
int MAX_SAMPLES = 50;  // # of samples to determine baseline

void setup()
{
  pinMode(13, OUTPUT);
  Serial.begin(9600);          //  setup serial
  delay(100);                  //let things stabilize

  // determine average
  unsigned int sum = 0;
  for(int i=0;i<MAX_SAMPLES;i++){
      sum += analogRead(analogPin);
  }  
  baseline = sum/MAX_SAMPLES;

}

void loop()
{
  
  val = analogRead(analogPin);    // read the input pin

  // if 20% below baseline print something
  if( val < (baseline * 0.8)){
    digitalWrite(13, HIGH);
    Serial.print("Goal!!! baseline:");             // debug value
    Serial.println(baseline);
  } else {
       digitalWrite(13, LOW); 
  }
  
  delay(100);

}

