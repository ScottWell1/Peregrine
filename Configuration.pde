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


// Generic code to load from config files

class Configuration extends Properties
{
  boolean getBooleanProperty(String id, boolean defState)
  {
    return boolean(getProperty(id,""+defState));
  }
 
  int getIntProperty(String id, int defVal)
  {
    return int(getProperty(id,""+defVal)); 
  }
 
  float getFloatProperty(String id, float defVal)
  {
    return float(getProperty(id,""+defVal)); 
  }  
  
  String getStringProperty(String id, String defVal)
  {
    return getProperty(id,""+defVal); 
  } 
}
