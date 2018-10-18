
require ecmc,4.0.3
require ecmctraining,2.1.0
require axis,10.1.2

############################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_ECMC_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_ECMC_PREFIX=IOC2:)")

drvAsynECMCPortConfigure("$(ECMC_ASYN_PORT)", 0, 0, 0)
asynOctetSetOutputEos("$(ECMC_ASYN_PORT)", -1, ";\n")
asynOctetSetInputEos("$(ECMC_ASYN_PORT)", -1, ";\n")

asynSetTraceMask("$(ECMC_ASYN_PORT)", -1, 0x41)
asynSetTraceIOMask("$(ECMC_ASYN_PORT)", -1, 2)
asynSetTraceIOMask("$(ECMC_ASYN_PORT)", -1, 6)
asynSetTraceInfoMask("$(ECMC_ASYN_PORT)", -1, 1)

#-----------------------
EthercatMCCreateController("$(ECMC_MOTOR_PORT)", "$(ECMC_ASYN_PORT)", "32", "200", "1000", "")

############################################################
############# Misc settings:

#Disable function call trace printouts
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetEnableFuncCallDiag(0)"

# enable on change printouts from objects (for easy logging)
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetTraceMaskBit(15,1)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")

############################################################
############# Configure hardware:

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster(0)"

#0  0:0  PREOP  +  EK1100 EtherCAT-Koppler (2A E-Bus)

#Configure EK1100 EtherCAT Coupler
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "0")
< ../hardware/ecmcEK1100-EtherCatCoupler$(ECMC_GEN_EC_RECORDS)

#1  0:1  PREOP  +  EL1018 8K. Dig. Eingang 24V, 10�s

#Configure EL1018 digital input terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "1")
< ../hardware/ecmcEL1018-digitalInput$(ECMC_GEN_EC_RECORDS)

#2  0:2  PREOP  +  EL2808 8K. Dig. Ausgang 24V, 0.5A

#Configure EL2808 digital output terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "2")
< ../hardware/ecmcEL2808-digitalOutput$(ECMC_GEN_EC_RECORDS)


# Save the slave number for later
epicsEnvSet("ECMC_EC_SLAVE_NUM_DIG_OUT", "${ECMC_EC_SLAVE_NUM}")

#3  0:3  PREOP  +  EL5101 1K. Inc. Encoder 5V

#Configure EL5101 incremental encoder terminal, motor 1 (Lab. Actuator)
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "3")
< ../hardware/ecmcEL5101-IncEncoder$(ECMC_GEN_EC_RECORDS)

#4  0:4  PREOP  +  EL5101 1K. Inc. Encoder 5V

#Configure EL5101 incremental encoder terminal, motor 2 (Buncher Mobile Tuner)
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "4")
< ../hardware/ecmcEL5101-IncEncoder$(ECMC_GEN_EC_RECORDS)

#5  0:5  PREOP  +  EL3002 2K.Ana. Eingang  +/-10V

# Configure EL3002 analog input terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "5")
< ../hardware/ecmcEL3002-analogInput$(ECMC_GEN_EC_RECORDS)

#6  0:6  PREOP  +  EL4032 2K. Ana. Ausgang +/-10V, 12bit

# Configure EL4032 analog output terminal
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "6")
< ../hardware/ecmcEL4032-analogOutput$(ECMC_GEN_EC_RECORDS)

#7  0:7  PREOP  +  EL9410 E-Bus Netzteilklemme (Diagnose)

# Configure EL9410 Ebus Power Supply
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "7")
< ../hardware/ecmcEL9410-powerSupplyEBus$(ECMC_GEN_EC_RECORDS)

#8  0:8  PREOP  +  EL7037 1K. Schrittmotor-Endstufe (24V, 1.5A)

#Configure EL7037 stepper drive terminal, motor 1
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "8")
< ../hardware/ecmcEL7037-StepperDrive$(ECMC_GEN_EC_RECORDS)

#Configure motor for EL7037
< ../hardware/ecmcEL7037-Motor-Nanotec-ST5918L1008

#9  0:9  PREOP  +  EL7037 1K. Schrittmotor-Endstufe (24V, 1.5A)

#Configure EL7037 stepper drive terminal, motor 2
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "9")
< ../hardware/ecmcEL7037-StepperDrive$(ECMC_GEN_EC_RECORDS)

#Configure motor for EL7037
< ../hardware/ecmcEL7037-Motor-Mclennan-HT18C230

#Max full step freq = 8000Hz (setting is 3)
EthercatMCConfigController ${ECMC_MOTOR_PORT}, "Cfg.EcAddSdo(${ECMC_EC_SLAVE_NUM},0x8012,0x5,3,1)"

#Apply hardware configuration
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcApplyConfig(1)"

##############################################################################
############# Write outputs in order to power switches (see elec. drawings):

#Write to outputs in order to power limit switches (see electrical drawings)
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},0,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},1,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},2,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},3,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},4,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},5,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},6,2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "WriteEcEntry(${ECMC_EC_SLAVE_NUM_DIG_OUT},7,2)"

##############################################################################
############# Configuration of motor 1:

# Custom settings for Axis 1
< ecmcMCU-2axis-ESSB-Lab_Axis1

# Apply configurations to ECMC
< ../motion/ecmcMCU-10xx-Axis

##############################################################################
############# Configuration of motor 2:

# Custom settings for Axis 2
< ecmcMCU-2axis-ESSB-Lab_Axis2

# Apply configurations to ECMC
< ../motion/ecmcMCU-10xx-Axis

##############################################################################
############# Configure diagnostics:

# Set to one to be able to check if the EtherCAT is OK
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetDomainFailedCyclesLimit(100)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetDiagAxisIndex(1)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetDiagAxisFreq(2)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetDiagAxisEnable(1)"
# enable jitter printouts
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetTraceMaskBit(13,1)"

##############################################################################
############# Load general controller level records:
dbLoadRecords("ecmcControllerGeneral.db","P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0")

##############################################################################
############# Go to runtime:

EthercatMCConfigController MCU1 .ctrl.ErrRst
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetAppMode(1)"

#var streamDebug 1
