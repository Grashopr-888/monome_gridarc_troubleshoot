import org.monome.Monome;
import oscP5.*;

Monome m;
int[] positions;  // Track each encoder's position (0 to 64)
int numLeds = 64;  // Number of LEDs in each encoder ring
float[] rotationSpeeds;  // Track rotation speeds for each encoder's object
float[] angles;  // Track the rotation angle for each encoder's object
int[] objectTypes;  // Store the type of object for each encoder
color[] bgColors;  // Store background colors for each object

PVector[] objectSizes;  // Store object sizes for each encoder

public void setup() {
  size(800, 800, P3D);  // Set up 3D canvas for 3D rendering
  
  // Initialize Monome with correct serial number
  println("Initializing Monome with serial number: m0000007");
  m = new Monome(this, "m0000007");
  
  if (m == null) {
    println("Monome object failed to initialize");
  } else {
    println("Monome object initialized successfully");
  }
  
  positions = new int[4];  // Track positions for 4 encoders
  rotationSpeeds = new float[4];  // Store rotation speed for each object
  angles = new float[4];  // Rotation angles for each object
  objectTypes = new int[4];  // Type of object for each encoder
  bgColors = new color[4];  // Background color for each object
  objectSizes = new PVector[4];  // Store the object size for each encoder
  
  // Initialize default values
  for (int i = 0; i < 4; i++) {
    rotationSpeeds[i] = 0.01;  // Default slow rotation
    angles[i] = 0;
    objectTypes[i] = int(random(3));  // Random object type
    bgColors[i] = color(random(255), random(255), random(255));  // Random color
    objectSizes[i] = new PVector(50, 50, 50);  // Default size
    println("Initialized encoder " + i);
  }
}

public void draw() {
  background(0);  // Set black background
  lights();  // Enable lighting

  // Loop through all four encoders
  for (int i = 0; i < 4; i++) {
    // Update rotation angle based on each encoder's rotation speed
    angles[i] += rotationSpeeds[i];

    // Draw objects in their respective quadrants
    pushMatrix();
    
    // Set the position for each object to different quadrants
    if (i == 0) {
      translate(width * 0.25, height * 0.25, 0);  // Top-left quadrant
    } else if (i == 1) {
      translate(width * 0.75, height * 0.25, 0);  // Top-right quadrant
    } else if (i == 2) {
      translate(width * 0.25, height * 0.75, 0);  // Bottom-left quadrant
    } else if (i == 3) {
      translate(width * 0.75, height * 0.75, 0);  // Bottom-right quadrant
    }
    
    // Set background color for each object
    fill(bgColors[i]);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, width / 2, height / 2);  // Draw background in each quadrant
    
    // Rotate the object
    rotateY(angles[i]);
    rotateX(angles[i] * 0.5);
    
    // Draw the object based on the current type and size
    drawObject(i, objectSizes[i].x);  // Use encoder position to determine size
    
    popMatrix();
    
    // Update the LEDs to reflect the encoder position
    updateLEDs(i);
  }
}

// Draw the current object for each encoder
public void drawObject(int encoderIndex, float size) {
  switch (objectTypes[encoderIndex]) {
    case 0:
      box(size);
      break;
    case 1:
      sphere(size / 2);
      break;
    case 2:
      drawCone(size / 2, 0, size * 1.5);
      break;
  }
}

// Update the LEDs for each encoder based on the position (0 to 64)
public void updateLEDs(int encoderIndex) {
  int[] led = new int[numLeds];  // Create LED array for the encoder
  
  // Light up LEDs based on the current position
  for (int i = 0; i < positions[encoderIndex]; i++) {
    led[i] = 15;  // Full brightness
  }
  
  // Refresh the LEDs for the encoder
  m.refresh(encoderIndex, led);
  println("Refreshing LEDs for encoder " + encoderIndex + " with position " + positions[encoderIndex]);
}

// Handle encoder rotation (delta)
public void delta(int n, int d) {
  // n = encoder index, d = delta (change in rotation)
  println("Encoder " + n + " rotated by " + d);  // Log encoder activity
  
  // Update position
  positions[n] += d;
  positions[n] = constrain(positions[n], 0, numLeds);  // Constrain between 0 and 64
  
  // Update the size of the object based on the encoder's position
  objectSizes[n].x = positions[n] * 5;  // Scale based on position
  
  // If the encoder reaches the maximum position (64), start rapid rotation
  if (positions[n] == 64) {
    rotationSpeeds[n] = 0.2;  // Rapid rotation speed
  } else {
    rotationSpeeds[n] = 0.01;  // Slow rotation speed
  }
  
  // Print the encoder position to the console
  println("Encoder " + n + " moved. New position: " + positions[n]);
}

// Handle encoder button presses
public void key(int n, int s) {
  // If button is pressed (s = 1), generate a new object for this encoder
  if (s == 1) {
    println("Encoder " + n + " pressed. Generating new object.");
    objectTypes[n] = int(random(3));  // Random object type
    bgColors[n] = color(random(255), random(255), random(255));  // Random background color
    rotationSpeeds[n] = 0.01;  // Reset rotation speed
    angles[n] = 0;  // Reset rotation angle
  }
}

// Custom function to draw a cone in Processing
public void drawCone(float r1, float r2, float h) {
  beginShape(TRIANGLE_STRIP);
  for (float i = 0; i < TWO_PI; i += 0.1) {
    float x1 = r1 * cos(i);
    float y1 = r1 * sin(i);
    float x2 = r2 * cos(i);
    float y2 = r2 * sin(i);
    vertex(x1, y1, 0);
    vertex(x2, y2, h);
  }
  endShape();
}
