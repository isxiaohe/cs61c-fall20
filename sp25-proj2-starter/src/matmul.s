.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0, 1
    blt a1, t0, error
    blt a2, t0, error
    blt a5, t0, error
    bne a2, a4, error
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)   # i
    sw s1, 8(sp)   # j
    sw s2, 12(sp)  # k
    sw s3, 16(sp)  # m (a1)
    sw s4, 20(sp)  # n (a2)
    sw s5, 24(sp)  # p (a5)
    sw s6, 28(sp)  # base_A (a0)
    sw s7, 32(sp)  # base_B (a3)
    sw s8, 36(sp)  # base_C (a6)

    mv s3, a1
    mv s4, a2
    mv s5, a5
    mv s6, a0
    mv s7, a3
    mv s8, a6

    li s0, 0            # i = 0
outer_loop_start:
    beq s0, s3, outer_loop_end

    li s1, 0
inner_loop_start:
    beq s1, s5, next_i

    li s2, 0   # k        
    li t0, 0   # sum  
    
inner_k:
    beq s2, s4, store_c
    
    mul t1, s0, s4      # t1 = i * n
    add t1, t1, s2      # t1 = i * n + k
    slli t1, t1, 2      # t1 = (i * n + k) * 4
    add t1, s6, t1      # t1 = A + offset
    lw t2, 0(t1)        # t2 = A[i][k]

    mul t3, s2, s5      # t3 = k * p
    add t3, t3, s1      # t3 = k * p + j
    slli t3, t3, 2      # t3 = (k * p + j) * 4
    add t3, s7, t3      # t3 = B + offset
    lw t4, 0(t3)        # t4 = B[k][j]

    mul t5, t2, t4      # t5 = A[i][k] * B[k][j]
    add t0, t0, t5      # sum += t5

    addi s2, s2, 1      # k++
    j inner_k




store_c:
    mul t1, s0, s5      # t1 = i * p
    add t1, t1, s1      # t1 = i * p + j
    slli t1, t1, 2      # t1 = (i * p + j) * 4
    add t1, s8, t1      # t1 = C + offset
    sw t0, 0(t1)        # C[i][j] = sum

    addi s1, s1, 1      # k++
    j inner_loop_start


next_i:
    addi s0, s0, 1      # i++
    j outer_loop_start  

outer_loop_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 40

    # Epilogue
    jr ra

error:
    li a0, 38
    j exit
