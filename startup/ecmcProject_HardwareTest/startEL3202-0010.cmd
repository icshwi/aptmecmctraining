#require ecmc,5.0.0
#require ecmctraining,4.0.0
#require axis,10.1.5

require ecmc,5.0.0
require ecmctraining,4.0.0
require EthercatMC,2.0.1
require stream, 2.7.7
require iocStats,1856ef5


#require ecmc,4.3.0
#require ecmctraining,3.0.0
#require axis,10.1.5

< ../general/init

###############################################################################
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

###############################################################################
############# Misc settings:
# Disable function call trace printouts
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetEnableFuncCallDiag(0)"

# Disable on change printouts from objects (for easy logging)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(15,0)"

# Disable on command transform diag
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetTraceMaskBit(7,0)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-epicsrecords" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

# Update records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "99")

###############################################################################
############# Configure hardware:

epicsEnvSet("STREAM_PROTOCOL_PATH", "/home/iocuser/e3/e3-ecmctraining/ecmctraining/protocol")

epicsEnvSet("ECMC_EC_MASTER_ID"               "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

# Configure EL3202-0010 analog input hardware
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "3")
< ../hardware/ecmcEL3202-0010-analogInput$(ECMC_GEN_EC_RECORDS)

############# Configure sensors:
# Common for all channels
< ../hardware/ecmcEL32X4-Sensor-PT100-common

# Configure channel 1 with S+S Regeltechnik HFT50 PT100
epicsEnvSet("ECMC_EC_SDO_INDEX",         "0x8000")
< ../hardware/ecmcEL3202-0010-Sensor-chX_S+S_RegelTechnik_HTF50_PT100

# Configure channel 2 with S+S Regeltechnik HFT50 PT100
epicsEnvSet("ECMC_EC_SDO_INDEX",         "0x8010")
< ../hardware/ecmcEL3202-0010-Sensor-chX_S+S_RegelTechnik_HTF50_PT100

# Apply hardware configuration
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcApplyConfig(1)"

###############################################################################
############# Configure diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(10)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"

##############################################################################
############# Load general controller level records:

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"
