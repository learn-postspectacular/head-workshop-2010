import toxi.color.*;
import toxi.color.theory.*;
import toxi.geom.*;

import processing.opengl.*;

// number of data axes
int numDimensions;
// max radius of visualization
float maxRadius=300;

float averageRadius;

// storage for loaded data items
DataItem[] samples;

// color gradient mapper
ToneMap palette;

void setup() {
  size(1024,768,OPENGL);
  // load text file from data folder
  String[] lines=loadStrings("data.csv");
  // number of samples = number of lines in file
  numDimensions=lines.length;
  samples=new DataItem[numDimensions];
  // maxValue will contain largest data value
  int maxValue=0;
  // totalSum is used to compute average
  float totalSum=0;
  for(int i=0; i<numDimensions; i++) {
    // parse a single line
    String[] items=split(lines[i],',');
    DataItem data=new DataItem(items[0],int(items[1]));
    samples[i]=data;
    // update max value, if needed
    if (data.count>maxValue) {
      maxValue=data.count;
    }
    totalSum+=data.count;
  }
  // compute scale factor to match maxRadius setting
  float normFactor=(float)maxRadius/maxValue;
  // compute average data value
  averageRadius=totalSum/numDimensions*normFactor;
  // set vertex positions (using polar coordinates)
  for(int i=0; i<numDimensions; i++) {
    float radius=float(samples[i].count)*normFactor;
    float theta=radians(i*360.0/numDimensions);
    samples[i].setPosition(theta,radius);
  }
  // create color palette
  ColorGradient grad=new ColorGradient();
  grad.addColorAt(0,NamedColor.PINK);
  grad.addColorAt(128,NamedColor.CYAN);
  grad.addColorAt(255,NamedColor.YELLOW);
  // create a map for the number interval: 0 -> maxRadius
  // any value within that interval will be mapped to a color on the gradient
  palette=new ToneMap(0,maxRadius,grad);
}

void draw() {
  background(255);
  noStroke();
  translate(width/2,height/2);
  // render polygon as triangle fan
  beginShape(TRIANGLE_FAN);
  // center point will have start color of gradient
  fill(palette.getARGBToneFor(0));
  vertex(0,0);
  // use supersampling to iterate over all data points
  // but only use data values for every 2nd iteration
  // all odd indices will be mapped to the average radius
  // that will give us additional information and improve
  // legibility & meaning of this visualization
  for(int i=0; i<=(numDimensions*2); i++) {
      // check if index is even?
      // and ensure last vertex is connected to first
    int j=i;
    if (j==numDimensions*2) {
      j=0;
    }
    // if even, to use data points
    if (0==(j % 2)) {
      DataItem d=samples[j/2];
      fill(palette.getARGBToneFor(d.pos.x));
      Vec2D p=d.pos.copy().toCartesian();
      vertex(p.x,p.y);
    } else {
      // else use average radius
      float theta=radians(i*360.0/(numDimensions*2));
      fill(palette.getARGBToneFor(averageRadius));
      Vec2D p=new Vec2D(averageRadius,theta).toCartesian();
      vertex(p.x,p.y);
    }
  }
  endShape(CLOSE);
  // show the label for each data
  for(int i=0; i<numDimensions; i++) {
    DataItem d=samples[i];
    d.drawLabel();
  }
  // draw average value as circle overlay
  noFill();
  stroke(0);
  ellipseMode(RADIUS);
  ellipse(0,0,averageRadius,averageRadius);
}

