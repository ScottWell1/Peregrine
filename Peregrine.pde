/******************************************************************************
 *
 *  Peregrine Copyright (C) 2013 by Trevor White.
 *  ..Updates for Processing4 by Scott Welliver, 2021.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Some included fonts are licensed under under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************
 *
 * TRADEMARKS
 *
 * No claim is herein made to rights for any trademarks mentioned internally
 * or in documentation.  All such trademarks remain the exclusive property of
 * the respective owners.  In particular: 
 *   Laserbee (TM) is a registered trademark of J.BAUER Electronics
 * 
 * No inference is made that this program is endorsed, approved, or tested by
 * the legal holders of any trademarks mentioned.  
 *
 ******************************************************************************
 */


// Imports
import javax.swing.*;
import controlP5.*;
import processing.serial.*;
import java.util.*;
import java.io.*;
import java.security.*;

import java.awt.Frame;
import java.awt.BorderLayout;

// Version definition
String version = "1.6.0";
String appWindowTitle = "Peregrine " + version;

// Input type declarations
final int INPUT_SIMPLE = 0;
final int INPUT_OPENLPM = 1;
final int INPUT_KENOMETER = 2;
final int INPUT_RADIANT = 3;
final int INPUT_LASERBEE = 4;
String[] LPMNames = { "INPUT_SIMPLE", "INPUT_OPENLPM", "INPUT_KENOMETER", "INPUT_RADIANT", "INPUT_LASERBEE" };

// protocol detection is automatic, but start with INPUT_SIMPLE as default
int INPUT_TYPE = INPUT_SIMPLE;

// Baud Rate default
int BAUD_RATE = 9600;

// Autorefresh
int autorefresh = 0;

// Object for our controls
private ControlP5 cp5;

// Main menu control
//MultiList mainMenu;  //multilist broken in processing 4 (and maybe 3?)

// Labels for power and time
Textlabel pLabels[] = new Textlabel[11];
Textlabel tLabels[] = new Textlabel[10];
Textlabel floatingTimeLabel;
Textlabel floatingPowerLabel;

// Dropdowns for COM port and baud rate
ScrollableList COMSelector;
int COMSelectorItemHeight = 20;
ScrollableList BaudSelector;
int BaudSelectorItemHeight = 20;
int maxSelectorHeight = 21 * 20;
public int defaultBaudRate = 9600;


// Buttons for connection and refreshing
Button connectButton;
Button refreshButton;

// Buttons for menu options -- old menu relied on MultiList class, which is broken.
Button exportGraphButton;
Button exportDataButton;
Button newMeasureButton;
Button resetButton;
Button debugButton;
Button serialDebugButton;

// Title and message labels
Textlabel titleLabel;
Textlabel messageLabel;

// Current reading and associated label
Textlabel currentReadingLabelLabel;
Textlabel currentReadingLabel;

// Peak and associated label
Textlabel peakReadingLabelLabel;
Textlabel peakReadingLabel;

// Average and associated label
Textlabel averageReadingLabelLabel;
Textlabel averageReadingLabel;

// Detected protocol
Textlabel protocolLabel;

// The cursor for our data array.
int dataCursor = 0;

// Array full of data
Float[] data = new Float[600];

ArrayList readingsList;
ArrayList timesList;

ArrayList localReadingsList;
ArrayList localTimesList;


// FONT VARIABLES
public PFont robotoMed8;
public PFont robotoSemiBold9;
public PFont robotoMed11;
public PFont robotoSemiBold11;
public PFont robotoMed14;
public PFont robotoSemiBold14i;
public PFont robotoSemiBold19;
public PFont robotoMed26;

// The most recently streamed value, for use in labels.
/*
 * References to this can be changed to use data[dataCursor - 1] I suppose;
 * where dataCursor > 0.
 */
Float mostRecentData = 0.0;

// Serial port resource.
public Serial port;

// State variable for beginning a new measurement
public int start_flag = 0;

boolean mouseover = true;
boolean serialDebugFeature = false;   //defines whether feature is available; draw will hide button if off
boolean serialDebug = false;          //defines current state -- draw will show/hide window (Note: Hide window doesn't currently work on linux)
boolean enviroDebugFeature = false;
boolean enviroDebug = false;
 
Textarea debugLabelArea0;
Textarea debugValueArea0;
Textarea debugLabelArea1;
Textarea debugValueArea1;

LinkedList timestampList;

int exceptions = 0;
int indexErrors = 0;
boolean IndexOutOfRange = false;

SerialDebuggerWindow winSerialDebug;
JFileChooser fc = new JFileChooser(); 

boolean exitFlag = false;

ArrayList CPUUsages;
java.lang.management.OperatingSystemMXBean o;
com.sun.management.OperatingSystemMXBean osMxBean;
java.lang.management.RuntimeMXBean rtMxBean;
int nProcessors;
long lastCPUTime;
long lastUptime;
boolean threading = false;

//counter for draw() loop
int drawCount = 0;
int linuxWinDelay = 0;

public ControlFont cfont;

//DEFINES BOTTOM OF GRAPH ON SCREEN
int graphYmax = 400;

public String logStamp() {
   return nf(float(millis())/1000,5,3);
}

void setup()   //runs at start of application
{
  size(661,560,JAVA2D);   //resized in Draw() if debug is selected.  But mouse activity outside this initial "size()" is not processed! 
      
  //CREATE FONTS... 
  robotoMed8 =       createFont("RobotoMono-Medium.ttf",8);
  robotoSemiBold9 =  createFont("RobotoMono-SemiBold.ttf",9);
  //robotoSemiBold10 = createFont("RobotoMono-SemiBold.ttf",10);
  robotoMed11 =      createFont("RobotoMono-Medium.ttf",11);
  robotoSemiBold11 = createFont("RobotoMono-SemiBold.ttf",11);
  robotoMed14 =      createFont("RobotoMono-Medium.ttf",14);
  robotoSemiBold14i= createFont("RobotoMono-SemiBoldItalic.ttf",14);
  robotoSemiBold19 = createFont("RobotoMono-SemiBold.ttf",19);
  robotoMed26 =      createFont("RobotoMono-Medium.ttf",26);
    
  //cfont = new ControlFont(arial11);
  cfont = new ControlFont(robotoMed11);
  
  frameRate(24);
  
  CPUUsages = new ArrayList();
  
  o = java.lang.management.ManagementFactory.getOperatingSystemMXBean();
  if (o instanceof com.sun.management.OperatingSystemMXBean)
  {
    osMxBean = (com.sun.management.OperatingSystemMXBean) o;
    nProcessors = osMxBean.getAvailableProcessors();
  }
  lastCPUTime = 1;
  lastUptime = 1;
  rtMxBean = java.lang.management.ManagementFactory.getRuntimeMXBean();

  //CREATE NEW MEASUREMENT WINDOW
  winNewMeasurement = new NewMeasurementWindow("New", 300, 300);
  winNewMeasurement.getSurface().setVisible(false);   //hide until needed.  This fails on Linux as of 2021-08-22
 
  graphBuffer = createGraphics(600, graphYmax-1, JAVA2D); 
  
  //GET SETTINGS/OPTIONS FROM ./data/peregrine.conf file
  Configuration pconfig = new Configuration();
  try  {
    pconfig.load(createInput("Peregrine.conf"));
    mouseover = pconfig.getBooleanProperty("Environment.GUI.Graph.MouseoverEffects", true);
    serialDebugFeature = pconfig.getBooleanProperty("Developer.Serial.Debugger", false);
    enviroDebugFeature = pconfig.getBooleanProperty("Developer.Environment.Debugger", false);
    INPUT_TYPE = INPUT_OPENLPM; // autodetect, no longer need this...  pconfig.getIntProperty("Comm.Serial.Protocol", INPUT_OPENLPM);
    defaultBaudRate = pconfig.getIntProperty("Comm.Serial.Baud",9600);
    autorefresh = 1; //  always used, no longer optional.    =pconfig.getIntProperty("Comm.Serial.Autorefresh", 0);
    threading = pconfig.getBooleanProperty("Environment.Threading", false);
    linuxWinDelay = pconfig.getIntProperty("Linux.WindowHide.Delay",250);  //ms delay between visible and invisible (otherwise linux doesn't handle hidden windows correctly)
  }
  catch (IOException e)
  {
    exceptions++;
  }
  

  //CREATE SERIAL DEBUG WINOW (if feature selected)
  //serialDebugFeature value, read from config file, controls serial debug window as follows:
  //    serialDebugFeature true: Create window, set Serial button visible, button will toggle serialDebug flag on/off.
  //    serialDebugFeature false = Window not created, Serial button invisible.  serialDebug stays false, preventing
  //         any attempts writing to non-existent controls on non-existent window.
  if(serialDebugFeature) {
   winSerialDebug = new SerialDebuggerWindow("Serial Console",398,600);  //creates window with controls
   winSerialDebug.getSurface().setVisible(false);  //hide window until requested.  Additional kludge in draw() needed for linux.
   serialDebug=false;  //state will be changed by serialDebugButton toggle.
  }
  
  // Set system look and feel 
  try
  { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); } 
  catch (Exception e)
  { }
  fc = new JFileChooser(); 
  
  timestampList = new LinkedList();
  
  // Set up GUI.
  GUISetup();
  surface.setTitle("Peregrine - " + version);
  
  // Set up data collection
  DataSetup();
}

void draw()  {
  background(color(255,255,255));
  
  //surfaces not displayed properly on linux when set invisible in setup().  This kludge makes it right.
  if (drawCount<2) {
    drawCount++;   // [0, 1, 2]
    if (drawCount==1) {  //second draw() loop; first one draws everything first time
      if (platform==LINUX) {
          winNewMeasurement.getSurface().setVisible(true);
          if(serialDebugFeature) winSerialDebug.getSurface().setVisible(true);
          delay(linuxWinDelay);
          winNewMeasurement.getSurface().setVisible(false);
          if(serialDebugFeature) winSerialDebug.getSurface().setVisible(false);
      }
    }
  }
    
  if(enviroDebugFeature) {
    debugButton.setVisible(true);
    }
    else {
        debugButton.setVisible(false);
      }
   
  if(enviroDebug) {
    surface.setSize(1061,560);
  }
  else {
    surface.setSize(661,560);
  }  

  if(serialDebugFeature) {  //means serial debug window will have been created in setup(), so show toggle button
    serialDebugButton.setVisible(true);
    }
    else {
      serialDebugButton.setVisible(false);
    }
    
  if(connected) {
     if (millis()-connectionTime >1500) {
        protocolLabel.setVisible(true);
        protocolLabel.setText("Recv:\n  "+ split(LPMNames[INPUT_TYPE],"_")[1] + "(" + str(int(packets)) + " packets)" );
     }
  }
  else {
    protocolLabel.setText("");
    protocolLabel.setVisible(false);
  }
    
  //reposition/resize dropdowns, since ControP5 ScrollableList currently doesn't yet support "UP" direction  
  if(BaudSelector.isOpen()) {
    int ctrlHeight = (BaudSelector.getItems().size()+1)*BaudSelectorItemHeight;
    if(ctrlHeight>maxSelectorHeight) {ctrlHeight=maxSelectorHeight;}
    BaudSelector.setHeight(ctrlHeight);
    BaudSelector.setPosition(460, 445-ctrlHeight+BaudSelectorItemHeight);
  }
  else {
     BaudSelector.setPosition(460, 445);
  }
  
  if(COMSelector.isOpen()) {
      int ctrlHeight = (COMSelector.getItems().size()+1)*BaudSelectorItemHeight;
      if(ctrlHeight>maxSelectorHeight) {ctrlHeight=maxSelectorHeight;}
      COMSelector.setHeight(ctrlHeight);
      COMSelector.setPosition(514, 445-ctrlHeight+COMSelectorItemHeight);
      
  }
  else {
      COMSelector.setPosition(514,445);
  }
  
  try
  {
    if(autorefresh == 1) thread("refreshSerial");
    drawFn();
    
    if(threading)
    {
      if(saveDataFlag)
      {
        saveDataFlag = false;
        thread("saveData");
      }
      if(saveGraphFlag)
      {
        saveGraphFlag = false;
        thread("saveGraph");
      }
    }
    else
    {
      if(saveDataFlag) saveData();
      if(saveGraphFlag) saveGraph();
    }
  }
  catch (NullPointerException e)
  {
    exceptions++;
  }
  catch (IndexOutOfBoundsException e)
  {
    exceptions++;
  }
}

void alert(String text, int alertLevel)   //level=0 "Info", level=1 "Warning", level=2 "Error" 
{ 
  messageLabel.setText(text);
  switch(alertLevel) {
    case 0 : 
      messageLabel.setColorValue(color(0, 0, 0));
      //messageLabel.setFont(arial11);
      messageLabel.setFont(robotoMed11);
      break;
    case 1 :
      messageLabel.setColorValue(color(#9D5508));
      //messageLabel.setFont(arial11);
      messageLabel.setFont(robotoMed11);
      break;
    case 2 :
      messageLabel.setColorValue(color(255,0,0));
      //messageLabel.setFont(arialB11);
      messageLabel.setFont(robotoMed11);
      break;
    }
}

void alert(String text) {
 alert(text,0);
 }

void nonMouseOver()
{
  graphMouseover = false;
    
  floatingTimeLabel.setPosition(-30, -30);
  floatingPowerLabel.setPosition(-30, -30);
  
  // Convert the current reading to a string and write it to the label
  Float current = mostRecentData;
  current *= 10;
  current = float(round(current));
  current /= 10;
  String currentReadingText = current.toString();
  while(currentReadingText.length() < 7)
  {
    currentReadingText = " " + currentReadingText;
  }
  
  currentReadingLabelLabel.setText("Current Reading");
  currentReadingLabel.setColor(color(0, 0, 0));
  
  currentReadingLabel.setText(currentReadingText + "mW");
  //currentReadingLabel.setText("99999.9mW");
}

Float rawAverage = 0.0;
boolean graphMouseover = false;
boolean lastMouseState = false;
int lastMouseButton = 0;
boolean SelectionBox = false;
boolean CreatingSelectionBox = false;
int StationarySelectionBoxIndex = 0;
int StationarySelectionBoxX = 0;
int StationarySelectionBoxY = 0;
int StationarySelectionBoxDesiredTime = 0;
int MovingSelectionBoxIndex = 0;
int MovingSelectionBoxX = 0;
int MovingSelectionBoxY = 0;
int MovingSelectionBoxDesiredTime = 0;

Float SelectionBoxPeak = 0.0;
Float SelectionBoxMin = 0.0;
Float SelectionBoxAverage = 0.0;

int pThreshold = 0;
int pTime = 0;

void drawFn()
{
  if(start_flag == 1) doStart();
  if(start_flag == 2) doParameterizedStart(pThreshold, pTime);
  //if(INPUT_TYPE == INPUT_KENOMETER && !kenometerHandshake && port != null) port.write(0xFF);
  
  HandshakeProcess();
    
  localReadingsList = new ArrayList(readingsList);
  localTimesList = new ArrayList(timesList);
  
  boolean mouseState = mousePressed;
  int mouseBtn = mouseButton;
  
  List mouseoverList = cp5.getWindow().getMouseOverList();
  String mousedControl = "";
  if(mouseoverList.size() > 0) mousedControl = ((ControllerInterface)mouseoverList.get(0)).getName();
  
  // Set the background color to white
  background(color(255, 255, 255));
  
  // Draw a graph on it
  CreateGraph(49, 30, 601, graphYmax, 0xAA, color(255, 255, 255), 25.0);
  
  Integer desiredTime = 0;
  int selectedIndex = 0;
  
  int xPos = pmouseX;
  int yPos = pmouseY;
  if(mouseover && xPos > 49 && xPos < 650 && yPos > 30 && yPos < 430 && localReadingsList.size() > 0 && ( !mouseState || mouseBtn != 37 ) ) // ( ( !mouseState || mouseBtn != 39 ) || state != STATE_DONE )
  {
    graphMouseover = true;
    if(mouseBtn == RIGHT) ResetSelectionBox();  //39=RIGHT
    stroke(color(0, 0, 0));

    Integer last = 0;
    try { last = (Integer)localTimesList.get(localTimesList.size() - 1); } catch (Exception e) { exceptions++; }
    String floatingLabelText = "empty";
    
    float vertCurPos = 0;
    float horiCurPos = 0;
    Integer selectedTime = 0;
    Float selectedReading = 0.0;
    
    if( ( ( xPos - 49 ) / 600.0 ) * graphTime < ( last - graphStart ) )
    {
      //Float dataPointsPerTime = ( localReadingsList.size() / ( (float)last - (float)graphStart ) );
      desiredTime = (int)( ( ( xPos - 49 ) / 600.0 ) * graphTime );
      
      int index = BinarySearch(localTimesList, (int)(graphStart + desiredTime), 0, localTimesList.size() - 1);
      
      int[] values = {0, 0, 0};
      
      if(index > 0) values[0] = (int)abs( (Integer)localTimesList.get(index - 1) - desiredTime - graphStart ); else values[0] = (int)pow(2, 31);
      values[1] = (int)abs( (Integer)localTimesList.get(index    ) - desiredTime - graphStart );
      if(index < localTimesList.size() - 1) values[2] = (int)abs( (Integer)localTimesList.get(index + 1) - desiredTime - graphStart ); else values[2] = (int)pow(2, 31);
                       
      int delta = 0;
      //int target = millis();
      for(int i = 0; i < 3; i++)
        if(values[i] < values[delta]) delta = i;
        
      index += delta - 1;
      
      selectedIndex = index;
      if(selectedIndex >= localReadingsList.size() && localReadingsList.size() > 0) selectedIndex = localReadingsList.size() - 1;
      
      Integer time = (Integer)localTimesList.get(index);
      Float reading = (Float)localReadingsList.get(index);
      
      vertCurPos = (int)( ( ( time - graphStart ) / (float)graphTime ) * 600.0 );
      //horiCurPos = (int)( ( reading / (float)graphRange ) * 400.0 );
      horiCurPos = (int)( ( reading / (float)graphRange ) * graphYmax );  //MOVEUP10
      
      selectedTime = time;
      selectedReading = (Float)localReadingsList.get(index);
    }
    else
    {
      desiredTime = (int)( ( ( xPos - 49 ) / 600.0 ) * graphTime );
      vertCurPos = (int)( ( ( last - graphStart ) / (float)graphTime ) * 600.0 );
      //horiCurPos = (int)( ( (Float)localReadingsList.get(localReadingsList.size() - 1) / (float)graphRange ) * 400.0 );
      horiCurPos = (int)( ( (Float)localReadingsList.get(localReadingsList.size() - 1) / (float)graphRange ) * graphYmax );  //MOVEUP10
      selectedTime = last;
      selectedReading = (Float)localReadingsList.get(localReadingsList.size() - 1);
      selectedIndex = localReadingsList.size() - 1;
    }
    
    Float value = (selectedTime - graphStart) * 1.0;
    value /= 100;
    value = (float)round(value);
    value /= 10;
    floatingLabelText = value.toString();
    floatingTimeLabel.setText(floatingLabelText);
    
    for(int i = 0; i < 11; i++)
    {
      pLabels[i].setPosition(-100, 0);
    }
    
    for(int i = 0; i < 10; i++)
    {
      tLabels[i].setPosition(-100, 0);
    }
    
    // Convert the current reading to a string and write it to the label
    Float selected = selectedReading;
    selected *= 10;
    selected = float(round(selected));
    selected /= 10;
    String currentReadingText = selected.toString();
    
    while(currentReadingText.length() < 7)
    {
      currentReadingText = " " + currentReadingText;
    }
    currentReadingLabel.setText(currentReadingText + "mW");
    //currentReadingLabel.setText("99999.0mW");
    
    currentReadingLabelLabel.setText("Selected Reading");
    currentReadingLabel.setColor(lineColor);
    
    floatingPowerLabel.setText(currentReadingText);

    //line(xPos, 30, xPos, 430);
    //line(vertCurPos + 50, 30, vertCurPos + 50, 430);
    line(vertCurPos + 50, 30, vertCurPos + 50, graphYmax+30);  //MOVEUP10
    //floatingTimeLabel.setPosition(vertCurPos + 50 - ( getStringWidth(floatingLabelText) / 2 ) - 3, 432);
    floatingTimeLabel.setPosition(vertCurPos + 50 - ( getStringWidth(floatingLabelText) / 2 ) - 3, graphYmax+32);  //MOVEUP10
    
    if(selected > 0.0)
    {
      //line(50, 430 - horiCurPos, 649, 430 - horiCurPos);
      line(50, 430 - horiCurPos, 649, graphYmax+30 - horiCurPos);  //MOVEUP10
      //floatingPowerLabel.setPosition(50 - getStringWidth(currentReadingText) - 6, 430 - horiCurPos - 4);
      floatingPowerLabel.setPosition(50 - getStringWidth(currentReadingText) - 6, graphYmax+30 - horiCurPos - 4);   //MOVEUP10
    }
    else
    {
      floatingPowerLabel.setPosition(-50, -50);
    }
    //floatingPowerLabel.setPosition(50 - ( ( currentReadingText.length() - 1 ) * 6 ) + ( countOnes(currentReadingText) * 3 ) - 7, 430 - horiCurPos - 4);
    
    
  }
  else if(mouseover && xPos > 49 && xPos < 650 && yPos > 30 && yPos < 430 && localReadingsList.size() > 0 /*&& ( state == STATE_DONE || state == STATE_GRAPHING )*/ )
  {
    nonMouseOver();
    
    if(mouseState)
    {
      CreatingSelectionBox = true;
      
      if(!lastMouseState)
      {
        if(mouseBtn == 37)
        {
          SelectionBox = true;
        
          StationarySelectionBoxDesiredTime = min((int)( ( ( xPos - 49 ) / 600.0 ) * graphTime ), (Integer)localTimesList.get(localTimesList.size() - 1) - graphStart);
          int index = BinarySearch(localTimesList, (int)(graphStart + StationarySelectionBoxDesiredTime), 0, localTimesList.size() - 1);
          int[] values = {0, 0, 0};
          
          if(index > 0) values[0] = (int)abs( (Integer)localTimesList.get(index - 1) - StationarySelectionBoxDesiredTime - graphStart ); else values[0] = (int)pow(2, 31);
          values[1] = (int)abs( (Integer)localTimesList.get(index    ) - StationarySelectionBoxDesiredTime - graphStart );
          if(index < localTimesList.size() - 1) values[2] = (int)abs( (Integer)localTimesList.get(index + 1) - StationarySelectionBoxDesiredTime - graphStart ); else values[2] = (int)pow(2, 31);
                           
          int delta = 0;
          //int target = millis();
          for(int i = 0; i < 3; i++)
            if(values[i] < values[delta]) delta = i;
            
          index += delta - 1;
          
          StationarySelectionBoxIndex = index;
          if(StationarySelectionBoxIndex >= localReadingsList.size() && localReadingsList.size() > 0) StationarySelectionBoxIndex = localReadingsList.size() - 1;
        }
      }
      
      MovingSelectionBoxDesiredTime = min((int)( ( ( xPos - 49 ) / 600.0 ) * graphTime ), (Integer)localTimesList.get(localTimesList.size() - 1) - graphStart);
      int index = BinarySearch(localTimesList, (int)(graphStart + MovingSelectionBoxDesiredTime), 0, localTimesList.size() - 1);
      int[] values = {0, 0, 0};
      
      if(index > 0) values[0] = (int)abs( (Integer)localTimesList.get(index - 1) - MovingSelectionBoxDesiredTime - graphStart ); else values[0] = (int)pow(2, 31);
      values[1] = (int)abs( (Integer)localTimesList.get(index    ) - MovingSelectionBoxDesiredTime - graphStart );
      if(index < localTimesList.size() - 1) values[2] = (int)abs( (Integer)localTimesList.get(index + 1) - MovingSelectionBoxDesiredTime - graphStart ); else values[2] = (int)pow(2, 31);
                       
      int delta = 0;
      //int target = millis();
      for(int i = 0; i < 3; i++)
        if(values[i] < values[delta]) delta = i;
        
      index += delta - 1;
      
      MovingSelectionBoxIndex = index;
      if(MovingSelectionBoxIndex >= localReadingsList.size() && localReadingsList.size() > 0) MovingSelectionBoxIndex = localReadingsList.size() - 1;
      
      Float SBMin = 9999.9;
      Float SBMax =    0.0;
      int SBBegin = min(MovingSelectionBoxIndex, StationarySelectionBoxIndex);
      int SBEnd = max(MovingSelectionBoxIndex, StationarySelectionBoxIndex);
      
      for(int i = SBBegin; i <= SBEnd; i++)
      {
        Float test = (Float)localReadingsList.get(i);
        if(test < SBMin) SBMin = test;
        if(test > SBMax) SBMax = test;
      }
      
      //Integer stationaryTime = (Integer)localTimesList.get(index);
      //Float stationaryReading = (Float)localReadingsList.get(index);
      
      int SBX1 = min(MovingSelectionBoxDesiredTime, StationarySelectionBoxDesiredTime);
      int SBX2 = max(MovingSelectionBoxDesiredTime, StationarySelectionBoxDesiredTime);
      if(SBX1 > (Integer)localTimesList.get(localTimesList.size() - 1)) SBX1 = (Integer)localTimesList.get(localTimesList.size() - 1);
      if(SBX2 > (Integer)localTimesList.get(localTimesList.size() - 1)) SBX2 = (Integer)localTimesList.get(localTimesList.size() - 1);
        
      //StationarySelectionBoxX = (int)( ( ( (Integer)localTimesList.get(SBBegin) - graphStart ) / (float)graphTime ) * 600.0 );
      StationarySelectionBoxX = (int)( ( ( SBX1 ) / (float)graphTime ) * 600.0 );
      //StationarySelectionBoxY = (int)( ( SBMax / (float)graphRange ) * 400.0 );
      StationarySelectionBoxY = (int)( ( SBMax / (float)graphRange ) * graphYmax );   //MOVEUP10
      //MovingSelectionBoxX = (int)( ( ( (Integer)localTimesList.get(SBEnd) - graphStart ) / (float)graphTime ) * 600.0 ) + 1;
      MovingSelectionBoxX = (int)( ( ( SBX2 ) / (float)graphTime ) * 600.0 );
      //MovingSelectionBoxY = (int)( ( SBMin / (float)graphRange ) * 400.0 );
      MovingSelectionBoxY = (int)( ( SBMin / (float)graphRange ) * graphYmax ); //MOVEUP10
    }
    else
    {
      if(lastMouseState)
      {
        // Now update the start and end indices;
        //SelectionBox = false;
      }
    }
  }
  else
  {
    nonMouseOver();
  }
  
  if(SelectionBox)
  {
    if(!mouseState || CreatingSelectionBox)
    {
      //int SIndex = BinarySearch(localTimesList, (int)(graphStart + StationarySelectionBoxDesiredTime), 0, localTimesList.size() - 1);
      //int MIndex = BinarySearch(localTimesList, (int)(graphStart + MovingSelectionBoxDesiredTime), 0, localTimesList.size() - 1);
      
      Float SBMin = 9999.9;
      Float SBMax =    0.0;
      int SBBegin = min(MovingSelectionBoxIndex, StationarySelectionBoxIndex);
      int SBEnd = max(MovingSelectionBoxIndex, StationarySelectionBoxIndex);
      
      for(int i = SBBegin; i <= SBEnd; i++)
      {
        Float test = (Float)localReadingsList.get(i);
        if(test < SBMin) SBMin = test;
        if(test > SBMax) SBMax = test;
      }
      
      SelectionBoxMin = SBMin;
        
      //StationarySelectionBoxX = (int)( ( ( (Integer)localTimesList.get(SBBegin) - graphStart ) / (float)graphTime ) * 600.0 );
      //StationarySelectionBoxY = (int)( ( SBMax / (float)graphRange ) * 400.0 );
      StationarySelectionBoxY = (int)( ( SBMax / (float)graphRange ) * graphYmax );  //MOVEUP10
      //MovingSelectionBoxX = (int)( ( ( (Integer)localTimesList.get(SBEnd) - graphStart ) / (float)graphTime ) * 600.0 ) + 1;
      //MovingSelectionBoxY = (int)( ( SBMin / (float)graphRange ) * 400.0 );
      MovingSelectionBoxY = (int)( ( SBMin / (float)graphRange ) * graphYmax );  //MOVEUP10
      
      // Adjustments
      StationarySelectionBoxX += 0;
      StationarySelectionBoxY += -1;
      MovingSelectionBoxX += 0;
      MovingSelectionBoxY += -1;
      if(StationarySelectionBoxY < 0) StationarySelectionBoxY = 0;
      if(MovingSelectionBoxY < 0) MovingSelectionBoxY = 0;
      //if(StationarySelectionBoxY > 400) StationarySelectionBoxY = 400;
      if(StationarySelectionBoxY > 400) StationarySelectionBoxY = graphYmax;   //MOVEUP10
      //if(MovingSelectionBoxY > 400) MovingSelectionBoxY = 400;
      if(MovingSelectionBoxY > 400) MovingSelectionBoxY = graphYmax;  //MOVEUP10
    }
    
    stroke(color(0, 0, 0));
    //line(StationarySelectionBoxX + 50, 31, StationarySelectionBoxX + 50, 429);
    line(StationarySelectionBoxX + 50, 31, StationarySelectionBoxX + 50, graphYmax+29);  //MOVEUP10
    line(50, 430 - StationarySelectionBoxY, 649, 430 - StationarySelectionBoxY);
    //line(MovingSelectionBoxX + 50, 31, MovingSelectionBoxX + 50, 429);
    line(MovingSelectionBoxX + 50, 31, MovingSelectionBoxX + 50, graphYmax+29);  //MOVEUP10
    //line(50, 430 - MovingSelectionBoxY, 649, 430 - MovingSelectionBoxY);
    line(50, 430 - MovingSelectionBoxY, 649, graphYmax+30 - MovingSelectionBoxY);  //MOVEUP10
    fill(color(30, 144, 255, 50));
    //rect(StationarySelectionBoxX + 50, 430 - StationarySelectionBoxY, MovingSelectionBoxX - StationarySelectionBoxX, StationarySelectionBoxY - MovingSelectionBoxY);
    rect(StationarySelectionBoxX + 50, (graphYmax+30) - StationarySelectionBoxY, MovingSelectionBoxX - StationarySelectionBoxX, StationarySelectionBoxY - MovingSelectionBoxY);  //MOVEUP10
    
    SelectionBoxPeak = 0.0;
    Float SelectionBoxTotal = 0.0;
    int SelectionBoxCount = 0;
    for(int i = min(StationarySelectionBoxIndex, MovingSelectionBoxIndex); i <= max(StationarySelectionBoxIndex, MovingSelectionBoxIndex); i++)
    {
      Float value = (Float)localReadingsList.get(i);
      if(value > SelectionBoxPeak) SelectionBoxPeak = value;
      SelectionBoxTotal += value;
      SelectionBoxCount++;
    }
    SelectionBoxAverage = SelectionBoxTotal / SelectionBoxCount;
    
    SelectionBoxPeak *= 10;
    SelectionBoxPeak = float(round(SelectionBoxPeak));
    SelectionBoxPeak /= 10;
    
    String peakReadingText = SelectionBoxPeak.toString();
    while(peakReadingText.length() < 7)
    {
      peakReadingText = " " + peakReadingText;
    }
    peakReadingLabel.setText(peakReadingText + "mW");
    //peakReadingLabel.setText("99999.9mW");
    peakReadingLabel.setColor(lineColor);
    peakReadingLabelLabel.setText("Selection Peak");
    
    Float SelectionBoxRoundedAverage = SelectionBoxAverage;
    SelectionBoxRoundedAverage *= 10;
    SelectionBoxRoundedAverage = float(round(SelectionBoxRoundedAverage));
    SelectionBoxRoundedAverage /= 10;
    
    String averageReadingText = SelectionBoxRoundedAverage.toString();
    while(averageReadingText.length() < 7)
    {
      averageReadingText = " " + averageReadingText;
    }
    averageReadingLabel.setText(averageReadingText + "mW");
    //averageReadingLabel.setText("99999.9mW");
    averageReadingLabel.setColor(lineColor);
    averageReadingLabelLabel.setText("Selection Average");
  }
  else
  {
    Float peak = maxData;
    peak *= 10;
    peak = float(round(peak));
    peak /= 10;
    
    String peakReadingText = peak.toString();
    while(peakReadingText.length() < 7)
    {
      peakReadingText = " " + peakReadingText;
    }
    peakReadingLabel.setText(peakReadingText + "mW");
    //peakReadingLabel.setText("99999.9mW");
    peakReadingLabel.setColor(color(0, 0, 0));
    peakReadingLabelLabel.setText("Peak");
    
    Float average = 0.0;
    rawAverage = 0.0;
    if(localReadingsList.size() > 0)
    {
      for(int i = 0; i < localReadingsList.size(); i++) average += (Float)localReadingsList.get(i);
      average /= localReadingsList.size();
      rawAverage = average;
      average *= 10;
      average = float(round(average));
      average /= 10;
    }
    
    String averageReadingText = average.toString();
    while(averageReadingText.length() < 7)
    {
      averageReadingText = " " + averageReadingText;
    }
    averageReadingLabel.setText(averageReadingText + "mW");
    //averageReadingLabel.setText("99999.9mW");
    averageReadingLabel.setColor(color(0, 0, 0));
    averageReadingLabelLabel.setText("Average");
  }
  
  lastMouseState = mouseState;
  lastMouseButton = mouseBtn;
 
  
  int datasetDuration = 0;
  if(localTimesList.size() > 0) datasetDuration = (Integer)localTimesList.get(localTimesList.size() - 1) - (Integer)localTimesList.get(0);
  
  // Prepare to draw lines.
  stroke(color(0, 0, 0));

  //draw boxes
  // Serial Baud, Com, Refresh
  line(458, 443, 650, 443);  //top
  line(458, 443, 458, 476);  //left
  line(650, 443, 650, 476);  //right
  //line(650, 461, 458, 461);  //no bottom line needed, together with connect button
    
  //connect button
  line(458,476,458,506);
  line(458,506,650,506);
  line(650,506,650,476);
  //line(650,476,458,476);  //no top line needed; together with baud/com/refresh
    
  // Message
  line( 10, 443, 455, 443);
  line(455, 443, 455, 461);
  line(455, 461,  10, 461);
  line( 10, 461,  10, 443);
  
  // Current reading
  line( 10, 463, 157, 463);
  line( 10, 463,  10, 506);
  line(157, 463, 157, 506);
  line( 10, 506, 157, 506);
  
  // Peak
  line(159, 463, 305, 463);
  line(159, 463, 159, 506);
  line(305, 463, 305, 506);
  line(159, 506, 305, 506);
  
  // Average
  line(307, 463, 455, 463);
  line(307, 463, 307, 506);
  line(455, 463, 455, 506);
  line(307, 506, 455, 506);

  //smooth();
  
  
  if(enviroDebug)
  {
    line(661,  30, 859,  30);
    line(859,  30, 859, 506);
    line(859, 506, 661, 506);
    line(661, 506, 661,  30);
    
    line(861,  30, 1059,  30);
    line(1059,  30, 1059, 506);
    line(1059, 506, 861, 506);
    line(861, 506, 861,  30);
    
    String debugLabels0 = "";
    String debugValues0 = "";
    String debugLabels1 = "";
    String debugValues1 = "";
    
    debugLabels0 += "Peregrine" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Lifetime" + "\n";
    debugValues0 += millis() + "\n";
    
    debugLabels0 += " Framerate" + "\n";
    debugValues0 += frameRate + "\n";
    
    debugLabels0 += " State" + "\n";
    debugValues0 += stateNames[state] + "\n";
    
    debugLabels0 += " Exit Flag" + "\n";
    debugValues0 += exitFlag + "\n";
    
    debugLabels0 += " Exceptions" + "\n";
    debugValues0 += exceptions + "\n";

    debugLabels0 += "\n";
    debugValues0 += "\n";
    
    debugLabels0 += "Execution" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Graph Render" + "\n";
    debugValues0 += graphRenderTime + "\n";
    
    debugLabels0 += " Line Render" + "\n";
    debugValues0 += lineRenderTime + "\n";
    
    debugLabels0 += " Peak Search" + "\n";
    debugValues0 += peakSearchTime + "\n";
    
    debugLabels0 += "\n";
    debugValues0 += "\n";
    
    debugLabels0 += "Concurrency" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Threads" + "\n";
    debugValues0 += java.lang.Thread.activeCount() + "\n";
    
    debugLabels0 += " List Changes" + "\n";
    debugValues0 += readingsList.size() - localReadingsList.size() + "\n";
    
    debugLabels0 += "\n";
    debugValues0 += "\n";
    
    debugLabels0 += "Dataset" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Readings" + "\n";
    debugValues0 += readingsList.size() + "\n";
    
    debugLabels0 += " Times" + "\n";
    debugValues0 += timesList.size() + "\n";
    
    debugLabels0 += " Max." + "\n";
    debugValues0 += maxData + "\n";
    
    debugLabels0 += " Average" + "\n";
    debugValues0 += rawAverage + "\n";
    
    debugLabels0 += " Duration" + "\n";
    debugValues0 += datasetDuration + "\n";
    
    debugLabels0 += "\n";
    debugValues0 += "\n";
    
    debugLabels0 += "Graph" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Start" + "\n";
    debugValues0 += graphStart + "\n";
    
    debugLabels0 += " Duration" + "\n";
    debugValues0 += graphTime + "\n";
    
    debugLabels0 += " Threshold" + "\n";
    debugValues0 += graphThreshold + "\n";
    
    debugLabels0 += " Max" + "\n";
    debugValues0 += graphRange + "\n";
    
    debugLabels0 += " Values per Pixel" + "\n";
    debugValues0 += readingsPerPixel + "\n";
    
    debugLabels0 += " Step" + "\n";
    debugValues0 += arrayStep + "\n";
    
    debugLabels0 += " Rerender" + "\n";
    debugValues0 += rerender + "\n";
    
    debugLabels0 += "\n";
    debugValues0 += "\n";
    
    debugLabels0 += "Serial" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Connected" + "\n";
    debugValues0 += connected + "\n";
    
    debugLabels0 += " Protocol" + "\n";
    debugValues0 += LPMNames[INPUT_TYPE] + "\n";

    debugLabels0 += " BAUD_RATE\n";
    debugValues0 += str(BAUD_RATE) + "\n";
    
    debugLabels0 += " Datarate (Hz)" + "\n";
    debugValues0 += speed + "\n";
    
    debugLabels0 += " Packets" + "\n";
    debugValues0 += packets + "\n";
    
    debugLabels0 += " Bytes" + "\n";
    debugValues0 += bytesReceived + "\n";
    
    debugLabels0 += " Delta" + "\n";
    if(connected) {
      debugValues0 += millis() - lastReceive + "\n";
    }
    else {
      debugValues0 += 0 +"\n";
    }
    
    debugLabels0 += " Elapsed" + "\n";
    debugValues0 += lastElapsed + "\n";
    
    debugLabels0 += " Malformed" + "\n";
    debugValues0 += malformedPackets + "\n";
    
    debugLabels0 += " Aborted" + "\n";
    debugValues0 += serialEventsAborted + "\n";
    
    debugLabels0 += "\n";
    debugValues0 += "\n";

    debugLabels0 += "Kenometer" + "\n";
    debugValues0 += "\n";
    
    debugLabels0 += " Handshaken" + "\n";
    debugValues0 += kenometerHandshake + "\n";
    
    debugLabels0 += " Attempts" + "\n";
    debugValues0 += kenometerHandshakeAttempts + "\n";
    
    debugLabels1 += "OS" + "\n";
    debugValues1 += "\n";
    
    debugLabels1 += " Name" + "\n";
    debugValues1 += System.getProperty("os.name") + "\n";
    
    debugLabels1 += " Version" + "\n";
    debugValues1 += System.getProperty("os.version") + "\n";
    
    debugLabels1 += " Architecture" + "\n";
    debugValues1 += System.getProperty("os.arch") + "\n";
    
    debugLabels1 += " Account" + "\n";
    debugValues1 += System.getProperty("user.name") + "\n";
    
    debugLabels1 += "\n";
    debugValues1 += "\n";
    
    debugLabels1 += "JVM" + "\n";
    debugValues1 += "\n";
    
    long CPUTime = osMxBean == null ? 1 : osMxBean.getProcessCpuTime();
    long uptime = rtMxBean == null ? 1 : rtMxBean.getUptime();
    long elapsedCPUTime = CPUTime - lastCPUTime;
    long elapsedTime = uptime - lastUptime;
    Float CPUUsage = Math.min(100F, elapsedCPUTime / (elapsedTime * 10000F * nProcessors));
    
    CPUUsages.add(CPUUsage);
    if(CPUUsages.size() > 24) CPUUsages.remove(0);
    Float CPUTotal = 0.0;
    for(int e = 0; e < CPUUsages.size(); e++) CPUTotal += (Float)CPUUsages.get(e);
    CPUTotal /= CPUUsages.size();
    
    debugLabels1 += " CPU Usage" + "\n";
    debugValues1 += CPUTotal + "\n";
    
    debugLabels1 += " RAM Allocated" + "\n";
    debugValues1 += Runtime.getRuntime().totalMemory() + "\n";
    
    debugLabels1 += " Uptime" + "\n";
    debugValues1 += uptime + "\n";
    
    debugLabels1 += " Version" + "\n";
    debugValues1 += System.getProperty("java.version") + "\n";
    
    debugLabels1 += " Vendor" + "\n";
    debugValues1 += System.getProperty("java.vendor") + "\n";
    
    lastCPUTime = CPUTime;
    lastUptime = uptime;
    
    debugLabels1 += "\n";
    debugValues1 += "\n";
    
    debugLabels1 += "GUI" + "\n";
    debugValues1 += "\n";
        
    debugLabels1 += " Mouseover" + "\n";
    debugValues1 += mousedControl + "\n";
    
    debugLabels1 += "\n";
    debugValues1 += "\n";
    
    debugLabels1 += "Cursor" + "\n";
    debugValues1 += "\n";
    
    debugLabels1 += " Graph Time" + "\n";
    debugValues1 += desiredTime + "\n";
    
    debugLabels1 += " Global Time" + "\n";
    debugValues1 += desiredTime + graphStart + "\n";
    
    if(selectedIndex >= readingsList.size() && readingsList.size() > 0)
    {
      selectedIndex = readingsList.size() - 1;
      indexErrors++;
      IndexOutOfRange = true;
    }
    
    debugLabels1 += " Selected Index" + "\n";
    debugValues1 += selectedIndex + "\n";
    
    debugLabels1 += " Out of Range" + "\n";
    debugValues1 += IndexOutOfRange + "\n";
    
    debugLabels1 += " Index Errors" + "\n";
    debugValues1 += indexErrors + "\n";
    
    debugLabels1 += " Selected Value" + "\n";
    if(graphMouseover) debugValues1 += (Float)readingsList.get(selectedIndex) + "\n"; else if (IndexOutOfRange) debugValues1 += "out of range\n"; else debugValues1 += "\n";
    
    debugLabels1 += " Selected Time" + "\n";
    if(graphMouseover) debugValues1 += (Integer)timesList.get(selectedIndex) + "\n"; else if (IndexOutOfRange) debugValues1 += "out of range\n"; else debugValues1 += "\n";
    
    debugLabels1 += " Loop Iterations" + "\n";
    debugValues1 += BinarySearchIterations + "\n";
    
    debugLabels1 += "\n";
    debugValues1 += "\n";
    
    debugLabels1 += "Selection Box" + "\n";
    debugValues1 += "\n";
    
    debugLabels1 += " Active" + "\n";
    debugValues1 += SelectionBox + "\n";
    
    debugLabels1 += " Creating" + "\n";
    debugValues1 += CreatingSelectionBox + "\n";
    
    debugLabels1 += " A - Time" + "\n";
    debugValues1 += StationarySelectionBoxDesiredTime + "\n";
    
    debugLabels1 += " A - Index" + "\n";
    debugValues1 += StationarySelectionBoxIndex + "\n";

    debugLabels1 += " A - X" + "\n";
    debugValues1 += StationarySelectionBoxX + "\n";
    
    debugLabels1 += " A - Y" + "\n";
    debugValues1 += StationarySelectionBoxY + "\n";
    
    debugLabels1 += " B - Time" + "\n";
    debugValues1 += MovingSelectionBoxDesiredTime + "\n";
    
    debugLabels1 += " B - Index" + "\n";
    debugValues1 += MovingSelectionBoxIndex + "\n";

    debugLabels1 += " B - X" + "\n";
    debugValues1 += MovingSelectionBoxX + "\n";
    
    debugLabels1 += " B - Y" + "\n";
    debugValues1 += MovingSelectionBoxY + "\n";

    debugLabels1 += " Min." + "\n";
    debugValues1 += SelectionBoxMin + "\n";
    
    debugLabels1 += " Max." + "\n";
    debugValues1 += SelectionBoxPeak + "\n";
    
    debugLabels1 += " Average" + "\n";
    debugValues1 += SelectionBoxAverage + "\n";
    
    debugLabels1 += "\n";
    debugValues1 += "\n";
    
    debugLabels1 += "Human Interface" + "\n";
    debugValues1 += "\n";
    
    debugLabels1 += " X Position" + "\n";
    debugValues1 += pmouseX + "\n";
    
    debugLabels1 += " Y Position" + "\n";
    debugValues1 += pmouseY + "\n";
    
    debugLabels1 += " Mouse Pressed" + "\n";
    debugValues1 += mousePressed + "\n";
    
    debugLabels1 += " Button" + "\n";
    debugValues1 += mouseButton + "\n";
    
    debugLabels1 += " Key Pressed" + "\n";
    debugValues1 += keyPressed + "\n";
    
    debugLabels1 += " Key" + "\n";
    if ( keyCode >= 65 && keyCode <= 90 || keyCode >= 48 && keyCode <= 57 ) debugValues1 += key + "\n";
    else debugValues1 += "\n";
    
    debugLabels1 += " Key Code" + "\n";
    debugValues1 += keyCode + "\n";
    
    debugLabelArea0.setText(debugLabels0);
    debugValueArea0.setText(debugValues0);
    debugLabelArea1.setText(debugLabels1);
    debugValueArea1.setText(debugValues1);
  }
  
  BinarySearchIterations = 0;
  IndexOutOfRange = false;
  CreatingSelectionBox = false;
  
  if(exitFlag)
  {
    //if(port != null)
    if(connected)
    {
      port.clear();
      port.stop();
      connected = false;
    }
    else
    {
      super.exit();
    }
  }






}
