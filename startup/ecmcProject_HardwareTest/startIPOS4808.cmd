require ecmc,anderssandstrom
require ecmctraining,anderssandstrom
require axis,10.1.5

< ../general/init

############################################################
############# General:

## values for motor 1
epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_PREFIX=IOC2:)")

############################################################
############# ASYN Configuration:

ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)

asynOctetSetOutputEos(${ECMC_ASYN_PORT}, -1, ";\n")
asynOctetSetInputEos(${ECMC_ASYN_PORT}, -1, ";\n")

asynSetTraceMask(${ECMC_ASYN_PORT}, -1, 0x41)
asynSetTraceIOMask(${ECMC_ASYN_PORT}, -1, 6)
asynSetTraceInfoMask(${ECMC_ASYN_PORT}, -1, 15)

EthercatMCCreateController(${ECMC_MOTOR_PORT}, ${ECMC_ASYN_PORT}, "32", "200", "1000", "")

############################################################
############# Misc settings:

# Disable function call trace printouts
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEnableFuncCallDiag(0)"

# Disable on change printouts from objects (for easy logging)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(15,0)"

# Disable on command transform diag
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(7,0)"

# Enable EtherCAT diag
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(5,1)"

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

epicsEnvSet("ECMC_EC_MASTER_ID"          "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

# Configure IPOS 4808 Drive terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "24")
< ../hardware/ecmcIPOS4808-driveCSV${ECMC_GEN_EC_RECORDS}

# Configure Motor
< ../hardware/ecmcIPOS4808-Motor-OrientalMotor-PK296DB

# Apply hardware configuration
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcApplyConfig(1)"

##############################################################################
############# Configuration of motor 1:

# Custom settings for Axis 1
< startIPOS4808_Axis1

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

##############################################################################
############# Diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(10)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisEnable(0)"

##############################################################################
############# Load general controller level records:

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"
