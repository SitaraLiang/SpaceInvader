.data
    player_x: .word 0
    player_y: .word 0
    player_width: .word 5
    player_height: .word 2
    player_color: .word 0x00ff7f7f
    player_life: .word 7
    left: .word 105
    right: .word 112
    fire: .word 111
    quit: .word 113
    RCR: .word 0xffff0000
    RDR: .word 0xffff0004
	
.text

#####################################################################
# Function          : P_create
# Description       : Initialise the position (x, y) of player
# Pre-condition     : I_width, I_height, player_width and player_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
P_create:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 I_height
    lw t1 player_height
    sub t2 t0 t1
    la t0 player_y
    sw t2 0(t0)

    lw t0 I_width
    li t1 2
    div t0 t0 t1
    lw t2 player_width
    div t2 t2 t1
    sub t3 t0 t2
    la t0 player_x
    sw t3 0(t0)

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret


#####################################################################
# Function          : P_display
# Description       : Display the player correspond with its position
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
P_display:
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
    lw a0 player_x
    lw a1 player_y
    lw a2 player_width
    lw a3 player_height
    lw a4 player_color
    jal I_rectangle

    li s0 0
    lw s1 player_life
    lw s2 I_width
    sub a0 s2 s1
    li a1 0
    mv a2 s1
    li a3 1
    li a4 0x006df288 # green
    jal I_rectangle

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
# Function          : P_move
# Description       : Update the attributs of player based on user input
#                     - case 'o': fire 
#                     - case 'i': update the position of player to left
#                     - case 'p': update the position of player to right
#                     - case 'q': force quit
# Pre-condition     : The necessary attributs of player are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
P_move:
    # prologue
    addi sp sp -8
    sw ra 0(sp)
    sw s0 4(sp)

    # body
    lw t1 RCR
    lw t0 0(t1)
    beqz t0, fin_P_move
    lw t2 RDR 
    lw t3 0(t2)

    lw s0 player_x

    lw t1 left
    beq t3 t1 P_move_left
    lw t1 right
    beq t3 t1 P_move_right
    lw t1 fire
    beq t3 t1 P_move_fire
    lw t1 quit
    beq t3 t1 P_move_quit
    
    # other characters
    j fin_P_move

    P_move_left:
        addi s0 s0 -2 # the default step of player is 2
        bltz s0 P_move_leftmost
        la t0 player_x
        sw s0 0(t0)
        j fin_P_move

    P_move_leftmost:
        la t0 player_x
        sw zero 0(t0)
        j fin_P_move

    P_move_right:
        addi s0 s0 2 # the default step of player is 2
        lw t0 player_width
        lw t1 I_width
        add t2 s0 t0 # t2 = player_x + player_width
        bgt t2 t1 P_move_rightmost
        la t0 player_x
        sw s0 0(t0)
        j fin_P_move
    
    P_move_rightmost:
        sub t2 t1 t0 # t2 = I_width - player_x
        la t0 player_x
        sw t2 0(t0)
        j fin_P_move

    P_move_fire:
        lw a0 player_x
        lw a1 player_y
        li a2 1
        jal M_fire
        j fin_P_move

    P_move_quit:
        j end_game


    fin_P_move:
        # epilogue
        lw ra 0(sp)
        lw s0 4(sp)
        addi sp sp 8
        ret


#####################################################################
# Function          : P_reduce_lives
# Description       : 
# Pre-condition     : I_buff, I_visu, I_width, I_height are already initialised
# @param[in]        : /
# @param[out]       : /
# @return           : / 
# Post-condition    : /
#####################################################################
P_reduce_lives:
    # prologue
    addi sp sp -4
    sw ra 0(sp)

    # body
    lw t0 player_life
    addi t0 t0 -1
    bltz t0 end_game
    la t1 player_life
    sw t0 0(t1)

    # epilogue
    lw ra 0(sp)
    addi sp sp 4
    ret
