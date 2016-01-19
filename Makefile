SRC_DIR = $(dir .)
OBJS = $(shell find $(SRC_DIR) -iname '*.o')
FLASH_OBJS = objects/pflash/progress.o \
    objects/pflash/ast-sf-ctrl.o \
    objects/pflash/libflash/libflash.o \
    objects/pflash/libflash/libffs.o \
    objects/pflash/arm_io.o

CFLAGS += $(shell pkg-config --cflags gio-unix-2.0) \
	  -Iincludes -Iobjects/pflash -I.
LDLIBS += $(shell pkg-config --libs gio-unix-2.0)

all: board_vpd pcie_slot_present pflash button_power button_reset control_host \
	power_control led_controller hwmons_barreleye flasher flash_bios \
	host_watchdog control_bmc

interfaces/%.o: CFLAGS += -fPIC

.PHONY: clean
clean:
	$(RM) bin/*.exe bin/pflash
	$(RM) lib/libopenbmc_intf.so
	$(RM) $(OBJS)
	$(RM) -r lib

lib/libopenbmc_intf.so: LDFLAGS += -shared
lib/libopenbmc_intf.so: LDLIBS += $(shell pkg-config --libs glib-2.0)
lib/libopenbmc_intf.so: interfaces/openbmc_intf.o
	mkdir -p lib
	$(LINK.o) $< -o $@

button_power button_reset control_host power_control led_controller: % : \
    objects/%_obj.o includes/object_mapper.o includes/gpio.o \
    lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o bin/$@.exe

flash_bios host_watchdog hwmons_barreleye: % : \
    objects/%_obj.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o bin/$@.exe

control_bmc board_vpd: % : objects/%_obj.o lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o bin/$@.exe

flasher: objects/flasher_obj.o $(FLASH_OBJS) lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o bin/$@.exe

pflash: objects/pflash/pflash.o $(FLASH_OBJS) lib/libopenbmc_intf.so
	$(LINK.c) $(LDFLAGS) $^ -o bin/$@

pcie_slot_present: objects/pcie_slot_present_obj.o includes/gpio.o
	$(LINK.o) $^ $(LDLIBS) -o bin/$@.exe
