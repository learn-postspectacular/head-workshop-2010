// number of data axes
int numDimensions;
// max radius of visualization
float maxRadius=300;
float averageRadius;

// storage for loaded data items
DataItem[] samples;

void setup() {
  size(1024,768);
  // load text file from data folder
  String[] lines=loadStrings("data.csv");
  // number of samples = number of lines in file
  numDimensions=lines.length;
  samples=new DataItem[numDimensions];
  int maxValue=0;
  float totalSum=0;
  for(int i=0; i<numDimensions; i++) {
    String[] items=split(lines[i],',');
    DataItem data=new DataItem(items[0],int(items[1]));
    samples[i]=data;
    if (data.count>maxValue) {
      maxValue=data.count;
    }
    totalSum+=data.count;
  }
  float normFactor=(float)maxRadius/maxValue;
  averageRadius=totalSum/numDimensions*normFactor;
  for(int i=0; i<numDimensions; i++) {
    float radius=float(samples[i].count)*normFactor;
    float theta=radians(i*360.0/numDimensions);
    samples[i].setPosition(theta,radius);
  }
}

void draw() {
  background(255);
  translate(width/2,height/2);
  fill(255,0,0);
  beginShape();
  for(int i=0; i<(numDimensions*2); i++) {
    if (0==(i % 2)) {
    DataItem d=samples[i/2];
    vertex(d.x,d.y);
    } else {
      float theta=radians(i*360.0/(numDimensions*2));
      float x=cos(theta)*averageRadius;
      float y=sin(theta)*averageRadius;
      vertex(x,y);
    }
  }
  endShape(CLOSE);
  for(int i=0; i<numDimensions; i++) {
    DataItem d=samples[i];
    d.drawLabel();
  }
  noFill();
  ellipseMode(RADIUS);
  ellipse(0,0,averageRadius,averageRadius);
}

