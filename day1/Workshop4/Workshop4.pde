// source data based on this spreadsheet:
// https://spreadsheets.google.com/ccc?key=0AuTvi4zFIJ3kdFVrcXJtc3pXMkVYRmtZYlJlRXZRSUE&hl=en_GB#gid=0
import toxi.processing.*;

import toxi.data.csv.*;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.geom.*;
import toxi.geom.mesh.*;

import processing.opengl.*;

// number of data axes
int numSlices;

// max radius of visualization
float maxRadius=300;
// gap between slices (in 3D)
float sliceWidth=50;

// storage for loaded data items
DataSlice[] samples;

// Helper library for drawing geometry
ToxiclibsSupport gfx;

// Mesh container
TriangleMesh mesh;

void setup() {
  size(1024,768,OPENGL);
  gfx=new ToxiclibsSupport(this);
  // load text file from data folder
  String[] lines=loadStrings("workshop_stats.csv");
  // first line of CSV file only contains the field names
  // of the spreadsheet
  String[] fields=split(lines[0],',');
  // number of samples = number of lines in file
  numSlices=lines.length-1;
  // create storage for all slices
  samples=new DataSlice[numSlices];
  // globalMaxValue will contain max value of ALL slices
  float globalMaxValue=0;
  for(int i=1; i<=numSlices; i++) {
    // create a data slice of each CSV line
    DataSlice data=new DataSlice(lines[i],fields);
    // update max value, if needed
    if (data.maxValue>globalMaxValue) {
      globalMaxValue=data.maxValue;
    }
    // store for later
    samples[i-1]=data;
  }
  // now we know the absolute peak and can compute
  // global scale factor to match defined maxRadius
  float normFactor=(float)maxRadius/globalMaxValue;
  // scale all slices accordingly
  for(DataSlice item : samples) {
    item.scale(normFactor);
  }
  // create new mesh container
  mesh=new TriangleMesh();
  // iterate over all slices
  for(int i=0; i<numSlices-1; i++) {
    // connect each slice with its successor
    // curr = vertices of current slice
    Vec2D[] curr=samples[i].vertices;
    // next = vertices of next slice
    Vec2D[] next=samples[i+1].vertices;
    // calculate offsets of each slice
    Vec3D currOffset=new Vec3D(0,0,i*sliceWidth);
    Vec3D nextOffset=new Vec3D(0,0,(i+1)*sliceWidth);
    // iterate over all points of the polygons
    for(int j=0; j<curr.length; j++) {
      int id=j+1;
      if (id==curr.length) {
        id=0;
      }
      /*
       * Create triangle faces in
       * counter clockwise order:
       * Triangle 1: A->B->C
       * Triangle 2: C->B->D
       *
       * C     D
       * +-----+ === next slice (i+1)
       * | \   |
       * |  \  |
       * |   \ |
       * |    \|
       * +-----+ === curr slice (i)
       * A     B
       */
      // compute the 4 points in 3D space
      Vec3D a=curr[j].to3DXY().addSelf(currOffset);
      Vec3D b=curr[id].to3DXY().addSelf(currOffset);
      Vec3D c=next[j].to3DXY().addSelf(nextOffset);
      Vec3D d=next[id].to3DXY().addSelf(nextOffset);
      // create mesh faces (see sketch in comments above)
      mesh.addFace(a,b,c);
      mesh.addFace(c,b,d);
    }
  }
  // center mesh around world origin
  mesh.center(null);
  // save mesh as STL file
  mesh.saveAsSTL(sketchPath("monday.stl"));
}

void draw() {
  background(255);
  lights();
  fill(255,0,0);
  // move world origin to center of screen plane
  // and force Processing into 3D mode (by specifying Z coordinate)
  translate(width/2,height/2,0);
  // link camera view to mouse position
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  // draw mesh
  gfx.mesh(mesh);
}

