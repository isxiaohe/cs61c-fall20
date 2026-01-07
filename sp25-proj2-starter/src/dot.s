.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    ble a2 zero number_fault
    ble a3 zero stride_fault
    ble a4 zero stride_fault
    
    li t0 0 # idx
    li t1 0 # For accum
    ebreak
loop_start:
    mul t2 t0 a3 # t2 = idx for a0
    slli t2 t2 2
    add t2 t2 a0
    lw t2 0(t2)
    mul t3 t0 a4 # t3 = idx for a0
    slli t3 t3 2
    add t3 t3 a1
    lw t3 0(t3)
    mul t2 t2 t3
    add t1 t1 t2
    addi t0 t0 1    
    blt t0 a2 loop_start
    
loop_end:
    mv a0 t1

    # Epilogue
    jr ra

number_fault:
    li a0 36
    j exit

stride_fault:
    li a0 37
    j exit