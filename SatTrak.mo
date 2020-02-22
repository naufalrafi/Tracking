package SatTrak
  model Satellite "Models Spacecraft Trajectory in Perifocal coords"
    constant Real pi = Modelica.Constants.pi;
    constant Real d2r = Modelica.Constants.D2R;
    constant Real k2 = 2.2005645e4 "0.5J2Re^2 (km2)";
    constant Real mu = 398600.4418 "km^3/s^2";
    parameter Real M0 "Mean anomaly at Epoch (deg)";
    parameter Real N0 "Mean motion at Epoch (rev/d)";
    parameter Real eccn "Eccentricity";
    parameter Real Ndot2 "1st Der Mean Motion over 2 (rev/d2)";
    parameter Real Nddot6 "2nd Der Mean Motion over 6 (rev/d3)";
    parameter Real raan0 "Right Ascension Ascending Node at Epoch (deg)";
    parameter Real argper0 "Argument of Perigee at Epoch (deg)";
    parameter Real incl "Inclination angle (deg)";
    parameter Real tstart "Time from ref epoch to start of sim (sec)";
    Real M "Mean Anomaly (deg)";
    Real N "Mean Motion (rev/d)";
    Real E "Eccentric Anomaly (deg)";
    Real theta "true anomaly (deg)";
    Real a "Semi-major axis (km)";
    Real a0 = (398600.4 * 86400 ^ 2 / 4 / pi ^ 2 / N0 ^ 2) ^ (1 / 3) "Semi-major axis at Epoch";
    Real raan "Right Ascension Ascending Node (deg)";
    Real argper "Argument of Perigee (deg)";
    Real r "Satellite radial distance (km)";
    Real rotang[3] "TODO: fill in the angles here";
    Real p_sat_pf[3] "Satellite posn in pf coords (km)";
    Real v_sat_pf[3] "Satellite vel in pf coords (km/s)";
    //Following procedure from 6.5.1 "Perifocal Coordinates for the Spacecraft"
  initial equation
    raan = raan0 + N0 * 360. / 86400. * (3. * k2 * cos(incl * d2r) / (a ^ 2 * (1. - eccn ^ 2) ^ 2)) * tstart;
    argper = argper0 + N0 * 360. / 86400. * (-3. * k2 * (5. * cos(incl * d2r) ^ 2 - 1.) / (a ^ 2 * (1. - eccn ^ 2) ^ 2)) * tstart;
    a = a0;
    N = N0 + 2 * Ndot2 * (time / 86400. ^ 2) + 3 * Nddot6 * (time ^ 2 / 86400. ^ 3);
    M = M0 + N0 * (360. * tstart) / 86400. + 360. * Ndot2 * (tstart / 86400.) ^ 2 + 360. * Nddot6 * (tstart / 86400.) ^ 3;
  equation
//step 2, Mean Anomaly
    der(M) = N0 * (360. / 86400.) + 2 * 360. * Ndot2 * (time / 86400. ^ 2) + 3 * 360. * Nddot6 * (time ^ 2 / 86400. ^ 3);
    M * d2r = E * d2r - eccn * sin(E * d2r);
    tan(theta * d2r / 2.) = sqrt((1. + eccn) / (1. - eccn)) * tan(E * d2r / 2.) "step 5, convert E to theta";
    N = 86400 / (2. * pi) * sqrt(mu / a ^ 3);
    der(N) = 2 * 360. * Ndot2 * (1 / 86400. ^ 2) + 6 * 360. * Nddot6 * (time / 86400. ^ 3);
    r = a * (1. - eccn ^ 2) / (1. + eccn * cos(theta * d2r)) "step 6, find range to satellite";
//step 7, position and velocity in perifocal coordinates
    p_sat_pf[1] = r * cos(theta * d2r);
    p_sat_pf[2] = r * sin(theta * d2r);
    p_sat_pf[3] = 0.;
    v_sat_pf[1] = der(p_sat_pf[1]);
    v_sat_pf[2] = der(p_sat_pf[2]);
    v_sat_pf[3] = der(p_sat_pf[3]);
//J2 stuff
    der(raan) = N * 360. / 86400. * (3. * k2 * cos(incl * d2r) / (a ^ 2 * (1 - eccn ^ 2) ^ 2));
    der(argper) = N * 360. / 86400. * (-3. * k2 * (5. * cos(incl * d2r) ^ 2 - 1) / (a ^ 2 * (1 - eccn ^ 2) ^ 2));
//and inputting rotation angles from perifocal -> ECI
    rotang[1] = -argper / d2r;
    rotang[2] = -incl / d2r;
    rotang[3] = -raan / d2r;
  end Satellite;

  model Station
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axesRotations;
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
    constant Real Re = 6378.137 "Earth radius (km)";
    constant Real f = 1 / 298.257223563 "Earth ref ellipsoid flattening";
    constant Real ecc_e_sq = 2 * f - f ^ 2 "Square of earth eccentricity";
    constant Real d2r = Modelica.Constants.D2R;
    parameter Real stn_long "Station longitude (degE)";
    parameter Real stn_lat "Station latitude (degN)";
    parameter Real stn_elev "Station elevation (m)";
    Real p_stn_topo[3] "Station coordinates in TOPO";
    Real p_stn_ECF[3] "Station coordinates in ECF (km)";
    Real N_phi "Ellipsoidal Radius of Curvature in the meridian (km)";
    Real TM[3, 3] "Transform matrix from ECF to topo";
    Integer seq[3] "rotation axes";
    Real ang[3] "rotation angles";
  equation
    N_phi = Re / sqrt(1 - ecc_e_sq * sin(d2r * stn_lat) ^ 2);
    ang = {d2r * stn_long, d2r * (90 - stn_lat), d2r * 90};
    seq = {3, 2, 3};
    p_stn_ECF[1] = (N_phi + stn_elev * 10 ^ (-3)) * cos(d2r * stn_lat) * cos(d2r * stn_long);
    p_stn_ECF[2] = (N_phi + stn_elev * 10 ^ (-3)) * cos(d2r * stn_lat) * sin(d2r * stn_long);
    p_stn_ECF[3] = (1 - ecc_e_sq) * N_phi * sin(d2r * stn_lat);
    TM = axesRotations(seq, ang);
    p_stn_topo = resolve2(TM, p_stn_ECF);
  end Station;

  function sat_ECI "Converts Peri-focal coordinates to ECI"
    // Function to calculate the current satellite trajectory in ECI coordinates.
    // Author : Matthieu
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axesRotations;
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
  
    input Real ang[3] "-argper, -inc, -raan (rad)";
    input Real p_pf[3] "Posn vector in Perifocal coords (km)";
    input Real v_pf[3] "Velocity vector in Perifocal coords (km/s)";
    
    output Real p_ECI[3] "Posn vector in ECI coords (km)";
    output Real v_ECI[3] "Velocity vector in ECI coords (km/s)";
    
    protected
      Integer seq[3] = {3,1,3} "Angle sequence from pf to ECI";
      Real TM[3, 3]= axesRotations(sequence=seq, angles=ang);
    
    algorithm
      p_ECI := resolve2(TM, p_pf);
      v_ECI := resolve2(TM, v_pf);
  
  end sat_ECI;

  function theta_d
    // Function to calculate the Greenwich Mean Sidereal Time in degrees
    input Real days "Number of days from J2000 to start of day in question";
    input Real hours "hours from midnight of the day in question to time in question";
    output Real GMST "GMST angle (deg)";
  protected
    Real T = days / 36525 "number of julian centuries";
    Real r = 1.002737909350795 + 5.9006e-11 * T - 5.9e-15 * T ^ 2;
  algorithm
    GMST := 100.4606184 + 36000.77005 * T + 0.00038793 * T ^ 2 - 2.6e-8 * T ^ 3 "GMST at midnight [degrees]";
    GMST := GMST + 360 * r * hours;
    GMST := mod(GMST, 360) "remove integer multiples of 360 degrees";
// Author : Matthieu
//    Real Tuu = days/36525;
//    Real d2r = Modelica.Constants.D2R;
//    Real GMST_h = 6.697374558 + 0.06570982441906*days + 1.00273790935*hours + 0.000026*Tuu^2;
//    Real GMST_d = GMST_h * 15;
//
//  algorithm
//    GMST := mod(GMST_d, 360);
  end theta_d;

  function sat_ECF "Converts ECI to ECF coordinates"
    // Function to calculate the current satellite position and velocity in ECF coordinates
  
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axisRotation;
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
  
    input Real ang "GMST angle (deg)";
    input Real p_ECI[3] "Position vector in ECI coordinates (km)";
    input Real v_ECI[3] "Velocity vector in ECI coordinates (km/s)";
    
    output Real p_ECF[3] "Position vector in ECF coordinates (km)";
    output Real v_ECF[3] "Relative Velocity vector in ECF coordinates (km/s)";
  
  protected
    Real d2r = Modelica.Constants.D2R;
    Real theta_dot[3] = {0., 0., 360/86154.091} "Relative motion in the constant sidereal motion of the Earth";
    Integer ax = 3;
    Real wcross[3, 3] = skew({0., 0., 360. / 86164. * d2r});
    Real TM[3, 3] = axisRotation(axis = ax, angle = ang * d2r);
    
    Real v_ECF_inertial[3];
    Real v_ECI_rel[3];
  
  algorithm
    p_ECF := resolve2(TM, p_ECI);
    v_ECF_inertial := resolve2(TM, v_ECI);
    v_ECI_rel := v_ECI - wcross * p_ECI;
    v_ECF := resolve2(TM, v_ECI_rel);
  
  end sat_ECF;

  function range_ECF2topo
    // Function to find the current satellite position and velocity in the topocentric system coordinates.
    // Author : Matthieu Durand
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
    input Real p_stn_ECF[3] "Position of station in ECF coords";
    input Real p_sat_ECF[3] "Position of satellite in ECF coords";
    input Real v_sat_ECF[3] "Relative Velocity of satellite in ECF coords";
    input Real TM[3, 3] "Transform matrix from ECF to topo";
    output Real p_sat_topo[3] "Position of satellite relative to station, topo coords (km)";
    output Real v_sat_topo[3] "Velocity of satellite relative to station, topo coords (km/s)";
  algorithm
    p_sat_topo := resolve2(TM, p_sat_ECF - p_stn_ECF);
    v_sat_topo := resolve2(TM, v_sat_ECF);
  end range_ECF2topo;

  // This function calculates look angles, azimuth and elevation, at the station position in the topocentric system
  // Inputs: Topocentric position and velocity vectors of the satellite
  //Outputs: Azimuth, Elevation Look-Angles at Station

  function range_topo2look_angles
    input Real p_sat_topo[3] "Position of satellite in topo coords (km)";
    input Real v_sat_topo[3] "Velocity of satellite in topo coords (km)";
    
    output Real az "Azimuth look angle (deg)";
    output Real el "Elevation look angle (deg)";
    output Real dazdt "Azimuth rate (deg/s)";
    output Real deldt "Elevation rate (deg/s)";
    
  protected
    Real d2r = Modelica.Constants.D2R;
    
  algorithm
    az := atan(p_sat_topo[1] / p_sat_topo[2]);
    el := atan(p_sat_topo[3] / sqrt(p_sat_topo[1] ^ 2 + p_sat_topo[2] ^ 2));
    dazdt := (v_sat_topo[1] * p_sat_topo[2] - v_sat_topo[2] * p_sat_topo[1]) / (p_sat_topo[1:2] * p_sat_topo[1:2]);
    deldt := (sqrt(p_sat_topo[1:2] * p_sat_topo[1:2]) * v_sat_topo[3] - p_sat_topo[3] * (p_sat_topo[1:2] * v_sat_topo[1:2]) / sqrt(p_sat_topo[1:2] * p_sat_topo[1:2])) / (p_sat_topo * p_sat_topo);
    
  end range_topo2look_angles;

  model FINAL
    constant Real pi = Modelica.Constants.pi;
    constant Real d2r = Modelica.Constants.D2R;
    constant Real k2 = 2.2005645e4 "0.5J2Re^2 (km2)";
    constant Real Gconst = 398600.4;
    parameter Real M0 "Mean anomaly at Epoch (deg)";
    parameter Real N0 "Mean motion at Epoch (rev/d)";
    parameter Real eccn "Eccentricity";
    parameter Real incl "Inclination angle (deg)";
    parameter Real Ndot2 "1st Der Mean Motion over 2 (rev/d2)";
    parameter Real Nddot6 "2nd Der Mean Motion over 6 (rev/d3)";
    parameter Real raan0 "Right Ascension Ascending Node at Epoch (deg)";
    parameter Real argper0 "Argument of Perigee at Epoch (deg)";
    parameter Real tstart "Time from ref epoch to start of sim (sec)";
    parameter Real stn_long "Station longitude (degE)";
    parameter Real stn_lat "Station latitude (degN)";
    parameter Real stn_elev "Station elevation (m)";
    parameter Real d0 "Number of days from J2000 to start of tracking day";
    parameter Real h0 "Number of hours after 00:00:00 of d0";
    parameter Real azlim "Azimuth of azelmin/max";
    parameter Real azelmin "min elevation at azlim";
    parameter Real azelmax "max elevation at azlim";
    parameter Real azspeedmax "max daz/dt";
    parameter Real elspeedmax "max del/dt";
    SatTrak.Satellite Sat(M0 = M0, N0 = N0, eccn = eccn, Ndot2 = Ndot2, Nddot6 = Nddot6, raan0 = raan0, incl = incl, argper0 = argper0, tstart = tstart);
    SatTrak.Station Stn(stn_long = stn_long, stn_lat = stn_lat, stn_elev = stn_elev);
    Real p_sat_ECI[3] "Satellite position in ECI coordinates (km)";
    Real v_sat_ECI[3] "Satellite velocity in ECI coordinates (km/s)";
    Real GMST "GMST angle (deg)";
    Real p_sat_ECF[3] "Position vector in ECF coordinates (km)";
    Real v_sat_ECF[3] "Relative Velocity vector in ECF coordinates (km/s)";
    Real p_sat_topo[3] "position of satellite relative to station (km)";
    Real v_sat_topo[3] "velocity of satellite relative to sration (km/s)";
    Real hours "day fraction at simulation time";
    Real Azimuth "Satellite azimuth (deg/s)";
    Real Elevation "Satellite elevation (deg/s)";
    Real dazdt "Satellite azimuth speed (deg/s)";
    Real deldt "Satellite elevation speed (deg/s)";
    Real Elmin = 9 "Minimum Elevation For Station (deg)";
    Real Elmax = 89 "Maximum Elevation for Station (deg)";
    //  Real AOS "time of Acqusition of Signal";
    //  Real LOS "time of Loss of Signal";
    //  Boolean inView "Satellite is in view";
    //  Boolean NinView "Satellite is not in view";
  equation
//Satellite Perifocal to ECI
    (p_sat_ECI, v_sat_ECI) = sat_ECI(ang = {-1 * d2r * Sat.argper, -1 * d2r * incl, -1 * d2r * Sat.raan}, p_pf = Sat.p_sat_pf, v_pf = Sat.v_sat_pf);
//GMST angle from epoch date
    hours = h0 + time * (1 / 86400) "start dayfrac + simulation time (seconds converted to dayfrac)";
    GMST = theta_d(days = d0, hours = hours);
//Satellite ECI to ECF
    (p_sat_ECF, v_sat_ECF) = sat_ECF(ang = GMST, p_ECI = p_sat_ECI, v_ECI = v_sat_ECI);
//Range, trajectory of satellite relative to station
    (p_sat_topo, v_sat_topo) = range_ECF2topo(p_stn_ECF = Stn.p_stn_ECF, p_sat_ECF = p_sat_ECF, v_sat_ECF = v_sat_ECF, TM = Stn.TM);
//Look angles
    (Azimuth, Elevation, dazdt, deldt) = range_topo2look_angles(p_sat_topo = p_sat_topo, v_sat_topo = v_sat_topo);
//VISIBILITY
//elmin = azelmin; //Modelica.Math.Vectors.interpolate(azlim, azelmin, Azimuth);
//elmax = azelmax; //Modelica.Math.Vectors.interpolate(azlim, azelmax, Azimuth);
//  NinView = Elevation<azelmin or Elevation>azelmax;
//  inView = Elevation>=azelmin and Elevation<=azelmax;
//
//  if initial() then
//    if inView then
//      AOS = 0;
//    else
//      AOS = -1;
//    end if;
//  end if;
//
//  when edge(inView) then
//    AOS = time;
//  end when;
//
//  when edge(NinView) then
//    LOS = time;
//  end when;
  end FINAL;
end SatTrak;
