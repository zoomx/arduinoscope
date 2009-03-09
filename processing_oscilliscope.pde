/*
 * Oscilloscope
 * Scope and logic analyzer to visualize volage on arduino digital and analog pins
 * 
 * (c) 2009 David Konsumer <konsumer@jetboystudio.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.

lots of ideas from:
http://accrochages.drone.ws/en/node/90

features:
  * logic analyzer mode that shows 1's and 0's clearly.
  * pause frame
  * save frame
  * configurable pin-count
  * use as many pins as will fit on screen (tested with 12 at 800x800, seems ok)
  * use scope class in your own thing, easy to reuse, and setup any kind of GUI
  * shows volts, based on scaling settings

data is formatted by LF char, and scope nums are seperated by " "

*/

// TODO: add zooming
// TODO: detect things like SPI/i2C, label graph
// TODO: use rectangle for logic, to make it more efficient
// TODO: add timecoding

import processing.serial.*;
import controlP5.*;

// how many scopes, you decide.
Scope[] scopes = new Scope[6];

Serial port;
ControlP5 controlP5;

PFont fontLarge;
PFont fontSmall;

int LINE_FEED=10; 

int[] vals;

void setup() 
{
  // put whatever you like, for size, in here
  // pick a neat multiple of scope count for height to amke it line up
  size(800, 800, P2D);
  background(0);
  
  controlP5 = new ControlP5(this);
  
  // set these up under tools/create font
  fontLarge = loadFont("TrebuchetMS-20.vlw");
  fontSmall = loadFont("Uni0554-8.vlw");
  
  int[] dimv = new int[2];
  dimv[0] = width-130; // 130 margin for text
  dimv[1] = height/scopes.length;
  
  // setup vals from serial
  vals = new int[scopes.length];
  
  for (int i=0;i<scopes.length;i++){
    int[] posv = new int[2];
    posv[0]=0;
    posv[1]=dimv[1]*i;

    // random color, that will look nice and be visible
    scopes[i] = new Scope(posv, dimv, color((int)random(255), (int)random(127)+127, 255));
    
    controlP5.addButton("pause",1,dimv[0]+10,posv[1]+10,32,20).setId(i);
    controlP5.addButton("logic",1,dimv[0]+52,posv[1]+10,29,20).setId(i+50);
    controlP5.addButton("save",1,dimv[0]+92,posv[1]+10,29,20).setId(i+100);
  }
  
  port = new Serial(this, Serial.list()[0], 115200);
  
  // clear and wait for linefeed
  port.clear();
  port.bufferUntil(LINE_FEED);
}

void draw()
{
  background(0);
  
  // int[] vals = getTestValuesSquare();
  
  for (int i=0;i<scopes.length;i++){
    // update and draw scopes
    
    scopes[i].addData(vals[i]);
    scopes[i].draw();
    
    // conversion multiplier for voltage
    float multiplier = scopes[i].multiplier/scopes[i].resolution;
    
    // convert arduino vals to voltage
    float minval = scopes[i].minval * multiplier;
    float maxval = scopes[i].maxval * multiplier;
    float pinval =  scopes[i].values[scopes[i].values.length-1] * multiplier;
    
    // add lines
    scopes[i].drawBounds();
    stroke(255);
    line(0, scopes[i].pos[1], width, scopes[i].pos[1]);
    
    // add labels
    fill(255);
    textFont(fontLarge);
    text(pinval, width-60, scopes[i].pos[1]+scopes[i].dim[1]-10);
    
    textFont(fontSmall);
    text("min: "+minval, scopes[i].dim[0]+10, scopes[i].pos[1]+40);
    text("max: "+maxval, scopes[i].dim[0]+10, scopes[i].pos[1]+48);
    
    fill(scopes[i].c);
    text("pin: "+i, scopes[i].dim[0]+10,scopes[i].pos[1]+scopes[i].dim[1]-10);
  }
  
  // draw text seperator
  stroke(255);
  line(scopes[0].dim[0], 0, scopes[0].dim[0],height);
  
  // update buttons
  controlP5.draw();
  
}

// handles button clicks
void controlEvent(ControlEvent theEvent) {
  int id = theEvent.controller().id();
  
  // button families are in chunks of 50 to avoid collisions
  if (id < 50){
    scopes[id].pause=!scopes[id].pause;
  }else if (id < 100){
    scopes[id-50].logic=!scopes[id-50].logic;
  }else if(id < 150){
    String fname = "data"+(id-100)+".csv";
    scopes[id-100].saveData(fname);
    println("Saved as "+fname);
  }
}

// handle serial data
void serialEvent(Serial p) { 
  String data = p.readStringUntil(LINE_FEED);
  if (data != null) {
    // println(data);
    vals = int(split(data, ' '));
  }
}


// for test data, you can comment, if not using
int d=0;
ControlTimer ct = new ControlTimer();


int[] getTestValuesSin(){
  int[] vals = new int[scopes.length];
  
  // this is test data
  if (d==45){
    d=0;
  }
  
  int sval = (int) abs(sin(d*2)*1023.0f);
  for (int i=0;i<scopes.length;i++){
    vals[i]=sval;
  }
  
  d++;
  
  return vals;
}

int oldtime;
int time;
boolean up=false;

int[] getTestValuesSquare(){
  int[] vals = new int[scopes.length];
  
  ct.setSpeedOfTime(25);
  oldtime=time;
  time = ct.second();  
  
  if (oldtime==time){
    up = !up;
  }
  
  for (int i=0;i<scopes.length;i++){
    if (up){
      vals[i]=1023;
    }else{
       vals[i]=0;
    }
  }
  
  return vals;
}



class Scope{
  int[] pos; // x, y start position
  int[] dim; // w, h dimensions
  color c; // color for lines
  color bounds_color=color(30); // color for center line
  color[] logic_colors; // size 2 color array for 0/1, red/green by default
  
  int[] values; // all values in the graph
  float resolution = 1024.0f; // max number that be displayed
  float multiplier = 5f; // the voltage multiplier
  
  int minval;
  int maxval;
  boolean logic = false; // use colors to show 0/1?
  boolean pause = false; // freeze input?
  
  /*
  posv is position (x,y)
  dimv is dimensions (w,h)
  cv is color for line
  */
  Scope(int[] posv, int[] dimv, color cv){
    pos = posv;
    dim = dimv;
    c = cv;
    values = new int[dim[0]];
    
    // red and green defaults for logic colors
    logic_colors = new color[2];
    logic_colors[0]=color(255,0,0);
    logic_colors[1]=color(0,255,0);
    
    // I set this high here, so it will be overidden, with first smaller value:
    minval = (int)resolution;
  }
  
  void draw(){
    if (!logic){
      stroke(c);
    }
    for (int x=1; x<dim[0]; x++) {
      if (logic){
        if (values[x] > (resolution/2)){
          stroke(logic_colors[1]);
        }else{
          stroke(logic_colors[0]);
        }
        line(pos[0] + dim[0]-x-2,   pos[1], 
             pos[0] + dim[0]-x-2, pos[1] + dim[1]);
      }else{
        line(pos[0] + dim[0]-x, pos[1] + dim[1]-getY(values[x-1])-1, 
             pos[0] + dim[0]-x, pos[1] + dim[1]-getY(values[x])-1);
      }
    }
  
  }
  
  // draw center line
  void drawBounds(){
    stroke(bounds_color);
    line(pos[0],pos[1]+(dim[1]/2), dim[0], pos[1]+(dim[1]/2));
  }
  
  // add a single point
  void addData(int val){
    if (!pause){
      for (int i=0; i<dim[0]-1; i++){
        values[i] = values[i+1];
      }
      values[dim[0]-1] = val;
      if (val < minval){
        minval = val;
      }
      if (val > maxval){
        maxval=val;
      }
    }
  }
  
  // save current frame
  void saveData(String filename){
    String[] lines = new String[values.length];
    for (int i = 0; i < values.length; i++) {
      lines[i] = "" + values[i];
    }
    saveStrings(filename, lines);
  }
  
  
  private int getY(int val){
    return (int)(val / resolution * dim[1]) - 1;
  }
  
}

