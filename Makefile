SRC_DIR = $(dir .)

FLASH_OBJS := objects/pflash/arm_io.o \
    objects/pflash/ast-sf-ctrl.o \
    objects/pflash/libflash/libffs.o \
    objects/pflash/libflash/libflash.o \
    objects/pflash/progress.o

EXES := board_vpd \
    button_power \
    button_reset \
    control_bmc \
    control_host \
    flash_bios \
    flasher \
    host_watchdog \
    hwmons_barreleye \
    led_controller \
    pcie_slot_present \
    power_control

GPIO_EXES := button_power \
    button_reset \
    control_host \
    led_controller \
    power_control

MAPPER_EXES := flash_bios \
    host_watchdog \
    hwmons_barreleye

INTF_EXES := control_bmc \
    board_vpd

BINS = pflash

CFLAGS += $(shell pkg-config --cflags gio-unix-2.0) \
	  -Iincludes -Iobjects/pflash -I.

LDLIBS += $(shell pkg-config --libs gio-unix-2.0)

all: $(EXES) $(BINS)

.PHONY: $(EXES) $(BINS)
$(EXES): % : bin/%.exe

$(BINS): % : bin/%

interfaces/%.o: CFLAGS += -fPIC

.PHONY: clean
clean:
	$(RM) $(EXES) $(BINS)
	$(RM) lib/libopenbmc_intf.so
	$(RM) $(shell find $(SRC_DIR) -iname '*.o')
	$(RM) -r lib

lib/libopenbmc_intf.so: LDFLAGS += -shared
lib/libopenbmc_intf.so: LDLIBS += $(shell pkg-config --libs glib-2.0)
lib/libopenbmc_intf.so: interfaces/openbmc_intf.o
	mkdir -p lib
	$(LINK.o) $< -o $@

$(patsubst %, bin/%.exe, $(GPIO_EXES)): bin/%.exe : \
    objects/%_obj.o includes/object_mapper.o includes/gpio.o \
    lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o $@

$(patsubst %, bin/%.exe, $(MAPPER_EXES)): bin/%.exe : \
    objects/%_obj.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o $@

$(patsubst %, bin/%.exe, $(INTF_EXES)): bin/%.exe : \
    objects/%_obj.o lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o $@

bin/flasher.exe: objects/flasher_obj.o $(FLASH_OBJS) lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o $@

bin/pcie_slot_present.exe: objects/pcie_slot_present_obj.o includes/gpio.o
	$(LINK.o) $^ $(LDLIBS) -o $@

bin/pflash: objects/pflash/pflash.o $(FLASH_OBJS) lib/libopenbmc_intf.so
	$(LINK.o) $^ $(LDLIBS) -o $@
