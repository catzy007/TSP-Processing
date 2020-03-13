import pathfinder.*;

Graph[] gs = new Graph[4];
PImage[] graphImage = new PImage[4];
int start[] = new int[4];
int end[] = new int[4];
float nodeSize[] = new float[4];
  
int graphNo = 0;
int algorithm;

int overAlgorithm, overOption, overGraph;
//int offX = 10, offY = 10;
int offX = 0, offY = 0;

boolean[] showOption = new boolean[3];
  
GraphNode[] gNodes, rNodes;
GraphEdge[] gEdges, exploredEdges;
// Pathfinder algorithm
IGraphSearch pathFinder;
// Used to indicate the start and end nodes as selected by the user.
GraphNode startNode, endNode;
boolean selectMode = false;

//PImage backImage;

long time;


void setup(){
  size(800,800);
  cursor(CROSS);
  smooth();
  ellipseMode(CENTER);
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
  graphImage[graphNo] = loadImage("Untitled.png");
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

void mousePressed(){
}

void mouseDragged(){
}

void mouseReleased(){
}

void mouseMoved(){
}

void mouseClicked(){
  startNode = gs[graphNo].getNodeAt(50, 50, 0, 16.0f);
  endNode = gs[graphNo].getNodeAt(mouseX, mouseY, 0, 16.0f);
  start[graphNo] = startNode.id();
  end[graphNo] = endNode.id();
  usePathFinder(pathFinder);
}

void draw(){
  pushMatrix();
  translate(offX, offY);
  if(graphImage[graphNo] != null)
    image(graphImage[graphNo],0,0);

  //if(showOption[2])
  //    drawEdges(exploredEdges, color(0,0,255), 1.8f, false);

  drawRoute(rNodes, color(200,0,0), 5.0f);

  if(selectMode){
    stroke(0);
    strokeWeight(1.5f);
    if(endNode != null)
      line(startNode.xf(), startNode.yf(), endNode.xf(), endNode.yf());
    else
      line(startNode.xf(), startNode.yf(), mouseX, mouseY);
  }
  popMatrix();
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
