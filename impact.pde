// class for expanding circle animation for when balls hit walls
class impact {
  PVector p;
  int maxSize = 300;
  float d;
  
  impact(PVector p_) {
    p = p_;
    d = 0; // re-initialize to 0 on ball impact (re-construct)
  }
  
  void update(){
    if (d < maxSize) {
      d+=5; // if ball is less than its max size, make it bigger
    }
  }
  
  void display() {
    if (d < maxSize) { // only display when circle doesn't reach max size
      noFill();
      stroke(255, 500-(500*(d/maxSize))); // opacity lowers as circle expands
      strokeWeight(2);
      ellipse(p.x,p.y,d,d);
    }
  }
}
