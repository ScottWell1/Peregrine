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

String[] stateNames = { "STATE_WAITING", "STATE_MONITOR", "STATE_GRAPHING", "STATE_DONE", "STATE_STOPPED" };

final int STATE_WAITING = 0;
final int STATE_MONITOR = 1;
final int STATE_GRAPHING = 2;
final int STATE_DONE = 3;
final int STATE_STOPPED = 4;

int state = STATE_MONITOR;

int startTime = 0;
int graphTime = 60000;
int graphStart = 0;
color lineColor = color(255, 0, 0);

Float graphThreshold = 0.0;

void DataSetup()
{
  readingsList = new ArrayList();
  timesList = new ArrayList();
}

void ResetData()
{
  readingsList.clear();
  timesList.clear();
  arrayStep = 1;
}

// Add a reading to our data array
int last = 0;
void addReading(Float reading)
{
  int currentTime = millis();
  
  if( state == STATE_WAITING)
  {
    if(reading > graphThreshold)
    {
      state = STATE_GRAPHING;
      graphStart = millis();
      alert("Collecting data...");
    }
    else
    {
      return;
    }
  }
  
  if( state == STATE_GRAPHING)
  {
    if(currentTime - graphStart >= graphTime)
    {
      state = STATE_DONE;
      alert("Done!  Use 'Save Graph' or Reset.");
    }
  }
  
  if( state == STATE_DONE || state == STATE_STOPPED )
  {
    return;
  }
  
    if(readingsList.size() > 0)
  {
    readingsList.add(reading);
    timesList.add(currentTime);
    dataCursor++; 
    
    while((Integer)timesList.get(timesList.size() - 1) - (Integer)timesList.get(0) > graphTime)
    {
      readingsList.remove(0);
      timesList.remove(0);
      graphStart = (Integer)timesList.get(0);
      dataCursor--;
      rerender = true;
    }
  }
  else
  {
    readingsList.add(reading);
    timesList.add(currentTime);
    dataCursor++; 
    graphStart = currentTime;
    rerender = false;
  }

  last = currentTime;
}

void resetToMonitor()
{
  state = STATE_MONITOR;
  readingsList.clear();
  timesList.clear();
  dataCursor = 0;
  arrayStep = 1;
  SelectionBox = false;
  
  surface.setTitle(appWindowTitle);
  
  graphTime = 60000;
}

void doStart()
{
  readingsList.clear();
  timesList.clear();
  dataCursor = 0;
  arrayStep = 1;
  SelectionBox = false;
    
  surface.setTitle(appWindowTitle + " (TESTING: " + winNewMeasurement.nameText.getText() + ")");
  graphTitle = winNewMeasurement.nameText.getText();
  
  int timeValue = 0;
  try { timeValue = Integer.parseInt(winNewMeasurement.durationText.getText()) * 1000; } catch ( Exception e ) { exceptions++; }
  int duration = (int)winNewMeasurement.durationList.getValue();
  if( duration == 1 ) timeValue *= 60;
  if( duration == 2 ) timeValue *= 3600;
  
  Float thresholdValue = 0.0;
  try { thresholdValue = Float.parseFloat(winNewMeasurement.thresholdText.getText()); } catch ( Exception e ) { exceptions++; }
  graphThreshold = thresholdValue;
  
  lineColor = winNewMeasurement.cp.getColorValue();
  
  if(timeValue == 0)
  {
    state = STATE_MONITOR;
    graphTime = 60000;
    alert("Monitoring...");
  }
  else
  {
    state = STATE_WAITING;
    graphTime = timeValue;
    graphThreshold = thresholdValue;
    alert("Waiting for power threshold to be reached...");
  }
  
  graphStart = millis();
  start_flag = 0;
}

void doParameterizedStart(int threshold, int time)
{  
  readingsList.clear();
  timesList.clear();
  dataCursor = 0;
  arrayStep = 1;
  SelectionBox = false;
  surface.setTitle(appWindowTitle + " " + winNewMeasurement.nameText.getText());
  graphTitle = winNewMeasurement.nameText.getText();
  
  lineColor = winNewMeasurement.cp.getColorValue();
  
  state = STATE_WAITING;
  graphTime = time;
  graphThreshold = (float)threshold;
  alert("Waiting for input...");
  
  graphStart = millis();
  
  
  start_flag = 0;
}
