# all auxiliary functions, like base.h

    

.macro printString (%string)
    la a0, %string
    li a7, 4
    ecall
.end_macro 


.macro printInt (%res)
    mv a0, %res
    li a7, 1
    ecall
.end_macro

.macro malloc (%res) (%var)
    slli t0 %res 2
    mv a0, t0
    li a7, 9
    ecall
    la t0 %var
    sw a0, 0(t0)
.end_macro


