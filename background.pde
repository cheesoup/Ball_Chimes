// background grid
void drawGrid() {
  stroke(100);
  strokeWeight(1);
  for (float i = 0; i < width; i += width/mScale.length) {
    line(i, 0, i, height);
  }
  for (float i = 0; i < height; i += height/mScale.length) {
    line(0, i, width, i);
  }
  fill(0);
  line(0, 0, width, height);
  line(0, height, width, 0);
  square(50, 50, width-100);
}

// help screen
void helpScreen() {
  fill(255);
  if (key == TAB && keyPressed) {
    text("Use the left mouse button to pull the bright blue ball.", 55, 65);
    text("Use the right mouse button to stop all the balls.", 55, 80);
    text("The chimes played when a ball bounces", 55, 95);
    text("off a wall are tuned to C Major Pentatonic.", 55, 110);
    text("NOTE: Ball on ball hit detection is still buggy.", 55, 140);
    text("Also sound randomly crashes sometimes.", 55, 155);
  } else text("Press Tab for help", 55, 65);
}
