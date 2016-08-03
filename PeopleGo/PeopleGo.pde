import ketai.sensors.*;
KetaiLocation location;

final String[] info = loadStrings("info.txt");
final int nPeople = info.length;

String[] names = new String[nPeople];
float[] lat = new float[nPeople];
float[] lon = new float[nPeople];
Person[] people = new Person[nPeople];

void setup() {
  orientation(PORTRAIT);
  fullScreen();
  location = new KetaiLocation(this);

  for (int i=0; i!=nPeople; ++i) {
    names[i] = info[i].substring(0, info[i].indexOf(","));
    lat[i] = float(info[i].substring(info[i].indexOf(",")+1, info[i].indexOf(",", info[i].indexOf(",")+1)));
    if (Float.isNaN(lat[i])) {
      println("Person " + i + " has a wrong latitude");
    }
    lon[i] = float(info[i].substring(info[i].indexOf(",", info[i].indexOf(",")+1)+1));
    if (Float.isNaN(lon[i])) {
      println("Person " + i + " has a wrong longitude");
    }

    people[i] = new Person(names[i], new Location(names[i]), loadImage(names[i]+".png"));
    people[i].loc.setLatitude(lat[i]);
    people[i].loc.setLongitude(lon[i]);
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