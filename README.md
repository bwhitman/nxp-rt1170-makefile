# Makefile for NXP RT1170 / Maaxboard demo

This is a Make-based toolchain for the NXP RT1170 / 1176 series of 1GHz MCUs that avoids using the MCUxpresso tool system as much as possible. I'm more comfortable developing this way and thought I'd put in the work to get a make-based toolchain going instead of using the Eclipse-based IDE.

This particular example project contains and builds the [baked-in demo](https://github.com/Avnet/MaaXBoard-RT-V3--GUI-Demo) of the AVNet "Maaxboard RT", which is an otherwise quite good RT1170 dev board. But it should work for the RT1170 EVK or other related boards. You may have to swap out the flash drivers, etc.

## Setup

Get a [MaaxBoard RT](https://www.avnet.com/wps/portal/us/products/avnet-boards/avnet-board-families/maaxboard/maaxboard-rt/) and a [MCU-Link](https://www.nxp.com/design/microcontrollers-developer-resources/mcu-link-debug-probe:MCU-LINK). 

Download and install the [MCUXpresso](https://www.nxp.com/design/software/development-software/mcuxpresso-software-and-tools-/mcuxpresso-integrated-development-environment-ide:MCUXpresso-IDE) IDE. Run it once, then quit it. 

Edit the `Makefile` if you need to.

If you have an M1-based Mac and don't want to use Rosetta emulation for the `gnu-arm-none-eabi-*` toolchain, download the [latest xPack arm64 build of the Arm embedded toolchain](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v10.3.1-2.3/) and install it in `../m1-arm-embedded/xpack...` and uncomment the Makefile to use that instead. (In practice, this build takes 12 seconds on my M1 Max under Rosetta and 8s native.)

## Usage

`make` will hopefully build the SDK folders as well as the source folder and link it to `demo.afx`. 

`make flash` will flash the `demo.afx` to your board.

`make clean` removes all object and afx files.

`make monitor` opens a serial terminal to the board.

