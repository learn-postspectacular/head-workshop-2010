// custom physics particle which also contains
// further display information and a reference to
// the original tweet this node represents
class Node extends VerletParticle2D {
  
  Tweet tweet;
  TColor col;
  int height;
  
  Node(float x, float y, Tweet t, TColor c, int h) {
    super(x,y);
    col=c;
    height=h;
  }
}

// export all nodes as CSV text file
void saveNodes() {
  String layout="";
  for(VerletParticle2D p : physics.particles) {
    Node node=(Node)p;
    layout+=node.x+","+node.y+","+node.height+"\n";
  }
  String fileName=SEARCH_TERM+DateUtils.timeStamp()+".txt";
  saveStrings(fileName,new String[]{ layout });
  println("saved: "+fileName);
}
