.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)   # filename string
    sw s1, 8(sp)   # matrix pointer
    sw s2, 12(sp)  # rows
    sw s3, 16(sp)  # cols
    sw s4, 20(sp)  # file descriptor (fd)
    sw s5, 24(sp)  # total elements / temporary storage

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # 1. Open the file for writing (fopen)
    mv a0, s0
    li a1, 1       # write-only
    jal ra, fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s4, a0      # s4 = fd

    # 2. Write number of rows and columns
    addi sp, sp, -8
    sw s2, 0(sp)   
    sw s3, 4(sp)   

    mv a0, s4
    addi a1, sp, 0 
    li a2, 1       
    li a3, 4      
    jal ra, fwrite
    li t0, 1
    bne a0, t0, fwrite_error

    mv a0, s4
    addi a1, sp, 4 
    li a2, 1       
    li a3, 4       
    jal ra, fwrite
    li t0, 1
    bne a0, t0, fwrite_error

    addi sp, sp, 8 

    # 3. Write the matrix data
    mul s5, s2, s3 # s5 = rows * cols 
    mv a0, s4      # fd
    mv a1, s1      # matrix pointer
    mv a2, s5      
    li a3, 4      
    jal ra, fwrite
    bne a0, s5, fwrite_error 

    # 4. Close the file (fclose)
    mv a0, s4
    jal ra, fclose
    li t0, -1
    beq a0, t0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    ret

# --- Error Handling ---

fopen_error:
    li a0, 27
    j exit

fclose_error:
    li a0, 28
    j exit

fwrite_error:
    li a0, 30
    j exit