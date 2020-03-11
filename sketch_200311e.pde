PShape s;

boolean pressed = false;
boolean begin = false;
boolean firstRun = true;
IntList nodeInputX, nodeInputY;

int maxNodes = 15; //Intentional limiter, you may need to change this
PVector[] nodes;
int[] order;
int[] currentPath;
int nodeCount;
float recordDistance;

int rectX, rectY;
int rectSize = 50;
color rectColor;
color rectHighlight;
boolean rectOver = false;

void setup() {
  size(800, 641);
  // The file "bot.svg" must be in the data folder
  // of the current sketch to load successfully
  s = loadShape("jalan_semarang.svg");
  s.disableStyle();
  nodeInputX = new IntList();
  nodeInputY = new IntList();
  
  //define node, order, path
  nodes = new PVector[maxNodes];
  order = new int[maxNodes];
  currentPath = new int[maxNodes];
  
  //define button properties
  rectColor = color(255,0,0);
  rectHighlight = color(51);
  rectX = width - rectSize - 10;
  rectY = height - rectSize - 10;
}

void update(int x, int y) {
  if(overRect(rectX, rectY, rectSize, rectSize)){
    rectOver = true;
  }else{
    rectOver = false;
  }
}

//Check if mouse above button
//OUTPUT
//  return true -> bool : if mouse above
//  return false -> bool : if mouse away
boolean overRect(int x, int y, int width, int height){
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void mousePressed() {
  pressed = true;
  if (rectOver) {
    pressed = false;
    begin = true;
    nodeCount = nodeInputX.size();
    if(nodeCount > maxNodes){
      for(int i = nodeCount-1; i >= maxNodes; i--){
        nodeInputX.remove(i);
        nodeInputY.remove(i);
      }
      nodeCount = nodeInputX.size();
    }
    //print(nodeInputX + "\n"); print(nodeInputY + "\n");
    print("Begin with " + nodeCount + " nodes\n");
    for (int i = 0; i < nodeCount; i++) {
      PVector v = new PVector(nodeInputX.get(i), nodeInputY.get(i));
      nodes[i] = v;
      order[i] = i;
    }
    float d = calcDistance(nodes, order);
    print("Current shortest distance " + d + "\n");
    recordDistance = d;
    arrayCopy(order, currentPath);
  }
}

void draw() {
  //background(250);
  //draw map
  if(firstRun){
    noFill();
    stroke(0,0,255);
    strokeWeight(0.5);
    beginShape();
    shape(s,0,0);
    endShape();
    firstRun = false;
  }
  
  //draw button
  stroke(255,0,0);
  strokeWeight(1);
  fill(255,0,0);
  beginShape();
  rect(rectX, rectY, rectSize, rectSize);
  endShape();
  update(mouseX, mouseY);
  
  if(pressed && !overRect(rectX, rectY, rectSize, rectSize)){
    nodeInputX.append(mouseX);
    nodeInputY.append(mouseY);
    line(mouseX-10, mouseY, mouseX+10, mouseY);
    line(mouseX, mouseY-10, mouseX, mouseY+10); 
    pressed = false;
  }
  
  if(begin){
    background(250);
    //draw map
    noFill();
    stroke(0,0,255);
    strokeWeight(0.5);
    beginShape();
    shape(s,0,0);
    endShape();
    
    //draw test
    noFill();
    stroke(0, 255, 255);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < nodeCount; i++) {
      int n = order[i];
      vertex(nodes[n].x, nodes[n].y);
    }
    vertex(nodes[order[0]].x, nodes[order[0]].y);
    endShape();
    
    //draw result
    noFill();
    stroke(0);
    strokeWeight(1);
    beginShape();
    for (int i = 0; i < nodeCount; i++) {
      int n = currentPath[i];
      line(nodes[n].x-10, nodes[n].y, nodes[n].x+10, nodes[n].y);
      line(nodes[n].x, nodes[n].y-10, nodes[n].x, nodes[n].y+10); 
      vertex(nodes[n].x, nodes[n].y);
    }
    vertex(nodes[currentPath[0]].x, nodes[currentPath[0]].y);
    //print("zero " + nodes[currentPath[0]].x + ", " + nodes[currentPath[0]].y + "\n");
    //print("end " + nodes[currentPath[nodeCount-1]].x + ", " + nodes[currentPath[nodeCount-1]].y +"\n");
    endShape();
    
    float d = calcDistance(nodes, order);
    if (d < recordDistance) {
      print("Current shortest distance " + d + "\n");
      recordDistance = d;
      arrayCopy(order, currentPath);
    }
    tspSolve();
  }
}

//Lexiographic ordering algorithm
//1. Find largestI (P[x]<P[x+1])
//2. Find largestJ (P[x]<P[y])
//3. Swap (P[x] and P[y])
//4. Reverse from (largestI + 1 to the end)
void tspSolve(){
// https://www.quora.com/How-would-you-explain-an-algorithm-that-generates-permutations-using-lexicographic-ordering
// STEP 1 =====================================
  // find largestI (P[x]<P[x+1])
  int largestI = -1;
  for(int i = 0; i < nodeCount - 1; i++){
    if (order[i] < order[i + 1]) {
      largestI = i;
    }
  }
  if(largestI == -1){
    println("finished");
    noLoop();
  }else{
// STEP 2 =====================================
    // find largestJ (P[x]<P[y])
    int largestJ = -1;
    for(int j = 0; j < nodeCount; j++){
      if(order[largestI] < order[j]){
        largestJ = j;
      }
    }
// STEP 3 =====================================
    // swap (P[x] and P[y])
    swap(order, largestI, largestJ);
// STEP 4 =====================================
    // reverse from (largestI + 1 to the end)
    int size = nodeCount - largestI - 1;
    int[] endArray = new int[size];
    arrayCopy(order, largestI + 1, endArray, 0, size);
    endArray = reverse(endArray);
    arrayCopy(endArray, 0, order, largestI+1, size);
  }
}

//Swap 2 values in given array
//INPUT
//  a -> int[] : array to proceed
//  i -> int : index 1
//  j -> int : index 2
//OUTPUT
//  array with swapped value -> void
void swap(int[] arr, int i, int j) {
  int temp = arr[i];
  arr[i] = arr[j];
  arr[j] = temp;
}

//Calculate total distance between each nodes
//INPUT
//  nodes -> PVector[]
//  order -> int[]
//OUTPUT
//  sum distance -> float
float calcDistance(PVector[] nodes, int[] order){
  float sum = 0;
  for (int i = 0; i < nodeCount - 1; i++) {
    int indexA = order[i];
    int indexB = order[i + 1];
    PVector nodeA = nodes[indexA];
    PVector nodeB = nodes[indexB];
    float d = dist(nodeA.x, nodeA.y, nodeB.x, nodeB.y);
    sum += d;
  }
  sum += dist(nodes[order[0]].x, nodes[order[0]].y, 
              nodes[order[nodeCount - 1]].x, nodes[order[nodeCount - 1]].y);
  return sum;
}
