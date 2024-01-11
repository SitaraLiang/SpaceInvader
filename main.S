.include "lib/utils.S"

.text
j main
.include "src/image.S"
.include "src/player.S"
.include "src/obstacle.S"
.include "src/invader.S"
.include "src/missile.S"


.text
main:
    jal I_create
    jal I_welcome
    jal P_create
    jal O_create
    jal Invader_create
    jal M_create

    loop_main:
    	jal P_move
    	jal Invader_move
    	jal M_move

	    jal I_erase
	
        jal P_display
        jal O_display
        jal Invader_display
        jal M_display

        jal I_buff_to_visu

	# sleep
	li a0 100
	li a7 32 
	ecall
	
        j loop_main

end_game:
    j exit

exit:
    jal I_ending
    li a7 10 
    ecall
