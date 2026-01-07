.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    li t0 0
    bgt a1 zero loop_start
    li a0 36
    j exit

loop_start:
    slli t1 t0 2
    add t1 t1 a0
    lw t2 0(t1)
    bge t2 zero loop_continue
    li t2 0
loop_continue:
    sw t2 0(t1)
    addi t0 t0 1
    blt t0 a1 loop_start

loop_end:


    # Epilogue
    jr ra
