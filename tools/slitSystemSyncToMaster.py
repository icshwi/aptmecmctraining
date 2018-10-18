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

ecmcSlitDemoLib.setAxisReset(leftMotor, 1)
ecmcSlitDemoLib.setAxisReset(rightMotor, 1)
ecmcSlitDemoLib.setAxisReset(gapMotor, 1)
ecmcSlitDemoLib.setAxisReset(centerMotor, 1)
ecmcSlitDemoLib.setAxisReset(masterMotor, 1)
time.sleep(0.5)

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

time.sleep(2)

#change traj source of gap to external
print 'Set traj source to external for gap axis.'
epics.caput(gapMotor + '-TrajSourceType-Cmd', 1)
error=ecmcSlitDemoLib.getAxisError(gapMotor,1);

#Enable all axis 5 (all axes should then be enabled)
print 'Enable  axis 5 (all axes should then be enabled).'
ecmcSlitDemoLib.setAxisEnable(masterMotor, 1)
error=ecmcSlitDemoLib.getAxisError(masterMotor,1)
time.sleep(0.5) #ensure enabled 

#Jog master
print 'Jog master axis.'
error=ecmcSlitDemoLib.moveAxisVelocity(masterMotor,10);

time.sleep(10)

#Move center to position 50
print 'Move center axis to position 20.'
done=ecmcSlitDemoLib.moveAxisPosition(centerMotor,20,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)
print 'Move center axis to position -20.'
done=ecmcSlitDemoLib.moveAxisPosition(centerMotor,-20,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)
print 'Jog center axis in positive direction.'
done=ecmcSlitDemoLib.moveAxisVelocity(centerMotor,10)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(10)
print 'Stop center axis.'
done=ecmcSlitDemoLib.stopAxis(centerMotor,10)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(3)
print 'Move center axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(centerMotor,0,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(4)
print 'Stop master  axis.'
done=ecmcSlitDemoLib.stopAxis(masterMotor,10)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)
print 'Move master axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(masterMotor,0,200)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)
print 'Disable master axis.'
ecmcSlitDemoLib.setAxisEnable(masterMotor, 0)

time.sleep(2)
#change traj source of center position to external
print 'Set traj source to external for gap axis.'
epics.caput(centerMotor + '-TrajSourceType-Cmd', 1)
error=ecmcSlitDemoLib.getAxisError(gapMotor,1);

print 'Enable master axis.'
time.sleep(2)
ecmcSlitDemoLib.setAxisEnable(masterMotor, 1)

time.sleep(2)
#Jog master
print 'Jog master axis. Now both center position and gap are synchronized to the master'
error=ecmcSlitDemoLib.moveAxisVelocity(masterMotor,20);










