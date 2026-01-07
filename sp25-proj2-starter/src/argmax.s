.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    li t0 0
    bgt a1 zero loop_start
    li a0 36
    j exit

loop_start:
    slli t1 t0 2
    add t1 t1 a0
    lw t2 0(t1) # t2 = max(a0[:t0])
    li t3 0 # t3 = argmax(a0[:t0])
    addi t0 t0 1
    bge t0 a1 loop_end

loop_continue:
    slli t1 t0 2
    add t1 t1 a0
    lw t1 0(t1)
    bge t2 t1 check
    mv t2 t1
    mv t3 t0
    check:
    addi t0 t0 1
    blt t0 a1 loop_continue
loop_end:
    # Epilogue
    mv a0 t3

    jr ra