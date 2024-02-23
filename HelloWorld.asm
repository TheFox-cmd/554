
llb R1, 0x00     # Base mapped memory address: 0xC000
lhb R1, 0xC0 

llb R2, 0x0D     # Enter Key
lhb R2, 0x00 

llb R3, 0x0F     # available TX
lhb R3, 0x00 

llb R7, 0x00      # Incremental pointer
lhb R7, 0x10

llb R9, 0x00      # Base pointer
lhb R9, 0x10

llb R8, 0x01        # Constant 1
lhb R8, 0x00

jal Poll_tx        # First wait and set R15

#########################################################
# Print "Hello World"
#########################################################
# H
llb R6, 0x48
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# e
llb R6, 0x65
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# o
llb R6, 0x6f
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# ' '
llb R6, 0x20
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# W
llb R6, 0x57
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# o
llb R6, 0x6f
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# r
llb R6, 0x72
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# d
llb R6, 0x64
lhb R6, 0x00
sw R6, R1, 4

#########################################################
# Check poll status register to know if char of name available
#########################################################
WaitEnter: 
lw R6, R1, 4
sub R6, R6, R2
b neq, WaitEnter

#########################################################
# Print "Hello <name>"
#########################################################
# H
llb R6, 0x48
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# e
llb R6, 0x65
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# o
llb R6, 0x6f
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# ' '
llb R6, 0x20
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# <
llb R6, 0x3C
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# n
llb R6, 0x6E
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# a
llb R6, 0x61
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# m
llb R6, 0x6D
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# e
llb R6, 0x65
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# >
llb R6, 0x3E
lhb R6, 0x00
sw R6, R1, 4

#########################################################
# Check poll status register to know when can send next character
#########################################################
inputName:
jal Poll_rx
lw R6, R1, 4      # Load input char to R6
sw R6, R7, 0
sub R6, R6, R2    # Check if R6 is enter Key
b eq, PrintHello
add R7, R7, R8      # incre instr by 1
jal inputName

#########################################################
# Echo chars of typed name
#########################################################
PrintHello: 
# H
llb R6, 0x48
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# e
llb R6, 0x65
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# l
llb R6, 0x6c
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# o
llb R6, 0x6f
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx
# ' '
llb R6, 0x20
lhb R6, 0x00
sw R6, R1, 4
jal Poll_tx

Print:
lw R6, R9, 0
sw R6, R1, 4        # Send current char to C004
add R9, R9, R8     # incre instr by 1
sub R10, R7, R9
b neq Print
b uncond Loop

#########################################################
# Check poll status register to know when can send next character
#########################################################
Poll_tx: 
lw R4 R1 5      # Load status register
lhb R4 0x00     # Clear high byte
sub R4 R4 R3    # Compare status register with 0 TX circular buffer
b lte Poll_tx      # Jump if TX = 0
jr R15

#########################################################
# • Need to store off chars of typed name into memory
#########################################################
Poll_rx: 
lw R4 R1 5      # Load status register
sll R4, R4, 12  # Clear higher bits
sub R4 R4 R0    # Compare status register with 0
b eq Poll_rx    # Wait if empty
jr R15

Loop: 
b uncond Loop;