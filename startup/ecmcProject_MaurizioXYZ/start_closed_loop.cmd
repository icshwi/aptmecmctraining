##############################################################################
############# TEST FILE FOR MAURIZIO
#
# Configuration details:
# - Closed loop stepper (EL7047)
# - Limit switches linked to inputs of EL7047 (Not the best approach)
# - Scaled as a linear system (scaled in mm and mm/s)
# - Homing sequemce 0: simple homing (position will be set to zero when homing is triggered
# - Example of encoder offset added in "Motor 1" section below. Could be usefull for absolute encoders (potentiometer in this case)
#
#  Date: 2018-03-16
#
##############################################################################
############# EEE configuration:

require ecmc,4.2.0
require ecmctraining,3.0.0
require axis,10.1.5

##############################################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_PREFIX=IOC2:)")

ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)

asynOctetSetOutputEos("${ECMC_ASYN_PORT}", -1, ";\n")
asynOctetSetInputEos("${ECMC_ASYN_PORT}", -1, ";\n")
asynSetTraceMask("${ECMC_ASYN_PORT}", -1, 0x41)
asynSetTraceIOMask("${ECMC_ASYN_PORT}", -1, 6)
asynSetTraceInfoMask("${ECMC_ASYN_PORT}", -1, 1)

EthercatMCCreateController("${ECMC_MOTOR_PORT}", "${ECMC_ASYN_PORT}", "32", "200", "1000", "")

##############################################################################
############# Misc settings:

# Disable function call trace printouts
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetEnableFuncCallDiag(0)"

# Disable on change printouts from objects (enable for easy logging)
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetTraceMaskBit(15,0)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-asynrecords" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-asynrecords")

# Choose to generate EPICS-records for ax-entries (PosAct, SetPos,..)
# (For records use ECMC_GEN_AX_RECORDS="-asynrecords" otherwise ECMC_GEN_AX_RECORDS="") 
epicsEnvSet("ECMC_GEN_AX_RECORDS",          "-asynrecords")

# Update records in 10Hz (skip 99 cycles, based on 1000Hz sample rate)
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",          "99")

##############################################################################
############# Configure hardware:

epicsEnvSet("ECMC_EC_MASTER_ID"          "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

#Configure EK1100 coupler terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "0")
< ../hardware/ecmcEK1100-EtherCatCoupler$(ECMC_GEN_EC_RECORDS)

#Configure EL3255 for feedbacks
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "1")
< ../hardware/ecmcEL3255-potentiometerInput$(ECMC_GEN_EC_RECORDS)

#Configure EL7047 stepper drive terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "2")
< ../hardware/ecmcEL7047-StepperDrive$(ECMC_GEN_EC_RECORDS)
#  Configure motor for EL7047
< ../hardware/ecmcEL7047-Motor-Leadshine-57HS09

#Apply hardware configuration
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcApplyConfig(1)"

##############################################################################
############# Custom Hardware Settings:

# Set max current to 1500mA:
#epicsEnvSet("ECMC_EC_SLAVE_NUM",              "2")
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcAddSdo(${ECMC_EC_SLAVE_NUM},0x8010,0x1,5000,2)"

# Set reduced current to 1000mA:
#epicsEnvSet("ECMC_EC_SLAVE_NUM",              "2")
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcAddSdo(${ECMC_EC_SLAVE_NUM},0x8010,0x2,500,2)"

##############################################################################
############# Configuration of motor 1

# Custom settings for Axis 1
< axis_1_closed_loop

# Apply configurations to ECMC
< ../motion/ecmc_axis$(ECMC_GEN_AX_RECORDS)

# EXAMPLE (if needed): Offset encoder for axis 1 by 100.0.. NOTE: The command is commented out..
#EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.SetAxisEncOffset($(ECMC_AXIS_NO),100)"

##############################################################################
############# Configure diagnostics:

EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.EcSetDomainFailedCyclesLimit(100)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetDiagAxisIndex(1)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetDiagAxisFreq(2)"
EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetDiagAxisEnable(0)"

##############################################################################
############# Load general controller level records:

< ../general/general

##############################################################################
############# Go to runtime:

EthercatMCConfigController "${ECMC_MOTOR_PORT}", "Cfg.SetAppMode(1)"

#############################################################################
################ Custom Setup for RL3255 - Potentiometers

# Note: Work in Range [0,105] mm        
# LINR "SLOPE"
# ESLO "-0.0032145"
# EOFF "105"
# EGU "mm"


