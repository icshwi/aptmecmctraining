require aptmsupervisor,0.0.1

dbLoadRecords("dbStateMachine.db", "P=aptm")
dbLoadTemplate("dbtemperature.substitutions")


iocInit()

## Start sequence programs
#seq dummy, "P=aptm"
seq state_test, "P=aptm"
#seq collision_prevention, "P=aptm"
