#include <string.h>
#include <math.h>

#define WIDTH 80
#define HEIGHT 24
#define TORUS 0.06
#define RING 0.2
#define XROT 0.2
#define YROT 0.4

asm("li sp, 0xFFFF; j main");
volatile static char *tx = (char *)0x10010;
volatile static char *sx = (char *)0x10018;
const static int size = WIDTH * HEIGHT;

void wait_tx() {
  while (!(*sx&4)) {}
}

void print(char str[]) {
  wait_tx();
  int cnt = 0;
  while (!(*sx&4)) {}
  while (str[cnt] != 0)
    *tx = str[cnt++];
}

void clear() {
  print("\x1b[2J");
}

void home() {
  print("\x1b[H");
}

int main() {
  char screen_data[size];
  float buffer_data[size];
  float sin_lut[1024];
  float cos_lut[1024];
  print("Precomputing sin values...\n\r");
  for (int i = 0; i < 1024; i++)
    sin_lut[i] = sin((float)i*6.28/1024.0);
  print("Precomputing cos values...\n\r");
  for (int i = 0; i < 1024; i++)
    cos_lut[i] = cos((float)i*6.28/1024.0);
  print("Done!\n\r");
  float X = 0, Y = 0;
  while (1) {
    memset(&screen_data, ' ', size);
    memset(&buffer_data, 0, size*4);
    float sinX = sin_lut[(int)(X*1024.0/6.28)];
    float cosX = cos_lut[(int)(X*1024.0/6.28)];
    float sinY = sin_lut[(int)(Y*1024.0/6.28)];
    float cosY = cos_lut[(int)(Y*1024.0/6.28)];
    for(float ring = 0; 6.28 > ring; ring += RING) {
      float sinring = sin_lut[(int)(ring*1024.0/6.28)];
      float cosring = cos_lut[(int)(ring*1024.0/6.28)];
      float cosring2 = cosring+2;
      float pr1 = sinring*cosY;
      float pr2 = cosring2*sinY;
      float pr3 = cosring*cosY;
      float pr4 = cosring2*cosY;
      float pr5 = sinring*sinY;
      float pr6 = cosring*sinY;
      float pr7 = pr1+5;
      float pr8 = cosring*sinX;
      for(float torus = 0; 6.28 > torus; torus += TORUS) {
        float sintorus = sin_lut[(int)(torus*1024.0/6.28)];
        float costorus = cos_lut[(int)(torus*1024.0/6.28)];
        float mess = 1/(sintorus*pr2+pr7);
        float t = sintorus*pr4-pr5;
        int x=WIDTH/2+WIDTH*3/8*mess*
        (costorus*cosring2*cosX-t*sinX);
        int y=HEIGHT/2+1+HEIGHT*15/22*mess*
        (costorus*cosring2*sinX+t*cosX);
        int pixel = x+WIDTH*y;
        int N=8*((pr5-sintorus*pr3)*cosX-sintorus*pr6-pr1-costorus*pr8);
        if(HEIGHT>y&&y>0&&x>0&&WIDTH>x&&mess>buffer_data[pixel]){
          buffer_data[pixel]=mess;
          screen_data[pixel]=".,-~:;=!*#$@"[N>0?N:0];
        }
      }
    }
    clear(); home();
    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        wait_tx(); *tx = screen_data[y*WIDTH+x];
      }
      wait_tx(); *tx = '\n'; *tx = '\r';
    }
    X += XROT; Y += YROT;
    if (X > 6.28) X -= 6.28;
    if (Y > 6.28) Y -= 6.28;
  }
}
