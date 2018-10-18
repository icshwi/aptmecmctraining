##############################################################################
############# LEBT Doppler Motion Control crate 
#
# First version: Control of the Doppler
#
# Configuration details:
# - Close openloop until the encoder is replaced stepper (EL7037)
# - 2 Limit switches and one homing switch
# - Scaled as a linear system 
# - Homing sequemce 3: simple homing (position will be set to zero when homing is triggered)
#
#
#  Date: 2018-05-17
#
##############################################################################

# used with e3

require ecmc,5.0.0
require ecmctraining,4.0.0
require EthercatMC,2.0.1
require stream, 2.7.7
require iocStats,1856ef5

#Old configuration tested with EEE

#require ecmc,4.3.0
#require ecmctraining,3.0.0
#require axis,10.1.5

< ../general/init

############################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_PREFIX=LEBT-010:)")

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

# Disable on change printouts from objects (enable for easy logging)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(15,0)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

# Choose to generate EPICS-records for ax-entries (PosAct, SetPos,..)
# (For records use ECMC_GEN_AX_RECORDS="-records" otherwise ECMC_GEN_AX_RECORDS="") 
epicsEnvSet("ECMC_GEN_AX_RECORDS",          "-records")

# Update records in 100Hz (skip 9 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "9")

############################################################
############# Configure hardware:

< ../hardware/ecmcLEBT_Doppler

##############################################################################
############# Write outputs in order to power switches (see elec. drawings):

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(1,0,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,1,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,2,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,3,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,4,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,5,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,6,1)"
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(4,7,1)"

#use it when e3 is the the enviroment
epicsEnvSet("STREAM_PROTOCOL_PATH", "/home/mtcauser/e3/e3-ecmctraining/ecmctraining/protocol")

##############################################################################
############# Configuration of doppler:

# Custom settings for Doppler actuator (LEBT-010:PBI-DPLA-001)
< doppler

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

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


