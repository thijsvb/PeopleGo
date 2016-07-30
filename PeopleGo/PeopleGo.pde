import ketai.sensors.*;
KetaiLocation location;

Person person;

void setup() {
  orientation(PORTRAIT);
  fullScreen();
  location = new KetaiLocation(this);
  person = new Person("Bob", new Location("Bob"), loadImage("Bob.png"));
  person.loc.setLatitude(52.101385);
  person.loc.setLongitude(5.772528);
}

void draw() {
  if(location.getProvider() == "none"){
    text("GPS!",width/2,height/2);
    return;
  }
  
  float distance = round(location.getLocation().distanceTo(person.loc));
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