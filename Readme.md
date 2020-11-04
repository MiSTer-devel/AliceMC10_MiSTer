Matra-Hachette Alice MC-10 for MiSTer FPGA
==========================================

This is the port of the Alice 4K / Tandy MC-10 to MiSTer FPGA.
It's a work in progress.

About cassettes
---------------

The core can only load .c10 files, but the only difference with .k7 files (Alice) is the leader sections, which are not present on the .k7 format. I'll do a small conversion script later.

To do
-----

1. ~~Make it start.~~
2. ~~It is unstable, clock may be too low for the PLL.~~
3. ~~VDG register: U4 (1Y2) and CPU r/w lines are used to generate the U8 clock, which allows writing to the VDG register.
3.1 VDG register: The sound() command modifies the VDG register!~~
4. ~~Sound is not implemented.~~
5. ~~Joystick is not implemented.~~ Joystick doesn't work.
6. Fix keyboard mapping (backspace key)..
7. Fix OSD options.
8. ~~Cassette interface.~~
