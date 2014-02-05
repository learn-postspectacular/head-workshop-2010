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

import toxi.processing.*;

import processing.opengl.*;

final String SEARCH_QUERY="4sq";
final int TIME_STEP = 1;
final int NUM_SEARCHES = 10;

// number of ms per day
final long DAY_DURATION = 1000*60*60*24;

Twitter twitter = new Twitter("user","pass");

HashMap<Long,Tweet> tweets=new HashMap<Long,Tweet>();

ToxiclibsSupport gfx;

void setup() {
  size(1024,700,OPENGL);
  gfx=new ToxiclibsSupport(this);
  searchTwitter(SEARCH_QUERY);
}

void searchTwitter(String searchQuery) {
  Query query = new Query(searchQuery);
  query.rpp(100);
  Date referenceDate=new Date();
  for(int i=0; i<NUM_SEARCHES; i++) {
    String d=new SimpleDateFormat("yyyy-MM-dd").format(referenceDate);
    println("executing search for date: "+d);
    query.until(d);
    // execute search
    try {
      QueryResult result = twitter.search(query);
      for (Tweet tweet : result.getTweets()) {
        // first check if ID is unique?
        if (tweets.get(tweet.getId())==null) {
          // filter out tweets with GPS loc
          GeoLocation loc=tweet.getGeoLocation();
          if (loc!=null) {
            tweets.put(tweet.getId(),tweet);
            println("adding tweet: "+tweet);
          }
        } else {
          println("skipping: "+tweet.getId());
        }
      }
    } 
    catch(TwitterException e) {
      println(e.getMessage());
    }
    referenceDate.setTime(referenceDate.getTime()-TIME_STEP*DAY_DURATION);
  }
}

void draw() {
  background(0);
  fill(255);
  lights();
  translate(width/2,height/2,0);
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  gfx.origin(300);
  sphere(200);
  // iterate over all collected tweets
  for(Tweet tweet : tweets.values()) {
    GeoLocation loc=tweet.getGeoLocation();
    // convert geo location into cartesian world coordinates
    Vec3D p=new Vec3D(200,radians((float)loc.getLongitude())-HALF_PI,radians((float)loc.getLatitude())).toCartesian();
    // create a box at the computed position
    AABB box=new AABB(p,2);
    noStroke();
    fill(255,0,0);
    // draw box at position
    gfx.box(box);
    //text(loc.getLatitude()+";"+loc.getLongitude(),p.x,p.y,p.z);
  }
}

