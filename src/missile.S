.data
    max_nb_m: .word 4
    m_width: .word 1
    m_height: .word 5
    m_color: .word 0x00ffffff # white
    m_speed: .word 2 # default
    m_array: .word 0 # allocate dynamically max_nb_m*4
                     # each missile 3*4 octets: position x and y, direction
                     # direction: 0 from invader to player
                     # direction: 1 from player to invader
    

.text

#####################################################################
# Function          : M_create
# Description       : Initialise attributes of invaders
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
M_create:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 max_nb_m
    li t1 3
    mul t2 t1 t0
    malloc t2 m_array

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret


#####################################################################
# Function          : M_display
# Description       : Display the missies 
# Pre-condition     : all necessary attributes of missile are already initialised.
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
M_display:
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
    lw a2 m_width
    lw a3 m_height
    lw a4 m_color

    lw s0 m_array
    lw s1 max_nb_m
    li s2 0 # i = 0

    loop_M_display:
        # while (i < max_nb_m)
        bge s2 s1 fin_M_display
        lw a0 0(s0)
        # check the availability of missile
        beqz a0 next_loop_M_display

        lw a1 4(s0)
        jal I_rectangle

        next_loop_M_display:
            addi s0 s0 12
            addi s2 s2 1 # i++
            j loop_M_display


    fin_M_display:
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


#####################################################################
# Function          : M_move
# Description       : Move the missile
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
M_move:
    # prologue
    addi sp sp -48
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw a3 16(sp)
    sw s0 20(sp)
    sw s1 24(sp)
    sw s2 28(sp)
    sw s3 32(sp)
    sw s4 36(sp)
    sw s5 40(sp)
    sw s6 44(sp)

    # body
    lw s0 m_array
    lw s1 max_nb_m
    li s2 0 # i = 0
    lw s3 m_speed
    lw s4 m_height
    lw s5 I_height

    loop_M_move:
        # while (i < max_nb_m)
        bge s2 s1 fin_M_move

        # check the availability of missile
        lw t0 0(s0)
        beqz t0 next_loop_M_move # move to next missile
        
        # check the direction
        lw a2 8(s0) # a2 = direction of missile
        beqz a2 M_move_invader_to_player

        M_move_player_to_invader:
            lw a0 0(s0)
            lw a1 4(s0)
            sub a1 a1 s3

            # case 1: invader touch the ceiling
            bltz a1 M_move_reset

            # case 2: invader touch the obstacle
            lw a3 o_color
            mv s6 a0
            jal M_intersectWithColor
            bgtz a0 M_move_reset

            # case 3: invader touch the player
            mv a0 s6
            lw a3 invader_color
            jal M_intersectWithColor
            bgtz a0 M_move_intersect_invader

            # sinon, save the new valeur
            sw a1 4(s0)
            j next_loop_M_move

        M_move_invader_to_player:
            lw a0 0(s0)
            lw a1 4(s0)
            add a1 a1 s3
            add t0 a1 s4

            # case 1: invader touch the ground
            bge t0 s5 M_move_reset

            # case 2: invader touch the obstacle
            lw a3 o_color
            mv s6 a0
            jal M_intersectWithColor
            bgtz a0 M_move_reset

            # case 3: invader touch the player
            mv a0 s6
            lw a3 player_color
            jal M_intersectWithColor
            bgtz a0 M_move_intersect_player

            # sinon, save the new valeur
            sw a1 4(s0)
            j next_loop_M_move

        M_move_intersect_invader:
            mv a0 s6
            mv a1 a1
            jal Invader_destory
            j M_move_reset

        M_move_intersect_player:
            jal P_reduce_lives

        M_move_reset:
            sw zero 0(s0)

        next_loop_M_move:
            addi s0 s0 12
            addi s2 s2 1
            j loop_M_move

    fin_M_move:
        # epilogue
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw a3 16(sp)
        lw s0 20(sp)
        lw s1 24(sp)
        lw s2 28(sp)
        lw s3 32(sp)
        lw s4 36(sp)
        lw s5 40(sp)
        lw s6 44(sp)
        addi sp sp 48
        ret


#####################################################################
# Function          : M_fire
# Description       : Go through all the missiles in array and check the
#                     check the availability, 
#                     initialise the position of it
#                     based on the direction as argument
# Pre-condition     : m_height, j_width, invader_array, invader_width are already initialised
# @param[in]        : a0 - position x
#                     a1 - position y
#                     a2 - direction :  0 from invader to player
#                                       1 from player to invader
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
M_fire:
    # prologue
    addi sp sp -40
    sw ra 0(sp)
    sw a0 4(sp)
    sw a1 8(sp)
    sw a2 12(sp)
    sw s0 16(sp)
    sw s1 20(sp)
    sw s2 24(sp)
    sw s3 28(sp)
    sw s4 32(sp)
    sw s5 36(sp)

    # body
    lw s0 m_array
    lw s1 m_height
    lw s2 nb_invaders
    lw s3 invader_width
    li s4 0 # i = 0
    lw s5 max_nb_m

    M_fire_loop:
        # while (i < max_nb_m)
        bge s4 s5 fin_M_fire

        # check availability
        lw t0 0(s0)
        bgtz t0 missile_not_available_case # missile_x != 0

        beqz a2 M_fire_invader_to_player

        M_fire_player_to_invader:
            lw t1 player_width
            srli t1, t1, 1 # player_x /= 2
            add a0 a0 t1 # missile_x = player_x + player_x / 2
            sub a1 a1 s1 # missile_y = player_y - missile_height
            j position_missile_update

        M_fire_invader_to_player:
            srli t0 s3 1 # invader_width / 2
            add a0 a0 t0 # missile_x = invader_x + invader_width / 2
            add a1 a1 s1 # mssile_y = invader_y + missile_height

        position_missile_update:
            sw a0 0(s0)
            sw a1 4(s0)
            sw a2 8(s0)
            j fin_M_fire

        missile_not_available_case:
            addi s0 s0 12 # move to next missile
            addi s4 s4 1 # i++
            j M_fire_loop


    fin_M_fire:
        # epilogue
        lw ra 0(sp)
        lw a0 4(sp)
        lw a1 8(sp)
        lw a2 12(sp)
        lw s0 16(sp)
        lw s1 20(sp)
        lw s2 24(sp)
        lw s3 28(sp)
        lw s4 32(sp)
        lw s5 36(sp)
        addi sp sp 40
        ret


#####################################################################
# Function          : M_intersectWithColor
# Description       : Check if the unit intersect with the color
# Pre-condition     : m_height, j_width, invader_array, invader_width are already initialised
# @param[in]        : a0 - position x
#                     a1 - position y
#                     a2 - direction :  0 from invader to player
#                                       1 from player to invader
#                     a3 - color
# @param[out]       : a0: 0 - false, 1 - true
# @return           : / 
# Post-condition    : /
#####################################################################

M_intersectWithColor:
    # prologue
    addi sp sp -32
    sw ra 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw a3 12(sp)
    sw s0 16(sp)
    sw s1 20(sp)
    sw s2 24(sp)
    sw s3 28(sp)

    # body
    lw s0 m_height
    beqz a2 M_intersect_invader_to_player

    M_intersect_player_to_invader:
        mv s1 a1 # save the origin pos-y of missile
        mv s2 a0 # save the origin pos-x of missile
        loop_M_intersect:
            # while (i >= m_pos_y)
            beqz s0 M_intersect_false
            mv a1 s1
            mv a0 s2
            jal I_xy_to_addr
            lw t0 0(a0)
            beq t0 a3 M_intersect_true
            addi s1 s1 1 # m_pos_y++
            addi s0 s0 -1 # i--
            j loop_M_intersect

    M_intersect_invader_to_player:
        add a1 a1 s0
        jal I_xy_to_addr
        lw t0 0(a0)
        beq t0 a3 M_intersect_true
        li a0 0
        j fin_M_intersectWithColor

    M_intersect_true:
        li a0 1
        mv a1 s1
        j fin_M_intersectWithColor

    M_intersect_false:
        li a0 0

    fin_M_intersectWithColor:
        # epilogue
        lw ra 0(sp)
        lw a1 4(sp)
        lw a2 8(sp)
        lw a3 12(sp)
        lw s0 16(sp)
        lw s1 20(sp)
        lw s2 24(sp)
        lw s3 28(sp)
        addi sp sp 32
        ret

