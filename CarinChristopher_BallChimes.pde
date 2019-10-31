/*
Ball Chimes by Christopher Carin
Due date: Oct 1, 2019

 
 This is a project based on the Mondrian mode of the Din is Noise software synthesizer.
 There's a lot of functionality I wish I had time to add to this, but alas, this is what I have so far.
 Control the bright blue ball with the left mouse button and use it to bounce of walls and other balls to create
 random melodies. Use the right mouse button to slow all the balls down.
 
 Here is an example of the Din is Noise version:
 https://www.youtube.com/watch?v=xowLVPumgxg
 
 One thing to note is that balls in DIN do not bounce off of each other.
 
 Write up in retrospect:
 The initial work I shared on Sept. 10 was actually already made in Processing. It was webcam 'filter of sorts' which spliced footage of from two different webcam sources
 based on volume levels received by webcam's microphone input. The first webcam source was the ordinary MacBook webcam located above the monitor. The second source was a logitech 
 webcam pointed directly at the monitor. As the first webcam would capture the users the image, the second webcam would capture the analog image produced by the first webcam. The 
 result when splicing the two footages together was a very dreamy, digital, surreal, and dynamic image to look at. Extended periods of looking at it would actually give me headaches.
 Nonetheless the image was quite entrancing to look at. I wasn't really quite sure where else to go with that piece of work. The piece had already been inspired by an exploration of
 objects with USB connectivity. I guess what I wanted to retain from it was the sense of surrealism and dreaminess that it exuded.
 
 When I first came into this class, I was trying to program some moving ball physics for fun. After getting it working, it kind of reminded me of some software called Din is Noise, a 
 software synthesizer I had the pleasure of trying out over the summer. DIN is synth which specializes in drones and soundscapes. I figured if I could reproduce the sort of sounds DIN creates, 
 it could themetically match the dreamy & hazy feelings my webcam filter exuded.
 
 It took a while to get the physics working exactly how I wanted and there's still a lot that can be done visually to further emphasize the link between the two works, but I'm honestly pretty
 happy with what this sketch currently does.
 
 I remember Zev saying that this project is really about where we are as designers right now. What honestly has me interested the most is simply the computer's ability to generate an endless
 amount of ideas. I really love the idea of algorithmic music composition (so much so that when I do try to write music most is based on randomized loops/microloops). Benn Jordan (aka 
 The Flashbulb) said something along the lines of 'getting a computer to sing to is really a labour of one's own love for those things'. That may be a very wrong paraphrase but still,
 the idea resonates with me.
 
 List of resources reviewed during this project:
 https://processing.org/reference/libraries/sound/SinOsc.html [SinOsc Example]
 https://processing.org/reference/libraries/sound/Env.html [Env Example]
 https://www.youtube.com/watch?v=guWIF87CmBg&t [Billiard Ball Example]
 https://processing.org/examples/circlecollision.html [Circle Collision Example]
 https://www.youtube.com/watch?v=7eBLAgT0yUs [PVector to Mouse Example]
 
 The following resources were also used in for personal reference:
 
 Daniel Shiffman's "The Nature of Code 1: Vectors series"
 https://www.youtube.com/watch?v=mWJkvxQXIa8&list=PLRqwX-V7Uu6ZwSmtE13iJBcoI-r4y7iEc
 
 Khan Academy's "Visually adding and subtracting vectors"
 https://www.youtube.com/watch?v=BsBH8nAv5l4
 
 The Organic Chemistry Tutor's "Conservation of Momentum In Two Dimensions - 2D Elastic & Inelastic Collisions - Physics Problems"
 https://www.youtube.com/watch?v=9YRgHikdcqs
 
 Bugs:
 Ball on ball collision is buggy (might be fixed)
 Sound randomly crashes
 
 TODO maybe eventually (in order of perceived difficulty):
 ADSR Control
 Ability to control any ball of choice
 Ability to add/remove balls (implementing arraylists could probably do this)
 Amplitude based on momentum (mass/velocity)
 Friction/Gravity settings (currently everything is an elastic collission)
 Midi/OSC control
 Expand/Shrink/Add/Remove Walls
 Webcam based FFT visualizer
 */

/* 
 ding library (sinosc, env)
 sound code based off of [SinOsc Example] & [Env Example]
 */
import processing.sound.*;

ball[] Ball;
impact[] hit;
int totalBalls = 40;
// set amount of balls here (must always have at least 1; around 50+ the program will no longer load consitently)
PVector[] randomPt = new PVector[totalBalls]; // vector for initial points of the balls
float[] mScale = {261.63, 311.13, 349.23, 392.00, 466.16}; // c-major pentatonic's frequencies
// feel free to change the frequencies to whatever scale/chord/combination you want. 
// note zones on the walls are based on array length.

float attackTime = 0.001; // ADSR settings
float sustainTime = 0.5;
float sustainLevel = 2.0;
float releaseTime = 0.5;

float amp;

void setup() {
  size(800, 800); // not having width and height be equal makes the scale array a little bit more annoying
  background(0);
  Ball = new ball[totalBalls];
  hit = new impact[totalBalls];
  amp = 1.0/totalBalls;

  // set randomPt
  for (int i = 0; i < totalBalls; i++) {
    randomPt[i] = new PVector(random(width), random(height)); // initialize randomPt
  }
  for (int j = 0; j < totalBalls; j++) {
    ;
    for (int k = 0; k < totalBalls; k++) {
      while (randomPt[j].dist(randomPt[k]) < 100 && j != k) {    // j != k ensures ball doesn't check against itself
        randomPt[j] = new PVector(random(width), random(height)); // double check that everything is at least 100px apart (randomPt[j].dist(randomPt[k]) < 100). If it is re-randomize.
        k = 0;
      }
    }
  }

// initialize balls and impacts
  for (int i = 0; i < totalBalls; i++) {
    Ball[i] = new ball(new SinOsc(this), new Env(this), randomPt[i], mScale, amp);
    hit[i] = new impact(Ball[i].pos);
  }
  Ball[0].col = #03FFCA; // controlled ball is blue
}

void draw() {
  clear();
  drawGrid();
  for (int j = 0; j < totalBalls; j++) { // run through all balls
    Ball[j].move();
    if (Ball[j].wallCollision()) {
      hit[j] = new impact(Ball[j].pos.copy());
    }
    for (int k = 0; k < totalBalls; k++) { // check current ball against every other ball
      if (j != k) Ball[j].ballCollision(Ball[k]); // j != k is so the ball doesn't check against itself (avoid self-collision)
    }
    hit[j].update();
    Ball[0].gotoMouse();
    Ball[j].brake();
    hit[j].display();
    Ball[j].display();
    helpScreen();
  }
}
