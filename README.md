# RISCV16B

This is a project based on the RISC-V documentation of compressed instructions. 

The purpose of the project is to develop a simple microcontroller efficient porêm, with communication protocols, system interruptions and other functionalities that I am still planning. 

To run our processor we created an interpreter, since we don’t have a compiler with only compressed instructions (at least I haven’t found one yet). In this way, we can create from the assembly is not all that bad, our program. 

The purpose of this project is to think simply in a microcontroller and later join this project with the 32-bit microcontroller already developed. It will be a great challenge but I want to get to run a basic linux kernel inside this microcontroller. 

The code is being written all in Verilog and the interpreter in python, I tried to make the code as segmented as possible to facilitate maintenance and development. 