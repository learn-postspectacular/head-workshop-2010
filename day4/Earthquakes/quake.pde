// this simple class is storing details about the loaded earth quakes
class Quake {
  
  // 3D position
  Vec3D loc;
  // 2D screen positions
  Vec2D screenPos=new Vec2D();
  Vec2D labelPos=new Vec2D();
  // reference to the original feed entry structure
  SyndEntry entry;
  // extracted depth of epi centre
  float depth;
  // visibility flag
  boolean isVisible;
  
  Quake(float lat, float lon, SyndEntry e) {
    entry=e;
    // transform lat/lon coordinates into cartesian space
    loc=new Vec3D(EARTH_RADIUS/2,radians(lon),radians(lat)).toCartesian();
    // do some scraping of the feed text to extract depth value
    String raw=entry.getDescription().getValue();
    int idx=raw.indexOf(DEPTH_PREFIX);
    if (idx!=-1) {
      int startIdx=idx+DEPTH_PREFIX.length();
      String rawPos=raw.substring(startIdx,startIdx+8);
      depth=float(rawPos.substring(0,rawPos.indexOf(" ")));
    }
  }
}
