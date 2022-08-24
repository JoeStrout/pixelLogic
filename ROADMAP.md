
## Exercises

- Drawing Lines: connect inputs directly to outputs.  Light up a smiley face.
- Crossing Lines: learn the crossing trick; connect inputs to outputs in a different order.  
- Not Gate: draw the Not gate in all four orientations.
- Binary Display: light up a 0 or 1 based on the input level.
- Double Not: chain two Not gates to make a logic diode.
- Or: combine traces (protected by double-nots) to implement an OR gate.
- AND gate: make an AND gate from three Not gates.
- Alarm circuit: turn on the output (alarm) if the Armed input is high, and the Motion Sensor or the Window Sensor is high.
- Binary Comparator: given two input bits A and B, light up the appropriate of three outputs: A < B, A = B, or A > B.
- Greater than 5: take a 3-digit binary input, and determine whether it represents a value bigger than 5.
- Binary Decoder: connect 3 input lines to 8 output lines in such a way that the correct output lights up for each binary input.
- Prime Number Detector: 3-digit binary input; light up the output for prime numbers (2, 3, 5, and 7).
- 7-Segment Display: take a 4-digit binary input, and light up a 7-segment display to show the right digit 0-F.
- XOR gate: make an XOR gate.
- Half Adder: add two bits, resulting in a 2-digit output (or Sum and Carry outputs).  Solution uses the XOR gate.
- Full Adder: add three bits, producing a 2-digit output.  Solution uses Half Adder.
- 2-to-1 Multiplexer: uses a Select input to choose which other input (A or B) is routed to the output (Z).
- NAND Latch: first introduction to sequential (stateful) circuits.  Two inputs, S and R; a brief S-low latches the output on, and a brief R-low latches it off.

## Peripherals

We are toying with the idea of adding some peripherals that can be controlled via pins on the edge of the board.  These would be optional in the sandbox, and present only on certain exercises.

- **Speaker**: 8 pins select the note (pitch); 3 pins select the tone (waveform).
- **Text Display**: interface like a RAM bank: data bus, address register, and read/write signal pins.  Address could be treated as row (4 bits) and column (5 bits) for a 32x16 display.
- **Pixel Display**: as above, but data is only 4 bits (selecting from a 16-color palette), and address can be treated as X (8 bits) and Y (7 bits) for a 256x128 display.
- **Sprite Display**: not sure of the interface here.  Would love something simpler than a bank of magic RAM, but it's hard to do without requiring a ton of pins.
