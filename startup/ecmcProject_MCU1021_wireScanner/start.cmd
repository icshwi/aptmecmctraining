require ecmc,4.3.0
require ecmctraining,3.0.0
require axis,10.1.5

< ../general/init

############################################################
############# Description:
# 
# This file is inteded to use with (MCU1021).
#
# The functionality demostrated by this startup file is:
# 1. Collision interlock. Only one axis at the time are allowed to 
#    move from the low limit switch. 3 layers of safety is implemented 
#    in order to avoid collision. 
#    1. The extra swithes (mounted togheter with low limit switches) can 
#       be wired to a relay that break power to the other drive (the
#       relay can be wired in many configuration, terminals on the back).
#    2. Soft interlock (called externalhwinterlock below). Each axis not 
#       allowed to move if the other axis is not at the lower limit switch.
#       The power will be removed from the terminal by software if needed.
#    3. Each EL7037 terminal has two inputs. These inputs can be 
#       configured to enable/disable the amplfier in the terminal (by sdo). 
#       This configuration is made for input 1 of the EL7037 terminals. 
#       The switch supervising the "other" axis needs to be connected to 
#       input 1 of the EL7037 drive.
#
# 2. Latching and storing of axes actual position.
#    1. An event is configured to trigger on rising edge of input 1 of the
#       terminal EL1252-0050 (NOTE 5V I/O).
#    2. Two data storages (currently 1000 elements) are configuered to hold data.
#    3. Two data recorders are configuerd to record actual position of each axis
#       into a data storage when the event is triggered.
#
# A CSS gui is available in order to visulaize the data. 
#
##############################################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_PREFIX=IOC_WS:)")

ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)
asynOctetSetOutputEos(${ECMC_ASYN_PORT}, -1, ";\n")
asynOctetSetInputEos(${ECMC_ASYN_PORT}, -1, ";\n")
asynSetTraceMask(${ECMC_ASYN_PORT}, -1, 0x41)
asynSetTraceIOMask(${ECMC_ASYN_PORT}, -1, 6)
asynSetTraceInfoMask(${ECMC_ASYN_PORT}, -1, 15)

EthercatMCCreateController(${ECMC_MOTOR_PORT}, ${ECMC_ASYN_PORT}, "32", "200", "1000", "")

##############################################################################
############# Misc settings:
# Disable function call trace printouts
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEnableFuncCallDiag(0)"

# Disable on change printouts from objects (enable for easy logging)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(15,0)"

# Enable on command transform diag
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(7,1)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

# Choose to generate EPICS-records for ax-entries (PosAct, SetPos,..)
# (For records use ECMC_GEN_AX_RECORDS="-records" otherwise ECMC_GEN_AX_RECORDS="") 
epicsEnvSet("ECMC_GEN_AX_RECORDS",          "-records")

# Update records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "99")


##############################################################################
############# Configure hardware:

< ../hardware/ecmcMCU1021

##############################################################################
############# Write outputs in order to power switches (see elec. drawings):

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},0,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},1,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},2,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},3,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},4,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},5,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},6,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},7,1)"

##############################################################################
############# Configuration of motor 1:

# Custom settings for Axis 1
< axis_1

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

##############################################################################
############# Configuration of motor 2:

# Custom settings for Axis 2
< axis_2

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

##############################################################################
############# Syncronization settings:

#Only allow one axis to be enabled simultaneous 
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisTransformCommandExpr(1)=IF(En1){En2:=0}#"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisEnableCommandsTransform(1,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisEnableCommandsFromOtherAxis(1,1)"

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisTransformCommandExpr(2)=IF(En2){En1:=0}#"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisEnableCommandsTransform(2,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisEnableCommandsFromOtherAxis(2,1)"

##############################################################################
############# Event handler:

epicsEnvSet("ECMC_EVENT_INDEX",                "1")

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.CreateEvent($(ECMC_EVENT_INDEX))"
# Trigger (digital bit)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkEcEntryToEvent($(ECMC_EVENT_INDEX),0,5,INPIN_1,0)"
# Edge triggered
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEventType($(ECMC_EVENT_INDEX),1)"
# Sample time not used in type 2
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEventSampleTime($(ECMC_EVENT_INDEX),10)"
# On  pos edge
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEventTriggerEdge($(ECMC_EVENT_INDEX),0)"
# Disable arm sequence
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEventEnableArmSequence($(ECMC_EVENT_INDEX),0)"
# Enable printouts
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEventEnablePrintouts($(ECMC_EVENT_INDEX),0)"
# Enable and validate event
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEventEnable($(ECMC_EVENT_INDEX),1)"
dbLoadRecords("ecmcEvent.db", "P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0,Index=$(ECMC_EVENT_INDEX)")

##############################################################################
############# Storage 1  For axis 1:

epicsEnvSet("ECMC_STORAGE_INDEX",              "1")
epicsEnvSet("ECMC_STORAGE_SIZE",               "1000")

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.CreateStorage($(ECMC_STORAGE_INDEX),$(ECMC_STORAGE_SIZE),0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.ClearStorage($(ECMC_STORAGE_INDEX))"
dbLoadRecords("ecmcDataStorage.db", "P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0,Index=$(ECMC_STORAGE_INDEX),Size=$(ECMC_STORAGE_SIZE)")

##############################################################################
############# Recorder 1 for axis 1:

epicsEnvSet("ECMC_RECORDER_INDEX",             "1")
epicsEnvSet("ECMC_STORAGE_INDEX",              "1")
epicsEnvSet("ECMC_EVENT_INDEX",                "1")
# First consumer of event:
epicsEnvSet("ECMC_EVENT_CONSUMER_INDEX",        "0")

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.CreateRecorder($(ECMC_RECORDER_INDEX))"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkStorageToRecorder($(ECMC_STORAGE_INDEX),$(ECMC_RECORDER_INDEX))"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkRecorderToEvent($(ECMC_RECORDER_INDEX),$(ECMC_EVENT_INDEX),$(ECMC_EVENT_CONSUMER_INDEX))"
# Link actual value (2) of axis 1 to recorder
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkAxisDataToRecorder($(ECMC_RECORDER_INDEX),1,2)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetRecorderEnablePrintouts($(ECMC_RECORDER_INDEX),0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetRecorderEnable($(ECMC_RECORDER_INDEX),1)"
dbLoadRecords("ecmcDataRecorder.db", "P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0,Index=$(ECMC_RECORDER_INDEX)")

##############################################################################
############# Storage 2 for axis 2:

epicsEnvSet("ECMC_STORAGE_INDEX",              "2")
epicsEnvSet("ECMC_STORAGE_SIZE",               "1000")

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.CreateStorage($(ECMC_STORAGE_INDEX),$(ECMC_STORAGE_SIZE),0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.ClearStorage($(ECMC_STORAGE_INDEX))"
dbLoadRecords("ecmcDataStorage.db", "P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0,Index=$(ECMC_STORAGE_INDEX),Size=$(ECMC_STORAGE_SIZE)")

##############################################################################
############# Recorder 2 for axis 2:

epicsEnvSet("ECMC_RECORDER_INDEX",             "2")
epicsEnvSet("ECMC_STORAGE_INDEX",              "2")
epicsEnvSet("ECMC_EVENT_INDEX",                "1")
# Second consumer of event:
epicsEnvSet("ECMC_EVENT_CONSUMER_INDEX",        "1")

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.CreateRecorder($(ECMC_RECORDER_INDEX))"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkStorageToRecorder($(ECMC_STORAGE_INDEX),$(ECMC_RECORDER_INDEX))"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkRecorderToEvent($(ECMC_RECORDER_INDEX),$(ECMC_EVENT_INDEX),$(ECMC_EVENT_CONSUMER_INDEX))"
# Link actual value (=2) of axis 2 to recorder
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkAxisDataToRecorder($(ECMC_RECORDER_INDEX),2,2)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetRecorderEnablePrintouts($(ECMC_RECORDER_INDEX),0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetRecorderEnable($(ECMC_RECORDER_INDEX),1)"
dbLoadRecords("ecmcDataRecorder.db", "P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0,Index=$(ECMC_RECORDER_INDEX)")

##############################################################################
############# Configure external hardware interlock for Axis 1:
# Enable cmd is removed by software if interlocked.
# Axis 1 are only allowed to move when input of drive is high
epicsEnvSet("ECMC_AXIS_NO",                "1")
epicsEnvSet("ECMC_EXT_HW_INPUT_SLAVE",     "7" )
epicsEnvSet("ECMC_MON_EXT_HW_IL_BIT",      "11")
epicsEnvSet("ECMC_EC_ALIAS_EXT_HW",        "STM_STATUS")
epicsEnvSet("ECMC_MON_EXT_HW_IL_ENA",      "1")
epicsEnvSet("ECMC_MON_EXT_HW_IL_POL",      "0")


EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkEcEntryToAxisMonitor($(ECMC_EXT_HW_INPUT_SLAVE),$(ECMC_EC_ALIAS_EXT_HW),$(ECMC_AXIS_NO),3,$(ECMC_MON_EXT_HW_IL_BIT))"
# Enable ext hw interlock
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisMonEnableExtHWInterlock($(ECMC_AXIS_NO),$(ECMC_MON_EXT_HW_IL_ENA))"
# Set interlock type to NO (not optimal from safety aspect).
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisMonExtHWInterlockPolarity($(ECMC_AXIS_NO),$(ECMC_MON_EXT_HW_IL_POL))"

##############################################################################
############# Configure external hardware interlock for Axis 2:
# Enable cmd is removed by software if interlocked.
# Axis 2 are only allowed to move when input of drive is high
epicsEnvSet("ECMC_AXIS_NO",                "2")
epicsEnvSet("ECMC_EXT_HW_INPUT_SLAVE",     "8")
epicsEnvSet("ECMC_MON_EXT_HW_IL_BIT",      "11")
epicsEnvSet("ECMC_EC_ALIAS_EXT_HW",        "STM_STATUS")
epicsEnvSet("ECMC_MON_EXT_HW_IL_ENA",      "1")
epicsEnvSet("ECMC_MON_EXT_HW_IL_POL",      "0")

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.LinkEcEntryToAxisMonitor($(ECMC_EXT_HW_INPUT_SLAVE),$(ECMC_EC_ALIAS_EXT_HW),$(ECMC_AXIS_NO),3,$(ECMC_MON_EXT_HW_IL_BIT))"
# Enable ext hw interlock (0=Disable, 1=Enable)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisMonEnableExtHWInterlock($(ECMC_AXIS_NO),$(ECMC_MON_EXT_HW_IL_ENA))"
# Set interlock type to NO (not optimal from safety aspect).
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisMonExtHWInterlockPolarity($(ECMC_AXIS_NO),$(ECMC_MON_EXT_HW_IL_POL))"

##############################################################################
############# Configure diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(100)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisIndex(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisFreq(2)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisEnable(0)"

##############################################################################
############# Load general controller level records:

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"


