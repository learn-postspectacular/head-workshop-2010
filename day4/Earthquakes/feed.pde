// this function is using the ROME library to initialize the data feed
// see usage examples at:
// http://georss.geonames.org/
//
void initFeed() {
  try {
    SyndFeedInput input = new SyndFeedInput();
    SyndFeed feed = input.build(new XmlReader(openStream(FEED_URL)));
    List<SyndEntry> entries = feed.getEntries();
    // convert all feed entries into Quake instances
    for (SyndEntry entry : entries) {
        Position pos = GeoRSSUtils.getGeoRSS(entry).getPosition();
        Quake q=new Quake(
          (float)pos.getLatitude(),
          (float)pos.getLongitude(),
          entry
        );
        quakes.add(q);
    }
  }
  catch (Exception ex) {
    ex.printStackTrace();
  } 
}
