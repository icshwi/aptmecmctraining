require ecmc,anderssandstrom
require ecmctraining,anderssandstrom
require axis,10.1.5

< ../general/init

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
# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

# Update records in 1000Hz (skip 0 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "0")

############################################################
############# Configure hardware:

epicsEnvSet("ECMC_EC_MASTER_ID"          "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

epicsEnvSet("ECMC_EC_SLAVE_NUM",              "13")
< ../hardware/ecmcEL4102-analogOutput${ECMC_GEN_EC_RECORDS}

# Configure channel 1 with default values (just to show the available settings) NOTE: Strange that first ch is 8010 and not 8000 like similar terminals
epicsEnvSet("ECMC_EC_SDO_INDEX",         "0x8010")
< ../hardware/ecmcEL4XXX-settings-chX-default

# Configure channel 2 with default values (just to show the available settings)
epicsEnvSet("ECMC_EC_SDO_INDEX",         "0x8020")
< ../hardware/ecmcEL4XXX-settings-chX-default

# Apply hardware configuration
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcApplyConfig(1)"

###############################################################################
############# Configure diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(10)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"

##############################################################################
############# Load general controller level records:

# Update general records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "99")

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"
