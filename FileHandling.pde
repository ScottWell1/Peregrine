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

void saveData()
{
  /*if(state != STATE_DONE)
  {
    //JOptionPane.showConfirmDialog(null, "A measurement must be completed before a graph can be saved.", "Invalid Operation", JOptionPane.WARNING_MESSAGE);
    alert("No completed dataset to save.");
    saveGraphFlag = false;
    return;
  }*/
  
  fc.setCurrentDirectory(new File(System.getProperty("user.home"))); 
  fc.setDialogType(JFileChooser.SAVE_DIALOG);
  fc.setDialogTitle("Save Dataset");
  
  if(fc.showSaveDialog(null) == JFileChooser.APPROVE_OPTION /*&& state == STATE_DONE*/)
  {
    String strFileName = fc.getSelectedFile().getPath();
    if(!strFileName.endsWith(".csv")) strFileName += ".csv";
    
    File f = new File(strFileName);

    if(f.exists())
    {
      int reply = JOptionPane.showConfirmDialog(null, "File already exists.  Replace it?\n", "File Replacement", JOptionPane.WARNING_MESSAGE, JOptionPane.YES_NO_OPTION);
      if(reply == JOptionPane.YES_OPTION)
      {
        f.delete();
      }
      else
      {
        return;
      }
    }
    
    try
    {
      f.createNewFile();
      
      FileWriter fw = new FileWriter(f);
      BufferedWriter out = new BufferedWriter(fw);
      
      String data = "Time (s),Power (mW)\n";
      for(int i = 0; i < readingsList.size(); i++)
      {
        Float time = ( (Integer)timesList.get(i) - graphStart ) / 1000.0;
        
        data += time + "," + readingsList.get(i) + "\n";
      }
      
      out.write(data);
      out.close();
    }
    catch (Exception e)
    {
      exceptions++;
      alert("Error writing file.");
    }
    
  }
  
  //saveDataFlag = false;
  alert("Data export complete.");
}

void saveGraph()
{
  /*if(state != STATE_DONE)
  {
    //JOptionPane.showConfirmDialog(null, "A measurement must be completed before a graph can be saved.", "Invalid Operation", JOptionPane.WARNING_MESSAGE);
    alert("No completed graph to save.");
    saveGraphFlag = false;
    return;
  }*/
  
  fc.setCurrentDirectory(new File(System.getProperty("user.home"))); 
  fc.setDialogType(JFileChooser.SAVE_DIALOG);
  fc.setDialogTitle("Save Graph");
  
  int graphHeight = 850;
  int graphWidth = 0;
  //int graphStroke = 1;
  
  try
  {
    Configuration pconfig = new Configuration();
    pconfig.load(createInput("Peregrine.conf"));
    graphHeight = pconfig.getIntProperty("Export.Graph.Height", 5000);
    //graphStroke = pconfig.getIntProperty("Export.Graph.StrokeWidth", 1);
  }
  catch (IOException e)
  {
    println("couldn't read config file...");
    exceptions++;
  }
  
  //graphWidth = (int)(graphHeight * 1.294);
  graphHeight = 850;
  graphWidth = 1100;
  
  PGraphics graphRender = createGraphics(graphWidth, graphHeight, JAVA2D);
  graphRender.beginDraw();
  graphRender.smooth();
  
  // Setup drawing area
  graphRender.background(color(255, 255, 255));
  graphRender.fill(color(255, 255, 255));
  graphRender.stroke(color(0, 0, 0));
  
  // Title Outline
  //graphRender.rect(10, 10, 1079, 82);
  
  // Graph Area
  graphRender.rect(88, 103, 1001, 600);
  
  // Lines
  graphRender.stroke(color(128, 128, 128));
  for(int i = 0; i < 9; i++)
  {
    graphRender.line(188 + ( i * 100 ), 104, 188 + ( i * 100 ), 702);
    graphRender.line(89, 163 + ( i * 60 ), 1088, 163 + ( i * 60 ));
  }
  
  // Draw Line
  graphRender.stroke(lineColor);
  int lastX = -1;
  int lastY = -1;
  Float renderTotal = 0.0;
  Float renderPeak = 0.0;
  for(int i = 0; i < readingsList.size(); i += arrayStep)
  {
    Float currentRenderReading = (Float)readingsList.get(i);
    //println((Float)readingsList.get(i));
    renderTotal += currentRenderReading;
    if(currentRenderReading > renderPeak)
      renderPeak = currentRenderReading;
    
    int gX = 89 + (int)( 999 * ( ( (Integer)timesList.get(i) - graphStart ) / (float)graphTime ) );
    int gY = int((float)( (Float)readingsList.get(i) / graphRange ) * float(600 - 1)) + 1;
    //int gX = int( ( timeMult * (Integer)localTimesList.get(i) ) - timeSub);
    //int gY = int( (Float)localReadingsList.get(i) * readingMult ) + 1;
    
    if(lastX > -1)
    {
      //line(x + 1 + lastX, y + h - lastY, x + 1 + gX, y + h - gY);
      //graphBuffer.line(x + 1 + lastX, y + h - lastY, x + 1 + gX, y + h - gY);
      graphRender.line(lastX, 704 - lastY, gX, 704 - gY);
    }
    
    lastX = gX;
    lastY = gY;
  }
  
  // Draw over any zero values
  graphRender.stroke(color(0, 0, 0));
  graphRender.line(88, 703, 1089, 703);
  
  // Draw over any negative values
  graphRender.fill(color(255, 255, 255));
  graphRender.stroke(color(255, 255, 255));
  graphRender.rect(0, 704, 1099, 850);
  
  // Time labels
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arialB11, 15);
  graphRender.textFont(robotoMed11, 15);
  graphRender.rotate(HALF_PI);
  for(int i = 1; i <= 10; i++)
  {
    graphRender.textAlign(LEFT);
    Float value = i * ( graphTime / 10.0 );
    value /= 100;
    value = (float)round(value);
    value /= 10;
    //graphRender.text(value.toString(), 188 + ( i * 100 ), 705);
    graphRender.text(value.toString(), 710, -184 + ( ( i - 1 ) * -100 ));
  }
  graphRender.rotate(HALF_PI * -1.0);
  
  // Y Axis Label
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arialB11, 15);
  graphRender.textFont(robotoSemiBold11, 15);
  graphRender.rotate(HALF_PI * -1.0);
  graphRender.textAlign(CENTER);
  graphRender.text("Power (mW)", -403, 25);
  graphRender.rotate(HALF_PI);
  
  // X Axis Label
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arialB11, 15);
  graphRender.textFont(robotoSemiBold11, 15);
  graphRender.text("Time (s)", 588, 770);
  
  // Power labels
  for(int i = 1; i <= 10; i++)
  {
    graphRender.textAlign(RIGHT);
    Float value = ( 11 - i ) * ( graphRange / 10.0 );
    value *= 10;
    value = (float)round(value);
    value /= 10;
    graphRender.text(value.toString(), 84, 109 + ( ( i - 1 ) * 60 ));
  }
  
  // Draw over any zero values
  graphRender.stroke(color(0, 0, 0));
  graphRender.line(88, 703, 1089, 703);
  
  // Write graph title
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arialB11, 32);
  graphRender.textFont(robotoSemiBold11, 32);
  graphRender.textAlign(CENTER);
  if(state == STATE_MONITOR)
    graphRender.text("Monitoring", graphWidth / 2, 72);
  else
    graphRender.text(graphTitle, graphWidth / 2, 72);
  //graphRender.text("abcdefghijklmnopqrstuvwxyz", graphWidth / 2, 72);
  
  // Round Peak
  renderPeak *= 10;
  renderPeak = float(round(renderPeak));
  renderPeak /= 10;
  
  // Round Average
  Float renderAverage = renderTotal / readingsList.size();
  renderAverage *= 10;
  renderAverage = float(round(renderAverage));
  renderAverage /= 10;

  // Write Peak
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arialB11, 30);
  graphRender.textFont(robotoSemiBold11, 30);
  graphRender.textAlign(RIGHT);
  //graphRender.text("Peak: ", 160, 800);
  graphRender.text("Peak: ", 175, 800);
  String renderPeakString = renderPeak.toString();
  //graphRender.text(renderPeakString + "mW", 310, 800);
  graphRender.text(renderPeakString + "mW", 335, 800);
  
  // Write Average
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arialB11, 30);
  graphRender.textFont(robotoSemiBold11, 30);
  graphRender.textAlign(RIGHT);
  //graphRender.text("Average: ", 150, 835);
  graphRender.text("Average: ", 175, 835);
  String renderAverageString = renderAverage.toString();
  //graphRender.text(renderAverageString + "mW", 310, 835);
  graphRender.text(renderAverageString + "mW", 335, 835);
  
  // Write Message
  graphRender.fill(color(0, 0, 0));
  //graphRender.textFont(arial11, 15);
  graphRender.textFont(robotoMed11, 15);
  
  graphRender.textAlign(RIGHT);
  graphRender.text("Generated by Peregrine Univeral LPM Interface", 1096, 842);
  
  graphRender.endDraw();
  
  if(fc.showSaveDialog(null) == JFileChooser.APPROVE_OPTION /*&& state == STATE_DONE*/)
  {
    String strFileName = fc.getSelectedFile().getPath();
    if(!strFileName.endsWith(".png")) strFileName += ".png";
    
    File f = new File(strFileName);
  
    if(f.exists())
    {
      int reply = JOptionPane.showConfirmDialog(null, "File already exists.  Replace it?\n", "File Replacement", JOptionPane.WARNING_MESSAGE, JOptionPane.YES_NO_OPTION);
      if(reply == JOptionPane.YES_OPTION)
      {
        f.delete();
      }
      else
      {
        return;
      }
    }
    
    try
    {
      graphRender.save(strFileName);
    }
    catch (Exception e)
    {
      exceptions++;
      alert("Error writing file.");
    }
    
  }
  
  //saveGraphFlag = false;
  alert("Graph export complete.");
}
