#CC=gcc
SRC_DIR = .
OBJS    = objects/pflash/progress.o objects/pflash/ast-sf-ctrl.o
OBJS	+= objects/pflash/libflash/libflash.o objects/pflash/libflash/libffs.o
OBJS	+= objects/pflash/arm_io.o
CFLAGS += $(shell pkg-config --cflags gio-unix-2.0 glib-2.0) -Iincludes -Iobjects/pflash -I.
LDLIBS=$(shell pkg-config --libs gio-unix-2.0 glib-2.0)

interfaces/%.o: CFLAGS += -fPIC

all: setup power_control led_controller button_power button_reset control_host host_watchdog board_vpd pcie_slot_present flash_bios flasher pflash hwmons_barreleye control_bmc

setup: 
	mkdir -p lib

.PHONY: clean
clean:  
	$(RM) -r lib bin/*.exe $(shell find $(SRC_DIR) -iname '*.o')

lib/libopenbmc_intf.so: interfaces/openbmc_intf.o
	$(CC) -shared -o $@ interfaces/openbmc_intf.o $(LDFLAGS)

power_control: objects/power_control_obj.o includes/gpio.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

led_controller: objects/led_controller_obj.o includes/gpio.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

led_controller_new: objects/led_controller_new.o
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS) -lsystemd

button_power: objects/button_power_obj.o includes/gpio.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

button_reset: objects/button_reset_obj.o includes/gpio.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

control_host: objects/control_host_obj.o includes/gpio.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

flash_bios: objects/flash_bios_obj.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

host_watchdog: objects/host_watchdog_obj.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

board_vpd: objects/board_vpd_obj.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

pcie_slot_present: objects/pcie_slot_present_obj.o includes/gpio.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

flasher:  $(OBJS) objects/flasher_obj.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

pflash: $(OBJS) objects/pflash/pflash.o
	$(CC) -o bin/$@ $^ $(LDFLAGS)

hwmons_barreleye: objects/hwmons_barreleye_obj.o includes/object_mapper.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

control_bmc: objects/control_bmc_obj.o lib/libopenbmc_intf.so
	$(CC) -o bin/$@.exe $^ $(LDFLAGS) $(LDLIBS)

