void initPhysics() {
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(0,0,width*2,height*2));
  List<VerletParticle2D> anchors=new ArrayList<VerletParticle2D>();
  List<Float> clusterSizes=new ArrayList<Float>();
  for(HashMap<Long,Tweet> results : clusterResults) {
    // turn hashmap into temporary list and sort chronologically
    List<Tweet> tweets=new ArrayList<Tweet>(results.values());
    Collections.sort(tweets, new TweetComparator());
    VerletParticle2D anchor=null;
    // iterate over all tweets of sorted list
    List<VerletParticle2D> clusterParticles=new ArrayList<VerletParticle2D>();
    TColor col=TColor.newHSV(random(1),random(0.85,1),random(0.7,1));
    float circumference=tweets.size()*NODE_RADIUS*2;
    float clusterRadius=circumference/PI/2;
    clusterSizes.add(clusterRadius);
    for(int i=0; i<tweets.size(); i++) {
      int nodeHeight=tweets.get(i).getText().length();
      println("node height: "+nodeHeight);
      // create new particle
      Node p = new Node(random(width), random(height),tweets.get(i),col,nodeHeight);
      // add to physics simulation
      physics.addParticle(p);
      // keep hold of it temporarily
      clusterParticles.add(p);
      if (i==0) {
        anchor=p;
        anchors.add(p);
      } else {
        // spring to centre node of the cluster
        VerletSpring2D s=new VerletSpring2D(anchor,p,clusterRadius,0.1);
        physics.addSpring(s);
        for(int j=1; j<i; j++) {
          s=new VerletMinDistanceSpring2D(p,clusterParticles.get(j),NODE_RADIUS*2,0.1);
          physics.addSpring(s);
        }
      }
    }
  }
  // connect all cluster centre nodes with each other
  for(int i=0; i<anchors.size()-1; i++) {
    for(int j=i+1; j<anchors.size(); j++) {
      float distance=clusterSizes.get(i)+clusterSizes.get(j)+NODE_RADIUS*3;
      VerletSpring2D s=new VerletSpring2D(anchors.get(i),anchors.get(j),distance,0.1);
      physics.addSpring(s);
    }
  }
}

