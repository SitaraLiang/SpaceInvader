.include "../lib/utils.S"


.data
    width_pixels: .word 256
    height_pixels: .word 256
    width_units: .word 8
    height_units: .word 8
    I_width: .word 0
    I_height: .word 0
    I_visu: .word 0
    I_buff: .word 0


.text


#####################################################################
# Function          : I_create
# Description       : Allocate dynamically the memory of image from heap,
#                     Store adress into I_buff and I_visu
# Pre-condition     : The global variables width_pixels, 
#                                          height_pixels,
#                                          width_units,
#                                          height_units,
#                     are already initialised.
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : I_buff and I_visu store the allocated address
#####################################################################
I_create:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 width_pixels
    lw t1 height_pixels
    lw t2 width_units
    lw t3 height_units

    div t4 t0 t2
    div t5 t1 t3
    la t0 I_width
    sw t4 0(t0)
    la t0 I_height
    sw t5 0(t0)
    mul t6 t4 t5
    malloc t6 I_visu
    malloc t6 I_buff

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret

#####################################################################
# Function          : I_background
# Description       : Allocate dynamically the memory of image from heap,
#                     Store adress into I_buff and I_visu
# Pre-condition     : The global variables width_pixels, 
#                                          height_pixels,
#                                          width_units,
#                                          height_units,
#                     are already initialised.
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : I_buff and I_visu store the allocated address
#####################################################################
I_background:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 I_width
    lw t1 I_height
    mul t2 t0 t1 # t2 <- size
    lw t0 I_buff # t0 <- I_buff
    li t5 0x00ffff00 # yellow
    li t1 0 # i = 0

    loop_I_background:
        # while (i < size)
        bge t1 t2 fin_I_background
        slli t4 t1 2
        add t3 t4 t0
        sw t5 0(t3)
        addi t1 t1 1 # i++
        j loop_I_background

    fin_I_background:
        # epilogue
        lw ra 0(sp)
        addi sp sp 4
        ret


#####################################################################
# Function          : I_xy_to_addr
# Description       : Convert a pair of coordinates into an address
# Pre-condition     : I_buff and I_width are already initialised
#                     0 <= a0, a1 < I_width, I_height
# @param[in]        : a0[int] -> Abscissa of the unit
#                     a1[int] -> Ordinate of the unit
# @param[out]       : a0 -> Address of the unit in the image memory
# @return           : / 
# Post-condition    : /
#####################################################################
I_xy_to_addr:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 I_width
    mul t1 a1 t0
    add t1 t1 a0
    slli t1 t1 2
    lw t0 I_buff
    add t0 t0 t1
    mv a0 t0

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret


#####################################################################
# Function          : I_addr_to_xy
# Description       : Convert an address into a pair of coordinates
# Pre-condition     : I_buff and I_width are already initialised
#                     Address in a0 is valid
# @param[in]        : a0 -> Address of the unit in the image memory
# @param[out]       : a0[int] -> Abscissa of the unit
#                     a1[int] -> Ordinate of the unit
# @return           : / 
# Post-condition    : / 
#####################################################################
I_addr_to_xy:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 I_buff
    sub t0 a0 t0
    srli t0 t0 2
    lw t1 I_width
    div a1 t0 t1
    rem a0 t0 t1

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret

#####################################################################
# Function          : I_plot
# Description       : Color the corresponding pixel with the specific color.
#                     This function calls I_xy_to_addr
# Pre-condition     : The coordinates (a0, a1) is valid
# @param[in]        : a0[int] -> Abscissa of the unit
#                     a1[int] -> Ordinate of the unit
#                     a2 -> color en hexadecimal
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
I_plot:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    jal I_xy_to_addr
    sw a2 0(a0)

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret


#####################################################################
# Function          : I_rectangle
# Description       : Color the rectangle with the specific color.
# Pre-condition     : The coordinates (a0, a1) is valid
#                     The height and width of rectangle are valid
# @param[in]        : a0[int] -> Abscissa of the unit
#                     a1[int] -> Ordinate of the unit
#                     a2[int] -> width of rectangle
#                     a3[int] -> height of rectangle
#                     a4 -> color en hexadecimal
# @param[out]       : /
# @return           : / 
# Post-condition    : / 
#####################################################################
I_rectangle:
    # prologue
    addi sp sp -52
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw a4 20(sp)
    sw s0 24(sp)
    sw s1 28(sp)
    sw s2 32(sp)
    sw s3 36(sp)
    sw s4 40(sp)
    sw s5 44(sp)
    sw s6 48(sp)

    mv s0 a0 # x 
    mv s1 a1 # y
    mv s2 a2 # width
    mv s3 a3 # height
    mv s4 a4 # color

    # body
    li s5 0 # i = 0

    loop_I_rectangle:
    # while (i < height)
        bge s5 s3 fin_I_rectangle
        add a1 s1 s5 # y += i
        li s6 0 # j = 0

        inner_loop_I_rectangle:
        # while (j < width)
            bge s6 s2 next_inner_loop_I_rectangle
            add a0 s0 s6  # x += j
            mv a2 s4
            jal I_plot
            addi s6 s6 1 # j++
            j inner_loop_I_rectangle

        next_inner_loop_I_rectangle:
        addi s5 s5 1 # i++
        j loop_I_rectangle


    fin_I_rectangle:
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
        lw s3 36(sp)
        lw s4 40(sp)
        lw s5 44(sp)
        lw s6 48(sp)
        addi sp sp 52
        ret



#####################################################################
# Function          : I_erase
# Description       : Reset all pixels in image with black color (0x00000000)
# Pre-condition     : I_buff, I_width and I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
I_erase:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 I_width
    lw t1 I_height
    mul t2 t0 t1 # t2 <- size
    lw t0 I_buff # t0 <- I_buff
    li t5 0x00ffff00 # yellow
    li t1 0 # i = 0

    loop_I_erase:
        # while (i < size)
        bge t1 t2 fin_I_erase
        slli t4 t1 2
        add t3 t4 t0
        sw t5 0(t3)
        addi t1 t1 1 # i++
        j loop_I_erase

    fin_I_erase:
        # epilogue
        lw ra 0(sp)
        addi sp sp 4
        ret


#####################################################################
# Function          : I_buff_to_visu
# Description       : Transfer data from I_buff to I_visu.
# Pre-condition     : I_buff and I_visu are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
I_buff_to_visu:
    # prologue
    addi sp sp -16
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)

    # body
    lw t0 I_width
    lw t1 I_height
    mul s2 t0 t1 # s2 <- size

    lw s0 I_buff
    lw s1 I_visu
    li t0 0 # i = 0

    loop_I_buff_to_visu:
        # while (i < size)
        bge t0 s2 fin_I_buff_to_visu
        slli t1 t0 2
        add t2 s0 t1 
        add t3 s1 t1
        lw t4 0(t2) # t3 = I_buff[i]
        sw t4 0(t3) # I_visu[i] = t3
        addi t0 t0 1 # i++
        j loop_I_buff_to_visu

    fin_I_buff_to_visu:
        # epilogue
        lw ra 0(sp)
        lw s0 4(sp)
        lw s1 8(sp)
        lw s2 12(sp)
        addi sp sp 16
        ret



#####################################################################
# Function          : I_welcome
# Description       : Welcome animation before starting the game
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
I_welcome:
    # prologue
    addi sp sp -24
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw a4 20(sp)

    # body
    li a0 0 # x = 0
    li a1 0 # y = 0
    li a4 0x00800080 # a4 <- purpule
    lw a2 I_width
    lw a3 I_height

    loop_I_welcome:
        bltz a2 fin_I_welcome
        jal I_erase
        jal I_rectangle
        jal I_buff_to_visu
        addi a2 a2 -1
        #li a0 50
        #li a7 32 
        #ecall
        li a0 0
        j loop_I_welcome

    fin_I_welcome:
        # epilogue
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw a3 16(sp)
        lw a4 20(sp)
        addi sp sp 24
        ret


#####################################################################
# Function          : I_ending
# Description       : Ending animation after finishing the game
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
I_ending:
    # prologue
    addi sp sp -28
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw a4 20(sp)
    sw a5 24(sp)

    # body
    li a0 0 # x = 0
    li a1 0 # y = 0
    li a4 0x00800080 # a4 <- yellow
    li a2 1
    lw a3 I_height
    lw a5 I_width

    loop_I_ending:
        bgt a2 a5 fin_I_ending
        jal I_erase
        jal I_rectangle
        jal I_buff_to_visu
        addi a2 a2 1
        j loop_I_ending

    fin_I_ending:
        # epilogue
        lw ra 0(sp)
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw a3 16(sp)
        lw a4 20(sp)
        lw a5 24(sp)
        addi sp sp 28
        ret

