import ketai.sensors.*;
KetaiLocation location;

String[] info;
int nPeople;

Person[] people;

void setup() {
  orientation(PORTRAIT);
  fullScreen();
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
  if (location.getProvider() == "none") {
    text("GPS!", width/2, height/2);
    return;
  }

  float distance = round(location.getLocation().distanceTo(people[0].loc));
  text(distance, width/2, height/2);
}

class Person {
  String name;
  Location loc;
  PImage img;

  Person(String Name, Location Loc, PImage Img) {
    name = Name;
    loc = Loc;
    img = Img;
  }
}