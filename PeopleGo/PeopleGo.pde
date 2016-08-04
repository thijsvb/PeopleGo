import ketai.sensors.*;
KetaiLocation location;

String[] info;
int nPeople;

Person[] people;

PFont Lato;

void setup() {
  orientation(PORTRAIT);
  fullScreen();
  Lato = createFont("Lato-Regular.ttf", 32);
  textFont(Lato);
  textSize(width/10);
  
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
  if (location.getProvider() == "none") {
    text("GPS!", width/2, height/2);
    return;
  }

  noStroke();
  fill(255);
  rect(width/20, height/3, width*9/10, height, width/40);

  fill(0);
  text(people[0].letter + ": " + people[0].distance(location) + "m", width/20, height/2);
}

class Person {
  String name;
  char letter;
  Location loc;
  PImage img;

  Person(String Name, Location Loc, PImage Img) {
    name = Name;
    letter = name.charAt(0);
    loc = Loc;
    img = Img;
  }
  
  int distance(KetaiLocation kloc){
    return int(kloc.getLocation().distanceTo(loc));
  }
}