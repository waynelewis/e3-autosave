#
#  Copyright (c) 2017 - 2018   Jeong Han Lee
#  Copyright (c) 2019          European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author  : Jeong Han Lee
# email   : han.lee@esss.se
# Date    : Tuesday, March 19 11:08:51 CET 2019
# version : 0.0.3

# Get where_am_I before include driver.makefile.
# After driver.makefile, where_am_I is the epics base,
# so we cannot use it

# LEGACY_RSET should be defined before driver.makefile
# require-ess from 3.0.1
LEGACY_RSET = YES


where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include ${E3_REQUIRE_TOOLS}/driver.makefile
include $(E3_REQUIRE_CONFIG)/DECOUPLE_FLAGS


# To enable autosaveBuild, use dbLoadRecordsHookRegister.  (But it doesn't
# appear in EPICS base until 3.14.12.5, so disable by default for now.)
# ESS uses the more than 3.14.12.5, so we enable them by default

USR_CFLAGS   += -DDBLOADRECORDSHOOKREGISTER

USR_CFLAGS   += -Wno-unused-variable
USR_CFLAGS   += -Wno-unused-function
USR_CPPFLAGS += -Wno-unused-variable
USR_CPPFLAGS += -Wno-unused-function

ASAPP:=asApp

ASAAPDB:= $(ASAPP)/Db
ASAPPSRC:= $(ASAPP)/src

HEADERS += $(ASAPPSRC)/os/Linux/osdNfs.h

SOURCES += $(ASAPPSRC)/dbrestore.c
SOURCES += $(ASAPPSRC)/save_restore.c
SOURCES += $(ASAPPSRC)/initHooks.c
SOURCES += $(ASAPPSRC)/fGetDateStr.c
SOURCES += $(ASAPPSRC)/configMenuSub.c
SOURCES += $(ASAPPSRC)/os/Linux/osdNfs.c
SOURCES += $(ASAPPSRC)/verify.c

DBDS    += $(ASAPPSRC)/asSupport.dbd

SCRIPTS += $(wildcard ../iocsh/*.iocsh)

TEMPLATES += $(ASAAPDB)/save_restoreStatus.db
TEMPLATES += $(ASAAPDB)/configMenu.db


## asVerify will be installed in both $PROD_BIN_PATH and $EPICS_BASE/bin/$(T_A)
## with suffix $(E3_MODULE_VERSION)
##
TEMP_PATH :=$(where_am_I)O.$(EPICSVERSION)_$(T_A)
ASVERIFY  :=$(TEMP_PATH)/bin/asVerify_$(E3_MODULE_VERSION)

BINS += $(ASVERIFY)


vpath %.c   $(where_am_I)$(ASAPPSRC)
vpath %.h   $(where_am_I)$(ASAPPSRC)


verify$(DEP): $(ASVERIFY)
	@echo  $^
	install -m 755 $^  $(EPICS_BASE)/bin/$(T_A)/


# We only use linux, so I added $(OP_SYS_LDFLAGS) $(ARCH_DEP_LDFLAGS)
# Fortunately, libautosave.so isn't used to compile asVerify, so we ignore its flags
$(ASVERIFY): asVerify.c $(patsubst %.c,%.o, asVerify.c verify.c )
	@echo ""
	@echo ">>>>> asVerify Init "
	$(RM) $@
	$(MKDIR) -p $(TEMP_PATH)/bin
	$(CCC) -o $@ -L$(EPICS_BASE_LIB) -Wl,-rpath,$(EPICS_BASE_LIB) $(OP_SYS_LDFLAGS) $(ARCH_DEP_LDFLAGS)  $(filter %.o, $^) -lca -lCom 
	@echo "<<<<< asVerify Done"
	@echo ""



.PHONY: db
db:
#
.PHONY: vlibs
vlibs:
#

