require ecmc,anderssandstrom
require ecmctraining,anderssandstrom
require axis,10.1.5

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

# Choose to generate EPICS-records for ax-entries (PosAct, SetPos,..)
# (For records use ECMC_GEN_AX_RECORDS="-records" otherwise ECMC_GEN_AX_RECORDS="") 
epicsEnvSet("ECMC_GEN_AX_RECORDS",          "-records")

# Update records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "99")

###############################################################################
############# Configure hardware:

epicsEnvSet("ECMC_EC_MASTER_ID"               "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

#Configure EL1018 digital input terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "0")
< ../hardware/ecmcEL1018-digitalInput$(ECMC_GEN_EC_RECORDS)

#Configure EL2808 digital output terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "1")
< ../hardware/ecmcEL2808-digitalOutput$(ECMC_GEN_EC_RECORDS)

# Save the slave number for later
epicsEnvSet("ECMC_EC_SLAVE_NUM_DIG_OUT", "${ECMC_EC_SLAVE_NUM}")

#Configure EL5101 incremental encoder terminal, motor 1
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "2")
< ../hardware/ecmcEL5101-IncEncoder$(ECMC_GEN_EC_RECORDS)

#Configure EL5101 incremental encoder terminal, motor 2
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "3")
< ../hardware/ecmcEL5101-IncEncoder$(ECMC_GEN_EC_RECORDS)

# Configure EL9505 Power supply terminal 5V
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "4")
< ../hardware/ecmcEL9505-powerSupply5V$(ECMC_GEN_EC_RECORDS)

# Configure EL1252 digital input terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "5")
< ../hardware/ecmcEL1252-digitalInput$(ECMC_GEN_EC_RECORDS)

# Configure EL9410 Power supply with refresh of E-Bus.
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "6")
< ../hardware/ecmcEL9410-powerSupplyEBus$(ECMC_GEN_EC_RECORDS)

#Configure EL7037 stepper drive terminal, motor 1
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "7")
< ../hardware/ecmcEL7037-StepperDrive$(ECMC_GEN_EC_RECORDS)

#Configure motor for EL7037
< ../hardware/ecmcEL7037-Motor-Nanotec-ST4118L1804-B

#Configure EL7037 stepper drive terminal, motor 2
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "8")
< ../hardware/ecmcEL7037-StepperDrive$(ECMC_GEN_EC_RECORDS)

#Configure motor for EL7037
< ../hardware/ecmcEL7037-Motor-Nanotec-ST4118L1804-B

# Apply hardware configuration
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcApplyConfig(1)"

##############################################################################
############# Write outputs in order to power switches (see elec. drawings):

EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},0,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},1,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},2,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},3,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},4,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},5,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},6,1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},7,1)"

###############################################################################
############# Configure diagnostics:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDomainFailedCyclesLimit(10)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcEnablePrintouts(0)"

##############################################################################
############# Load general controller level records:

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAppMode(1)"
