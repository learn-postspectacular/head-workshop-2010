// utility class to sort tweets by age
class TweetComparator implements Comparator<Tweet> {
  
  int compare(Tweet a, Tweet b) {
    return (int)(a.getCreatedAt().getTime()-b.getCreatedAt().getTime());
  }
}
