import ketai.sensors.*;
KetaiLocation location;

String[] info;
int nPeople;

Person[] people;

PFont Lato;

PVector[] nearbyCords;
int encounter = -1;

void setup() {
  orientation(PORTRAIT);
  fullScreen();
  Lato = createFont("Lato-Regular.ttf", 32);
  textFont(Lato);

  nearbyCords = new PVector[]{
    new PVector(width/3, height/2), 
    new PVector(width*2/3, height/2), 
    new PVector(width/3, height*2/3), 
    new PVector(width*2/3, height*2/3), 
    new PVector(width/3, height*5/6), 
    new PVector(width*2/3, height*5/6)
  };

  location = new KetaiLocation(this);

  info = loadStrings("info.txt");
  nPeople = info.length;
  people = new Person[nPeople];

  for (int i=0; i!=nPeople; ++i) {
    String name = info[i].substring(0, info[i].indexOf(","));
    float lat = float(info[i].substring(info[i].indexOf(",")+1, info[i].indexOf(",", info[i].indexOf(",")+1)));
    if (Float.isNaN(lat)) {
      println("Person " + i + " has a wrong latitude");
    }
    float lon = float(info[i].substring(info[i].indexOf(",", info[i].indexOf(",")+1)+1));
    if (Float.isNaN(lon)) {
      println("Person " + i + " has a wrong longitude");
    }

    people[i] = new Person(name, new Location(name), loadImage(name+".png"));
    people[i].loc.setLatitude(lat);
    people[i].loc.setLongitude(lon);
  }
}

void draw() {
  background(0, 255, 128);
  noStroke();
  fill(0, 255, 128);
  if (location.getProvider() == "none") {
    text("GPS!", width/2, height/2);
    return;
  }

  int[] distances = new int[nPeople];
  int nNearby = 0;

  for (int i=0; i!=nPeople; ++i) {
    distances[i] = people[i].distance(location);
    if(distances[i] <= 5){
      encounter = i;
    }
    if (distances[i] <= 200) {
      ++nNearby;
    }
  }

  int[] sortDist = sort(distances);
  int[] nearby = new int[nNearby];

  for (int i=0; i!=nNearby; ++i) {
    for (int j=0; j!=nPeople; ++j) {

      if (sortDist[i] == distances[j]) {
        nearby[i] = j;
      }
    }
  }
  
  if(encounter != -1){
    if(people[encounter].found){
      fill(0, 255, 128);
    } else {
      fill(66, 106, 108);
    }
    textAlign(CENTER, CENTER);
    text(people[encounter].name, width/2, width/6);
  }

  fill(255);
  rect(width/20, height/3, width*9/10, height, width/40);

  fill(66, 106, 108);
  textAlign(CENTER, TOP);
  textSize(width/20);
  text("NEARBY", width/2, height/3+width/20);
  rect(width/3, height/3+width*3/20, width/3, 10, 5);
  textAlign(CENTER, CENTER);
  for(int i=0; i!=nNearby; ++i){
    if(i == 6){return;}
    text(people[nearby[i]].letter + ": " + people[nearby[i]].distance(location) + "m", nearbyCords[i].x, nearbyCords[i].y);
  }
}

class Person {
  String name;
  char letter;
  Location loc;
  PImage img;
  boolean found = false;

  Person(String Name, Location Loc, PImage Img) {
    name = Name;
    letter = name.charAt(0);
    loc = Loc;
    img = Img;
  }

  int distance(KetaiLocation kloc) {
    return int(kloc.getLocation().distanceTo(loc));
  }
}