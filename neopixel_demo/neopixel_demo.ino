// Low power NeoPixel earrings example.  Makes a nice blinky display
// with just a few LEDs on at any time...uses MUCH less juice than
// rainbow display!

#include <Adafruit_NeoPixel.h>

#define PIN 0
#define NUM 16

Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUM, PIN);

uint8_t  mode   = 0, // Current animation effect
offset = 0; // Position of spinny eyes
uint32_t color  = 0x0000ff; // Start red
uint32_t prevTime;

float rcurr;
float gcurr;
float bcurr;

void setup() {
  pixels.begin();
  //  pixels.setBrightness(60); // 1/3 brightness
  prevTime = millis();
  randomSeed(analogRead(0));

  //  updateAll(0,0,0xff);
  rcurr=0;
  gcurr=0;
  bcurr=255;

}

#define MAXBLUE 0xff
#define MINBLUE 100

#define MINBRIGHT 20
#define MAXBRIGHT 95

#define BLENDSTEPS 8

void loop() {
  uint8_t  c;

  // Pick a new color to fade to
  float rnew=random(0,180);
  float gnew=random(0,255);
  float bnew=random(100,255);

  // compute color steps to reach new color
  float rstep=(rnew-rcurr)/float(BLENDSTEPS);
  float gstep=(gnew-gcurr)/float(BLENDSTEPS);
  float bstep=(bnew-bcurr)/float(BLENDSTEPS);

  for(float inc=0; inc<BLENDSTEPS;inc++){
    float r=rcurr+(inc*rstep);
    float g=gcurr+(inc*gstep);
    float b=bcurr+(inc*bstep);  

    //    float minBr = min(MINBRIGHT,min(r,min(g,b)));
    //    float maxBr = MAXBRIGHT; //max(MAXBRIGHT,max(r,max(g,b)));

    updateAll(r,g,b);
    for(c = MINBRIGHT; c<= MAXBRIGHT; c++){
      pixels.setBrightness(c);
//      for(uint8_t l=0; l< NUM; l++){
//          pixels.setPixelColor(l, r+random(0,10), g+random(0,10), b+random(0,30));
//      }
      // Pixel "glitter" effect to make it look more gritty
      for(uint8_t l=0; l< 3; l++){
          pixels.setPixelColor(random(0,NUM), r+random(0,5), g+random(0,20), b+random(0,20));
      }

      pixels.show();
//      delay(12);
      delay(3);
    }
    for(c=MAXBRIGHT; c>= MINBRIGHT; c--){
      pixels.setBrightness(c);
      // Pixel "glitter" effect to make it look more gritty
      for(uint8_t l=0; l< 3; l++){
          pixels.setPixelColor(random(0,NUM), r+random(0,5), g+random(0,20), b+random(0,20));
      }
      pixels.show();
//      delay(10);
      delay(3);
    }
  }
  rcurr=rnew;
  gcurr=gnew;
  bcurr=bnew;

}


// Make all the pixels the same color
void updateAll(float r, float g, float b){
  for(uint8_t l=0; l< NUM; l++){
    pixels.setPixelColor(l, r, g, b);
    //    pixels.setPixelColor(l, r+random(0,20), g+random(0,20), b+random(0,20));
  }  
}


/*
*
 * 
 * 
 * switch(mode) {
 * 
 * case 0: // Random sparks - just one LED on at a time!
 * i = random(32);
 * pixels.setPixelColor(i, color);
 * pixels.show();
 * delay(10);
 * pixels.setPixelColor(i, 0);
 * break;
 * 
 * case 1: // Spinny wheels (8 LEDs on at a time)
 * for(i=0; i<16; i++) {
 * uint32_t c = 0;
 * if(((offset + i) & 7) < 2) c = color; // 4 pixels on...
 * pixels.setPixelColor(   i, c); // First eye
 * pixels.setPixelColor(31-i, c); // Second eye (flipped)
 * }
 * pixels.show();
 * offset++;
 * delay(50);
 * break;
 * }
 * 
 * t = millis();
 * if((t - prevTime) > 8000) {      // Every 8 seconds...
 * mode++;                        // Next mode
 * if(mode > 1) {                 // End of modes?
 * mode = 0;                    // Start modes over
 * color >>= 8;                 // Next color R->G->B
 * if(!color) color = 0xffae00; // Reset to red
 * }
 * for(i=0; i<32; i++) pixels.setPixelColor(i, 0);
 * prevTime = t;
 * }
 * 
 **/











