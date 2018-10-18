require ecmc,anderssandstrom
require ecmctraining,anderssandstrom
require axis,10.1.5

< ../general/init

############################################################
############# ASYN Configuration:

epicsEnvSet("ECMC_MOTOR_PORT",    "$(SM_ECMC_MOTOR_PORT=MCU1)")
epicsEnvSet("ECMC_ASYN_PORT",     "$(SM_ASYN_PORT=MC_CPU1)")
epicsEnvSet("ECMC_PREFIX",        "$(SM_ECMC_PREFIX=IOC2:)")

#drvAsynECMCPortConfigure("$(ECMC_ASYN_PORT)", 0, 0, 0)
ecmcAsynPortDriverConfigure($(ECMC_ASYN_PORT),1000,0,0)
asynOctetSetOutputEos("$(ECMC_ASYN_PORT)", -1, ";\n")
asynOctetSetInputEos("$(ECMC_ASYN_PORT)", -1, ";\n")

asynSetTraceMask("$(ECMC_ASYN_PORT)", -1, 0x41)
asynSetTraceIOMask("$(ECMC_ASYN_PORT)", -1, 2)
asynSetTraceIOMask("$(ECMC_ASYN_PORT)", -1, 6)
asynSetTraceInfoMask("$(ECMC_ASYN_PORT)", -1, 1)

EthercatMCCreateController("$(ECMC_MOTOR_PORT)", "$(ECMC_ASYN_PORT)", "32", "200", "1000", "")

############################################################
############# Misc settings:

#Disable function call trace printouts
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetEnableFuncCallDiag(0)"

# enable on change printouts from objects (for easy logging)
#EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetTraceMaskBit(15,1)"

# enable jitter printouts
#EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetTraceMaskBit(13,1)"

# Choose to generate EPICS-records for EtherCAT-entries 
# (For records use ECMC_GEN_EC_RECORDS="-records" otherwise ECMC_GEN_EC_RECORDS="") 
epicsEnvSet("ECMC_GEN_EC_RECORDS",          "-records")
#Skip 9 cycles => update every 10 cycles, 1kHz realtime loop=> 100Hz update rate in IOC
epicsEnvSet("ECMC_ASYN_SKIP_CYCLES",       "9")

############################################################
############# Configure hardware:

epicsEnvSet("ECMC_EC_MASTER_ID"          "0")

#Choose master
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetMaster($(ECMC_EC_MASTER_ID))"

#Configure EL7037 stepper drive terminal, motor 2
epicsEnvSet("ECMC_EC_SLAVE_NUM",              "15")
< ../hardware/ecmcEL7037-StepperDrive-PosIF$(ECMC_GEN_EC_RECORDS)

#Configure motor for EL7037
< ../hardware/ecmcEL7037-Motor-Trinamic-QMot-QSH4218-41-10-035

#Apply hardware configuration
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcApplyConfig(1)"

##############################################################################
############# Write outputs in order to power switches (see elec. drawings):

# Set to one to be able to check if the EtherCAT is OK
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetDiagnostics(1)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcEnablePrintouts(0)"
EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.EcSetDomainFailedCyclesLimit(100)"

##############################################################################
############# Load general controller level records:
dbLoadRecords("ecmcControllerGeneral.db","P=$(ECMC_PREFIX),PORT=$(ECMC_ASYN_PORT),A=0")

##############################################################################
############# Go to runtime:

EthercatMCConfigController "$(ECMC_MOTOR_PORT)", "Cfg.SetAppMode(1)"

# Below is a sequence describing what records to use for absolute positioning! 
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-StartType 1
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-AccCmd 1000
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-DecCmd 1000
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-VelCmd 500
# Enable
#mcu002> dbpf IOC2:ec0-s15-EL7037-Drv-Cmd 1
# Move one rev (200step*64microstepping)
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-PosCmd 12800
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-Cmd 0
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-Cmd 1
# Get actual position alt 1
#mcu002> dbgf IOC2:ec0-s15-EL7037-Enc-PosAct
# Get actual position alt 2
#mcu002> dbgf IOC2:ec0-s15-EL7037-Pos-Pos
# Stop motion
#mcu002> dbpf IOC2:ec0-s15-EL7037-Pos-Cmd 0

