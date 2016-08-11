# PeopleGo
People Go is an Android app like Pokémon Go, but instead of Pokémon you catch people. You can enter people with their names, images and location. Then you can make the app to find and make pictures with them.

## How to play
When you are within 200 meters of a person, the first letter of their name and their distance to you shows up on the nearby screen.

<img alt="Nearby" src="Screenshots/Nearby.png" width=400></img>

When you are within 10 meters of a person, you can encounter them.

<img alt="Blue" src="Screenshots/BlueEncounter.png" width=400></img>
<img alt="Green" src="Screenshots/GreenEncounter.png" width=400></img>

When you tap a person you encounter, you can take a picture with them. However, because some functions don't work (yet) in Processing for Android, you then have to take a screenshot to save the image.

<img alt="Shoot" src="Screenshots/GreenShoot.png" width=400></img>

## How to make
To make your own version of the app, you need a couple things:
* [Processing](http://processing.org) with [Android mode](http://android.processing.org)
* The names of the people you want to add
* Pictures of them in `png` format (preferebly with transparent backgrounds)
* The latitude and longitude of the locations you want them to be

#### Step 1
In the `data` folder remove all the images that are in there now.

#### Step 2
Add your own images in the `data` folder. Make sure the images have the names of the people you want to add. For example; when you want to add Bob, you should name the image of Bob `Bob.png`.

#### Step 3
Open the file `info.txt` and delete what is in there now.

### Step 4
For every person, make a line in `info.txt` with their name, their latitude and their longitude with commas inbetween. For example; when you want to add Bob at the Northpole, you should add the line `Bob,90.0,0.0`
