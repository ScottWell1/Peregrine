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

long bytesReceived = 0;
long packets = 0;
Integer lastReceive = 0;
int lastElapsed = 0;
Float speed = 0.0;
int malformedPackets = 0;

boolean discardSerial = false;
boolean kenometerHandshake = false;
int kenometerHandshakeAttempts = 0;
int serialEventsAborted = 0;

int packetDiscardPeriod = 200;   //ms duration after connect to discard packets, to avoid partial/malformed packets at start of connection
int meterCommTimeout = 5000;     //if connected and actively receiving, then no data received for longer than Xms will cause auto-disconnect.

//void processSerial(Serial p)
void processSerial()
{
  if(exitFlag || !connected)
  {
    serialEventsAborted++;
    return;
  }
  
  // Grab the string from the port
  String inString = (port.readString());
  lastElapsed = millis() - lastReceive;
  lastReceive = millis();
  packets++;
  bytesReceived += inString.length();
  speed = 1000.0 / lastElapsed;
    
  if(serialDebug)
  {
    String discardStatus = "";
    if(discardSerial) {
      discardStatus = " (DISCARDED)";
    }
    winSerialDebug.Receive(inString+discardStatus);
  }
  
  if(discardSerial)   //set true when connecting; effect is to throw away potentially partial packet after connection
  {
    if( (millis()-connectionTime)<packetDiscardPeriod ) { //just throw away everything for 1/4 second after connection
      port.clear();
      return;
    }
    else {
      discardSerial = false;
      port.clear();
      return;
    }
  } 
  
  float sampleTime = 5000;
  timestampList.add(lastReceive);
  while((Integer)timestampList.getFirst() < (Integer)timestampList.getLast() - sampleTime) timestampList.remove(0);
  
  if(timestampList.size() > 1)
    speed = float(timestampList.size()) / ( ( float((Integer)timestampList.getLast()) - float((Integer)timestampList.getFirst())) / 1000 );
  else
    speed = 0.0;
  
  Float toAdd = 0.0;
  
  // Now we do our automatic detection of the packet type.
  char[] inputArray = inString.toCharArray();
  if(inputArray[0] == '\r')
  {
    // It has to be a LaserBee, since it uses this format
    INPUT_TYPE = INPUT_LASERBEE;
  }
  else if(inputArray[0] >= 'a' && inputArray[0] <= 'z')
  {
    // It's lower case, so it's probably OpenLPM or is at least compatible.
    INPUT_TYPE = INPUT_OPENLPM;
  }
  else if(inputArray[0] >= 'A' && inputArray[0] <= 'Z')
  {
    // Upper case.  Probably Radiant.
    INPUT_TYPE = INPUT_RADIANT;
  }
  else if(inputArray[0] >= '0' && inputArray[0] <= '9')
  {
    // Either simple or Kenometer.
    INPUT_TYPE = INPUT_SIMPLE;
  }
  
  // Process based on input type
  switch( INPUT_TYPE )
  {
    case INPUT_SIMPLE:
      toAdd = float(inString);
      break;
    case INPUT_OPENLPM:
      String[] inputOpenLPM = split(inString, " ");
      if(inputOpenLPM[0].compareTo("d") == 0)
        toAdd = parseFloat(inputOpenLPM[1]);
      else if(inputOpenLPM[0].trim().compareTo("s") == 0)
        start_flag = 1;
      else if(inputOpenLPM[0].compareTo("sp") == 0 && inputOpenLPM.length == 3)
      {
        pThreshold = parseInt(inputOpenLPM[1]);
        pTime = parseInt(inputOpenLPM[2].trim());
        start_flag = 2;
      }
      else
        return;
      break;
    case INPUT_KENOMETER:
      toAdd = float(inString);
      if(toAdd == -1)
      {
        kenometerHandshake = true;
        return;
      }
      break;
    case INPUT_RADIANT:
      String[] inputRadiant = split(inString, " ");
      if(inputRadiant[0].compareTo("D") == 0)
        toAdd = parseFloat(inputRadiant[1]);
      break;
    case INPUT_LASERBEE:
      // Split based on the comma position
      String[] inputLaserBee = split(inString, ",");
      toAdd = float(inputLaserBee[0]);
      break;
    
  }
     
  if(toAdd.isNaN() || toAdd.isInfinite())
  {
    malformedPackets++;
    
    if(serialDebug || enviroDebug)
      alert("Malformed packet: " + inString.replace("\n", "\\n").replace("\r", "\\r"));
    else
      alert("Malformed packet.  Count: " + malformedPackets);
    
    return;
  }
  
  if(toAdd > 9999.9) toAdd = 9999.9;
  
  try
  { 
    // Add a reading to our array
    addReading(toAdd);
  
    // Update mostRecentData.
    mostRecentData = toAdd;
  }
  catch (Exception e)
  {
    //println(inString);
    exceptions++;
    return;
  }
}

void HandshakeProcess()
{
  if(connected)
  {
    
    //if(millis() - connectionTime < millis() - lastReceive)
    
    if( (millis() - connectionTime)>250 && lastReceive==0 ) {  //connected for >250ms, NOTHING received
     
      // We haven't received anything, is the LPM a Kenometer?  It requires input to get response...
      // We'll switch to that protocol so the handshake is tried.
      INPUT_TYPE = INPUT_KENOMETER;
    }
    else {
      if(!(lastReceive==0) && millis() - lastReceive > meterCommTimeout) { //we were receiving, but stream stopped and nothing for 1.5s
         if (serialDebug) {
           winSerialDebug.serialLog.append("ERROR: Comm Timeout, no data received for >" + str(meterCommTimeout) + "ms\nAUTO-DISCONNECTED.\n");
         }
         Connect();  //currently connected, so this will disconnect
         return;
      }
    }
    
    if(INPUT_TYPE == INPUT_KENOMETER && !kenometerHandshake)
    {
      kenometerHandshakeAttempts++;
      port.write(0xFF);
      if(kenometerHandshakeAttempts>30) {  
        //Kenometer is last protocol checked; if no data then connection has failed to find any meter
        Connect();  //currently in connected state, so this will disconnect
        alert("ERROR: No Input. Check COM port and Baud Rate!",2);
      }
        
    }
  }
}
