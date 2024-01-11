.data
    invader_x: .word 0
    invader_y: .word 2
    invader_width: .word 3
    invader_height: .word 1
    nb_invaders: .word 20
    nb_invader_rows: .word 4
    nb_invader_per_row: .word 0 # for simplify the calculation
    invader_color: .word 0x0052211f # brown
    invader_horizontal_space: .word 1
    invader_vertical_space: .word 1
    invader_direction: .word 0 # 0: from left to right
                               # 1: from right to left
    invader_array: .word 0 # allocate dynamically nb_invaders*4
                           # each invader 4 octets: 0 dead 1 alive


.text

#####################################################################
# Function          : Invader_create
# Description       : Initialise attributes of invaders
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
Invader_create:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw s0 nb_invaders
    malloc s0 invader_array

    li t0 0
    # initialise all invaders to "alive"
    loop_Invader_create:
        bge t0 s0 fin_Invader_create
        slli t1 t0 2
        add t2 a0 t1
        li t1 1 # 1: alive, 0: dead
        sw t1 0(t2)
        addi t0 t0 1
        j loop_Invader_create 

    fin_Invader_create:
        lw t0 nb_invader_rows
        div t1 s0 t0
        la t0 nb_invader_per_row
        sw t1 0(t0)
        
        # epilogue
        lw ra 0(sp)
        addi sp sp 4
        ret

#####################################################################
# Function          : Invader_display
# Description       : Display invaders
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
Invader_display:
    # prologue
    addi sp sp -60
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw a4 20(sp)
    sw a5 24(sp)
    sw a6 28(sp)
    sw s0 32(sp)
    sw s1 36(sp)
    sw s2 40(sp)
    sw s3 44(sp)
    sw s4 48(sp)
    sw s5 52(sp)
    sw s6 56(sp)

    # body
    lw a0 invader_x
    lw a1 invader_y
    lw a2 invader_width # 3
    lw a3 invader_height # 1
    lw a4 invader_color

    li s0 0 # i = 0
    lw s1 nb_invader_rows
    lw s3 nb_invader_per_row
    lw s4 invader_array
    lw s5 invader_horizontal_space # 1
    lw s6 invader_vertical_space # 2
    add s5 s5 a2 # 1 + 3 = 4
    add s6 s6 a3 # 2 + 1 = 3


    loop_Invader_display:
        # while (i < nb_invader_rows)
        bge s0 s1 fin_Invader_display
        li s2 0 # j = 0

        inner_loop_Invader_display:
            # while (j < nb_invader_per_row) 
            bge s2 s3 next_loop_Invader_display
            lw t0 0(s4)
            beqz t0 dead_invader_case

            # randomly choose a invader (1/4 possibility)
            mv a5 a0 # invader_x
            mv a6 a1 # invader_y
            lw a1 nb_invaders
            li t0 100
            mul a1 a1 t0
            li a7 42
            ecall
            li t0 40
            bgt t0 a0 invader_fire
            mv a0 a5
            mv a1 a6
            j next_inner_loop_Invader_display

            invader_fire:
                mv a0 a5
                mv a1 a6
                mv a5 a2
                li a2 0
                jal M_fire
                mv a2 a5

            next_inner_loop_Invader_display:
                jal I_rectangle
                addi s2 s2 1 # j++
                add a0 a0 s5 # update x, move to next invader
                addi s4 s4 4
                j inner_loop_Invader_display

            dead_invader_case:
                addi s2 s2 1 # j++
                add a0 a0 s5 # update x, move to next invader
                addi s4 s4 4
                j inner_loop_Invader_display


        next_loop_Invader_display:
            addi s0 s0 1 # i++
            lw a0 invader_x # reinitialise a0 to origin x
            add a1 a1 s6 # update y, move to next row
            j loop_Invader_display


    fin_Invader_display:
        # epilogue
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw a3 16(sp)
        lw a4 20(sp)
        lw a5 24(sp)
        lw a6 28(sp)
        lw s0 32(sp)
        lw s1 36(sp)
        lw s2 40(sp)
        lw s3 44(sp)
        lw s4 48(sp)
        lw s5 52(sp)
        lw s6 56(sp)
        addi sp sp 60
        ret


#####################################################################
# Function          : Invader_move
# Description       : Move invaders
# Pre-condition     : The necessary attributs of invaders are already initialised
# @param[in]        : /
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
Invader_move:
    # prologue
    addi sp sp -28
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)

    # body
    lw t0 invader_direction
    lw s0 invader_x
    lw s1 invader_y
    lw s2 I_width
    lw s3 o_y
    bgtz t0 Invader_move_right_to_left

    # 0: from left to right
    Invader_move_left_to_right:
        addi s0 s0 1 # the default step of player is 1
        lw t0 invader_width
        lw t2 nb_invader_per_row
        lw t3 invader_horizontal_space
        addi t4 t2 -1 # t4 = nb_space 
        mul t4 t4 t3 # t4 = width of space
        mul t2 t2 t0 # t2 = width of invader
        add t2 t2 t4 # t2 = width of space + width of invader
        add t2 s0 t2 # t2 = s0 + t2
        beq t2 s2 Invader_move_down # if invader reach rightmost side of image
        la t0 invader_x
        sw s0 0(t0)
        j fin_Invader_move

    # 1: from right to left
    Invader_move_right_to_left:
        addi s0 s0 -1
        beqz s0 Invader_move_down # if invader reach leftmost side of image
        la t0 invader_x
        sw s0 0(t0)
        j fin_Invader_move  

    Invader_move_down:
        addi s1 s1 1
        lw s4 invader_vertical_space
        lw s5 nb_invader_rows
        lw t0 invader_height
        addi t1 s5 -1 # t1 = nb_invader_rows - 1
        mul s5 s5 t0 # s5 = nb_invader_rows * invader_height
        mul s4 s4 t1 # s4 = (nb_invader_rows - 1) * invader_vertical_space
        add t0 s1 s5
        add t0 t0 s4
        bge t0 s3 end_game # Invader touch ground
        la t0 invader_y
        sw s1 0(t0)
        la t0 invader_x
        sw s0 0(t0)
        
        # change direction
        la t0 invader_direction
        lw t2 0(t0)
        beqz t2 change_to_left

        change_to_right:
            sw zero 0(t0)
            j fin_Invader_move

        change_to_left:
            li t1 1
            sw t1 0(t0)


    fin_Invader_move:
        # epilogue
        lw ra 0(sp)
        lw s0 4(sp)
        lw s1 8(sp)
        lw s2 12(sp)
        lw s3 16(sp)
        lw s4 20(sp)
        lw s5 24(sp)
        addi sp sp 28
        ret


#####################################################################
# Function          : Invader_destory
# Description       : Destroy the invader, 
#                     change the value of this invader in the invader_array to 0 
# Pre-condition     : The necessary attributs of invaders are already initialised
# @param[in]        : a0 - position_x of missile
#                     a1 - position_y of missile
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
Invader_destory:
    # prologue
    addi sp sp -32
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    sw s3 16(sp)
    sw s4 20(sp)
    sw s5 24(sp)
    sw s6 28(sp)

    # body
    lw s0 invader_width
    lw s1 invader_height
    lw s2 invader_x
    lw s3 invader_y

    sub a1 a1 s1 # get the destroyed invader_y

    sub t0 a0 s2# the x-difference between destroyed invader and first invader
    sub t1 a1 s3# the y-difference between destroyed invader and first invader
    
    lw s5 invader_horizontal_space
    lw s6 invader_vertical_space
    add s0 s0 s5 # 3 + 1 = 4
    add s1 s1 s6 # 1 + 2 = 3
    div t0 t0 s0 # index of column
    div t1 t1 s1 # index of row
    addi t1 t1 1

    lw t2 nb_invader_per_row
    mul t2 t2 t1 # index of row * nb_invader_per_row
    add t2 t2 t0 # plus index of column
    slli t2 t2 2

    lw t0 invader_array
    add t0 t0 t2
    sw zero 0(t0)

    # epilogue
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    lw s4 20(sp)
    lw s5 24(sp)
    lw s6 28(sp)
    addi sp sp 32
    ret
