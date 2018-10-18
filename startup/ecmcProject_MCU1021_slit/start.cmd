require ecmc,4.3.0
require ecmctraining,3.0.0
require axis,10.1.5

< ../general/init

##############################################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_PREFIX=IOC2:)")

ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)

asynOctetSetOutputEos("${ECMC_ASYN_PORT}", -1, ";\n")
asynOctetSetInputEos("${ECMC_ASYN_PORT}", -1, ";\n")

asynSetTraceMask("${ECMC_ASYN_PORT}", -1, 0x41)
asynSetTraceIOMask("${ECMC_ASYN_PORT}", -1, 2)
asynSetTraceIOMask("${ECMC_ASYN_PORT}", -1, 6)

asynSetTraceInfoMask("${ECMC_ASYN_PORT}", -1, 1)

EthercatMCCreateController("${ECMC_MOTOR_PORT}", "${ECMC_ASYN_PORT}", "32", "200", "1000", "")

##############################################################################
############# Misc settings:

#Disable function call trace printouts
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetEnableFuncCallDiag(0)"

# Disable on change printouts from objects (enable for easy logging)
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetTraceMaskBit(15,0)"

# Enable on change printouts from transformation objects 
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetTraceMaskBit(7,1)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

# Choose to generate EPICS-records for ax-entries (PosAct, SetPos,..)
# (For records use ECMC_GEN_AX_RECORDS="-records" otherwise ECMC_GEN_AX_RECORDS="") 
epicsEnvSet("ECMC_GEN_AX_RECORDS",          "-records")

# Update records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",          "99")

##############################################################################
############# Configure hardware:

< ../hardware/ecmcMCU1021

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

##############################################################################
############# Configuration of motor 3 (left blade):

# Custom settings for Axis 3
< axis_3

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

# Sync. settings
< axis_3_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync

##############################################################################
############# Configuration of motor 4 (right blade):

# Custom settings for Axis 4
< axis_4

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

# Sync. settings
< axis_4_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync

##############################################################################
############# Configuration of motor 1 (center position):

epicsEnvSet("ECMC_MOTOR_NAME",    "xp")
epicsEnvSet("ECMC_R",             "xp-")
epicsEnvSet("ECMC_AXIS_NO",       "1")
epicsEnvSet("ECMC_DESC",          "Center position")
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
< axis_1_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync

##############################################################################
############# Configuration of motor 2 (gap):

epicsEnvSet("ECMC_MOTOR_NAME",    "xg")
epicsEnvSet("ECMC_R",             "xg-")
epicsEnvSet("ECMC_AXIS_NO",       "2")
epicsEnvSet("ECMC_DESC",          "Gap")
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
< axis_2_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync

##############################################################################
############# Configuration of motor 5 (master, timing):

epicsEnvSet("ECMC_MOTOR_NAME",    "master")
epicsEnvSet("ECMC_R",             "master-")
epicsEnvSet("ECMC_AXIS_NO",       "5")
epicsEnvSet("ECMC_DESC",          "Master")
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
< axis_5_sync

# Apply configurations to ECMC
< ../motion/ecmc_axis_sync

##############################################################################
############# Configure diagnostics:

EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.EcSetDomainFailedCyclesLimit(100)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetDiagAxisIndex(4)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetDiagAxisFreq(2)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetDiagAxisEnable(0)"

##############################################################################
############# Load general controller level records:

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetAppMode(1)"

