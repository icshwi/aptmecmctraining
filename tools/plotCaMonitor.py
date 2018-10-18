#!/usr/bin/python
# coding: utf-8
import sys
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

# Usage example:
#  camonitor IOC2:xr-PosSet IOC2:xr-PosAct IOC2:xr-VelAct IOC2:xr.RBV 2>&1 | tee ~/projects/temp/qwerty.txt
#  python plotCaMonitor.py ~/projects/temp/qwerty.txt

class caMonitorArrayParser:
  def __init__(self):
    return

  def lineValid(self, line):
    pos1=line.rfind(':')
    if pos1>0:
      return 1
    else:
      return 0

  def getTimeFromString(self,line):
    return datetime.strptime(line,"%Y-%m-%d %H:%M:%S.%f") 

  def getValues(self,line):
    mylist=line.split()
    data = np.array(mylist[3])
    timeString=mylist[1]+" "+mylist[2]
    timeVal=self.getTimeFromString(str(timeString))
    pvName=mylist[0]
    return pvName, timeVal, data

class caPVArray:
  def __init__(self,name):
    self.name=name
    self.dataSet=np.array([])
    self.timeSet=np.array([])
    self.dataSetLength=0
    return

  def setName(self, name):
    self.name=name
    return
  
  def getName(self):
    return self.name

  def getData(self):
    self.dataSet=self.dataSet.astype( np.dtype('float64'))
    return self.timeSet, self.dataSet

  def setValues(self,timeVal,value):
    self.dataSet=np.append(self.dataSet,value)
    self.timeSet=np.append(self.timeSet,timeVal)  
    self.dataSetLength=self.dataSetLength+1;
    return

  def getLength(self):
    return self.dataSetLength
 

def main():
  # Check args
  if len(sys.argv)!=2:
    print "python parseCaMonitorArray.py <filename>"
    print "example: python parseCaMonitorArray.py xx.txt"
    sys.exit()

  fname=sys.argv[1]
  dataFile=open(fname,'r')
  parser=caMonitorArrayParser()
  pvs=[]

  for line in dataFile:
    if not parser.lineValid(line):
      print "Not valid!"
      continue

    pvName, timeVal, data=parser.getValues(line)
    newPv=True;
    pvToAddDataTo=caPVArray(pvName)
    # See if old or new pv
    for pv in pvs:
      if pv.getName() == pvName:        
        pvToAddDataTo=pv
        newPv=False;
        break;
    
    pvToAddDataTo.setValues(timeVal,data)
    if newPv:       
      pvs.append(pvToAddDataTo)
      print "Added PV" + pvName
    
  legend=[]
  for pv in pvs: 
    legend.append(pv.getName())
    print  pv.getName()+ ": " + str(pv.getLength())
    timeSet, dataSet=pv.getData() 
    #for d in dataSet:
    #  print d
    x=timeSet
    y=dataSet
    plt.plot(x,y,'o-')


  plt.legend(legend)
  plt.grid()
  plt.title(fname)
  plt.xlabel("time")
  plt.show()
  

if __name__ == "__main__":
  main()
    
    
