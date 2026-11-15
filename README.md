# FPGA GCD Calculator

A 16-bit **Greatest Common Divisor (GCD) calculator** implemented in VHDL and deployed on a **Zybo Z7 FPGA development board** using Xilinx Vivado.

This project was developed as part of the VHDL coursework at **Polytech Grenoble – Grenoble INP – UGA**, during the fourth year of the Computer Science and Embedded Systems Engineering (IESE) program.

## Project Overview

The objective of this project is to implement a complete digital system capable of computing the Greatest Common Divisor (GCD) of two 16-bit unsigned integers.

The system integrates a GCD computation module, input generation logic, and multiplexed 7-segment display controllers to provide a hardware-based interface for displaying the computed result.

### System Operation

1. Select the input configuration using the FPGA board's switches.
2. Press the GO button to start the GCD computation.
3. Wait for the READY LED to indicate completion.
4. Read the computed GCD on the external 7-segment displays.

## Hardware Architecture

The system is organized into the following main components:

- **GCD Module (`pgcd`):** Computes the Greatest Common Divisor of two 16-bit numbers.
- **Input Generator (`genxy`):** Generates the input operands based on the switch configuration.
- **7-Segment Display Controller (`pmod_seg7_ctrl`):** Controls multiplexed 7-segment displays using clock division and digit selection.
- **Top-Level Module (`pgcd_top`):** Integrates the components and connects them to the FPGA's physical interfaces.

## Hardware and Tools

- **Hardware:** Digilent Zybo Z7 (Xilinx Zynq-7000)
- **Language:** VHDL
- **Development Environment:** Xilinx Vivado
- **Display:** Two external PMOD dual-digit 7-segment modules
- **Interfaces:** Push buttons, switches, LEDs, and PMOD connectors

## Repository Structure

```text
fpga-gcd-calculator/
├── src/            # VHDL source files
├── testbench/      # Simulation testbenches (to be added)
├── constraints/    # FPGA pin and timing constraints (to be added)
└── README.md
```

## Authors

Developed by:

- **Dhomini Bezerra Picanço**
- **Lucas dos Santos Givaldo**

Polytech Grenoble – Grenoble INP – UGA  
Academic Year: 2025–2026

## Acknowledgments

This project was developed as part of the VHDL practical coursework at Polytech Grenoble, under the guidance of L. Andrade and J. Alle-Monne.
