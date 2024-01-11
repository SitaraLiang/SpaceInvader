.data
    o_x: .word 0
    o_y: .word 0
    o_width: .word 5
    o_height: .word 3
    nb_o: .word 4
    o_color: .word 0x0021572f # dark green
    o_space: .word 0

.text
#####################################################################
# Function          : O_create
# Description       : Initialise the position of obstacle and space between each of them
# Pre-condition     : I_width, I_height, o_width, o_height and o_color are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
O_create:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    li t0 5
    lw t1 I_height
    div t2 t1 t0
    sub t1 t1 t2
    la t0 o_y
    sw t1 0(t0)

    lw t0 nb_o 
    lw t1 I_width 
    lw t2 o_width 
    mul t3 t0 t2
    sub t4 t1 t3 
    div t5 t4 t0 
    sub t2 t4 t5 
    li t3 2
    div t5 t5 t3 
    la t1 o_x
    sw t5 0(t1)
    addi t0 t0 -1 
    div t2 t2 t0 
    la t1 o_space
    sw t2 0(t1)

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret

#####################################################################
# Function          : O_display
# Description       : Display obstacles
# Pre-condition     : o_x, o_y, o_width, o_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
O_display:
    # prologue
    addi sp sp -36
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw a4 20(sp)
    sw s0 24(sp)
    sw s1 28(sp)
    sw s2 32(sp)

    # body
    lw a0 o_x
    lw a1 o_y
    lw a2 o_width
    lw a3 o_height
    lw a4 o_color

    lw s0 o_space
    add s0 s0 a2
    lw s1 nb_o
    li s2 0 # i = 0

    loop_O_display:
        # while (i < nb_o)
        bge s2 s1 fin_O_display
        jal I_rectangle
        add a0 a0 s0
        addi s2 s2 1 # i++
        j loop_O_display

    fin_O_display:
        # epilogue
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw a3 16(sp)
        lw a4 20(sp)
        lw s0 24(sp)
        lw s1 28(sp)
        lw s2 32(sp)
        addi sp sp 36
        ret
