import processing.opengl.*;

import toxi.util.*;
import java.awt.FileDialog;
import toxi.math.*;

List<HistogramWord> uniqueWords;

ZoomLensInterpolation zoomLens = new ZoomLensInterpolation();

float smoothStep=0.2;

int gap=10;
int labelGap=150;
int wordLimit=500;

HistogramSorter sortFunction;

void setup() {
  size(1024,600);
  initHistogram();
}

void draw() {
  float maxBarHeight=height-labelGap-20;
  float normFactor=maxBarHeight/sortFunction.getMetric(uniqueWords.get(0));
  float focalPos=map(mouseX,gap,width-gap,0.0,1.0);
  zoomLens.setLensPos(focalPos,smoothStep);
  zoomLens.setLensStrength(map(mouseY,0,height,-1,+1),smoothStep);
  int focalX=(int)zoomLens.interpolate(gap, width-gap, focalPos);
  background(255);
  noStroke();
  textAlign(RIGHT);
  fill(0);
  int space=10;
  int maxWords=min(uniqueWords.size(),wordLimit);
  for(int i=0; i<maxWords; i++) {
    float relativePos=(float)i/maxWords;
    HistogramWord w=uniqueWords.get(i);
    float barHeight=sortFunction.getMetric(w)*normFactor;
    int x=(int)zoomLens.interpolate(gap, width-gap, relativePos);
    int x2=(int)zoomLens.interpolate(gap, width-gap, (float)(i+1)/maxWords);
    int barWidth=max(x2-x-1,1);
    int barCenter=(x+x2)/2;
    if (abs(barCenter-focalX)<=barWidth/2) {
      fill(255,0,255);
    } else {
      fill(0);
    }
    rect((int)x,height-labelGap-barHeight-10,barWidth,barHeight);
    float ts=min(x2-x,18);
    if (ts>3) {
      textSize(ts);
      pushMatrix();
      translate(barCenter+ts/4,height-labelGap);
      rotate(-HALF_PI);
      text("("+sortFunction.getMetric(w)+") "+w.word,0,0);
      popMatrix();
    }
  } 
}

void initHistogram() {
  // use toxiclibs FileUtils to display a file chooser
  String fileName=FileUtils.showFileDialog(
    frame,
    "Choose a text file...",
    dataPath(""),
    new String[]{".txt",".rtf",".xml"},
    FileDialog.LOAD
  );
  // if user pressed cancel, use default file
  if (fileName==null) {
    fileName="bible.txt";
  }
  String[] lines= loadStrings(fileName);

  int totalWordCount =0;
  HashMap<String,Integer> histogram=new HashMap<String,Integer>();
  for(int i=0; i<lines.length; i++) {
    //quand c'est un multiple de 1000 il va diviser par 1000
    if(0==i %1000) {
      println("processing line : " +i);
    }
   //ne pas prendre en compte la ponctuation
   String[] words=splitTokens(lines[i]," ,./?!:():;'\"-&");

   //si le mot est encore inconnu met se mot à la valeur 1
   for(String w : words) {
     totalWordCount++;
     w=w.toLowerCase();
     if(histogram.get(w)==null){
       histogram.put(w,1);
       println("new word: "+w);
     } else {
       //augmente le mot de 1
       histogram.put(w,histogram.get(w)+1);
     }
   }
  }
  println("----\nstatistics:");
  println("total: "+totalWordCount);
  println("unique: "+histogram.size());

  uniqueWords=new ArrayList<HistogramWord>();
  for(String w : histogram.keySet()) {
    HistogramWord hw=new HistogramWord(w,histogram.get(w));
    uniqueWords.add(hw);
  }
  setSortFunction(new FrequencyComparator());
  for(int i=0; i<1000; i++) {
    println(uniqueWords.get(i).word.length());
  }
}

void keyPressed() {
  if (key=='f') {
    setSortFunction(new FrequencyComparator());
  }
  if (key=='l') {
    setSortFunction(new WordLengthComparator());
  }
}

// DONT REPEAT YOURSELF!
void setSortFunction(HistogramSorter s) {
  sortFunction=s;
  Collections.sort(uniqueWords,sortFunction);
}
