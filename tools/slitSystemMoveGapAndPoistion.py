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

print 'Move center axis to position -25.'
done=ecmcSlitDemoLib.moveAxisPosition(centerMotor,-25,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)

print 'Move gap axis to position 20.'
done=ecmcSlitDemoLib.moveAxisPosition(gapMotor,20,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)

print 'Move center axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(centerMotor,0,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)

print 'Move gap axis to position 0.'
done=ecmcSlitDemoLib.moveAxisPosition(gapMotor,0,100)
if not done:
  print "%s failed to position."
  sys.exit()

time.sleep(2)


