// this example is using Christopher Warnow's SunflowAPIAPI wrapper
// for the Sunflow opensource renderer
//
// http://sunflow.sf.net
// http://sunflowapiapi.googlecode.com
//
// The Sunflow JAR files are located in the /code folder of this sketch
// The SunflowAPIAPI library is bundled in the "put into libraries" folder
// (one level up from this sketch)
//
// For file size reasons, this sketch does NOT include the referenced
// terrain mesh, but you can regenerate it by running the NodeTerrain example

import toxi.geom.*;
import toxi.geom.mesh.*;

import java.awt.Color;
import com.briansteen.SunflowAPIAPI;

int sceneWidth = 1280;
int sceneHeight = 720;

void setup() {
  
  // load a binary STL model
  toxi.geom.mesh.TriangleMesh mesh;
  mesh=(toxi.geom.mesh.TriangleMesh)(
    new STLReader().loadBinary(
      dataPath("terrain.stl"),
      STLReader.TRIANGLEMESH)
  );
  
  // get all the mesh's vertices and faces as arrays
  float[] vertices=mesh.getUniqueVerticesAsArray();
  int[] faces=mesh.getFacesAsArray();
  
  // create a new sunflow instance and configure it
  SunflowAPIAPI sunflow = new SunflowAPIAPI();
  sunflow.setWidth(sceneWidth);
  sunflow.setHeight(sceneHeight);
  
  // set anti-aliasing preferences (powers of 4)
  sunflow.setAaMin(0);
  sunflow.setAaMax(1);
  
  // create lights and camera
  sunflow.setSunSkyLight("mySunskyLight");
  sunflow.setCameraPosition(50,120,250);
  sunflow.setCameraTarget(-5,0,0);
  sunflow.setThinlensCamera("thinLensCamera", 50f, (float)sceneWidth/sceneHeight);
  
  // create a mirrored ground plane
  sunflow.setMirrorShader("dark",new Color(128,128,136));
  // plane is located in the XZ plane
  sunflow.drawPlane("ground", new Point3(0,-8,0), new Vector3(0,1,0)); 
  
  // create a shader for the mesh and add it to the scene
  sunflow.setShinyDiffuseShader("myShinyShader", new Color(255,230,234), .66f);
  sunflow.drawMesh("terrain",vertices,faces);
  
  // choose a sunflow light simulation engine
  sunflow.setPathTracingGIEngine(64);
  
  // render the scene and save as PNG
  sunflow.render(sketchPath("twitter_terrain-"+sceneWidth+"x"+sceneHeight+".png"));
  exit();
}

