
/**
 * Flock of Boids
 * by Jean Pierre Charalambos.
 * 
 * This example displays the 2D famous artificial life program "Boids", developed by
 * Craig Reynolds in 1986 and then adapted to Processing in 3D by Matt Wetmore in
 * 2010 (https://www.openprocessing.org/sketch/6910#), in 'third person' eye mode.
 * Boids under the mouse will be colored blue. If you click on a boid it will be
 * selected as the scene avatar for the eye to follow it.
 *
 * Press ' ' to switch between the different eye modes.
 * Press 'a' to toggle (start/stop) animation.
 * Press 'p' to print the current frame rate.
 * Press 'm' to change the mesh visual mode.
 * Press 't' to shift timers: sequential and parallel.
 * Press 'v' to toggle boids' wall skipping.
 * Press 's' to call scene.fitBallInterpolation().
 * Press 'd' to change representation mode (Vertex-Vertex and Face-Vertex).
 * Press 'r' to change between inmediate and retained mode.
 * Press 'g' to hide or make graph appear
 * Press 'b' to begin recording the tests, you CAN'T use other commands during this mode, excvept switch eye modes. 
             When the recording is done, place the mouse over the graphs to see it's specific information and title
 * Press 'f' to change the figure of the mesh
 * Press 'h' to screenshot the results
 * Press 'o' to see the bounding sphere
 * Press 'c' to enable/disable frustum culling
 */

import frames.input.*;
import frames.input.event.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

Scene scene;
int flockWidth = 1280;
int flockHeight = 720;
int flockDepth = 600;
boolean avoidWalls = true;

// visual modes
// 0. Faces and edges
// 1. Wireframe (only edges)
// 2. Only faces
// 3. Only points
int mode;

// Representations
// 0. Vertex-Vertex
// 1. Face-Vertex
int representation;

int initBoidNum = 100; // amount of boids to start the program with
int scaleFactor = 5; //scale factor for vertices in PShape
ArrayList<Boid> flock;
Node avatar;
PShape shape[] = new PShape[3];
boolean animate = true;
boolean retained = true;
boolean boundingSphere = false;
boolean frustumCulling = false;
float boundSphereRadius = 18.0; //Only for tetrahedron

final String FILEPATH [] = {"shape.obj", "Arwing.obj", "KillerBee.obj"};

//PG Graphics
PGraphics pPlot;
PGraphics plot1;
PGraphics plot2;
PGraphics plot0;


float prevY;
int timing;
boolean graph;
int plotNumber;
String title;

//Carrying variables
int figure = 0;
boolean begin=false;
boolean finished;
float lastFramerate;
String titles[]={"Retained", "Inmediate: Vertex-Vertex", "Inmediate: Face - Vertex"};
float fpsAvg;
float fpsSum;

float fpsAvg0;
float fpsSum0;

float fpsAvg1;
float fpsSum1;

float fpsAvg2;
float fpsSum2;
Mesh mesh[] = new Mesh [3];

void setup() {
  size(1000, 800, P3D);
  scene = new Scene(this);
  scene.setBoundingBox(new Vector(0, 0, 0), new Vector(flockWidth, flockHeight, flockDepth));
  scene.setAnchor(scene.center());
  //frustum culling
  scene.enableBoundaryEquations( );
  Eye eye = new Eye(scene);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.fitBallInterpolation();
  
  //Retained mode
  for(int i=0;i<3;i++){
    shape[i] = loadShape( FILEPATH[i] ); shape[i].scale( scaleFactor );
    mesh[i] = new Mesh( representation, scaleFactor, shape[i], FILEPATH[i] );
  }
  
  // create and fill the list of boids
  flock = new ArrayList();
  for (int i = 0; i < initBoidNum; i++)
    flock.add(new Boid(new Vector(flockWidth / 2, flockHeight / 2, flockDepth / 2)));

  //create canvas
  pPlot = createGraphics (500, 325);
  plot0= createGraphics (400, 325);
  plot1= createGraphics (400, 325);
  plot2= createGraphics (400, 325);
  
  graph=true;
  finished = false;
  timing=0;
  plotNumber=0;
  title="";
  fpsAvg=0.0;fpsSum=0.0;
  fpsAvg0=0.0;fpsSum0=0.0;
  fpsAvg1=0.0;fpsSum1=0.0;
  fpsAvg2=0.0;fpsSum2=0.0;
    
}

void draw() {
  background(0);
  ambientLight(128, 128, 128);
  directionalLight(255, 255, 255, 0, 1, -100);
  walls();
  // Calls Node.visit() on all scene nodes.
  scene.traverse();
  
  // Plots the information of FrameRate vs FrameCount if graph is active
  if(graph)
    frontGraph();
  else
    frameCount--;
}

void walls() {
  pushStyle();
  noFill();
  stroke(255);

  line(0, 0, 0, 0, flockHeight, 0);
  line(0, 0, flockDepth, 0, flockHeight, flockDepth);
  line(0, 0, 0, flockWidth, 0, 0);
  line(0, 0, flockDepth, flockWidth, 0, flockDepth);

  line(flockWidth, 0, 0, flockWidth, flockHeight, 0);
  line(flockWidth, 0, flockDepth, flockWidth, flockHeight, flockDepth);
  line(0, flockHeight, 0, flockWidth, flockHeight, 0);
  line(0, flockHeight, flockDepth, flockWidth, flockHeight, flockDepth);

  line(0, 0, 0, 0, 0, flockDepth);
  line(0, flockHeight, 0, 0, flockHeight, flockDepth);
  line(flockWidth, 0, 0, flockWidth, 0, flockDepth);
  line(flockWidth, flockHeight, 0, flockWidth, flockHeight, flockDepth);
  popStyle();
}

void keyPressed() {
  //If the program isn't recording you can run commands.
  if ( !begin || ( begin && frameCount>1200 ) ) {
    switch (key) {
    case 'a':
      animate = !animate;
      break;
    case 's':
      if (scene.eye().reference() == null)
        scene.fitBallInterpolation();
      break;
    case 't':
      scene.shiftTimers();
      break;
    case 'p':
      println("Frame rate: " + frameRate);
      break;
    case 'v':
      avoidWalls = !avoidWalls;
      break;
    case 'm':
      mode = mode < 3 ? mode+1 : 0;
      break;
    case 'r':
      retained = !retained;
      break;
    case 'o':
      boundingSphere = !boundingSphere;
      break;
    case 'd':
      representation = ( representation + 1 ) % 2;
        mesh[figure] = new Mesh( representation, scaleFactor, shape[figure], FILEPATH[figure] );
      break;
    case 'g':
      graph = !graph;
      break;
    case 'b':
      mode=0;
      frameCount=-1;
      begin = !begin;
      break;
    case 'f':
      figure = figure < 2 ? figure+1 : 0;
      break;
    case 'c':
      frustumCulling = !frustumCulling;
      break;
    case 'h':
      saveFrame("results-#####.png");
      break;
    case ' ':
      if (scene.eye().reference() != null) {
        scene.lookAt(scene.center());
        scene.fitBallInterpolation();
        scene.eye().setReference(null);
      } else if (avatar != null) {
        scene.eye().setReference(avatar);
        scene.interpolateTo(avatar);
      }
      break;
    }
    
  }else{
    if(key==' '){
      if (scene.eye().reference() != null) {
        scene.lookAt(scene.center());
        scene.fitBallInterpolation();
        scene.eye().setReference(null);
      } else if (avatar != null) {
        scene.eye().setReference(avatar);
        scene.interpolateTo(avatar);
      }
    }
  }
}