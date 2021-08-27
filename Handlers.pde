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

public boolean connected = false;
int connectionAllowTime = 0;
int connectionTime = 0;
String portName;
//int listIndex;

public void toggleDebug()  //normally fired by toggleDebug button
{
  if(enviroDebug) {
    enviroDebug=false;
  }
  else {
    enviroDebug=true;
  }
}    

public void toggleSerialDebug()
{
   if(serialDebug) {
     serialDebug=false;
     winSerialDebug.getSurface().setVisible(false);
   }
   else {
       serialDebug=true;
       winSerialDebug.getSurface().setVisible(true);
   }
}   
   
public void Connect()  //automatically fired when button of scame name clicked!
{
  if( millis() < connectionAllowTime ) return;
  
  if(COMSelector.getItems().size()==0) {
     alert("ERROR: NO COM PORTS DETECTED!",2);
     delay(2);
     return;
  }
  
  //resetToMonitor();
  kenometerHandshake = false;
  kenometerHandshakeAttempts = 0;
  
  //if(port == null)
  if(!connected)
  {
    BAUD_RATE = int(cp5.get(ScrollableList.class, "BaudList").getItem(int(BaudSelector.getValue())).get("name").toString());
    portName = cp5.get(ScrollableList.class, "COMList").getItem(int(COMSelector.getValue())).get("name").toString();

    discardSerial = true;  //causes processSerial() to throw away initial packets
    packets = 0;
    
    /////////////////////////////////////////////////
    //TEST ONLY: CREATE FAILURE FOR EXCEPTION TEST!!!!
    //////////////////////////////////////////////////
    //portName="COM8";
    
    alert("Connecting to " + portName + "@ " + BAUD_RATE + " baud.");
    if(serialDebugFeature) {
      winSerialDebug.serialLog.append(logStamp()+" Connecting: " + portName + " at " + BAUD_RATE +" baud.\n");
    }
    
    try {
      port = new Serial(this, portName, BAUD_RATE);
    } 
    catch (Exception e) {
      alert("ERROR - Unable to open "+portName+"!\n",2);
      if(serialDebugFeature) {
        winSerialDebug.serialLog.append(logStamp()+" Exception opening "+portName+"\n");
        winSerialDebug.serialLog.append(logStamp()+" [" + e + "]\n");
      }
      return;
    }
    
    port.bufferUntil('\n');
   
    connectButton.setCaptionLabel("Disconnect")
                 .setColorBackground(color(200, 0, 0))
                 .setColorForeground(color(220, 0, 0))
                 .setColorActive(color(255, 0, 0))
                 ;
                 
    
    //alert("Connected on " + COMSelector.item((int)COMSelector.getValue()).getText() + ".");
    //alert("Connecting to " + portName + "@ " + BAUD_RATE + " baud.");
    
    connectionTime = millis();
    lastReceive = 0;
    connected = true;
    
  }
  else
  {
    if(serialDebugFeature) {
      winSerialDebug.serialLog.append(logStamp()+" Disconnecting.\n");
    }
    port.clear();
    port.stop();
    connected = false;
    lastReceive = 0;
    //port = null;
    
    connectButton.setCaptionLabel("Connect")
                 .setColorBackground(color(8, 174, 8))
                 .setColorForeground(color(8, 205, 8))
                 .setColorActive(color(61, 243, 61))
                 ;
    
    if(state == STATE_GRAPHING)
    {
      alert("Disconnected.  Timed measurement stopped.");
      state = STATE_STOPPED;
    }
    else
    {    
      alert("Disconnected.");
    }
  }
  
  //connectionAllowTime = millis() + 1000;
  connectionAllowTime = millis();
  
}

int lastRefresh = 0;

String[] comPorts = { "" };
boolean refreshSerialFinished = true;
int refreshSerialInterval = 1000;
int lastSerialRefresh = 0;
public void refreshSerial()
{
  if( millis() - lastSerialRefresh > refreshSerialInterval  && ( (COMSelector.getItems().size()==0) || (!COMSelector.isOpen()) ) ){  
    lastSerialRefresh = millis();
    comPorts = Serial.list();
    AutoRefresh();
    refreshSerialFinished = true;
  }
}

public void AutoRefresh()
{
  int oldCount = COMSelector.getItems().size(); 
  COMSelector.clear();
  int itemIndex = 0;
  for(int i = 0; i < comPorts.length; i++)  {
    if(!(comPorts[i].toLowerCase().contains("bluetooth"))) COMSelector.addItem(comPorts[i], itemIndex++);
  }
  int curCount = COMSelector.getItems().size();
  if (curCount == 1) {   //only one port available, go ahead and select it
    COMSelector.setValue(0);
  }
  if (curCount==0) {
      COMSelector.setCaptionLabel("COM Port");
      alert("WARNING: No COM ports detected.",1);
  }
  if (oldCount==0 && curCount>0) {
      alert("Ready.");
  }
  COMSelector.close();
}  

public void Refresh()   //automatically fired when button of same name clicked!
{
  COMSelector.clear();
  comPorts = Serial.list();
  int itemIndex = 0;
  for(int i = 0; i < comPorts.length; i++)
  {
    if(!(comPorts[i].toLowerCase().contains("bluetooth"))) COMSelector.addItem(comPorts[i], itemIndex++);
  }
}

//MultiListButton selectedBaudOption;
//MultiListButton newBaudOption;

NewMeasurementWindow winNewMeasurement = null;

  void NewOption()
  {
    String dt = nf(year(),4) + "-" + nf(month(),2) + "-" + nf(day(),2) + "@" + nf(hour(),2) + nf(minute(),2) + nf(second(),2);  
    winNewMeasurement.nameText.setValue("Laser Test "+dt);
    winNewMeasurement.getSurface().setVisible(true);
  }

void MonitorOption()
{
  resetToMonitor();
  if(connected) {
     alert("Monitoring...");
  }
  else {
    alert("Ready.");
  }
}

void StopOption()
{
  state = STATE_STOPPED;
  alert("Stopped.");
}

void ExitOption()
{
  exitFlag = true;
}

boolean saveGraphFlag = false;
void ExportGraphOption()
{
  saveGraphFlag = true;
}

boolean saveDataFlag = false;
void ExportDataOption()
{
  saveDataFlag = true;
}

void exit()
{
  exitFlag = true;
}

// Called when a serial event is raised (in this case, when a '\n' is received)
void serialEvent(Serial p)
{
  //try { processSerial(p); } catch (java.lang.NullPointerException e) { exceptions++; }
  try { processSerial(); } catch (java.lang.NullPointerException e) { exceptions++; }
}
