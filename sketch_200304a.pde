boolean pressed = false;
boolean begin = false;

PVector[] nodes;
int[] order;
int[] currentPath;
int maxNodes = 20;
int nodeCount;
float recordDistance;


IntList nodeInputX, nodeInputY;


int rectX, rectY;
int rectSize = 50;
color rectColor;
color rectHighlight;
boolean rectOver = false;

void setup() {
  size(800, 480);
  nodeInputX = new IntList();
  nodeInputY = new IntList();
  
  //lalala
  nodes = new PVector[maxNodes];
  order = new int[maxNodes];
  currentPath = new int[maxNodes];
  
  //define button properties
  rectColor = color(0);
  rectHighlight = color(51);
  rectX = width - rectSize - 10;
  rectY = height - rectSize - 10;
}

void mousePressed() {
  pressed = true;
  if (rectOver) {
    pressed = false;
    begin = true;
    nodeCount = nodeInputX.size();
    for (int i = 0; i < nodeCount; i++) {
      PVector v = new PVector(nodeInputX.get(i), nodeInputY.get(i));
      nodes[i] = v;
      order[i] = i;
    }
    float d = calcDistance(nodes, order);
    recordDistance = d;
    arrayCopy(order, currentPath);
  }
}

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
    //find largestJ (P[x]<P[y])
    int largestJ = -1;
    for(int j = 0; j < nodeCount; j++){
      if(order[largestI] < order[j]){
        largestJ = j;
      }
    }
// STEP 3 =====================================
    //swap (P[x] and P[y])
    swap(order, largestI, largestJ);
// STEP 4 =====================================
    //reverse from (largestI + 1 to the end)
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
float calcDistance(PVector[] nodes, int[] order) {
  float sum = 0;
  for (int i = 0; i < nodeCount - 1; i++) {
    int indexA = order[i];
    int indexB = order[i + 1];
    PVector nodeA = nodes[indexA];
    PVector nodeB = nodes[indexB];
    float d = dist(nodeA.x, nodeA.y, nodeB.x, nodeB.y);
    sum += d;
  }
  return sum;
}

void draw() {
  update(mouseX, mouseY);
  rect(rectX, rectY, rectSize, rectSize);
  
  if(pressed && !overRect(rectX, rectY, rectSize, rectSize)){
    nodeInputX.append(mouseX);
    nodeInputY.append(mouseY);
    line(mouseX-10, mouseY, mouseX+10, mouseY);
    line(mouseX, mouseY-10, mouseX, mouseY+10); 
    pressed = false;
  }
  
  if(begin){
    background(250);
    noFill();
    beginShape();
    for (int i = 0; i < nodeCount; i++) {
      int n = currentPath[i];
      line(nodes[n].x-10, nodes[n].y, nodes[n].x+10, nodes[n].y);
      line(nodes[n].x, nodes[n].y-10, nodes[n].x, nodes[n].y+10); 
      vertex(nodes[n].x, nodes[n].y);
    }
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

boolean overRect(int x, int y, int width, int height){
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void update(int x, int y) {
  if ( overRect(rectX, rectY, rectSize, rectSize) ) {
    rectOver = true;
  } else {
    rectOver = false;
  }
}
