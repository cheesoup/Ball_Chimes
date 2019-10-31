class ball {
  int d;
  float m;
  PVector pos, vel, acc, brakes;
  float[] scale;
  color col = color(random(200,255),random(200,255),random(200,255));
  boolean drawLine;
  Env env;
  SinOsc sine;
 
  ball(SinOsc s, Env e, PVector p, float[] sc, float a) {
    sine = s;
    env = e;
    pos = p;
    vel = new PVector();
    acc = new PVector();
    brakes = new PVector();
    d = (int)Math.floor(random(25,50));
    m = d;
    scale = sc;
    sine.amp(a);
  }
 
  // normal move function 
  void move() {
    vel.add(acc);
    pos.add(vel);
    vel.limit(20);
  }
  
  // function to pull circles to the mouse on left click
  // based on [PVector to Mouse Example]
  void gotoMouse() {
     if (mousePressed && mouseButton == LEFT) {
       drawLine = true;
       PVector mouse = new PVector(mouseX, mouseY);
       ellipse(mouse.x,mouse.y,10,10);
       mouse.sub(pos);
       mouse.setMag(1);
       acc = mouse.copy();
       stroke(col);
     } else {
       brakes.setMag(1);
       acc = brakes.copy();
       drawLine = false;
     }
  }
  
  // slow balls down on right mouse click
  void brake() {
    if (mousePressed && mouseButton == RIGHT) {
      vel.mult(0.9);
      if (abs(vel.x) < 0.01 && abs(vel.y) < 0.01) {
        vel = new PVector();
      }
    }
  }
 
 // function for pulling the note frequency out of the float[] scale
  float findFreq(float p) {
    int note = (int)(p/(width/scale.length));
    if (note > scale.length - 1) note = scale.length - 1;
    if (note < 0) note = 0;
    return scale[note];
  }
  
  /*
  ball against ball collision detection
  i still don't completely get the math behind this
  but i'm trying. physics isn't my best subject.
  comments from the example were left in for my own reference.
  refereced from [Circle Collision Example]
  
  some variables were renamed when trying to figure out how this code works
  */
  
  void ballCollision(ball b) {
    PVector dis = PVector.sub(b.pos,pos);
    float mag = dis.mag();
    float minDis = d/2 + b.d/2;

    
    if (mag < minDis) {
      float disCorrection = (minDis - mag)/2;
      PVector d = dis.copy();
      PVector correctionVector = d.normalize().mult(disCorrection);
      b.pos.add(correctionVector);
      pos.sub(correctionVector);
      
      // get angle of distanceVect
      float theta  = dis.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* posTemp will hold rotated ball positions. You 
       just need to worry about posTemp[1] position*/
      PVector[] posTemp = { new PVector(), new PVector() };
      
      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       posTemp[0].position.x and posTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      posTemp[1].x = cosine * dis.x + sine * dis.y;
      posTemp[1].y = cosine * dis.y - sine * dis.x;
      
      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * vel.x + sine * vel.y;
      vTemp[0].y  = cosine * vel.y - sine * vel.x;
      vTemp[1].x  = cosine * b.vel.x + sine * b.vel.y;
      vTemp[1].y  = cosine * b.vel.y - sine * b.vel.x;
      
      // extra hack added to 'hopefully' fix clumping completely (not in original [Circle Collision Example])
      // original math from [Billiard Ball Example] around the 12 min mark.
      float overlap=this.d/2+b.d/2-dist(posTemp[0].x,posTemp[0].y,posTemp[1].x,posTemp[1].y);
      posTemp[0].x+=overlap/2;
      posTemp[1].x+=overlap/2;
      
      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - b.m) * vTemp[0].x + 2 * b.m * vTemp[1].x) / (m + b.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((b.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + b.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      posTemp[0].x += vFinal[0].x;
      posTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] posFinal = { 
        new PVector(), new PVector()
      };

      posFinal[0].x = cosine * posTemp[0].x - sine * posTemp[0].y;
      posFinal[0].y = cosine * posTemp[0].y + sine * posTemp[0].x;
      posFinal[1].x = cosine * posTemp[1].x - sine * posTemp[1].y;
      posFinal[1].y = cosine * posTemp[1].y + sine * posTemp[1].x;

      // update balls to screen position
      posTemp[0].x += (vFinal[0].x );
      posTemp[1].x += (vFinal[1].x );
      
      posTemp[0].y += vFinal[0].y;
      posTemp[1].y += vFinal[1].y;

      pos.add(posFinal[0]);

      // update velocities
      vel.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      vel.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      b.vel.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      b.vel.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }
 
  // reverse acceleration+velocity and play a note when balls hit a wall
  boolean wallCollision() {
    boolean hit = false;
    if (pos.x > width) {
      vel.x *= -1;
      acc.x *= -1;
      pos.x = width - 1;
      sine.freq(findFreq(pos.y));
      sine.play();
      env.play(sine, attackTime, sustainTime, sustainLevel, releaseTime);
      hit = true;
    } else if (pos.x < 0) {
      vel.x *= -1;
      acc.x *= -1;
      pos.x = 1;
      sine.freq(findFreq(pos.y));
      sine.play();
      env.play(sine, attackTime, sustainTime, sustainLevel, releaseTime);
      hit = true;
    }
    if (pos.y > height) {
      vel.y *= -1;
      acc.y *= -1;
      pos.y = height - 1;
      sine.freq(findFreq(pos.x));
      sine.play();
      env.play(sine, attackTime, sustainTime, sustainLevel, releaseTime);
      hit = true;
    } else if (pos.y < 0) {
      vel.y *= -1;
      acc.y *= -1;
      pos.y = 1;
      sine.freq(findFreq(pos.x));
      sine.play();
      env.play(sine, attackTime, sustainTime, sustainLevel, releaseTime);
      hit = true;
    }
    
    return hit;
  }
 
  void display() { // visualz
    strokeWeight(3);
    stroke(255);
    if (drawLine) line(mouseX,mouseY,pos.x,pos.y);
    fill(col);
    strokeWeight(0);
    ellipse(pos.x, pos.y, d, d);
  }
}
