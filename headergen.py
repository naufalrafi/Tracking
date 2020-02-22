# -*- coding: utf-8 -*-
"""
Created on Tue Mar 19 19:59:23 2019

@author: Rafi
testEPHEM TimePosVel header generator
"""
filename = input("please name the file (include .txt file extension): ")
f= open(filename,'w+')
    

ver = input("STK Ephemeris version: ")
npts = input("Number of desired Ephemeris points: ")
scnep = input("Scenario epoch (STK DateTime fomat): ")
intmet = input("Interpolation method: ")
intord = input("Interpolation order: ")
CB = input("Central body: ")
CS = input("Coordinate system: ")
CSE = input("Coordinate system epoch: ")



f.write("stk.v." + str(ver) + '\n' + "NumberOfEphemerisPoints " + str(npts) + '\n' + "ScenarioEpoch           " + str(scnep) + '\n' + "InterpolationMethod     " + str(intmet) + '\n' + "InterpolationOrder      " + str(intord) + '\n' + "CentralBody             " + str(CB) + '\n' + "CoordinateSystem        " + str(CS) + '\n' + "CoordinateSystemEpoch	" + str(CSE) + '\n' + "EphemerisTimePosVel" + '\n')
f.close