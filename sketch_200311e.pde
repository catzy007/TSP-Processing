PShape s;

void setup() {
  size(800, 641);
  // The file "bot.svg" must be in the data folder
  // of the current sketch to load successfully
  s = loadShape("jalan_semarang.svg");
}

void draw() {
  background(204);
  //translate(width/2, height/2);
  //print(width + " " + height);
  shape(s,0,0);
}

//void mousePressed() {
//  // Shrink the shape 90% each time the mouse is pressed
//  s.scale(1.10);  
//}
