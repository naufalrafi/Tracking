# Tracking
python-OpenModelica-STK program that parses any number of satellites' Two-Line Elements from NORAD database into azimuth and elevation pointing angles and for any ground station. 

Tested and verified at Algonquin Radio Observatory with &lt;0.01 degree divergence from the site's own software.

<p align="center">
  <img src="https://github.com/naufalrafi/Tracking/blob/master/block%20diagram.png"><br>
  <b>Original programming structure plan</b>
  <br><br>
  <img src="https://github.com/naufalrafi/Tracking/blob/master/finalfinal.png"><br>
  <b>Final main.py program chain</b>
</p>


> A two-line element set (TLE) is a data format encoding a list of orbital elements of an Earth-orbiting object for a given point in time, the epoch. Using suitable prediction formula, the state (position and velocity) at any point in the past or future can be estimated to some accuracy. The TLE data representation is specific to the simplified perturbations models (SGP, SGP4, SDP4, SGP8 and SDP8), so any algorithm using a TLE as a data source must implement one of the SGP models to correctly compute the state at a time of interest. TLEs can describe the trajectories only of Earth-orbiting objects. TLEs are widely used as input for projecting the future orbital tracks of space debris for purposes of characterizing "future debris events to support risk analysis, close approach analysis, collision avoidance maneuvering" and forensic analysis.


**USER GUIDE**
- User needs to have OpenModelica installed (used for a streamlined container of all the mathematical models)
- User needs to update the ground station description file (STNFIL.txt) to match the ground station used for their tracking
- User needs to update the Two-Line Element file (NORADTLE.txt) to match the satellites they wish to track
- Run mainFULL.py

ASIDE: If user has access to AGI's STK software, they can visualize the orbit of the satellite they wish to track and they can check for any inaccuracies caused by outdated TLE files 
