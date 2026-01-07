.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
# =====================================
classify:
    # --- Check argc ---
    li t0, 5
    bne a0, t0, err_argc

    # --- Prologue ---
    addi sp, sp, -52
    sw ra, 0(sp)
    sw s0, 4(sp)   # argv
    sw s1, 8(sp)   # m0 pointer
    sw s2, 12(sp)  # m1 pointer
    sw s3, 16(sp)  # input pointer
    sw s4, 20(sp)  # h pointer
    sw s5, 24(sp)  # o pointer
    sw s6, 28(sp)  # a2 (print flag)
    # Stack space 32-52 used for matrix dimensions (6 * 4 bytes)
    # 32(sp): m0_rows, 36(sp): m0_cols
    # 40(sp): m1_rows, 44(sp): m1_cols
    # 48(sp): in_rows, 52(sp): in_cols (Note: check sp offset)

    mv s0, a1      # Save argv
    mv s6, a2      # Save print flag

    # --- Read pretrained m0 ---
    lw a0, 4(s0)       # argv[1]
    addi a1, sp, 32    # &m0_rows
    addi a2, sp, 36    # &m0_cols
    jal read_matrix
    mv s1, a0          # s1 = m0

    # --- Read pretrained m1 ---
    lw a0, 8(s0)       # argv[2]
    addi a1, sp, 40    # &m1_rows
    addi a2, sp, 44    # &m1_cols
    jal read_matrix
    mv s2, a0          # s2 = m1

    # --- Read input matrix ---
    lw a0, 12(s0)      # argv[3]
    addi a1, sp, 48    # &in_rows
    addi a2, sp, 52    # &in_cols
    jal read_matrix
    mv s3, a0          # s3 = input

    # --- Compute h = matmul(m0, input) ---
    # Result dimensions: m0_rows x in_cols
    lw t0, 32(sp)      # m0_rows
    lw t1, 52(sp)      # in_cols
    mul a0, t0, t1
    slli a0, a0, 2     # bytes = elements * 4
    jal malloc
    beq a0, x0, err_malloc
    mv s4, a0          # s4 = h

    mv a0, s1          # m0
    lw a1, 32(sp)      # m0_rows
    lw a2, 36(sp)      # m0_cols
    mv a3, s3          # input
    lw a4, 48(sp)      # in_rows
    lw a5, 52(sp)      # in_cols
    mv a6, s4          # h (buffer)
    jal matmul

    # --- Compute h = relu(h) ---
    mv a0, s4
    lw t0, 32(sp)      # m0_rows
    lw t1, 52(sp)      # in_cols
    mul a1, t0, t1     # number of elements
    jal relu

    # --- Compute o = matmul(m1, h) ---
    # Result dimensions: m1_rows x in_cols
    lw t0, 40(sp)      # m1_rows
    lw t1, 52(sp)      # in_cols
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    beq a0, x0, err_malloc
    mv s5, a0          # s5 = o

    mv a0, s2          # m1
    lw a1, 40(sp)      # m1_rows
    lw a2, 44(sp)      # m1_cols
    mv a3, s4          # h
    lw a4, 32(sp)      # h_rows (same as m0_rows)
    lw a5, 52(sp)      # h_cols (same as in_cols)
    mv a6, s5          # o (buffer)
    jal matmul

    # --- Write output matrix o ---
    lw a0, 16(s0)      # argv[4]
    mv a1, s5          # matrix o
    lw a2, 40(sp)      # o_rows (m1_rows)
    lw a3, 52(sp)      # o_cols (in_cols)
    jal write_matrix

    # --- Compute argmax(o) ---
    mv a0, s5
    lw t0, 40(sp)
    lw t1, 52(sp)
    mul a1, t0, t1
    jal argmax
    mv s0, a0          # s0 = classification result

    # --- If enabled, print argmax(o) and newline ---
    bne s6, x0, skip_print
    mv a0, s0
    jal print_int
    li a0, '\n'
    jal print_char

skip_print:
    # --- Free allocated memory ---
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free

    # --- Epilogue ---
    mv a0, s0          # Return classification
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 52
    ret

# --- Error Handling ---
err_argc:
    li a0, 31
    j exit

err_malloc:
    li a0, 26
    j exit