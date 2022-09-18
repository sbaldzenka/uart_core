# uart_core

UART IP-Core for FPGA projects.

Description of projects:
- **hdl** - VHDL files.
- **sim** - script files for modelsim/questasim.
- **tb** - testbench.

To set the UART baudrate, you must specify COEFF_BAUDRATE in the top project file.
### COEFF_BAUDRATE = aclk/baudrate.
> For example COEFF_BAUDRATE = 50000000 Hz / 9600 = 5208 dec = 1458 hex