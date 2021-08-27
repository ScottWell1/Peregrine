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

PGraphics graphBuffer;
PImage img;
boolean rerender = true;
int lastRendered = -1;

int lastX = -1;
int lastY = -1;

Float graphRange = 0.0;
Float maxData = 0.0;
String graphTitle = "NO TEST STARTED";

int graphRenderTime = 0;
int lineRenderTime = 0;
int peakSearchTime = 0;
float readingsPerPixel = 0.0;
int arrayStep = 0;

void CreateGraph(int x, int y, int w, int h, int foreColor, int backColor, Float maxPower)
{  
  int graphRenderStart = millis();
  
  fill(backColor);
  rect(x, y, w, h);
  
  stroke(0);
  line(x, y, x + w, y);
  line(x + w, y, x + w, y + h);
  line(x + w, y + h, x, y + h);
  line(x, y + h, x, y);

  Float maximum = maxPower;
  
  int peakSearchStart = millis();
  
  maxData = 0.0;
  for(int i = 0; i < localReadingsList.size(); i++)
  {
    if((Float)localReadingsList.get(i) > maxData) maxData = (Float)localReadingsList.get(i);
  }
  
  peakSearchTime = millis() - peakSearchStart;
  
  //print("CreateGraph ");
  //print("( State: " + stateNames[state] + " ) ");
  //print("( Elements: " + localReadingsList.size() + " ) ");
  //print("( Max: " + maxData + " ) ");
  //println();
  
  if(ceil(maxData / float(50)) == 1) maximum = 50.0;
  else if(ceil(maxData / float(100)) <= 10) maximum = ceil(maxData / float(100)) * float(100);
  else if(ceil(maxData / float(500)) <= 10) maximum = ceil(maxData / float(500)) * float(500);
  else if(ceil(maxData / float(5000)) <= 10) maximum = ceil(maxData / float(500)) * float(500);
  else if(ceil(maxData / float(50000)) <= 10) maximum = ceil(maxData / float(500)) * float(500);
  else if(ceil(maxData / float(500000)) <= 10) maximum = ceil(maxData / float(500)) * float(500);
  
  if(maxData <= 0) maximum = 100.0;
  
  boolean oldRerenderState = rerender;
  if(maximum > graphRange)
  {
    oldRerenderState = rerender;
    rerender = true;
  }
  
  graphRange = float(ceil(maximum));
  
  if(dataCursor == 0) maximum = 100.0;
  
  Float pInterval = ( h + 2 ) / 10.0;
  Float powerInterval = maximum / 10.0;
  
  for (int i = 0; i <= 10; i++)
  {
    //String labelID = "powerLabel" + i;
    Float powerText = (powerInterval * i);
    powerText *= 10;
    powerText = float(round(powerText));
    powerText /= 10;
    String labelText = powerText.toString();// + "mW";
    pLabels[i].setText(labelText)
              .setPosition(x - ( ( labelText.length() - 1 ) * 6 ) + ( countOnes(labelText) * 3 ) - 7, (int)( y + ( ( 10 - i ) * pInterval ) - 4 ))
              .setColorValue(0x00)
              ;
  }
  
  Float tInterval = w / 10.0;
  Float timeInterval = graphTime / 10000.0;
  
  for (int i = 0; i < 9; i++)
  {
    //String labelID = "timeLabel" + i;
    Float timeText = (timeInterval * ( i + 1 ));
    timeText *= 10;
    timeText = float(round(timeText));
    timeText /= 10;
    String labelText = timeText.toString();// + "mW";
    tLabels[i].setText(labelText)
              //.setPosition(x -  (int)( ( ( ( labelText.length() - 1 ) * 6 ) + ( countOnes(labelText) * 3 ) ) / 2 ) + (int)( tInterval * ( i + 1 )) - 4, 432)
              .setPosition(x -  (int)( ( ( ( labelText.length() - 1 ) * 6 ) + ( countOnes(labelText) * 3 ) ) / 2 ) + (int)( tInterval * ( i + 1 )) - 4, graphYmax+32)    //MOVEUP10
              .setColorValue(0x00)
              ;
  }
  
  stroke(lineColor);
  
  
  int lineRenderStart = millis();
  
  //final float readingMult = float(h - 1) / maximum;
  //final float timeMult = w / graphTime;
  //final float timeSub = ( w * graphStart ) / graphTime;
  
  //int arrayStepCandidate = 0;
  if(localReadingsList.size() > 1)
  {
    readingsPerPixel = localTimesList.size() / ( ( ( (Integer)localTimesList.get(localTimesList.size() - 1) - graphStart ) / float(graphTime) ) * w );
    //if( readingsPerPixel > 1 ) arrayStepCandidate = (int)( readingsPerPixel / ( ( frameRate / 24.0 ) / 2.0 ) );
    //if ( arrayStepCandidate > arrayStep ) arrayStep = arrayStepCandidate;
    //arrayStep = arrayStepCandidate;
  }
  
  arrayStep = 1;
  
  graphBuffer.beginDraw();
  //graphBuffer.smooth();
  
  if(rerender || lastRendered > localReadingsList.size() - 1)
  {
    graphBuffer.background(backColor);
    
    graphBuffer.stroke(foreColor);
    for (int i = 1; i < 10; i++)
    {
      graphBuffer.line(0, ( i * round(pInterval) ) + 1, graphBuffer.width, ( i * round(pInterval) ) + 1);
      graphBuffer.line(( i * round(tInterval) ) - 1, 0, ( i * round(tInterval)) - 1, graphBuffer.height);
    }
    
    
    lastRendered = -1;
    lastX = -1;
    lastY = -1;
  }
  
  graphBuffer.stroke(lineColor);
  graphBuffer.strokeWeight(2);  
  if(rerender)
  { 
    lastX = -1;
    lastY = -1;
    
    for(int i = 0; i < localReadingsList.size(); i += arrayStep)
    {
      int gX = (int)( w * ( ( (Integer)localTimesList.get(i) - graphStart ) / (float)graphTime ) );
      int gY = int((float)( (Float)localReadingsList.get(i) / maximum ) * float(h - 1)) + 1;
      //int gX = int( ( timeMult * (Integer)localTimesList.get(i) ) - timeSub);
      //int gY = int( (Float)localReadingsList.get(i) * readingMult ) + 1;
      
      if(lastX > -1)
      {
        //line(x + 1 + lastX, y + h - lastY, x + 1 + gX, y + h - gY);
        //graphBuffer.line(x + 1 + lastX, y + h - lastY, x + 1 + gX, y + h - gY);
        if(i > 1)
        {
          if(true || (Integer)localTimesList.get(i) - (Integer)localTimesList.get(i - 1) < ( 1000 / speed ) * 5)
            graphBuffer.line(lastX, h - lastY, gX, h - gY);
        }
      }
      
      lastX = gX;
      lastY = gY;
    }
    
    lastRendered = localReadingsList.size() - 1;
  }
  else if ( lastRendered < localReadingsList.size() - 1 )
  {
    for(int i = lastRendered + 1; i < localReadingsList.size(); i += arrayStep)
    {
      int gX = (int)( w * ( ( (Integer)localTimesList.get(i) - graphStart ) / (float)graphTime ) );
      int gY = int((float)( (Float)localReadingsList.get(i) / maximum ) * float(h - 1)) + 1;
      
      if(lastX > -1)
      {
        //line(x + 1 + lastX, y + h - lastY, x + 1 + gX, y + h - gY);
        //graphBuffer.line(x + 1 + lastX, y + h - lastY, x + 1 + gX, y + h - gY);
        if(i > 1)
        {
          if(true || (Integer)localTimesList.get(i) - (Integer)localTimesList.get(i - 1) < ( 1000 / speed ) * 2)
            graphBuffer.line(lastX, h - lastY, gX, h - gY);
        }
      }
      
      lastX = gX;
      lastY = gY;
    }
    
    lastRendered = localReadingsList.size() - 1;
  }
  graphBuffer.strokeWeight(1);
  
  graphBuffer.endDraw();
  
  //img = graphBuffer.get(0, 0, graphBuffer.width, graphBuffer.height);
  //image(img, x, y);
  image(graphBuffer, x + 1, y + 1);
  
  rerender = oldRerenderState;
  
  lineRenderTime = millis() - lineRenderStart;
  
  graphRenderTime = millis() - graphRenderStart;
}

//void DrawToGraph(int reading)
//{
//  
//}

int countOnes(String value)
{
  int ones = 0;
  for(int i = 0; i < value.length(); i++)
  {
    if(value.charAt(i) == '1') ones++;
  }
  return ones;
}

int getStringWidth(String s)
{
  int sWidth = 0;
  for(int i = 0; i < s.length(); i++)
  {
    switch(s.charAt(i))
    {
      case '1':
        sWidth += 3;
        break;
      case '.':
        sWidth += 2;
        break;
      case ' ':
        sWidth += 2;
        break;
      default:
        sWidth += 6;
        break;
    }
  }
  return sWidth;
}

void ResetSelectionBox()
{
  SelectionBox = false;
  CreatingSelectionBox = false;
  
  StationarySelectionBoxDesiredTime = 0;
  StationarySelectionBoxIndex = 0;
  StationarySelectionBoxX = 0;
  StationarySelectionBoxY = 0;
  
  MovingSelectionBoxDesiredTime = 0;
  MovingSelectionBoxIndex = 0;
  MovingSelectionBoxX = 0;
  MovingSelectionBoxY = 0;

  SelectionBoxPeak = 0.0;
  SelectionBoxAverage = 0.0;
}
