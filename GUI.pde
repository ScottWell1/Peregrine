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

void GUISetup()
{
  cp5 = new ControlP5(this);

  for (int i = 0; i <= 10; i++)
  {
    String labelID = "powerLabel" + i;
    pLabels[i] =  cp5.addTextlabel(labelID);
  }
  
  for (int i = 0; i < 10; i++)
  {
    String labelID = "timeLabel" + i;
    tLabels[i] =  cp5.addTextlabel(labelID);
  }
            
  newMeasureButton = cp5.addButton("NewOption")
                    .setLabel("New Timed\nMeasurement")
                    .setFont(robotoMed14)
                    .setPosition(11,515)
                    .setSize(100,40)
                    .align(CENTER,CENTER,CENTER,TOP)
                    ;

  exportGraphButton = cp5.addButton("ExportGraphOption")
                   .setLabel("Save\nGraph")
                   .setFont(robotoMed14)
                   .setPosition(125,515)
                   .setSize(65,40)
                   .align(CENTER,CENTER,CENTER,TOP)
                   ;

  exportDataButton = cp5.addButton("ExportDataOption")
                   .setLabel("Save\nData")
                   .setFont(robotoMed14)
                   .setPosition(192,515)
                   .setSize(65,40)
                   .align(CENTER,CENTER,CENTER,TOP)
                   ;
                    
                    
  resetButton     = cp5.addButton("MonitorOption")
                    .setLabel("Reset\nGraph")
                    .setFont(robotoMed14)
                    .setPosition(271,515)
                    .setSize(65,40)
                    .align(CENTER,CENTER,CENTER,TOP)
                    ;
  
  connectButton =  cp5.addButton("Connect")
                   //.setPosition(588, 445)
                   .setPosition(465,468)
                   //.setSize(61,15)
                   .setSize(180,34)
                   //.setFont(robotoMed26)
                   //.setFont(arialB19)
                   .setFont(robotoSemiBold19)
                   .setColorBackground(color(8, 174, 8))
                   .setColorForeground(color(8, 205, 8))
                   .setColorActive(color(61, 243, 61))
                   ;


  //manual refreshButton eliminated, auto-refresh seems to work well.
  //refreshButton =  cp5.addButton("Refresh")
  //                 .setPosition(605, 445)
  //                 .setSize(44,15)
  //                 .setFont(cfont)
  //                 ;
 
     
  debugButton = cp5.addButton("toggleDebug")
                   .setLabel("DEBUG")
                   .setPosition(610,539)
                   .setSize(44,15)
                   //.setFont(arialB11)
                   .setFont(robotoSemiBold11)
                   .setColorBackground(color(0,0,0))
                   .setColorForeground(color(152,148,28))
                   //.setColorActive(color(61,243,61))
                   ;
  
  serialDebugButton = cp5.addButton("toggleSerialDebug")
                   .setLabel("SERIAL")
                   .setPosition(610,520)
                   .setSize(44,15)
                   //.setFont(arialB11)
                   .setFont(robotoSemiBold11)
                   .setColorBackground(color(0,0,0))
                   .setColorForeground(color(152,148,28))
                   //.setColorActive(color(61,243,61))
                   ;
                   
  protocolLabel = cp5.addTextlabel("Protocol")
              .setText("Not Connected")
              .setPosition(370,520)
              //.setMultiline(true)  //causes index out of bounds error?  Not needed, accepts multiline with \n 
              //.setWidth(20)  //does nothing
              //.align(CENTER,CENTER,CENTER,CENTER)  //does nothing
              //.setColorBackground(color(255,0,0))  //does nothing
              //.setColorForeground(color(255,0,0))  //does nothing
              //.setColorValue(color(0,0,0)  //does nothing)
              .setColor(#7E1C1C)  //sets text color
              .setFont(robotoMed11)
              ;
      
  floatingTimeLabel = cp5.addTextlabel("Time")
              .setText("0.0")
              .setPosition(-30, -30)
              .setColorValue(0x00)
              //.setFont(ControlP5.standard56)
              ;
              
  floatingPowerLabel = cp5.addTextlabel("Power")
              .setText("0.0")
              .setPosition(-30, -30)
              .setColorValue(0x00)
              //.setFont(ControlP5.standard56)
              ;
  
  messageLabel = cp5.addTextlabel("Message")
              .setText("Ready.")
              .setPosition(10, 444)
              .setColorValue(color(0, 0, 0))
              //.setFont(arial11);
              .setFont(robotoMed11);
              ;
  
  titleLabel = cp5.addTextlabel("Title")
              .setText("Peregrine Universal LPM Interface")
              .setPosition(158, 2)
              .setColorValue(color(0, 0, 0))
              //.setFont(arialB19);
              .setFont(robotoSemiBold19);
              ;
  
  //always setup debug text areas, so debug can be switched on whenever needed.  Note that fields
  // are only updated when enviroDebug=true
  titleLabel.setText("Peregrine Universal LPM Interface                     [ Debug Mode ]");
              
  debugLabelArea0 = cp5.addTextarea("debugLabelArea0")
              .setPosition(662, 31)
              .setColorValue(color(0, 0, 0))
              //.setColorBackground(128)
              //.enableColorBackground()
              //.setColorValue(color(255, 255, 255))
              .setSize(85, 475)
              //.setFont(createFont("Consolas", 12))
              ;
    
  debugValueArea0 = cp5.addTextarea("debugValueArea0")
              .setPosition(748, 31)
              .setColorValue(color(0, 0, 0))
              //.setColorBackground(128)
              //.enableColorBackground()
              //.setColorValue(color(255, 255, 255))
              .setSize(111, 475)
              //.setFont(createFont("Consolas", 12))
              ;
              
   debugLabelArea1 = cp5.addTextarea("debugLabelArea1")
              .setPosition(862, 31)
              .setColorValue(color(0, 0, 0))
              //.setColorBackground(128)
              //.enableColorBackground()
              //.setColorValue(color(255, 255, 255))
              .setSize(85, 475)
              //.setFont(createFont("Consolas", 12))
              ;
    
  debugValueArea1 = cp5.addTextarea("debugValueArea1")
              .setPosition(948, 31)
              .setColorValue(color(0, 0, 0))
              //.setColorBackground(128)
              //.enableColorBackground()
              //.setColorValue(color(255, 255, 255))
              .setSize(111, 475)
              //.setFont(createFont("Consolas", 12))
              ;
  
  currentReadingLabelLabel = cp5.addTextlabel("CurrentReadingLabel")
              .setText("Current Reading")
              .setPosition(9, 466)
              .setColorValue(color(0, 0, 0))
              //.setFont(createFont("Lucida Console",12))
              ; 
  
  currentReadingLabel = cp5.addTextlabel("CurrentReading")
              .setText("99999.9mW")
              .setPosition(10, 474)  //was 18,474
              .setWidth(200)  //was 300
              .setColorValue(color(0, 0, 0))
              .setFont(robotoMed26)
              .align(RIGHT,CENTER,RIGHT,CENTER);
              //.setFont(createFont("Lucida Console",36))
              ;  
              
  peakReadingLabelLabel = cp5.addTextlabel("PeakReadingLabel")
              .setText("Peak")
              .setPosition(158, 466)
              .setWidth(200)
              .setColorValue(color(0, 0, 0))
              ; 
  
  peakReadingLabel = cp5.addTextlabel("PeakReading")
              .setText("99999.9mW")
              .setPosition(158,474)
              .setWidth(200)
              .setColorValue(color(0, 0, 0))
              .setFont(robotoMed26)
              .align(RIGHT,CENTER,RIGHT,CENTER)
              //.setFont(createFont("Lucida Console",36))
              ; 
             
  averageReadingLabelLabel = cp5.addTextlabel("AverageReadingLabel")
              .setText("Average")
              .setPosition(308, 466)
              .setColorValue(color(0, 0, 0))
              //.setFont(createFont("Lucida Console",12))
              ; 
  
  averageReadingLabel = cp5.addTextlabel("AverageReading")
              .setText("99999.9mW")
              .setWidth(200)
              .setPosition(308, 474)
              .setColorValue(color(0, 0, 0))
              .setFont(robotoMed26)
              //.setFont(createFont("Lucida Console",36))
              ; 
              
  setupCOMSelector();
  setupBaudSelector();
}

void setupBaudSelector()
{
  BaudSelector = cp5.addScrollableList("BaudList");
  BaudSelector.setType(ScrollableList.DROPDOWN);
  BaudSelector.setDirection(PApplet.DOWN);
  BaudSelector.setSize(52,240);   
  BaudSelector.setCaptionLabel("Baud Rate");
  BaudSelector.setFont(robotoMed11);
  BaudSelector.setColorForeground(color(8,205,8));   //box color when mouseover
  BaudSelector.setColorBackground(color(8,174,8));   //box color when inactive
  //BaudSelector.setColorValueLabel(color(85,5,8));    //text color of list items when expanded
  BaudSelector.setColorValueLabel(color(255,251,139));
  BaudSelector.setColorCaptionLabel(color(255,255,255));  //text color of selected item
  //BaudSelector.setColorActive(color(255,255,255));   //does nothing??
  
  BaudSelector.setPosition(460, 445);  //position changed in draw() to simulate "DROPUP" box
  BaudSelector.setItemHeight(BaudSelectorItemHeight);
  BaudSelector.setBarHeight(BaudSelectorItemHeight);

  BaudSelector.addItem("300", 0);
  BaudSelector.addItem("1200", 1);
  BaudSelector.addItem("2400", 2);
  BaudSelector.addItem("4800", 3);
  BaudSelector.addItem("9600", 4);
  BaudSelector.addItem("14400", 5);
  BaudSelector.addItem("19200", 6);
  BaudSelector.addItem("28800", 7);
  BaudSelector.addItem("38400", 8);
  BaudSelector.addItem("57600", 9);
  BaudSelector.addItem("115200", 10);
  BaudSelector.setValue(4);  //Set 9600, in case below locates no valid match to default specified in configuration file
  for (int i= 0; i<BaudSelector.getItems().size(); i++) {
    String theItem = cp5.get(ScrollableList.class, "BaudList").getItem(i).get("name").toString();
    //print(theItem+" ");
    if (defaultBaudRate==int(theItem))  {
      BaudSelector.setValue(i);    
    }
  }
}

void setupCOMSelector()
{
  COMSelector = cp5.addScrollableList("COMList");
  COMSelector.setPosition(514,445);  //position is changed in draw to simulate "DROPUP" box
  COMSelector.setSize(135,60); 
  COMSelector.setType(ScrollableList.DROPDOWN);
  COMSelector.setDirection(PApplet.DOWN);
  //COMSelector.setBackgroundColor(color(190));
  COMSelector.setItemHeight(COMSelectorItemHeight);  //was 15
  COMSelector.setBarHeight(COMSelectorItemHeight);
  COMSelector.setCaptionLabel("COM Port");
  COMSelector.setFont(robotoMed11);
  COMSelector.setColorForeground(color(8,205,8));   //box color when mouseover
  COMSelector.setColorBackground(color(8,174,8));   //box color when inactive
  COMSelector.setColorValueLabel(color(255,251,139));    //text color of list items when expanded
  COMSelector.setColorCaptionLabel(color(255,255,255));  //text color of selected item
  String[] comPorts = Serial.list();
  int itemIndex = 0;
  for(int i = 0; i < comPorts.length; i++)
  {
    if(!(comPorts[i].toLowerCase().contains("bluetooth"))) COMSelector.addItem(comPorts[i], itemIndex++);
  }
  if (COMSelector.getItems().size()>0) {  //if at least one port, select it
   COMSelector.setValue(0);
  }

}
