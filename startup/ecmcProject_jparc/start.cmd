
##############################################################################
############# jparc Motion Control crate 
#
# First version: Control of the jparc
#
# Configuration details:
# - Close openloop until the encoder is replaced stepper (EL7037)
# - 2 Limit switches and one homing switch
# - Scaled as a linear system 
# - Homing sequemce 3: simple homing (position will be set to zero when homing is triggered)
#
#
#  Date: 2018-07-25
#
##############################################################################

# used with e3

require ecmc,5.0.0
require ecmctraining,4.0.0
require EthercatMC,2.0.1
require stream, 2.7.7
require sequencer 2.1.21
require iocStats,1856ef5
 
#Old configuration tested with EEE

#require ecmc,4.3.0
#require ecmctraining,3.0.0
#require axis,10.1.5

# TOP is startup
epicsEnvSet("ECMC_STARTUP_TOP", "$(E3_CMD_TOP)/..")

< $(ECMC_STARTUP_TOP)/general/init


##>> ASYN Configuration:
##
epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_PREFIX=jparc:)")

ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)

asynOctetSetOutputEos(${ECMC_ASYN_PORT}, -1, ";\n")
asynOctetSetInputEos(${ECMC_ASYN_PORT}, -1, ";\n")

# asynSetTraceMask(${ECMC_ASYN_PORT}, -1, 0x41)
# asynSetTraceIOMask(${ECMC_ASYN_PORT}, -1, 6)
# asynSetTraceInfoMask(${ECMC_ASYN_PORT}, -1, 15)

EthercatMCCreateController(${ECMC_MOTOR_PORT}, ${ECMC_ASYN_PORT}, "32", "200", "1000", "")

##>>> ############# Misc settings:
##

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

##>>>> ############# Configure hardware:
##
< $(ECMC_STARTUP_TOP)/hardware/ecmc_jparc

##############################################################################
############# Write outputs in order to power switches (see elec. drawings):

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,0,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,1,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,2,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,3,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,4,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,5,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,6,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,7,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,8,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,9,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,10,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,11,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,12,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,13,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,14,1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "WriteEcEntry(2,15,1)"

#use it when e3 is the the enviroment
epicsEnvSet("STREAM_PROTOCOL_PATH", "$(ECMC_STARTUP_TOP)/../protocol")

##############################################################################
############# Configuration of motor 3 (OFFSET BETWEEN AXIS 1 AND 2):

epicsEnvSet("ECMC_MOTOR_NAME",    "xp")
epicsEnvSet("ECMC_R",             "xp-")
epicsEnvSet("ECMC_AXIS_NO",       "3")
epicsEnvSet("ECMC_DESC",          "OFFSET BETWEEN AXIS 1 AND 2 ")
epicsEnvSet("ECMC_SOFT_LOW_LIM",          "$(SM_DLLM=0)")
epicsEnvSet("ECMC_SOFT_HIGH_LIM",          "$(SM_DHLM=0)")

epicsEnvSet("ECMC_EC_SLAVE_NUM_MON_LLS",  "-1")                 # EtherCAT Slave No for low limit switch
epicsEnvSet("ECMC_EC_ALIAS_MON_LLS",      "ONE")                # PDO alias for low limit switch
epicsEnvSet("ECMC_EC_BIT_INDEX_MON_LLS",  "0")                  # Bit index for low limit switch

epicsEnvSet("ECMC_EC_SLAVE_NUM_MON_HLS",    "-1")               # EtherCAT Slave No for high limit switch
epicsEnvSet("ECMC_EC_ALIAS_MON_HLS",        "ONE")              # PDO alias for high limit switch
epicsEnvSet("ECMC_EC_BIT_INDEX_MON_HLS",    "0")                # Bit index for high limit switch

epicsEnvSet("ECMC_EC_SLAVE_NUM_MON_HOME_SWITCH", "-1")          # EtherCAT Slave No for home limit switch
epicsEnvSet("ECMC_EC_ALIAS_MON_HOME_SWITCH",     "ONE")         # PDO alias for home limit switch
epicsEnvSet("ECMC_EC_BIT_INDEX_MON_HOME",        "0")           # Bit index for home switch

< ../motion/ecmc_virt_axis$(ECMC_GEN_AX_RECORDS)

# Sync. settings
< axis_3_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync

##############################################################################
############# Configuration of Axis 1:

# Custom settings for jparc 001 actuator
< $(E3_CMD_TOP)/Axis_1

# Apply configurations to ECMC
< $(ECMC_STARTUP_TOP)/motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

# Sync. settings
< axis_1_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync
 
##############################################################################
############# Configuration of Axis 2:

# Custom settings for jparc 002 actuator                      
< $(E3_CMD_TOP)/Axis_2

# Apply configurations to ECMC
< $(ECMC_STARTUP_TOP)/motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

# Sync. settings
< axis_2_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync



# ##############################################################################
# ############# Configure diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(100)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisIndex(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisFreq(2)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetDiagAxisEnable(0)"

# ##############################################################################
# ############# Load general controller level records:

< $(ECMC_STARTUP_TOP)/general/general

# ##############################################################################
# ############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"


