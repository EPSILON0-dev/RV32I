// Config
#define WIDTH 80
#define HEIGHT 24
#define ITERATIONS_PER_DRAW 1
#define CURSOR_OFF
//#define DOUBLE_WIDTH
//#define RARE_ALIVE

// Game rules                [0][1][2][3][4][5][6][7]
const static char alive[8] = {0, 0, 1, 1, 0, 0, 0, 0};
const static char  dead[8] = {0, 0, 0, 1, 0, 0, 0, 0};

// Core startup
asm("li sp, 0xFFFF; j main");

// Global variables and pointers
volatile static char *tx = (char *)0x10010;
volatile static char *rx = (char *)0x10014;
volatile static char *sx = (char *)0x10018;
const static int size = WIDTH * HEIGHT;

int rand(int seed) {
  int val = seed << 4;
  val ^= seed >> 8;
  val ^= seed << 3;
  val ^= seed << 9;
  return val ^ (seed >> 2);
}

void wait_rx() {
  while (*sx&1) {}
}

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

void cursor_off() {
  print("\x1b[?25l");
}

void home() {
  print("\x1b[H");
}

int main() {

  // Generate variables
  char map[size];
  char val[size];
  int seed = 0;

  // Get the seed
  wait_rx(); seed = *rx;
  wait_rx(); seed = (seed<<8) + *rx;
  wait_rx(); seed = (seed<<16) + *rx;
  wait_rx(); seed = (seed<<24) + *rx;

  // Generate pseudorandom map
  for (int i = 0; i < size; i++)
  #ifdef RARE_ALIVE
    map[i] = ((seed = rand(seed))&15) ? ' ' : '#';
  #else
    map[i] = ((seed = rand(seed))&16) ? '#' : ' ';
  #endif

  // Clear the screen and turn off the cursor
  clear();
  #ifdef CURSOR_OFF
    cursor_off();
  #endif

  // Main game loop
  while (1) {

    // Home the cusror
    home();

    // Draw the map
    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        wait_tx(); *tx = map[y*WIDTH+x];
        #ifdef DOUBLE_WIDTH
          *tx = map[y*WIDTH+x];
        #endif
      }
      wait_tx(); *tx = '\n'; *tx = '\r';
    }

    for (int i = 0; i < ITERATIONS_PER_DRAW; i++) {
      // Get the neighbours number
      for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
          int loc = y*WIDTH+x; val[loc] = 0;
          if (x > 0) { val[loc] += (map[loc-1] == '#');
          if (y > 0) val[loc] += (map[loc-WIDTH-1] == '#');
          if (y < HEIGHT-1) val[loc] += (map[loc+WIDTH-1] == '#'); }
          if (x < WIDTH-1) { val[loc] += (map[loc+1] == '#');
          if (y > 0) val[loc] += (map[loc-WIDTH+1] == '#');
          if (y < HEIGHT-1) val[loc] += (map[loc+WIDTH+1] == '#'); }
          if (y > 0) val[loc] += (map[loc-WIDTH] == '#');
          if (y < HEIGHT-1) val[loc] += (map[loc+WIDTH] == '#');
        }
      }
      // Do the game iteration
      for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
          int loc = y*WIDTH+x;
          if (map[loc] == '#') {
            map[loc] = alive[(int)val[loc]] ? '#' : ' ';
          } else {
            map[loc] = dead[(int)val[loc]] ? '#' : ' ';
          }
        }
      }
    }
  }
}
