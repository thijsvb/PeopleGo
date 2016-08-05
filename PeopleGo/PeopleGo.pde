import android.os.Environment;

import ketai.sensors.*;
KetaiLocation location;

import ketai.ui.*;
import android.view.MotionEvent;
KetaiGesture gesture;

import ketai.camera.*;
KetaiCamera cam;

String[] info;
int nPeople;

Person[] people;

PFont Lato;

PVector[] nearbyCords;
int encounter;
boolean shoot = false;

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
  gesture = new KetaiGesture(this);
  cam = new KetaiCamera(this, int(height), int(width), 30);

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

  if (!shoot) {    
    background(0, 255, 128);
    noStroke();
    fill(0, 255, 128);
    if (location.getProvider() == "none") {
      text("GPS!", width/2, height/2);
      return;
    }

    int[] distances = new int[nPeople];
    int nNearby = 0;
    encounter = -1;

    for (int i=0; i!=nPeople; ++i) {
      distances[i] = people[i].distance(location);
      if (distances[i] <= 100) {                      //TEST VALUE!!!!!!!!!!!!!
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

    if (encounter != -1) {
      if (people[encounter].found) {
        fill(66, 106, 108);
      } else {
        fill(255);
      }
      textAlign(CENTER, CENTER);
      textSize(width/10);
      text(people[encounter].name, width/2, height/6);
    }

    fill(255);
    rect(width/20, height/3, width*9/10, height, width/40);

    fill(66, 106, 108);
    textAlign(CENTER, TOP);
    textSize(width/20);
    text("NEARBY", width/2, height/3+width/20);
    rect(width/3, height/3+width*3/20, width/3, 10, 5);
    textAlign(CENTER, CENTER);
    for (int i=0; i!=nNearby; ++i) {
      if (i == 6) {
        return;
      }
      text(people[nearby[i]].letter + ": " + people[nearby[i]].distance(location) + "m", nearbyCords[i].x, nearbyCords[i].y);
    }
  } else {
    if (cam.isStarted()) {
      pushMatrix();
      rotate(PI/2);
      cam.resize(height, width);
      image(cam, 0, -width);
      popMatrix();
      image(people[encounter].img, width/4, height/2-width/4);
      fill(240, 255, 240, 192);
      noStroke();
      ellipse(width/2, height-height/8, height/8, height/8);
      fill(240, 255, 240);
      stroke(66, 106, 108);
      strokeWeight(3);
      ellipse(width/2, height-height/8, height/10, height/10);
      noStroke();
      fill(66, 106, 108);
      ellipse(width/8, height-width/8, width/8, width/8);
      stroke(0, 255, 128);
      ellipse(width/8, height-width/8, width/10, width/10);
      pushMatrix();
      translate(width/8, height-width/8);
      line(-width/60, -width/60, width/60, width/60);
      line(-width/60, width/60, width/60, -width/60);
      popMatrix();
    }
  }
}

void onTap(float x, float y) {
  if (encounter != -1 && y < height/3 && !shoot) {
    shoot = true;
    cam.start();
  } else if (shoot && x < width/4 && y > height-width/4) {
    shoot = false;
    cam.stop();
  } else if (shoot && x < width/2 + width/20 && x > width/2 - width/20 && y > height-width/8-width/20) {
    pushMatrix();
    rotate(PI/2);
    cam.resize(height, width);
    image(cam, 0, -width);
    popMatrix();
    image(people[encounter].img, width/4, height/2-width/4);
    try {
      String folder = Environment.getExternalStorageDirectory().getAbsolutePath()+"/PeopleGo/";
      String filename = new File(folder, people[encounter].name + ".png").getAbsolutePath();
      save(filename);
      println("yay");
    } 
    catch(Exception e) {
      println(e);
    }
  }
}

void onCameraPreviewEvent() {
  cam.read();
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
    img.resize(width/2, width/2);
  }

  int distance(KetaiLocation kloc) {
    return int(kloc.getLocation().distanceTo(loc));
  }
}

//Keep touch events updated and forward them
public boolean surfaceTouchEvent(MotionEvent event) {
  super.surfaceTouchEvent(event);
  return gesture.surfaceTouchEvent(event);
}