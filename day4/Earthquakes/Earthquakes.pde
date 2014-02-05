// This exercise is loading an Atom feed of earthquakes of the past 7 days
// and uses the retrieved information to erode the earth's surface at the
// extracted locations as well as demonstrating a technique for labeling
// positions in 3D space using screenX/screenY.
//
// The feed is loaded using the opensource ROME library and the Geonames.org
// GeoRSS addon:
//
// https://rome.dev.java.net/
// http://georss.geonames.org/
//
// The earth mesh is created volumetrically and then textured using a bitmap
// texture. The texture coordinates are computed using spherical coordinates
//
// Furthermore, this sketch also demonstrates how to use the mouse wheel
// to manipulate display parameters (here zoom factor)

import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;

import processing.opengl.*;

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
import toxi.volume.*;

// earthquake data URL/filename
//String FEED_URL="http://earthquake.usgs.gov/earthquakes/catalogs/7day-M2.5.xml";
String FEED_URL="feed.xml";

// search string used for scraping the depth of a quakes epi center
String DEPTH_PREFIX="Depth</strong>: ";

// resolution of the volumetric space
int RES=32;

// absolute dimensions of the volumetric space
Vec3D SCALE=new Vec3D(500,500,500);

// constants for scaling feed values in relation to real world size
float REAL_EARTH_RADIUS=6365;
float EARTH_RADIUS=SCALE.x*0.8;
float EARTH_SCALE=EARTH_RADIUS/REAL_EARTH_RADIUS;

// texture space offset for longitude
float LON_OFFSET=0.5;

// list to store all quake details in
List<Quake> quakes=new ArrayList<Quake>();

ToxiclibsSupport gfx;
TriangleMesh mesh;

PImage earthImg;

// camera rotation & zoom
Vec2D currRot=new Vec2D();
Vec2D targetRot=new Vec2D();
float targetZoom=1;
float currZoom=targetZoom;

void setup() {
  size(1024,576,OPENGL);
  earthImg=loadImage("earth_1024x512.jpg");
  gfx=new ToxiclibsSupport(this);
  initFeed();
  initEarthMesh();
  calcTextureCoordinates();
  textFont(createFont("SansSerif",9));
  // start listening to mouse wheel changes
  // every time the mouse wheel is moved this code
  // is being run
  addMouseWheelListener(new MouseWheelListener() {
    public void mouseWheelMoved(MouseWheelEvent e) {
	float delta = -e.getWheelRotation()*0.05;
	targetZoom=constrain(targetZoom+delta,0.66,1.75);
    }
  });
}

void draw() {
  // interpolate zoom value towards target
  currZoom+=(targetZoom-currZoom)*0.2;
  background(230);
  fill(255);
  lights();
  // store the default (2d) coordinate system
  pushMatrix();
  // move into 3D and update cam rotation & zoom
  translate(width/2,height/2,0);
  // update cam rotation
  targetRot.set(mouseY*0.01,mouseX*0.01);
  currRot.interpolateToSelf(targetRot,0.2);
  rotateX(currRot.x);
  rotateY(currRot.y);
  scale(currZoom);
  //gfx.origin(300);
  noStroke();
  // draw the textured earth mesh
  textureMode(NORMALIZED);
  beginShape(TRIANGLES);
  texture(earthImg);
  // iterate over all mesh triangles
  // and add their vertices
  for(Face f : mesh.getFaces()) {
    vertex(f.a.x,f.a.y,f.a.z,f.uvA.x,f.uvA.y);
    vertex(f.b.x,f.b.y,f.b.z,f.uvB.x,f.uvB.y);
    vertex(f.c.x,f.c.y,f.c.z,f.uvC.x,f.uvC.y);
  }
  endShape();
  
  // create a matrix reflecting the current camera configuration
  Matrix4x4 mat=new Matrix4x4().rotateX(mouseY*0.01).rotateY(mouseX*0.01).scale(currZoom);
  for(Quake q : quakes) {
    // calculate the transformed quake 3D position
    Vec3D rotQ=mat.applyTo(q.loc).normalize();
    // check if the location is visible
    if (rotQ.dot(Vec3D.Z_AXIS)>0.5) {
      // if so, update the corresponding 2D screen space positions
      Vec3D pos=q.loc;
      q.screenPos.set(screenX(pos.x,pos.y,pos.z), screenY(pos.x,pos.y,pos.z));
      // the label for this quake will be slightly offset from the earth surface
      pos=q.loc.add(q.loc.getNormalizedTo(abs(q.depth)*0.2));
      q.labelPos.set(screenX(pos.x,pos.y,pos.z), screenY(pos.x,pos.y,pos.z));
      // only set label as visible, if within screen bounds
      q.isVisible=(q.labelPos.x>=0 && q.labelPos.x<width && q.labelPos.y>=0 && q.labelPos.y<height);
    } else {
      q.isVisible=false;
    }
  }
  popMatrix();
  // back to 2D...
  // ensure text is always on top of 3D scene
  hint(DISABLE_DEPTH_TEST);
  // draw labels for all visible quakes
  textAlign(CENTER);
  for(Quake q : quakes) {
    if (q.isVisible) {
      stroke(255,0,0);
      gfx.line(new Line2D(q.screenPos,q.labelPos));
      noStroke();
      // calculate the actual width of the label text
      float w=textWidth(q.entry.getTitle());
      fill(255,160);
      rect(q.labelPos.x-4-w/2,q.labelPos.y-10,w+8,14);
      fill(0,128,255);
      text(q.entry.getTitle(),q.labelPos.x,q.labelPos.y);
    }
  }
  // back to normal...
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  if (key==' ') {
    mesh.saveAsSTL(sketchPath("earth.stl"));
  }
}

