import org.monome.Monome;
import oscP5.*;

Monome g;
int[][] grid_led = new int[16][16];
boolean grid_dirty = true;

Monome a;
int arc_numLeds = 64;  // Number of LEDs in each encoder ring
int[] arc_led = new int[arc_numLeds];
int[] arc_positions = new int[4];  // Track each encoder's position (0 to 64)
boolean arc_dirty = true;

public void setup() {
//  g = new Monome(this, "m2949672");
//  g = new Monome(this, "m2949672");
  g = new Monome(this);
  a = new Monome(this, "m0000007");
}

public void key(int x, int y, int s) {
  System.out.println("grid key received: " + x + ", " + y + ", " + s);
  if (s == 1) {
    grid_led[y][x] ^= 15;
    grid_dirty = true;
  }
}

public void delta(int n, int d) {
  // Update position
  arc_positions[n] += d;
  arc_positions[n] = constrain(arc_positions[n], 0, arc_numLeds);  // Constrain between 0 and 64
  System.out.println("arc delta received: " + n + ", " + d);
  System.out.println("arc: " + n + " value = " + arc_positions[n]); 
  arc_dirty = true;
}

public void update_arc_leds(int encoderIndex) {
  // Loop through all four encoders
  int[] led = new int[arc_numLeds];  // Create LED array for the encoder

  // Light up LEDs based on the current position
  for (int i = 0; i < arc_positions[encoderIndex]; i++) {
    led[i] = 15;  // Full brightness
  }
  
  // Refresh the LEDs for the encoder
  a.refresh(encoderIndex, led);
}

public void draw(){
  if (grid_dirty) { 
    g.refresh(grid_led);
    grid_dirty = false;
  }
  if (arc_dirty){
    for (int i = 0; i < 4; i++) {
      update_arc_leds(i);
    }
  }
}
