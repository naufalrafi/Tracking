from Fileio import banner, errmsg, ReadStationFile, ReadNoradTLE, STKout, anykey, Pointing
from Datefun import doy, frcofd, rafiDateTimeFunc, ep2dat
import numpy as np
import datetime as dt

from OMPython import ModelicaSystem
 
banner()

Station = ReadStationFile("STNFIL.txt")
Satellites = ReadNoradTLE("NORADTLE.txt")

dd = doy(2019, 5, 1)
Hour = 12  #change before tracking
Minute = 00  #change before tracking
Second = 00  #change before tracking
hh = (Hour + (Minute/60) + (Second/3600))/24

timestart = 19000 + dd + hh #chosen time start as today, at 12:00:00.0000

# insert error conditions here
# if error, errmsg();
# else

print("Station and Satellites successfully loaded");

# user can take some time to examine the newly created Station and Satellites[i] variables
# these variables are in the form of named tuples, e.g. Sattellites[2].refepoch and Station.stnlat
# these variables are as documented in the procedure section

#anykey();


#Using OpenModelica models
mod1 = ModelicaSystem("SatTrak.mo", "SatTrak.FINAL", ["Modelica"])

for i in range(int(len(Satellites))):
    mod1.setParameters(M0=Satellites[i].meanan, N0=Satellites[i].meanmo, eccn=Satellites[i].eccn, Ndot2=Satellites[i].ndot, 
                       Nddot6=Satellites[i].nddot6, raan0=Satellites[i].raan, argper0=Satellites[i].argper, incl=Satellites[i].incl, 
                       tstart=((Satellites[i].refepoch - timestart)*3600*24), stn_long=Station.stnlong, 
                       stn_lat=Station.stnlat, stn_elev=Station.stnalt, d0 = 7060, h0 = 0.0)
                       #,azspeedmax = 3.0, elspeedmax = 3.0)
   mod1.setSimulationOptions(startTime=0., stopTime=18000., stepSize=720.)
   mod1.simulate()

   timemo = mod1.getSolutions("time")
   posmo = np.transpose([mod1.getSolutions("p_sat_ECF[1]"), mod1.getSolutions("p_sat_ECF[2]"), mod1.getSolutions("p_sat_ECF[3]")])
   velmo = np.transpose([mod1.getSolutions("v_sat_ECF[1]"), mod1.getSolutions("v_sat_ECF[2]"), mod1.getSolutions("v_sat_ECF[3]")])
   
   fname = str("periftry" + i + ".e")     
   STKout(fname, "EPHEMecf.txt", timemo, posmo, velmo)

   #AOS,LOS, POINTING 
   azim = mod1.getSolutions("Azimuth")
   elev = mod1.getSolutions("Elevation")
   dazdt = mod1.getSolutions("dazdt")
   deldt = mod1.getSolutions("deldt")

   npts = len(azim)

   time = []
   sataz = []
   satel = []
   satazv = []
   satelv = []

   for k in range(npts):
       if 9 <= elev[k] <= 89 and dazdt[k] <= 3.0 and deldt[k] <= 3.0:
           time.append(timemo[k])
           sataz.append(azim[k])
           satel.append(elev[k])
           satazv.append(dazdt[k])
           satelv.append(deldt[k])
       k+=1
        
   time = np.array(time)
   sataz = np.array(sataz)
   satel = np.array(satel)
   satazv = np.array(satazv)
   satelv = np.array(satelv)

   pfname = str("pointing" + str(i) + ".txt")
   Pointing(pfname, len(time), dd, hh, time, sataz, satel, satazv, satelv)


