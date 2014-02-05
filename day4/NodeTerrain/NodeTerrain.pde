// This tool was used to create a watertight 3D model of the
// network cluster created by the /day3/TwitterCity3D exercise
// We're loading an exported network layout text file and
// placing the nodes within a terrain, which is then smoothed
// and exported as 3D STL model for fabrication

import processing.opengl.*;

import toxi.geom.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.processing.*;

// file name of layout file
String LAYOUT_NAME="justin bieber20101014-11-55-54";

// terrain resolution
float GRID_SIZE=10;

// scale factor for elevations
float ELEVATION_SCALE=4;

// max physical terrain size in mm
float MAX_TERRAIN_SIZE=200;

ToxiclibsSupport gfx;
TriangleMesh mesh;

void setup() {
  size(1024,700,OPENGL);
  gfx=new ToxiclibsSupport(this);

  List<Vec3D> nodes=new ArrayList<Vec3D>();
  // those 2 vectors will contain the bounds
  // of the imported network
  Vec2D minV=Vec2D.MAX_VALUE.copy();
  Vec2D maxV=Vec2D.MIN_VALUE.copy();
  String[] layout=loadStrings(LAYOUT_NAME+".txt");
  // iterate over all lines (nodes) in the layout file
  for(String l : layout) {
    // isolate into x,y & height values
    if (l.length()>0) {
      String[] props=split(l,',');
      Vec3D p=new Vec3D(float(props[0]),float(props[1]),float(props[2]));
      nodes.add(p);
      // update bounds
      minV.x=min(minV.x,p.x);
      minV.y=min(minV.y,p.y);
      maxV.x=max(maxV.x,p.x);
      maxV.y=max(maxV.y,p.y);
    }
  }
  // use network bounds to compute terrain size
  // the variables contain the number of grid cells
  int terrainW=(int)((maxV.x-minV.x)/GRID_SIZE)+1;
  int terrainH=(int)((maxV.y-minV.y)/GRID_SIZE)+1;
  println("terrain size: "+terrainW+"x"+terrainH+" cells");
  // now create an array for storing elevation data
  // required to form a terrain
  float[] elevation=new float[terrainW*terrainH];
  // iterate over all imported nodes
  // and map their world location to a terrain cell
  for(Vec3D p : nodes) {
    // local position with in the network bounds
    Vec2D posInNetwork=new Vec2D(p.x-minV.x,p.y-minV.y);
    // scale down to terrain size
    posInNetwork.scaleSelf(1.0/GRID_SIZE);
    int tx=(int)posInNetwork.x;
    int ty=(int)posInNetwork.y;
    // compute array index
    // (we're storing 2D data in a 1D array, just like pixels)
    int idx=ty*terrainW+tx;
    elevation[idx]=p.z*ELEVATION_SCALE;
  }
  // create the actual terrain from the elevation array
  Terrain terrain=new Terrain(terrainW,terrainH,GRID_SIZE);
  terrain.setElevation(elevation);
  // turn into watertight 3D mesh
  mesh=terrain.toMesh(-20);
  // scale to fit physical size (longest edge)
  float scaleFactor;
  if (terrainW>terrainH) {
    scaleFactor=MAX_TERRAIN_SIZE/(terrainW*GRID_SIZE);
  } else {
    scaleFactor=MAX_TERRAIN_SIZE/(terrainH*GRID_SIZE);
  }
  println("scaling terrain to: "+nf(scaleFactor,1,2));
  mesh.scale(scaleFactor);
  println("mesh bounds: "+mesh.getBoundingBox());
  // convert mesh into Winged-Edge mesh structure
  // needed for smoothing operation
  mesh=new WETriangleMesh().addMesh(mesh);
  // apply 6x smoothing of all vertices
  new LaplacianSmooth().filter((WETriangleMesh)mesh,6);
  // save STL file into sketch folder
  mesh.saveAsSTL(sketchPath(LAYOUT_NAME+"-scale"+nf(scaleFactor,1,2)+".stl"));
}

void draw() {
  background(0);
  lights();
  translate(width/2,height/2,0);
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  noStroke();
  gfx.mesh(mesh);
}
