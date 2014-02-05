size(1024,768);
int numDimensions=6;
float radius=300;

background(255);
translate(width/2,height/2);

beginShape();
for(int i=0; i<numDimensions; i++) {
  float theta=radians(i*360.0/numDimensions);
  float x=cos(theta)*radius;
  float y=sin(theta)*radius;
  vertex(x,y);
}
endShape(CLOSE);

ellipseMode(RADIUS);
noFill();
ellipse(0,0,radius,radius);
