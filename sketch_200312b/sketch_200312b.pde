import pathfinder.*;

boolean map1_drawn = false;
boolean map2_drawn = false;
boolean tsp_finished = false;
boolean pressed = false;
boolean begin = false;
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
PImage semarang;

Graph[] gs = new Graph[4];
PImage[] graphImage = new PImage[4];
int start[] = new int[4];
int end[] = new int[4];
float nodeSize[] = new float[4];
  
int graphNo = 0;
int algorithm;

int overAlgorithm, overOption, overGraph;
int offX = 0, offY = 0;

boolean[] showOption = new boolean[3];
  
GraphNode[] gNodes, rNodes;
GraphEdge[] gEdges, exploredEdges;
// Pathfinder algorithm
IGraphSearch pathFinder;
// Used to indicate the start and end nodes as selected by the user.
GraphNode startNode, endNode;
boolean selectMode = false;

long time;

void setup(){
  size(820,400);
  cursor(CROSS);
  smooth();
  ellipseMode(CENTER);
  semarang = loadImage("1.png");
  
//TSP
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
  
//A-STAR
  overAlgorithm = overOption = overGraph = -1;
  showOption[2] = true;
  /* MAP 0 : Cityscape
   * map created from B&W image. Nodes are only created in 
   * white areas of the image.
   * Edges are created between adjacent nodes including 
   * diagonals and the traverse cost is based on distance
   * between the nodes. 
   */
  graphNo = 0;
  nodeSize[graphNo] = 4.0f;
  graphImage[graphNo] = loadImage("2.png");
  gs[graphNo] = new Graph();
  makeGraphFromBWimage(gs[graphNo], graphImage[graphNo], null, 100, 100, false);
  gNodes =  gs[graphNo].getNodeArray();

  // Get arrays of both the nodes and edges used by the
  // selected graph.
  gNodes =  gs[graphNo].getNodeArray();
  gEdges = gs[graphNo].getAllEdgeArray();
  // Create a path finder object based on the algorithm
  pathFinder = makePathFinder(gs[graphNo], algorithm);
  usePathFinder(pathFinder);
}

void usePathFinder(IGraphSearch pf){
  time = System.nanoTime();
  pf.search(start[graphNo], end[graphNo], true);
  time = System.nanoTime() - time;
  rNodes = pf.getRoute();
  exploredEdges = pf.getExaminedEdges();
}

IGraphSearch makePathFinder(Graph graph, int pathFinder){
  IGraphSearch pf = null;
  float f = (graphNo == 2) ? 2.0f : 1.0f;
  pf = new GraphSearch_Astar(gs[graphNo], new AshCrowFlight(f));
  return pf;
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

void mouseClicked(){
  //startNode = gs[graphNo].getNodeAt(50, 50, 0, 16.0f);
  //endNode = gs[graphNo].getNodeAt(mouseX, mouseY, 0, 16.0f);
  //start[graphNo] = startNode.id();
  //end[graphNo] = endNode.id();
  //usePathFinder(pathFinder);
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

void draw(){
  update(mouseX, mouseY);
  rect(rectX, rectY, rectSize, rectSize);
  fill(255,0,0);
  
  if(pressed && !overRect(rectX, rectY, rectSize, rectSize)){
    nodeInputX.append(mouseX);
    nodeInputY.append(mouseY);
    stroke(255, 0, 0);
    strokeWeight(3);
    line(mouseX-10, mouseY, mouseX+10, mouseY);
    line(mouseX, mouseY-10, mouseX, mouseY+10); 
    pressed = false;
  }
  
  if(!map2_drawn){
    image(semarang, 0, 0);
    //translate(offX, offY);
    //if(graphImage[graphNo] != null)
    //  image(graphImage[graphNo],0,0);
    map2_drawn = true;
  }
  
  if(begin){
    background(250);
    translate(offX, offY);
    //draw map
    image(semarang, 0, 0);
    //if(graphImage[graphNo] != null)
    //  image(graphImage[graphNo],0,0);
    //draw test
    noFill();
    stroke(0, 255, 255);
    strokeWeight(3);
    beginShape();
    for (int i = 0; i < nodeCount; i++) {
      int n = order[i];
      vertex(nodes[n].x, nodes[n].y);
    }
    vertex(nodes[order[0]].x, nodes[order[0]].y);
    endShape();
    
    //draw result
    noFill();
    stroke(255,0,0);
    strokeWeight(3);
    beginShape();
    for (int i = 0; i < nodeCount; i++) {
      int n = currentPath[i];
      line(nodes[n].x-10, nodes[n].y, nodes[n].x+10, nodes[n].y);
      line(nodes[n].x, nodes[n].y-10, nodes[n].x, nodes[n].y+10); 
      vertex(nodes[n].x, nodes[n].y);
    }
    vertex(nodes[currentPath[0]].x, nodes[currentPath[0]].y);
    endShape();
    
    float d = calcDistance(nodes, order);
    if (d < recordDistance) {
      print("Current shortest distance " + d + "\n");
      recordDistance = d;
      arrayCopy(order, currentPath);
    }
    tspSolve();
  }
  if(tsp_finished){
    if(!map1_drawn){
      image(semarang, 0, 0);
      //translate(offX, offY);
      //if(graphImage[graphNo] != null)
      //  image(graphImage[graphNo],0,0);
      map1_drawn = true;
    }
    for (int i = 0; i < nodeCount - 1; i++) {
      int n = currentPath[i];
      int m = currentPath[i + 1];
      //print(nodes[n].x, " " ,nodes[n].y, " - ", nodes[currentPath[i+1]].x, " " ,nodes[currentPath[i+1]].y, "\n");
      startNode = gs[graphNo].getNodeAt(nodes[n].x, nodes[n].y, 0, 16.0f);
      endNode = gs[graphNo].getNodeAt(nodes[m].x, nodes[m].y, 0, 16.0f);
      start[graphNo] = startNode.id();
      end[graphNo] = endNode.id();
      usePathFinder(pathFinder);
      
      //A-STAR
      pushMatrix();
      drawRoute(rNodes, color(200,0,0), 5.0f);
      if(selectMode){
        stroke(0);
        strokeWeight(1.5f);
        if(endNode != null){
          line(startNode.xf(), startNode.yf(), endNode.xf(), endNode.yf());
        }else{
          line(startNode.xf(), startNode.yf(), mouseX, mouseY);
        }
      }
      popMatrix();
    }
    int n = currentPath[nodeCount-1];
    int m = currentPath[0];
    startNode = gs[graphNo].getNodeAt(nodes[n].x, nodes[n].y, 0, 16.0f);
    endNode = gs[graphNo].getNodeAt(nodes[m].x, nodes[m].y, 0, 16.0f);
    start[graphNo] = startNode.id();
    end[graphNo] = endNode.id();
    usePathFinder(pathFinder);
    
    //A-STAR
    pushMatrix();
    drawRoute(rNodes, color(200,0,0), 5.0f);
    if(selectMode){
      stroke(0);
      strokeWeight(1.5f);
      if(endNode != null){
        line(startNode.xf(), startNode.yf(), endNode.xf(), endNode.yf());
      }else{
        line(startNode.xf(), startNode.yf(), mouseX, mouseY);
      }
    }
    popMatrix();
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
    tsp_finished = true;
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

void drawEdges(GraphEdge[] edges, int lineCol, float sWeight, boolean arrow){
  if(edges != null){
    pushStyle();
    noFill();
    stroke(lineCol);
    strokeWeight(sWeight);
    for(GraphEdge ge : edges){
      if(arrow)
        drawArrow(ge.from(), ge.to(), nodeSize[graphNo] / 2.0f, 6);
      else {
        line(ge.from().xf(), ge.from().yf(), ge.to().xf(), ge.to().yf()); 
      }
    }
    popStyle();
  }
}

void drawRoute(GraphNode[] r, int lineCol, float sWeight){
  if(r.length >= 2){
    pushStyle();
    stroke(lineCol);
    strokeWeight(sWeight);
    noFill();
    for(int i = 1; i < r.length; i++)
      line(r[i-1].xf(), r[i-1].yf(), r[i].xf(), r[i].yf());
    // Route start node
    strokeWeight(2.0f);
    stroke(0,0,160);
    fill(0,0,255);
    ellipse(r[0].xf(), r[0].yf(), nodeSize[graphNo], nodeSize[graphNo]);
    // Route end node
    stroke(160,0,0);
    fill(255,0,0);
    ellipse(r[r.length-1].xf(), r[r.length-1].yf(), nodeSize[graphNo], nodeSize[graphNo]); 
    popStyle();
  } 
}

 /**
  * Create a tiled graph from an image.
  * This method will accept 1 or 2 images to create a tiled graph (a 2D rectangualr
  * arrangements of nodes.
  * 
 */
void makeGraphFromBWimage(Graph g, PImage backImg, PImage costImg, int tilesX, int tilesY, boolean allowDiagonals){
  int dx = backImg.width / tilesX;
  int dy = backImg.height / tilesY;
  int sx = dx / 2, sy = dy / 2;
  // use deltaX to avoid horizontal wrap around edges
  int deltaX = tilesX + 1; // must be > tilesX

  float hCost = dx, vCost = dy, dCost = sqrt(dx*dx + dy*dy);
  float cost = 0;
  int px, py, nodeID, col;
  GraphNode aNode;

  py = sy;
  for(int y = 0; y < tilesY ; y++){
    nodeID = deltaX * y + deltaX;
    px = sx;
    for(int x = 0; x < tilesX; x++){
      // Calculate the cost
      if(costImg == null){
        col = backImg.get(px, py) & 0xFF;
        cost = 1;
      }
      else {
        col = costImg.get(px, py) & 0xFF;
        cost = 1.0f + (256.0f - col)/ 16.0f; 
      }
      // If col is not black then create the node and edges
      if(col != 0){
        aNode = new GraphNode(nodeID, px, py);
        g.addNode(aNode);
        if(x > 0){
          g.addEdge(nodeID, nodeID - 1, hCost * cost);
          if(allowDiagonals){
            g.addEdge(nodeID, nodeID - deltaX - 1, dCost * cost);
            g.addEdge(nodeID, nodeID + deltaX - 1, dCost * cost);
          }
        }
        if(x < tilesX -1){
          g.addEdge(nodeID, nodeID + 1, hCost * cost);
          if(allowDiagonals){
            g.addEdge(nodeID, nodeID - deltaX + 1, dCost * cost);
            g.addEdge(nodeID, nodeID + deltaX + 1, dCost * cost);
          }
        }
        if(y > 0)
          g.addEdge(nodeID, nodeID - deltaX, vCost * cost);
          if(y < tilesY - 1)
            g.addEdge(nodeID, nodeID + deltaX, vCost * cost);
      }
      px += dx;
      nodeID++;
    }
    py += dy;
  }
}

void drawArrow(GraphNode fromNode, GraphNode toNode, float nodeRad, float arrowSize){
  float fx, fy, tx, ty;
  float ax, ay, sx, sy, ex, ey;
  float awidthx, awidthy;

  fx = fromNode.xf();
  fy = fromNode.yf();
  tx = toNode.xf();
  ty = toNode.yf();

  float deltaX = tx - fx;
  float deltaY = (ty - fy);
  float d = sqrt(deltaX * deltaX + deltaY * deltaY);

  sx = fx + (nodeRad * deltaX / d);
  sy = fy + (nodeRad * deltaY / d);
  ex = tx - (nodeRad * deltaX / d);
  ey = ty - (nodeRad * deltaY / d);
  ax = tx - (nodeRad + arrowSize) * deltaX / d;
  ay = ty - (nodeRad + arrowSize) * deltaY / d;

  awidthx = - (ey - ay);
  awidthy = ex - ax;

  noFill();
  strokeWeight(4.0f);
  stroke(160, 128);
  line(sx,sy,ax,ay);

  noStroke();
  fill(48, 128);
  beginShape(TRIANGLES);
  vertex(ex, ey);
  vertex(ax - awidthx, ay - awidthy);
  vertex(ax + awidthx, ay + awidthy);
  endShape();
 }
