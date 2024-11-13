.data
displayaddress: .word 0x10008000

.text
lw $t0, displayaddress
li $t4, 0xffffff
    
    
add $t5, $zero, $zero
addi $t5, $t5, 256

lip_loop:
    add $t7, $t0, $t5       # Get current row address (base + row offset)
    sw $t4, 52($t7)          # Draw at first column (offset 0)
    sw $t4, 68($t7)          # Draw at second column (offset 4)
    addi $t5, $t5, 128      # Move to next row (add 256 to get to next row)
    beq $t5, 640, wider_vase       # If we hit 640, we're done
    j lip_loop              # Otherwise, continue loop

wider_vase:
    add $t8, $zero, $zero   
    addi $t8, $t8, 640      # Start at row 640
wider_loop:
    add $t7, $t0, $t8       # Get current row address
    sw $t4, 24($t7)        
    sw $t4, 96($t7)        
    
    addi $t8, $t8, 128      
    beq $t8, 2688, top_line_draw       
    j wider_loop            
    
top_line_draw:
add $t5, $zero, $zero      # Initialize offset to zero
addi $t7, $zero, 96       # Set final value (where we want to stop)
addi $t8, $zero, 640       # Row offset value
add $t6, $t0, $t8          # Base address + row offset (gets us to correct row)
addi $t2, $zero, 24        # Start at column 48

top_line_start:
add $t3, $t6, $t2          # Calculate current pixel position
sw $t4, 0($t3)             # Draw pixel at current position
addi $t2, $t2, 4           # Move to next pixel position
beq $t2, $t7, top_line_end # If we've reached the end, break
j top_line_start           # Otherwise, continue drawing

top_line_end: