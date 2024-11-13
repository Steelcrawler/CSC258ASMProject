.data
displayaddress: .word 0x10008000
keyboardAddress: .word 0xffff0000

.text
lw $t0, displayaddress

##########################################################################
# DRAW THE JAR
##########################################################################
addi $a0, $zero, 13 # Set X coordinate for starting point of line
addi $a1, $zero, 2 # Set Y coordinate for starting point of line
addi $a2, $zero, 3 # Set length of line
li $t1, 0xffffff # Set color of line
jal vert_setup

addi $a0, $zero, 17 # Set X coordinate for starting point of line
addi $a1, $zero, 2 # Set Y coordinate for starting point of line
addi $a2, $zero, 3 # Set length of line
li $t1, 0xffffff # Set color of line
jal vert_setup

addi $a0, $zero, 6 # Set X coordinate for starting point of line
addi $a1, $zero, 5 # Set Y coordinate for starting point of line
addi $a2, $zero, 16 # Set length of line
li $t1, 0xffffff # Set color of line
jal vert_setup

addi $a0, $zero, 24 # Set X coordinate for starting point of line
addi $a1, $zero, 5 # Set Y coordinate for starting point of line
addi $a2, $zero, 16 # Set length of line
li $t1, 0xffffff # Set color of line
jal vert_setup

addi $a0, $zero, 6 # Set X coordinate for starting point of line
addi $a1, $zero, 5 # Set Y coordinate for starting point of line
addi $a2, $zero, 8 # Set length of line
li $t1, 0xffffff # Set color of line
jal horz_setup

addi $a0, $zero, 17 # Set X coordinate for starting point of line
addi $a1, $zero, 5 # Set Y coordinate for starting point of line
addi $a2, $zero, 8 # Set length of line
li $t1, 0xffffff # Set color of line
jal horz_setup

addi $a0, $zero, 6 # Set X coordinate for starting point of line
addi $a1, $zero, 21 # Set Y coordinate for starting point of line
addi $a2, $zero, 19 # Set length of line
li $t1, 0xffffff # Set color of line
jal horz_setup

##########################################################################
# DRAW THE FIRST PILL
##########################################################################
j pill_draw



##########################################################################
# VERTICAL LINE DRAWING FUNCTION
##########################################################################
vert_setup:
sll $a0, $a0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
sll $a1, $a1, 7     # shift the Y value by 7 bits (multiply by 128)
add $t2, $t0, $a1   # add the Y offset to $t0
add $t2, $t2, $a0   # add the X offset to #t2
# Convert the line length from pixels to bytes
sll $a2, $a2, 7     # Convert the  line length from pixls to bytes (multiply by 4)
add $t3, $t2, $a2   # Add this offset to $t2 to figure out when to stop drawing

# Loop n times (n = length of the line)
draw_vert_line:
    sw $t1, 0($t2)          # Draw yellow pixel at current location
    addi $t2, $t2, 128        # Move current location 1 pixel to the right (4 bytes)
    beq $t2, $t3, end_draw_vert_line  # Break out of loop if we've drawn all the pixels in the line
    j draw_vert_line
end_draw_vert_line:
jr $ra

##########################################################################
# HORIZONTAL LINE DRAWING FUNCTION
##########################################################################
horz_setup:
sll $a0, $a0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
sll $a1, $a1, 7     # shift the Y value by 7 bits (multiply by 128)
add $t2, $t0, $a1   # add the Y offset to $t0
add $t2, $t2, $a0   # add the X offset to #t2
# Convert the line length from pixels to bytes
sll $a2, $a2, 2     # Convert the  line length from pixls to bytes (multiply by 4)
add $t3, $t2, $a2   # Add this offset to $t2 to figure out when to stop drawing

# Loop n times (n = length of the line)
draw_horz_line:
    sw $t1, 0($t2)          # Draw yellow pixel at current location
    addi $t2, $t2, 4        # Move current location 1 pixel to the right (4 bytes)
    beq $t2, $t3, end_draw_horz_line  # Break out of loop if we've drawn all the pixels in the line
    j draw_horz_line
end_draw_horz_line:
jr $ra

##########################################################################
# PILL DRAWING FUNCTION
##########################################################################
pill_draw:
li $t3, 0x0000ff          # load blue color
addi $t8, $zero, 384      # row offset value
add $t6, $t0, $t8         # base address + row offset
addi $t2, $zero, 60       # column position
add $t4, $t6, $t2         # calculate final pixel position
sw $t3, 0($t4)            # draw blue pixel at position

li $t3, 0xff0000          # load red color
addi $t8, $zero, 512      # row offset 
add $t6, $t0, $t8         # base address 
addi $t2, $zero, 60       # column position
add $t4, $t6, $t2         # pixel position
sw $t3, 0($t4)            # draw