boolean pressed = false;
IntList ListX, ListY;

void setup() {
  size(800, 480);
  ListX = new IntList();
  ListY = new IntList();
}

void mousePressed() {
  pressed = true;
}

void draw() {
  if(pressed){
    ListX.append(mouseX);
    ListY.append(mouseY);
    
    for(int i=0; i<ListX.size()-1; i++){
      if(ListX.size() > 1){
        line(ListX.get(i), ListY.get(i), ListX.get(i+1), ListY.get(i+1));
        print("distance " + i + " " + (i+1) + " : " + dist(ListX.get(i), ListY.get(i), ListX.get(i+1), ListY.get(i+1)) + "\n");
      }
    }
    line(mouseX-20, mouseY, mouseX+20, mouseY);
    line(mouseX, mouseY-20, mouseX, mouseY+20); 
    pressed = false;
    //print(ListX + "\n");
    //print(ListY + "\n");
  }
}
