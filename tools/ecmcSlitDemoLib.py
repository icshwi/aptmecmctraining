#!/usr/bin/env python

import epics
import os
import sys
import time
import math


MSTA_BIT_HOMED        =  1 << (15 -1)    #4000
MSTA_BIT_MINUS_LS     =  1 << (14 -1)    #2000
MSTA_BIT_COMM_ERR     =  1 << (13 -1)    #1000
MSTA_BIT_GAIN_SUPPORT =  1 << (12 -1)    #0800
MSTA_BIT_MOVING       =  1 << (11 -1)    #0400
MSTA_BIT_PROBLEM      =  1 << (10 -1)    #0200
MSTA_BIT_PRESENT      =  1 << (9 -1)     #0100
MSTA_BIT_HOME         =  1 << (8 -1)     #0080
MSTA_BIT_SLIP_STALL   =  1 << (7 -1)     #0040
MSTA_BIT_AMPON        =  1 << (6 -1)     #0020
MSTA_BIT_UNUSED       =  1 << (5 -1)     #0010
MSTA_BIT_HOMELS       =  1 << (4 -1)     #0008
MSTA_BIT_PLUS_LS      =  1 << (3 -1)     #0004
MSTA_BIT_DONE         =  1 << (2 -1)     #0002
MSTA_BIT_DIRECTION    =  1 << (1 -1)     #0001

####################################################################################
def triggHomeAxis(motor,cmdData):
  print "Start homing sequence of axis %s (nCmdData=%d)" % (motor,cmdData)
  hlm = float(epics.caget(motor + '.HLM'))
  llm = float(epics.caget(motor + '.LLM'))
  range_postion    = hlm - llm
  homing_velocity  = epics.caget(motor + '.HVEL')
  acceleration     = epics.caget(motor + '.ACCL')

  epics.caput(motor + '-ProcHom',cmdData)

  # Home the motor  
  msta = int(epics.caget(motor + '.MSTA'))
  if (msta & MSTA_BIT_PLUS_LS):
    epics.caput(motor + '.HOMR', 1)
  else:
    epics.caput(motor + '.HOMF', 1)

####################################################################################
def waitForAxis(motor,timeToWait):
  polltime=0.2
  sys.stdout.flush()
  time.sleep(polltime*2)
  wait_for_start = 5
  while wait_for_start > 0:
    wait_for_start -= polltime
    dmov = int(epics.caget(motor + '.DMOV'))
    movn = int(epics.caget(motor + '.MOVN'))
    sys.stdout.write('.')
    sys.stdout.flush()
    if movn and not dmov:
      break
    time.sleep(polltime)

  wait_for_done=timeToWait
  wait_for_done = math.fabs(wait_for_done) #negative becomes positive
  wait_for_done += 1 # One extra second for rounding
  while wait_for_done > 0:
    dmov = int(epics.caget(motor + '.DMOV'))
    movn = int(epics.caget(motor + '.MOVN'))
    sys.stdout.write('.')
    sys.stdout.flush()
    if dmov and not movn:
      print('')
      return True;
    time.sleep(polltime)
    wait_for_done -= polltime
  print('')
  return False

####################################################################################
def getAxisError(motor, exitOnError):
  errorId=int(epics.caget(motor + '-ErrId'))
  if errorId and exitOnError:
    print 'Axis %s in error state: %d' %(motor,errorId)
  return errorId

####################################################################################
def setAxisReset(motor, reset):
  epics.caput(motor + '-ErrRst', reset)
  return

####################################################################################
def setAxisEnable(motor, enable):
  epics.caput(motor + '.CNEN', enable)
  return

####################################################################################
#def moveAxisPosition(motor,position,timout):
def moveAxisPosition(motor,*restArgs):
  length=len(restArgs)
  if length<1  or length>2:
    print "moveAxisPosition: Wrong in arguments list (moveAxisPosition(motor,position,timout), timeout is optional)." 
    return False
  if length==1:
    position=restArgs[0]
    timeout=0
  if length==2:
    position=restArgs[0]
    timeout=restArgs[1]

  epics.caput(motor + '.VAL', position)

  getAxisError(motor,1)
  if timeout>0:
    done=waitForAxis(motor,timeout)
    if not done:
      print "%s failed to position."
      return False
  return True

####################################################################################
def setSoftHighLimt(motor,limt):
  epics.caput(motor + '.HLM',limt)
  return True

####################################################################################
def setSoftLowLimt(motor,limt):
  epics.caput(motor + '.LLM',limt)
  return True

####################################################################################
def moveAxisVelocity(motor,velocity):
  epics.caput(motor + '.JVEL',velocity)
  if velocity==0:
    print "moveAxisVelocity: Velocity must be !=0."
  if velocity>0:
    epics.caput(motor + '.JOGF', 1)
  else:
    epics.caput(motor + '.JOGR', 1)

  getAxisError(motor,1)
  return True

####################################################################################

#def stopAxis(motor,timeout)
def stopAxis(*restArgs):
  length=len(restArgs)
  if length<1  or length>2:
    print "stopAxis: Wrong in arguments list (stopAxis(motor,timout), timeout is optional)." 
    return False
  if length==1:
    motor=restArgs[0]
    timeout=0
  if length==2:
    motor=restArgs[0]
    timeout=restArgs[1]
  epics.caput(motor + '.STOP', 1)

  getAxisError(motor,1)
  if timeout>0:
    done=waitForAxis(motor,timeout)
    if not done:
      print "%s failed to position."
      return False
  return True


