.data
displayaddress: .word 0x10008000

.text
lw $t0, displayaddress
li $t4, 0xffffff
    
    
add $t5, $zero, $zero
addi $t5, $t5, 256

lip_loop:
    add $t7, $t0, $t5       # get current row address
    sw $t4, 52($t7)          # draw at first column 
    sw $t4, 68($t7)          # draw at second column 
    addi $t5, $t5, 128      # next row
    beq $t5, 640, wider_vase       # finish if we hit row 640 (meaning 3 pixels down)
    j lip_loop              

wider_vase:
    add $t8, $zero, $zero   
    addi $t8, $t8, 640      # start at row 640
wider_loop:
    add $t7, $t0, $t8       # current row address
    sw $t4, 24($t7)        
    sw $t4, 96($t7)        
    
    addi $t8, $t8, 128      
    beq $t8, 2688, top_line_draw       
    j wider_loop            
    
top_line_draw:
add $t5, $zero, $zero      # offset = 0
addi $t7, $zero, 96        # final location
addi $t8, $zero, 640       # row offset
add $t6, $t0, $t8          # starting Row
addi $t2, $zero, 24        # start at column 24

top_line_start:
# Check if current position is between 52 and 68
slti $t9, $t2, 56          # $t9 = 1 if $t2 <= 52
beq $t9, $zero, check_upper  # If $t9 = 0 (meaning $t2 >= 52), check upper bound
j draw_pixel               # If we get here, $t2 < 52, so draw

check_upper:
slti $t9, $t2, 68          # $t9 = 1 if $t2 < 68
beq $t9, $zero, draw_pixel # If $t9 = 0 (meaning $t2 >= 68), draw
j skip_pixel               # If we get here, 52 <= $t2 < 68, so skip

draw_pixel:
add $t3, $t6, $t2          # Calculate current pixel position
sw $t4, 0($t3)             # Draw pixel at current position

skip_pixel:
addi $t2, $t2, 4           # Move to next pixel position
beq $t2, $t7, bottom_line_draw # If we've reached the end, break
j top_line_start           # Otherwise, continue drawing

bottom_line_draw:
add $t5, $zero, $zero      # Initialize offset to zero
addi $t7, $zero, 100        # Set final value (where we want to stop)
addi $t8, $zero, 2688      # Row offset value for bottom line
add $t6, $t0, $t8          # Base address + row offset (gets us to correct row)
addi $t2, $zero, 24        # Start at column 24

bottom_line_start:
add $t3, $t6, $t2          # Calculate current pixel position
sw $t4, 0($t3)             # Draw pixel at current position
addi $t2, $t2, 4           # Move to next pixel position
beq $t2, $t7, bottom_line_end  # If we've reached the end, break
j bottom_line_start        

bottom_line_end:
li $t3, 0x0000ff          # Load blue color
addi $t8, $zero, 256      # Row offset value
add $t6, $t0, $t8         # Base address + row offset
addi $t2, $zero, 60       # Column position
add $t4, $t6, $t2         # Calculate final pixel position
sw $t3, 0($t4)            # Draw blue pixel at position

li $t3, 0xff0000          # Load blue color
addi $t8, $zero, 384      # Row offset value
add $t6, $t0, $t8         # Base address + row offset
addi $t2, $zero, 60       # Column position
add $t4, $t6, $t2         # Calculate final pixel position
sw $t3, 0($t4)            # Draw blue pixel at position


