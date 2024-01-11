
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
    beqz a2 M_intersect_invader_to_player

    M_intersect_player_to_invader:
        jal I_xy_to_addr
        lw t0 0(a0)
        beq t0 a3 M_intersect_true
        li a0 0
        j fin_M_intersectWithColor

    M_intersect_invader_to_player:
        lw s0 m_height
        mv s1 a1 # save the origin pos-y of missile
        mv s2 a0 # save the origin pos-x of missile
        add s3 s0 s1
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




M_intersectWithColor:
    ### Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw a1 20(sp)
    sw a2 24(sp)
    sw a3 28(sp)

    ### Corps
    mv s0, a0 # sauver a0 (x missile) dans s0
    mv s1, a1 # sauver a1 (y missile) dans s1
    mv s2, a3 # sauver a2 (couleur rectangle) dans s2

    lw s3 m_height # s3 = longueur du missile (en unité)

    M_intersecteCouleur__loop:
        # Parcourir la longueur du missile
        beqz s3, M_intersecteCouleur__end_loop

        # Accéder à l'adresse [(x,y) -> addr] et comparer la couleur
        mv a0, s0 # a0 =  x
        mv a1, s1 # a1 = y
        jal I_xy_to_addr # a0 = adresse dans I_buff
        lw t0, 0(a0) # t0 = couleur à l'adresse
        beq t0, s2, M_intersecteCouleur__inside # si la couleur correspond, c'est bon

        M_intersecteCouleur__outside:

        # Préparation de la prochaine itération
        addi s1, s1, 1 # incrémenter y missile
        addi s3, s3, -1 # décrémenter longueur restante
        j M_intersecteCouleur__loop

    M_intersecteCouleur__inside:
        li a0, 1 # retourner 1 car intersection
        mv a1, s1 # également retourner le y incriminé
        j M_intersecteCouleur__end
    
    M_intersecteCouleur__end_loop:
        li a0, 0 # retourner 0 car pas d'intersection

    M_intersecteCouleur__end:

    ### Epilogue
    lw a1 20(sp)
    lw a2 24(sp)
    lw a3 28(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    ret