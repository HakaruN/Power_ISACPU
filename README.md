# Power_ISA CPU
This project is for my Masters Dissertation. Documentation will be provided in the form of my Dissertation report (essentially a report describing the design, development and operations of the processor)

TODO:
Fix LoadStore unit because it's not commiting to memory and not reading from memory and/or outputting to the reg writeback
Implement more test hanesses for the later pipeline stages (after reg file)
New memory controller
Expand functionality of the stall unit (allow load/stores to stall the CPU)
Implement branch unit
Add L1D-cache to the Load/Store unit and implemenent Data memory controller.
Implement All instructions currently supported by the decoders into the functional units (that are possible withought microcode)


Implementation Status Notes:

-Instruction memory controller needs rewriting from scratch. Implementation Is to:
Transfer 4 bytes per cycle, takes a 16b address and fetches a 32 byte block of memory over 8 cycles.

-Condition register is unused at this time as there is no branch unit.
-FixedPoint Unit Exception register is unused so far.
