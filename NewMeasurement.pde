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
 *****************************************************************************/

public class NewMeasurementWindow extends PApplet
{
  Peregrine parent;
  ControlP5 cp5;
    
  public Textfield nameText;
  public Textfield durationText;
  public Textfield thresholdText;
  public ScrollableList durationList;
  //public DropdownList durationList;
  public ColorPicker cp;
  //public CustomColorPicker cp;
  public Button closeButton;
  public Button startButton;
  public int winWidth = 212;
  public int winHeight = 187;
  
  public NewMeasurementWindow() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    winWidth=300;
    winHeight=300;
    }
    
  public NewMeasurementWindow(String theName, int theWidth, int theHeight) {
    super();
    winWidth=theWidth;
    winHeight=theHeight;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    }
    
  public void settings() {   
    smooth();
  }
  
  public void setup() {
    surface.setTitle("Measurement");
    surface.setSize(280,270);
    //surface.setResizable(true);
    frameRate(24);
    
    cp5 = new ControlP5(this);
    Textfield.cursorWidth = 1;  //cursorWidth is class static; set here for all instances of ControP5.Textfield
    
    
    cp5.addTextlabel("nameLabel")
      .setText("Name")
      .setPosition(0, 2)
      .setFont(cfont)
      .setColorValue(color(0, 0, 0))
      ;
              
    nameText = cp5.addTextfield("nameText")
       .setPosition(10,17)
       .setSize(200,16)
       .setFont(cfont)
       .setColor(color(0,0,0))
       .setColorBackground(color(255, 255, 255))
       .setColorForeground(color(0, 0, 0))
       .setColorActive(color(192, 192, 192))
       .setColorCursor(color(0,0,0));
     
   cp5.addTextlabel("durationLabel")
      .setText("Test Duration ( zero for indefinite )")
      .setPosition(0, 42)
      .setFont(cfont)
      .setColorValue(color(0, 0, 0))
      ;
      
  durationText = cp5.addTextfield("durationText")
     .setPosition(10,58)
     .setSize(50,16)
     .setFont(cfont)
     .setColor(color(0,0,0))
     .setColorBackground(color(255, 255, 255))
     .setColorForeground(color(0, 0, 0))
     .setColorActive(color(192, 192, 192))
     .setColorCursor(color(0,0,0))
     ;
         
   Label.setUpperCaseDefault(false);
   durationList = cp5.addScrollableList("DurationList")
       .setType(ScrollableList.DROPDOWN)
       .setPosition(70,59)
       .setWidth(65)
       .setFont(cfont)
       .setBackgroundColor(color(190))
       .setItemHeight(16)
       .setBarHeight(18)
       .setValue(1)
       ;
    
  durationList.addItem("Seconds", 0);
  durationList.addItem("Minutes", 1);
  durationList.addItem("Hours", 2);
  durationList.setValue(0);
  durationList.setColorBackground(color(60));
  durationList.setColorActive(color(255, 128));
  
  cp5.addTextlabel("thresholdLabel")
      .setText("Test Start Threshold (mW)")
      .setPosition(0, 82)
      .setFont(cfont)
      .setColorValue(color(0, 0, 0))
      ;
      
  thresholdText = cp5.addTextfield("thresholdText")
     .setPosition(10, 98)
     .setSize(50, 16)
     .setFont(cfont)
     .setColor(color(0,0,0))
     .setColorBackground(color(255, 255, 255))
     .setColorForeground(color(0, 0, 0))
     .setColorActive(color(192, 192, 192))
     ;
   //thresholdText.cursorWidth = 1;
   thresholdText.setColorCursor(color(0,0,0));
  
  cp5.addTextlabel("colorLabel")
      .setText("Line Color")
      .setFont(cfont)
      .setPosition(0, 122)
      .setColorValue(color(0, 0, 0))
      ;
  
  //cp = new CustomColorPicker(cp5, "ColorPicker");
  cp = new ColorPicker(cp5, "ColorPicker");
  cp.setPosition(8, 137)
          .setWidth(202)
          .setColorValue(color(255, 0, 0, 255))
          ;
   //cp.setItemSize(202, 10);
   
   closeButton = cp5.addButton("Close")
     .setPosition(75, 215)
     .setSize(55,30)
     //.setFont(cfont)
     .setFont(robotoMed14);
     ;
   
   startButton = cp5.addButton("Start")
     .setPosition(148,215)
     .setSize(55,30)
     .setFont(robotoMed14);
     //.setFont(cfont)
     ;

   durationText.setValue("30");
   thresholdText.setValue("10");
   durationList.bringToFront();
  }

  public void draw() {
      background(color(255, 255, 255));
  }


  public ControlP5 control() {
    return cp5;
  }
  
  void Start()
  {
    if(connected) {
      start_flag = 1;
      surface.setVisible(false);  //hide window
    }
    else {
      alert("     *****  ERROR:  PLEASE CONNECT FIRST!  *****",2);
    }  
      
  }
  
  void Close()
  {
    surface.setVisible(false);
  }
  
}
