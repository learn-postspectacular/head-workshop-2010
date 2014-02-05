class DataItem {
  String label;
  int count;
  Vec2D pos;
  Vec2D labelPos;
  
  public DataItem(String label, int count) {
    this.label=label;
    this.count=count;
  }

  public void setPosition(float theta, float radius) {
    pos=new Vec2D(radius,theta);
    labelPos=new Vec2D(radius+20,theta);
  }

  public void drawLabel() {
    pushMatrix();
    Vec2D p=labelPos.copy().toCartesian();
    translate(p.x,p.y);
    float t=labelPos.y;
    if(t>HALF_PI && t<1.5*PI) {
      t+=PI;
      textAlign(RIGHT);
    } 
    else {
      textAlign(LEFT);
    }
    rotate(t);
    text(label,0,0);
    popMatrix();
  }
}

