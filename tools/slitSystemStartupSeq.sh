#!/bin/sh
if test -z "$PYEPICS_LIBCA"; then
    MYLIB=$EPICS_BASE/lib/$EPICS_HOST_ARCH/libca.so
    if test -r "$MYLIB"; then
	PYEPICS_LIBCA=$MYLIB
	export PYEPICS_LIBCA
    fi
fi &&
./slitSystemStartupSeq.py
./slitSystemMoveGapAndPoistion.py
./slitSystemSyncToMaster.py
