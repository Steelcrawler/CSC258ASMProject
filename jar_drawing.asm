.data
displayaddress: .word 0x10008000

.text
lw $t0, displayaddress
li $t4, 0xffffff
    
    
add $t5, $zero, $zero
addi $t5, $t5, 256
addi $t6, $zero, 640 # end value for outer loop

row_loop:
    add $t7, $t0, $t5       # Get current row address (base + row offset)
    sw $t4, 52($t7)          # Draw at first column (offset 0)
    sw $t4, 68($t7)          # Draw at second column (offset 4)
    addi $t5, $t5, 128      # Move to next row (add 256 to get to next row)
    beq $t5, $t6, wider_vase       # If we hit 640, we're done
    j row_loop              # Otherwise, continue loop

wider_vase:
    add $t8, $zero, $zero   
    addi $t8, $t8, 640      # Start at row 640
    addi $t6, $zero, 2688   # New end value
wider_loop:
    add $t7, $t0, $t8       # Get current row address
    sw $t4, 24($t7)        
    sw $t4, 96($t7)        
    
    addi $t8, $t8, 128      
    beq $t8, $t6, top_line_draw       
    j wider_loop            
    
top_line_draw:
    add $t8, $zero, $zero   
    addi $t8, $t8, 640
top_line_loop:
    add $t7, $t0, $t8
    beq $8

END:
