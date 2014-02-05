// this class stores data points for a single person/slice
// the data elements are stored within a HashMap and
// arranged in a circular manner for visualization purposes
class DataSlice {
  // slice name (e.g. person)
  String name;
  // name based container for original data
  HashMap<String,Float> props=new HashMap<String,Float>();
  // list of points for visualization
  Vec2D[] vertices;
  
  // max value of a slice
  float maxValue;
  
  public DataSlice(String line, String[] fields) {
    // separate line into individual elements
    String[] items=split(line,',');
    // 1st element = name
    name=items[0];
    // create storage for vertices
    vertices=new Vec2D[items.length-1];
    // iterate over all data items
    for(int i=1; i<items.length; i++) {
      float count=float(items[i]);
      // update maxValue if needed
      if (count>maxValue) {
        maxValue=count;
      }
      // store reference with field name in hashmap
      props.put(fields[i],count);
      // calculate vertex position (using polar coordinates)
      float radius=count;
      float theta=i*TWO_PI/(items.length-1);
      // store vertex position (as regular cartesian)
      vertices[i-1]=new Vec2D(radius+10,theta).toCartesian();
    }
  }

  // scales the vertices using the given factor 
  public void scale(float normFactor) {
    for(Vec2D p : vertices) {
      p.scaleSelf(normFactor);
    }
  }
}
