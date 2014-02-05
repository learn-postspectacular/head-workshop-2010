import toxi.math.conversion.*;
import toxi.geom.*;
import toxi.math.*;
import toxi.geom.mesh2d.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.math.waves.*;
import toxi.util.*;
import toxi.math.noise.*;

import toxi.physics2d.constraints.*;
import toxi.physics2d.*;

import processing.opengl.*;

String SEARCH_TERM="justin bieber";
int MIN_CLUSTER_SIZE=2;
int NODE_RADIUS=10;

HashMap<Long,Tweet> tweets;
HashSet<String> foundURLs;
List<HashMap<Long,Tweet>> clusterResults;

Twitter twitter = new Twitter("user","pass");

VerletPhysics2D physics;

void setup() {
  size(1024,700,OPENGL);
  tweets=searchTwitter(SEARCH_TERM);
  foundURLs=extractLinks(tweets);
  clusterResults=searchLinks();
  initPhysics();
}

void draw() {
  ellipseMode(RADIUS);
  background(255);
  physics.update();
  stroke(0);
  for(VerletSpring2D s : physics.springs) {
    line(s.a.x,s.a.y,s.b.x,s.b.y);
  }
  noFill();
  stroke(255,0,0);
  for(VerletParticle2D p : physics.particles) {
    ellipse(p.x,p.y,NODE_RADIUS,NODE_RADIUS);
  }
}

void initPhysics() {
  physics=new VerletPhysics2D();
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  List<VerletParticle2D> anchors=new ArrayList<VerletParticle2D>();
  for(HashMap<Long,Tweet> results : clusterResults) {
    // turn hashmap into temporary list and sort chronologically
    List<Tweet> tweets=new ArrayList<Tweet>(results.values());
    Collections.sort(tweets, new TweetComparator());
    VerletParticle2D anchor=null;
    // iterate over all tweets of sorted list
    List<VerletParticle2D> clusterParticles=new ArrayList<VerletParticle2D>();
    for(int i=0; i<tweets.size(); i++) {
      // create new particle
      VerletParticle2D p = new VerletParticle2D(random(width), random(height));
      // add to physics simulation
      physics.addParticle(p);
      // keep hold of it temporarily
      clusterParticles.add(p);
      if (i==0) {
        anchor=p;
        anchors.add(p);
      } else {
        VerletSpring2D s=new VerletSpring2D(anchor,p,NODE_RADIUS*2,0.1);
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
      VerletSpring2D s=new VerletMinDistanceSpring2D(anchors.get(i),anchors.get(j),NODE_RADIUS*4,0.05);
      physics.addSpring(s);
    }
  }
}

List<HashMap<Long,Tweet>> searchLinks() {
  List<HashMap<Long,Tweet>> rts=new ArrayList<HashMap<Long,Tweet>>();
  for(String url : foundURLs) {
    println("searching retweets for: "+url);
    HashMap<Long,Tweet> results=searchTwitter(url);
    println(results.size()+" tweets found");
    if (results.size()>MIN_CLUSTER_SIZE) {
      rts.add(results);
    }
  }
  return rts;
}

HashSet<String> extractLinks(HashMap<Long,Tweet> tweets) {
  HashSet<String> urls=new HashSet<String>();
  for(Tweet t : tweets.values()) {
    String msg=t.getText();
    String[] words=splitTokens(msg," ,?!();'\"");
    for(String w : words) {
      if (w.indexOf("http://")!=-1 && !urls.contains(w)) {
        // add link to the list of found links
        println("found URL: "+w);
        urls.add(w);
      }
    }
  }
  return urls;
}

HashMap<Long,Tweet> searchTwitter(String searchQuery) {
  HashMap<Long,Tweet> storage=new HashMap<Long,Tweet>();
  Query query = new Query(searchQuery);
  // set max number of search results (max=100)
  //query.rpp(100);
    try {
      QueryResult result = twitter.search(query);
      for (Tweet tweet : result.getTweets()) {
        // first check if ID is unique?
        if (storage.get(tweet.getId())==null) {
          storage.put(tweet.getId(),tweet);
        } else {
          println("skipping: "+tweet.getId());
        }
      }
    } 
    catch(TwitterException e) {
      println(e.getMessage());
    }
    return storage;
  }
