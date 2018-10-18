#!/usr/bin/env python

import epics
import os
import sys
import time
import math
import unittest
import ecmcSlitDemoLib

leftMotor = 'IOC2:xl'
rightMotor = 'IOC2:xr'
gapMotor = 'IOC2:xg'
centerMotor= 'IOC2:xp'
masterMotor= 'IOC2:master'


#Disable softLimits
ecmcSlitDemoLib.setSoftLowLimt(leftMotor, 0)
ecmcSlitDemoLib.setSoftLowLimt(rightMotor, 0)
ecmcSlitDemoLib.setSoftLowLimt(gapMotor, 0)
ecmcSlitDemoLib.setSoftLowLimt(centerMotor, 0)
ecmcSlitDemoLib.setSoftLowLimt(masterMotor, 0)

ecmcSlitDemoLib.setSoftHighLimt(leftMotor, 0)
ecmcSlitDemoLib.setSoftHighLimt(rightMotor, 0)
ecmcSlitDemoLib.setSoftHighLimt(gapMotor, 0)
ecmcSlitDemoLib.setSoftHighLimt(centerMotor, 0)
ecmcSlitDemoLib.setSoftHighLimt(masterMotor, 0)

#Reset error on all axis
print 'Reset error on all axes.'
ecmcSlitDemoLib.setAxisReset(leftMotor, 1)
ecmcSlitDemoLib.setAxisReset(rightMotor, 1)
ecmcSlitDemoLib.setAxisReset(gapMotor, 1)
ecmcSlitDemoLib.setAxisReset(centerMotor, 1)
ecmcSlitDemoLib.setAxisReset(masterMotor, 1)
time.sleep(0.5)
ecmcSlitDemoLib.setAxisReset(leftMotor, 0)
ecmcSlitDemoLib.setAxisReset(rightMotor, 0)
ecmcSlitDemoLib.setAxisReset(gapMotor, 0)
ecmcSlitDemoLib.setAxisReset(centerMotor, 0)
ecmcSlitDemoLib.setAxisReset(masterMotor, 0)

#ensure internal traj source of all axis 
print 'Ensure internal trajectory source on all axes'
ecmcSlitDemoLib.setAxisEnable(leftMotor, 0)
ecmcSlitDemoLib.setAxisEnable(rightMotor, 0)
ecmcSlitDemoLib.setAxisEnable(gapMotor, 0)
ecmcSlitDemoLib.setAxisEnable(centerMotor, 0)
ecmcSlitDemoLib.setAxisEnable(masterMotor, 0)
time.sleep(0.5) #ensure that enabled goes down
error=ecmcSlitDemoLib.getAxisError(leftMotor,1)
error=ecmcSlitDemoLib.getAxisError(rightMotor,1);
error=ecmcSlitDemoLib.getAxisError(gapMotor,1)
error=ecmcSlitDemoLib.getAxisError(centerMotor,1);
error=ecmcSlitDemoLib.getAxisError(masterMotor,1)

epics.caput(centerMotor + '-TrajSourceType-Cmd', 0)
epics.caput(gapMotor + '-TrajSourceType-Cmd', 0)
epics.caput(leftMotor + '-TrajSourceType-Cmd', 0)
epics.caput(rightMotor + '-TrajSourceType-Cmd', 0)
epics.caput(masterMotor + '-TrajSourceType-Cmd', 0)
error=ecmcSlitDemoLib.getAxisError(leftMotor,1);
error=ecmcSlitDemoLib.getAxisError(rightMotor,1);
error=ecmcSlitDemoLib.getAxisError(gapMotor,1);
error=ecmcSlitDemoLib.getAxisError(centerMotor,1);
error=ecmcSlitDemoLib.getAxisError(masterMotor,1);

#Start homing sequences
ecmcSlitDemoLib.triggHomeAxis(leftMotor,3)
ecmcSlitDemoLib.triggHomeAxis(rightMotor,3)

print 'Wait for homing sequences to finish:',
done=ecmcSlitDemoLib.waitForAxis(leftMotor,180)
if not done:
  print "%s failed to home." % leftMotor
  sys.exit()
done=ecmcSlitDemoLib.waitForAxis(rightMotor,180)
if not done:
  print "%s failed to home." % rightMotor
  sys.exit()

ecmcSlitDemoLib.setAxisEnable(masterMotor, 1)
#run master axis motor to 0
print 'Move master axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(masterMotor,0,1000)
if not done:
  print "%s failed to position." % masterMotor
  sys.exit()
ecmcSlitDemoLib.setAxisEnable(masterMotor, 0)


#disable amplifier of left and right motor
print 'Disable amplifiers on all axes.'
ecmcSlitDemoLib.setAxisEnable(leftMotor, 0)
ecmcSlitDemoLib.setAxisEnable(rightMotor, 0)
ecmcSlitDemoLib.setAxisEnable(gapMotor, 0)
ecmcSlitDemoLib.setAxisEnable(centerMotor, 0)
ecmcSlitDemoLib.setAxisEnable(masterMotor, 0)
time.sleep(1) #ensure that enabled goes down
error=ecmcSlitDemoLib.getAxisError(leftMotor,1)
error=ecmcSlitDemoLib.getAxisError(rightMotor,1);
error=ecmcSlitDemoLib.getAxisError(gapMotor,1);
error=ecmcSlitDemoLib.getAxisError(centerMotor,1);
error=ecmcSlitDemoLib.getAxisError(masterMotor,1);

#change traj source of left and right motor to external
print 'Set traj source to external for left and right axis.'
epics.caput(leftMotor + '-TrajSourceType-Cmd', 1)
epics.caput(rightMotor + '-TrajSourceType-Cmd', 1)
error=ecmcSlitDemoLib.getAxisError(leftMotor,1);
error=ecmcSlitDemoLib.getAxisError(rightMotor,1);

#enable gap and center motor
print 'Enable amplifiers on centre and gap axis.'
epics.caput(gapMotor + '.CNEN', 1)
epics.caput(centerMotor + '.CNEN', 1)
time.sleep(1) #ensure that enabled goes up
error=ecmcSlitDemoLib.getAxisError(gapMotor,1)
error=ecmcSlitDemoLib.getAxisError(centerMotor,1)

#run gap and center motor to 0
print 'Move gap axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(gapMotor,0,10)
if not done:
  print "%s failed to position."
  sys.exit()

print 'Move center axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(centerMotor,0,10)
if not done:
  print "%s failed to position."
  sys.exit()

print "Slit system ready to operate!"

