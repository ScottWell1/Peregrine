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

public class SerialDebuggerWindow extends PApplet
{
  Peregrine parent;
  ControlP5 cp5;
  
  public Textfield sendText;
  //public DropdownList typeList;
  public ScrollableList typeList;
  public Textarea serialLog;
  public Button sendButton;
  public int serWinWidth = 300;
  public int serWinHeight = 400;
  
  color recvColor = color(0,0,0);
  color sendColor = color(255,0,0);
  
  public SerialDebuggerWindow() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    serWinWidth=300;
    serWinHeight=300;
    }
    
  public SerialDebuggerWindow(String theName, int theWidth, int theHeight) {
    super();
    serWinWidth=theWidth;
    serWinHeight=theHeight;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    }
    
  public void setup() {
    
    surface.setSize(serWinWidth,serWinHeight);
    frameRate(24);
    cp5 = new ControlP5(this);
    Textfield.cursorWidth = 1;  //cursorWidth is class static; setting here applies to all instances
    Label.setUpperCaseDefault(false);  //sets static default in class for all instances of class.
              
    sendText = cp5.addTextfield("sendText")
       .setCaptionLabel("")
       .setPosition(3,2)
       .setSize(250,18)
       .setFont(robotoMed11)
       .setFocus(true)
       .setColor(color(0,0,0))
       .setColorBackground(color(255, 255, 255))
       .setColorForeground(color(0, 0, 0))
       .setColorActive(color(192, 192, 192))
       ;
     //sendText.cursorWidth = 1;
     sendText.setColorCursor(color(0,0,0));
     
  
  typeList = cp5.addScrollableList("TypeList");
  typeList.setType(ScrollableList.DROPDOWN);
  typeList.setDirection(PApplet.DOWN);
  typeList.setPosition(260, 2);
  typeList.setSize(60,80);
  typeList.setCaptionLabel("Type");
  typeList.setBackgroundColor(color(190));
  typeList.setItemHeight(18);
  typeList.setBarHeight(18);
  //typeList.setFont(arial11);
  typeList.setFont(robotoMed11);
  typeList.addItem("Bytes", 0);
  typeList.addItem("String", 1);
  typeList.setValue(0);
  typeList.setColorBackground(color(60));
  typeList.setColorActive(color(255, 128));
  
  sendButton = cp5.addButton("Send")
     .setPosition(325, 2)
     .setSize(50,18)
     //.setFont(arial11)
     .setFont(robotoMed11)
     ;

  serialLog = cp5.addTextarea("SerialLog")
              .setPosition(4, 28)
              //.setSize(390, 569)
              .setSize(390, 569)
              .setColorValue(color(0, 0, 0))
              .setColorBackground(#EDEBEB)
              .setFont(robotoMed11)
              .setLineHeight(13);
              ;

  typeList.bringToFront();
  }
  
  public void draw() {
      background(color(255, 255, 255));
      
      line(  2,  26, 395,  26);
      line(395,  26, 395, 598);
      line(395, 598,   2, 598);
      line(  2, 598,   2,  26);
      
  }
  
  void Send()
  {
    String toSend = sendText.getText();
    if(toSend.length() == 0) return;
    
    if(typeList.getValue() == 0)  //bytes in format XX XX XX XX
    {
      String[] toConvert = toSend.split(" ");
      byte[] sendBuf = new byte[toConvert.length];
      
      for(int i = 0; i < toConvert.length; i++)
      {
        Integer bI = Integer.parseInt(toConvert[i], 16);
        byte b = (byte)(bI & 0x000000FF); 
        sendBuf[i] = b;
      }
    
      if(connected && toConvert.length > 0)
      {      
        //serialLog.append("About to send (bytes).");
        //serialLog.scroll(1.0);
        port.write(sendBuf);
   
        serialLog.append(logStamp() +" SEND>>>> ");
                
        for(int i = 0; i < sendBuf.length; i++)
        {
          serialLog.append(String.format("%02X ", sendBuf[i]));
        }
        serialLog.append("\n");
        serialLog.scroll(1.0);
      }
    }
    else if(typeList.getValue() == 1)
    {
      if(connected && toSend.length() > 0)
      {
        //serialLog.append("About to send (string).\n");
        //serialLog.scroll(1.0);
        port.write(toSend);
        serialLog.append(logStamp() + " SEND >>>> " + toSend + "\n");
        serialLog.scroll(1.0);
      }
    }
    
    sendText.setText("");
  }
  
  public void Receive(String recv)
  {
    serialLog.append(logStamp() + " RECV> " + recv.replace("\n", "\\n").replace("\r", "\\r") + "\n");
    serialLog.scroll(1.0);
  }
};
