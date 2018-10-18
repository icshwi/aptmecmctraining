require ecmc,anderssandstrom
require ecmctraining,anderssandstrom
require axis,10.1.5
############################################################
############# General:
# This file is only used to download the basic setup to an technosoft drive.
# Normally this is done from Technosoft EasySetup or EasyMotion Studio.
# The setup information can be downloaded via SDO access (after parsing to ecmc format)
# Parsing tool can be found in ecmctraining/V2/startup/hardware/technosoft
# This procedure should only be needed to perform once (new drive or replacing of drive)
# Please ensure that the online cheksum corresponds to the offline checksum (see logfile printouts)
############################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_ECMC_PREFIX=IOC2:)")

ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)

asynOctetSetOutputEos("$(ECMC_ASYN_PORT)", -1, ";\n")
asynOctetSetInputEos("$(ECMC_ASYN_PORT)", -1, ";\n")

asynSetTraceMask("$(ECMC_ASYN_PORT)", -1, 0x41)
asynSetTraceIOMask("$(ECMC_ASYN_PORT)", -1, 6)
asynSetTraceInfoMask("$(ECMC_ASYN_PORT)", -1, 1)

EthercatMCCreateController("$(ECMC_MOTOR_PORT)", "$(ECMC_ASYN_PORT)", "32", "200", "1000", "")

############################################################
############# Misc settings:
# Disable function call trace printouts
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEnableFuncCallDiag(0)"

# Disable on change printouts from objects (for easy logging)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(15,1)"

# Disable on command transform diag
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(7,0)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

# Choose to generate EPICS-records for ax-entries (PosAct, SetPos,..)
# (For records use ECMC_GEN_AX_RECORDS="-records" otherwise ECMC_GEN_AX_RECORDS="") 
epicsEnvSet("ECMC_GEN_AX_RECORDS",          "-records")

# Update records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "99")

############################################################
############# Configure hardware:

epicsEnvSet("ECMC_EC_MASTER_ID"          "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

# Configure IPOS 8020 Drive terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "21")

< $(ECMC_STARTUP_TOP)/hardware/ecmcIPOS4808-driveCSV${ECMC_GEN_EC_RECORDS}

# Configure Motor
< $(ECMC_STARTUP_TOP)/hardware/ecmcIPOS4808-Motor-OrientalMotor-PK296DB

# Download base config (parsed from Techosoft EasySetup configuration): Only needed first time a drive is used..
< $(ECMC_STARTUP_TOP)/hardware/ecmcIPOS4808-EEPROM-BaseConfig-StepperOpenLoopCSV

# Apply hardware configuration
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcApplyConfig(1)"

##############################################################################
############# Diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(10)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisEnable(0)"

##############################################################################
############# Load general controller level records:

< $(ECMC_STARTUP_TOP)/general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"
