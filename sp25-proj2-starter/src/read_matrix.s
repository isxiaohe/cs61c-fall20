.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
# FILE FORMAT:
# The first 8 bytes are two 4 byte ints representing the # of rows and columns
# in the matrix. Every 4 bytes afterwards is an element of the matrix in
# row-major order.
# Arguments:
# a0 (char*) is the pointer to string representing the filename
# a1 (int*)  is a pointer to an integer, we will set it to the number of rows
# a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
# a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error, this function terminates the program with error code 26
# - If you receive an fopen error or eof, this function terminates the program with error code 27
# - If you receive an fclose error or eof, this function terminates the program with error code 28
# - If you receive an fread error or eof, this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue

    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)   
    sw s1, 8(sp)   
    sw s2, 12(sp)  
    sw s3, 16(sp)  
    sw s4, 20(sp)  
    sw s5, 24(sp)  

    mv s0, a0
    mv s1, a1
    mv s2, a2

    # 1. Open the file (fopen)
    mv a0, s0      # filename
    li a1, 0       # read-only
    jal ra, fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s3, a0      # s3 = fd

    # 2. Read number of rows (fread)
    mv a0, s3      # fd
    mv a1, s1      # row pointer
    li a2, 4       # read 4 bytes
    jal ra, fread
    li t0, 4
    bne a0, t0, fread_error

    # 3. Read number of columns (fread)
    mv a0, s3      # fd
    mv a2, s2      # col pointer
    mv a1, s2      
    li a2, 4       # read 4 bytes
    jal ra, fread
    li t0, 4
    bne a0, t0, fread_error

    # 4. Allocate memory (malloc)
    lw t1, 0(s1)   # t1 = rows
    lw t2, 0(s2)   # t2 = cols
    mul s5, t1, t2 # s5 = rows * cols
    slli s5, s5, 2 # s5 = total bytes (elements * 4)
    
    mv a0, s5
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s4, a0      # s4 = matrix pointer

    # 5. Read matrix data (fread)
    mv a0, s3      # fd
    mv a1, s4      # buffer = matrix pointer
    mv a2, s5      # total bytes
    jal ra, fread
    bne a0, s5, fread_error

    # 6. Close the file (fclose)
    mv a0, s3
    jal ra, fclose
    bne a0, x0, fclose_error

    # 7. Return matrix pointer
    mv a0, s4

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

malloc_error:
    li a0, 26
    j exit

fopen_error:
    li a0, 27
    j exit

fclose_error:
    li a0, 28
    j exit

fread_error:
    li a0, 29
    j exit