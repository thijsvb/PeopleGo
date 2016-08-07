//Import and initialize a KetaiLocation
import ketai.sensors.*;
KetaiLocation location;

//Import and initialize stuff for detecting taps
import ketai.ui.*;
import android.view.MotionEvent;
KetaiGesture gesture;

//Import and initialize camera stuff
import ketai.camera.*;
KetaiCamera cam;

//These will be used to load info about people from the info.txt file
String[] info;
int nPeople;

//This array will store that info (the Person class is at the bottom of this file)
Person[] people;

//Make a font, Lato is the open-source font used by Pokémon GO. Get it at www.latofonts.com
PFont Lato;

//This will store the coordinates where the nearby distances are displayed, I put them in an array to easily loop through them
PVector[] nearbyCords;
//This will store the person we are encountering, or -1 when there's no person close enough
int encounter;
//shoot as in shoot a picture, of the person you're encountering
boolean shoot = false;
//I need these to pause the frame when you take a picture of a person, you'll then have to take a screenshot. This is a stupid way of doing it, but unfortunatly the save() function doesn't work (yet) in Processing for Android. See this issue: https://github.com/processing/processing-android/issues/146
boolean screenshot = false;
float time;
//These distances are in meters, they're here so you can easily change them
final float encounterDist = 5;  //distance to a person when you can encounter and find them
final float nearbyDist = 200;  //distace to a persen when the show up on your nearby screen

void setup() {
  orientation(PORTRAIT);
  fullScreen();
  Lato = createFont("Lato-Regular.ttf", 32);
  textFont(Lato);

  //The nearby coordinates, there are six, that seems enough to me
  nearbyCords = new PVector[]{
    new PVector(width/3, height/2), 
    new PVector(width*2/3, height/2), 
    new PVector(width/3, height*2/3), 
    new PVector(width*2/3, height*2/3), 
    new PVector(width/3, height*5/6), 
    new PVector(width*2/3, height*5/6)
  };
  
  //All these need to be defined, note the camera's width and height are swapped, because it assumes to be in landscape
  location = new KetaiLocation(this);
  gesture = new KetaiGesture(this);
  cam = new KetaiCamera(this, int(height), int(width), 30);
  
  //get info from the info.txt file, the number of lines should be the number of people
  info = loadStrings("info.txt");
  nPeople = info.length;
  people = new Person[nPeople];
  
  //put all the info in the people array, each line of info.txt should follow this pattern: "name,latitude,longitude"
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
  //As mentioned before, this is stupid but save() doesn't work :(
  if (screenshot) {  
    //Showing the camera takes some rotation and stuff, because it assumes to be landscape
    pushMatrix();
    rotate(PI/2);
    cam.resize(height, width);
    image(cam, 0, -width);
    popMatrix();
    image(people[encounter].img, width/4, height/2-width/4);
  
    //Ten seconds should be enough to take a screenshot
    if (millis()-time >= 10000) {
      screenshot = false;
    }
    return;
  }
  
  //Everything in this if statement is needed when searching for people
  if (!shoot) {    
    background(0, 255, 128);
    noStroke();
    fill(0, 255, 128);
    //You should turn on your GPS
    if (location.getProvider() == "none") {
      text("GPS!", width/2, height/2);
      return;
    }
    
    //I'm going to store the distances in an array, so they don't change within draw(), also it helpes with looking for nearby people
    int[] distances = new int[nPeople];
    //The number of nearby people
    int nNearby = 0;
    //The person you encounter, only one person at a time, -1 means nobody
    encounter = -1;
  
    //Look who's nearby or whitin encounter distance
    for (int i=0; i!=nPeople; ++i) {
      distances[i] = people[i].distance(location);
      if (distances[i] <= encounterDist) {
        encounter = i;
      }
      if (distances[i] <= nearbyDist) {
        ++nNearby;
      }
    }
    
    //Sort to get the closest distances
    int[] sortDist = sort(distances);
    //Array to store all nearby people
    int[] nearby = new int[nNearby];
    
    //Look what distance corrospondes to what person. This means you'll see a person twice when there are two people the same distance away from you, but that chance is small enough to not figure out a better way to do this 
    for (int i=0; i!=nNearby; ++i) {
      for (int j=0; j!=nPeople; ++j) {

        if (sortDist[i] == distances[j]) {
          nearby[i] = j;
        }
      }
    }
    
    //When you encounter someone, show it. Use a different color for a person you've already found, altough this data isn't stored and will be lost when you close the app
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
    
    //The nearby screen
    fill(255);
    rect(width/20, height/3, width*9/10, height, width/40);

    fill(66, 106, 108);
    textAlign(CENTER, TOP);
    textSize(width/20);
    text("NEARBY", width/2, height/3+width/20);
    rect(width/3, height/3+width*3/20, width/3, 10, 5);
    textAlign(CENTER, CENTER);
    //Show all the nearby people (only their first letter), and your distance to them
    for (int i=0; i!=nNearby; ++i) {
      if (i == 6) {
        return;
      }
      text(people[nearby[i]].letter + ": " + people[nearby[i]].distance(location) + "m", nearbyCords[i].x, nearbyCords[i].y);
    }
  }
  //Now for when you are encountering a person
  else {
    //Prevent camera bugs by only doing stuff when the camera is started
    if (cam.isStarted()) {
      //Show the camera view
      pushMatrix();
      rotate(PI/2);
      cam.resize(height, width);
      image(cam, 0, -width);
      popMatrix();
      //Add a person on top of it
      image(people[encounter].img, width/4, height/2-width/4);
      
      //Main picture button
      fill(240, 255, 240, 192);
      noStroke();
      ellipse(width/2, height-height/8, height/8, height/8);
      fill(240, 255, 240);
      stroke(66, 106, 108);
      strokeWeight(3);
      ellipse(width/2, height-height/8, height/10, height/10);
      //Close button
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

//This function is called by the Ketai library, when it detects a tap
void onTap(float x, float y) {
  //When you encounter someone and tap their name
  if (encounter != -1 && y < height/3 && !shoot) {
    shoot = true;
    cam.start();
  } 
  //When you are encountering someone and tap the close button
  else if (shoot && x < width/4 && y > height-width/4) {
    shoot = false;
    cam.stop();
  } 
  //When you are encountering someone and tap the shoot button
  else if (shoot && x < width/2 + width/20 && x > width/2 - width/20 && y > height-(height/8+height/20)) {
    people[encounter].found = true;
    screenshot = true;
    time = millis();
  }
}

void onCameraPreviewEvent() {
  //Don't read the camera when you're taking a screenshot, this way the image will freeze
  if (!screenshot) {
    cam.read();
  }
}

class Person {
  String name;
  char letter;
  Location loc;
  PImage img;
  //At first, found will always be false. It becomes true when you find someone
  boolean found = false;

  Person(String Name, Location Loc, PImage Img) {
    //Load everything, the letter is just the first letter of someones name, resize the image now
    name = Name;
    letter = name.charAt(0);
    loc = Loc;
    img = Img;
    img.resize(width/2, width/2);
  }
  
  //This prevented me from having to type way to much whenever I wanted the distance to a person
  int distance(KetaiLocation kloc) {
    return int(kloc.getLocation().distanceTo(loc));
  }
}

//Keep touch events updated and forward them
public boolean surfaceTouchEvent(MotionEvent event) {
  super.surfaceTouchEvent(event);
  return gesture.surfaceTouchEvent(event);
}