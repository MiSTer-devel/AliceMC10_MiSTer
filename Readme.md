Matra-Hachette Alice MC-10 for MiSTer FPGA
==========================================

This is the port of the Alice 4K / Tandy MC-10 to MiSTer FPGA.
It's a work in progress.

Many games/programs already work, however, there's currently a bug in the video module that prevents some games from changing the display mode. Other MiSTer contributors and I are working on the problem right now.

About cassettes
---------------

The core can only load .c10 files. Therefore I provided a small Python script `k72c10.py` that can turn a .k7 file from Alice into a .c10 file. It simply adds the two leader sections before and after the name block.

Usage: `python k72c10.py <path to k7 file>`.

You will end up with a new file named k7.c10, which should be compatible with the core.

To do
-----

1. ~~Make it start.~~
2. ~~It is unstable, clock may be too low for the PLL.~~
3. ~~VDG register: U4 (1Y2) and CPU r/w lines are used to generate the U8 clock, which allows writing to the VDG register. VDG register: The sound() command modifies the VDG register!~~
4. ~~Sound is not implemented.~~
5. ~~Joystick is not implemented.~~ Joystick doesn't work.
6. ~~Fix keyboard mapping (backspace key, works like original: mapped to ctrl+A).~~
7. ~~Fix OSD options.~~
8. ~~Cassette interface.~~
9. ~~Add overlay for tape status?~~

I regularly update the RBF file for testing in /releases. There will be an official release when this list is completed :sweat_smile: