// this function is creating the earth mesh and erodes it
// at the locations of the earth quakes
// the mesh is created volumetrically using the toxiclibs
// voxel engine and isosurface classes
void initEarthMesh() {
  VolumetricSpace volume=new VolumetricSpaceArray(SCALE,RES,RES,RES);
  VolumetricBrush brush=new RoundBrush(volume,0);
  IsoSurface surface=new ArrayIsoSurface(volume);
  // create the actual world/earth
  brush.setSize(EARTH_RADIUS);
  brush.drawAtAbsolutePos(new Vec3D(),0.5f);
  // destroy the surface
  for(Quake q : quakes) {    
    for(float t=1.0; t>0.5; t-=0.05) {
      brush.setSize(q.depth*EARTH_SCALE*1.5*t);
      brush.drawAtAbsolutePos(q.loc.scale(t),-0.5f);
    }
  }
  volume.closeSides();
  mesh=(TriangleMesh)surface.computeSurfaceMesh(new TriangleMesh(),0.25f);
}

// this function computes texture coordinates
// for the generated earth mesh
void calcTextureCoordinates() {
  for(Face f : mesh.getFaces()) {
    f.uvA=calcUV(f.a);
    f.uvB=calcUV(f.b);
    f.uvC=calcUV(f.c);
  }
}

// compute a 2D texture coordinate from a 3D point on a sphere
// this function will be applied to all mesh vertices
Vec2D calcUV(Vec3D p) {
  Vec3D s=p.copy().toSpherical();
  Vec2D uv=new Vec2D(s.y/TWO_PI+LON_OFFSET,1-(s.z/PI+0.5));
  // make sure longitude is always within 0.0 ... 1.0 interval
  if (uv.x<0) uv.x+=1;
  else if (uv.x>1) uv.x-=1;
  return uv;
}

