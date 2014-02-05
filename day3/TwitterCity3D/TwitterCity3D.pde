// This sketch is first executing a twitter search and then
// displays a network of tweets (and re-tweets) for all links
// found in the original search results...
//
// CAUTION: Heavy use of this tool can get you banned from Twitter API
//
// This exercise makes heavy use of the most common Java collection
// classes as well as uses the toxiclibs physics engine to create a
// force directed layout and network clusters

import toxi.color.*;
import toxi.color.theory.*;
import toxi.processing.*;
import toxi.geom.*;
import toxi.util.*;
import toxi.physics2d.constraints.*;
import toxi.physics2d.*;

import processing.opengl.*;

String SEARCH_TERM="#design";
int MIN_CLUSTER_SIZE=2;
int NODE_RADIUS=10;

HashMap<Long,Tweet> tweets;
HashSet<String> foundURLs;
List<HashMap<Long,Tweet>> clusterResults;

Twitter twitter = new Twitter("user","pass");

VerletPhysics2D physics;

ToxiclibsSupport gfx;

void setup() {
  size(1024,700,OPENGL);
  gfx=new ToxiclibsSupport(this);
  tweets=searchTwitter(SEARCH_TERM);
  foundURLs=extractLinks(tweets);
  clusterResults=searchLinks();
  initPhysics();
}

void draw() {
  ellipseMode(RADIUS);
  background(255);
  lights();
  physics.update();
  Vec2D centroid=new Vec2D();
  for(VerletParticle2D p : physics.particles) {
    centroid.addSelf(p);
  }
  centroid.scaleSelf(1f/physics.particles.size());
  camera(centroid.x+0,centroid.y+500,500, centroid.x, centroid.y, 100, 0,1,0);
  stroke(0);
  for(VerletSpring2D s : physics.springs) {
    line(s.a.x,s.a.y,0,s.b.x,s.b.y,0);
  }
  noStroke();
  for(VerletParticle2D p : physics.particles) {
    Node node=(Node)p;
    Cone c=new Cone(new Vec3D(p.x,p.y,node.height*2/2),new Vec3D(0,0,1),NODE_RADIUS,NODE_RADIUS,node.height*2);
    fill(node.col.toARGB());
    gfx.mesh(c.toMesh(4));
  }
}

List<HashMap<Long,Tweet>> searchLinks() {
  List<HashMap<Long,Tweet>> rts=new ArrayList<HashMap<Long,Tweet>>();
  for(String url : foundURLs) {
    println("searching retweets for: "+url);
    HashMap<Long,Tweet> results=searchTwitter(url);
    println(results.size()+" tweets found");
    if (results.size()>=MIN_CLUSTER_SIZE) {
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
  query.rpp(100);
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
