size(1024,768);
int numDimensions;
float radius;

background(255);
translate(width/2,height/2);
fill(255,0,0);

String[] lines=loadStrings("data.csv");
numDimensions=lines.length;

// Don't Repeat Yourself = DRY
float[] xpos=new float[numDimensions];
float[] ypos=new float[numDimensions];
String[] labels=new String[numDimensions];

beginShape();
for(int i=0; i<numDimensions; i++) {
  String[] items=split(lines[i],',');
  radius=float(items[1])*30;
  float theta=radians(i*360.0/numDimensions);
  float x=cos(theta)*radius;
  float y=sin(theta)*radius;
  vertex(x,y);
  // store values
  xpos[i]=x;
  ypos[i]=y;
  labels[i]=items[0];
}
endShape(CLOSE);

for(int i=0; i<numDimensions; i++) {
  pushMatrix();
  translate(xpos[i],ypos[i]);
  float theta=radians(i*360.0/numDimensions);
  if(theta>HALF_PI && theta<1.5*PI) {
    theta+=PI;
    textAlign(RIGHT);
  } else {
    textAlign(LEFT);
  }
  rotate(theta);
  text("  "+labels[i]+"  ",0,0);
  popMatrix();
}
