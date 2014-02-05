class DataItem {
  String label;
  int count;
  float x,y;
  float lx,ly;
  float theta,radius;
  float labelRadius;
  
  public DataItem(String label, int count) {
    this.label=label;
    this.count=count;
  }

  public void setPosition(float theta, float radius) {
    x=cos(theta)*radius;
    y=sin(theta)*radius;
    this.theta=theta;
    this.radius=radius;
    this.labelRadius=radius+20;
    lx=cos(theta)*labelRadius;
    ly=sin(theta)*labelRadius;
  }

  public void drawLabel() {
    pushMatrix();
    translate(lx,ly);
    float t=theta;
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

