#
# NXP RT series makefile that avoids the insane MCUxpresso

TARGET=demo
DEVICE=maaxboard
DRIVER=MaaXBoard_S26KS256.cfx
CHIP=MIMXRT1176xxxxx
CONNECT_SCRIPT=RT1170_connect_M7_wake_M4.scp
# Get this from plugging your MCULink probe in and ls /dev/cu.usbmodem*, remove the last digit
PROBE=1WP3MI5XFXLFN

# Debug
#CFLAGS = -O0 -g3 -DDEBUG

# Release
CFLAGS = -O3

# The location of your MCUx App folder
MCUX=/Applications/MCUXpressoIDE_11.5.0_7232

#-------


MCUX_TOOLS=$(MCUX)/ide/plugins/com.nxp.mcuxpresso.tools.macosx_11.5.0.202107051138/tools
MCUX_TOOLSBIN=$(MCUX)/ide/plugins/com.nxp.mcuxpresso.tools.bin.macosx_11.5.0.202112161150/binaries

#Uncomment if you want to use the m1 native compilers, but tbh the speed gain is minimal and may have bugs
#LDFLAGS=-L$(MCUX)/ide/plugins/com.nxp.mcuxpresso.tools.macosx_11.5.0.202107051138/tools/arm-none-eabi/lib/thumb/v7e-m+dp/hard/
#MCUX_TOOLS=../m1-arm-embedded/xpack-arm-none-eabi-gcc-10.3.1-2.3

# Set parallel flag to # of CPUs
CPUS ?= $(shell sysctl -n hw.ncpu || echo 1)
MAKEFLAGS += --jobs=$(CPUS)


CC=$(MCUX_TOOLS)/bin/arm-none-eabi-gcc

LDFLAGS+=-nostdlib -Xlinker -Map="build/$(TARGET)-$(DEVICE).map" -Xlinker --gc-sections -Xlinker -print-memory-usage -Xlinker \
	--sort-section=alignment -Xlinker --cref -mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -T "$(DEVICE)/$(TARGET).ld" 

CFLAGS+=-std=gnu99 -DCPU_MIMXRT1176DVMAA -DAVT_DISPLAY_ROTATE_180 -DCPU_MIMXRT1176DVMAA_cm7 -DXIP_BOOT_HEADER_DCD_ENABLE=1  \
	-DFSL_FEATURE_PHYKSZ8081_USE_RMII50M_MODE -DCODEC_SGTL5000_ENABLE -DLWIP_ENET_FLEXIBLE_CONFIGURATION -DUSE_SDRAM \
	-DDATA_SECTION_IS_CACHEABLE=1 -DSDK_DEBUGCONSOLE=1 -DBOARD_USE_CODEC=1 -DXIP_EXTERNAL_FLASH=1 -DXIP_BOOT_HEADER_ENABLE=1 \
	-DUSE_RTOS=1 -DPRINTF_ADVANCED_ENABLE=1 -DFSL_RTOS_FREE_RTOS -DUSB_STACK_BM -DSDIO_ENABLED -DLV_CONF_INCLUDE_SIMPLE \
	-DLV_EX_CONF_INCLUDE_SIMPLE=1 -DFSL_SDK_DRIVER_QUICK_ACCESS_ENABLE=1 -DSDK_I2C_BASED_COMPONENT_USED=1 -DSERIAL_PORT_TYPE_UART=1 \
	-DCR_INTEGER_PRINTF -DPRINTF_FLOAT_ENABLE=0 -D__MCUXPRESSO -D__USE_CMSIS -D__NEWLIB__ -DLWIP_TIMEVAL_PRIVATE=0 \
	-DSDK_OS_FREE_RTOS -imacros "app_config.h" -mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -D__NEWLIB__ -fstack-usage \
	-specs=nano.specs -fno-common -c -ffunction-sections -fdata-sections -ffreestanding -fno-builtin -fmerge-constants

MCUX_FLASH_DIR0=$(MCUX_TOOLSBIN)/Flash
REDLINK=$(MCUX_TOOLSBIN)/crt_emu_cm_redlink
FLASHFLAGS=--vendor NXP -p $(CHIP) --ConnectScript $(DEVICE)/$(CONNECT_SCRIPT) --probeserial $(PROBE) -CoreIndex=0 \
	--flash-driver $(DEVICE)/$(DRIVER) -x $(DEVICE) --flash-dir $(MCUX_FLASH_DIR0) --flash-hashing --flash-dir $(DEVICE) 


DIR_OBJ = ./build

INC_DIRS := $(shell find code -type 'd' | sed s/^/-I/)
INCS := $(shell find code -name "*.h")
SRCS := $(shell find code -name "*.c")
OBJS = $(addprefix $(DIR_OBJ)/, $(SRCS:c=o))


all: $(TARGET).axf

clean:
	rm -rf $(DIR_OBJ)/*
	rm $(TARGET).axf

$(TARGET).axf: $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@

$(DIR_OBJ)/%.o: %.c $(INCS)
	mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) -c $< -I$(INC_DIRS)

flash: $(TARGET).axf
	$(REDLINK) --flash-load-exec $(TARGET).axf $(FLASHFLAGS)

monitor:
	screen /dev/cu.usbmodem$(PROBE)* 115200



