

//Represents the graph at the front of the screen
void frontGraph() {
  
  pushMatrix();
  //This fixes the graphs and text in front of the screen
  scene.beginScreenCoordinates();
  noLights();   
      color c=color(255,255,255);
      
      //If it's not 'recording', just plot the thing as a whole in real time.
      if(!begin){
        informationText(20, 20);
        c=color(255, 255, 0);
        drawCanvas(pPlot, 490, 370, c, true);
        textSize(26);
        text("Frame Count", 600, 360);
        translate(480, 600);
        rotate(PI+PI/2);
        text("FrameRate", 0, 0);
        
      }else{
        
        
        String avg="";
        //The mode graphs only plot 400 frames, so everytime 400 passes, it begins to plot the other.
        if(frameCount%400==0){
          plotNumber+=1;
        }
        
        //This stops the averaging of the frames if the recording is complete
        if(frameCount<1200){
          fpsSum+=frameRate;
          fpsAvg=(fpsSum/frameCount);
        }
        
        avg="Total FPS Average: "+fpsAvg;
        String mfps= "";
        
        //Sets the graph and color depending on the mode.
        switch(plotNumber){
          case 0:
            retained=true;
            title= titles[0];
            c=color(255, 255, 0);
            fpsSum0+=frameRate;
            fpsAvg0=(fpsSum0/(frameCount%400));
            mfps="Mode FPS avg: "+fpsAvg0;
            break;
          case 1:
            retained=false;
            representation=0;
            title= titles[1];
            c=color(0, 255, 255);
            fpsSum1+=frameRate;
            fpsAvg1=(fpsSum1/(frameCount%400));
            mfps="Mode FPS avg: "+fpsAvg1;
            break;
          case 2:
            title= titles[2];
            representation=1;
            c=color(0, 0, 255);
            fpsSum2+=frameRate;
            fpsAvg2=(fpsSum2/(frameCount%400));
            mfps="Mode FPS avg: "+fpsAvg2;
            break;
          default:
            //If the process is done, it evaluates if the mouse is over the graph to change the data
            boolean c0=overCanvas(0, 0, 400, 325);
            boolean c1=overCanvas(500, 0, 400, 325);
            boolean c2=overCanvas(0, 400, 400, 325);
            title=    c0  ? titles[0] 
                    : c1  ? titles[1]
                    : c2 ? titles[2]
                    : "";
            c =       c0  ? color(255, 255, 0) 
                    : c1  ? color(0, 255, 255)
                    : c2 ? color(0, 0, 255)
                    : color(255);
            mfps=     c0  ? ""+fpsAvg0
                    : c1  ? ""+fpsAvg1
                    : c2 ? ""+fpsAvg2
                    : "";
                    
            if(!mfps.equals(""))
              mfps="Mode FPS avg: "+mfps;
            ;
        }
        
        
        pushMatrix();
          textSize(26);
          fill(c);
          textAlign(LEFT);
          text(title, 450, 500);
          text(mfps, 450, 550);
          fill(255);
        popMatrix();
        textSize(20);
        text(avg, 450, 630);
        informationText(450, 650);
        
        //Draws the three canvases
        drawCanvas(plot0, 0, 0, c, plotNumber==0);
        drawCanvas(plot1, 500, 0, c, plotNumber==1);
        drawCanvas(plot2, 0, 400, c, plotNumber==2);
      }
    
  scene.endScreenCoordinates();
  popMatrix();
}

//Evaluates if the mouse is over the canvas AND there are graphs to begin with.
boolean overCanvas(int x, int y, int widths, int heights){
  if (mouseX >= x && mouseX <= x+widths && 
      mouseY >= y && mouseY <= y+heights)
      return true && graph;
  return false;
}

//Initializes the drawing and whether it has to drawn over it or not.
void drawCanvas(PGraphics plot, int posX, int posY, color c, boolean graph){
  plot.beginDraw();
  plot.strokeWeight(1);
  drawStuff(plot);
  plot.stroke(c);
  
  if (animate){
    if(graph) plotGraph(plot);
  }else{ 
    frameCount--;
  }
  
  plot.endDraw();
  image(plot, posX, posY);
}

//Plots the curve based in the framerate
void plotGraph(PGraphics plot){  
  int localFrameCount=frameCount%plot.width;
  if(!begin)
    checkFrameCount(localFrameCount);
  plot.strokeWeight(4);
  float plotVar = (plot.height*(80-frameRate))/80;
  plot.line(localFrameCount-1, prevY, localFrameCount, plotVar);
  prevY = plotVar;
}

//In general mode, resets the plot canvas to keep drawing
void checkFrameCount(int localFrameCount) {
  if (localFrameCount==0) {
    pPlot.clear();
    timing++;
  }
}

//Draws the mesh and numbers to plot over it
void drawStuff(PGraphics plot) {
  for (int i = 0; i <= plot.width; i += 50) {
    plot.fill(255, 0, 255);
    plot.text((i)+(timing*plot.width), i-20, plot.height-15);
    plot.stroke(255);
    plot.line(i, plot.height, i, 0);
  }
  for (int j = 0; j < plot.height; j += 40) {
    plot.fill(255, 0, 255);
    plot.text(80-j/(plot.height/80), 0, j);
    plot.stroke(255);
    plot.line(0, j, plot.width, j);
  }
}

//Sets the information of mode and current framerate
void informationText(int posX, int posY){
  textAlign(LEFT);
  fill(255);
  textSize(20);
  text("Is retained?   " + retained, posX, posY);
  text("Current representation mode:      " + ((representation == 0) ? "Vertex-Vertex":"Face-Vertex"), posX, posY+20);
  if(animate){ text("FrameRate:      " + frameRate, posX, posY+40); lastFramerate=frameRate;}
  else text("FrameRate:      " + lastFramerate, posX, posY+40);
  
}