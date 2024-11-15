.data
displayaddress: .word 0x10008000
keyboardAddress: .word 0xffff0000
first_x_pill: .word 15
first_y_pill: .word 6
first_color: .word 0
second_x_pill: .word 16
second_y_pill: .word 6
second_color: .word 0

.text
lw $t0, displayaddress

main:
    lw $t7, keyboardAddress        # Load keyboard base address
    lw $t8, 0($t7)                # Load first word from keyboard
    beq $t8, 1, keyboard_input    # If first word 1, key is pressed
    
main_draw:   
    jal check_bottom
    jal draw_jar
    # jal check_end_condition
    jal draw_pill
    
    li $v0, 32                    # syscall for sleep
    li $a0, 50                    # sleep for 50 milliseconds
    syscall
    
    j main                        # Loop back to main

##########################################################################
# CHECK END CONDITION LOGIC
##########################################################################
check_end_condition:
    addi $sp, $sp, -4   # update stack position
    sw $ra, 0($sp)      # write past $ra to stack to return later
    
    li $t6, 0           # counter for filled positions
    
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    li $t2, 6           # y = 5
    sll $t2, $t2, 7
    
    # Check (15,5)
    li $t1, 15          # x = 15
    sll $t1, $t1, 2     # x * 4
    add $t3, $t0, $t2   # base + y offset (reuse y=5 offset)
    add $t3, $t3, $t1   # + x offset
    lw $t4, 0($t3)      # load color at position
    beq $t4, 0x000000, continue  # if black, continue game
    addi $t6, $t6, 1    # increment filled counter
    
    # Check (16,5)
    li $t1, 16          # x = 16
    sll $t1, $t1, 2     # x * 4
    add $t3, $t0, $t2   # base + y offset (reuse y=5 offset)
    add $t3, $t3, $t1   # + x offset
    lw $t4, 0($t3)      # load color at position
    beq $t4, 0x000000, continue  # if black, continue game
    addi $t6, $t6, 1    # increment filled counter
    
    # If we got here and counter is 2, both positions were filled
    beq $t6, 2, game_over

continue:
    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous
    
game_over:
    li $v0, 10          # syscall for exit
    syscall             # quit the program
    

##########################################################################
# CHECK BOTTOM LOGIC
##########################################################################
check_bottom:
    addi $sp, $sp, -4   # update stack position
    sw $ra, 0($sp)      # write past $ra to stack to return later
    jal erase_prev      # erase current pill so that there is no interference by location
    
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    sll $a0, $s0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
    sll $a1, $s1, 7     # shift the Y value by 7 bits (multiply by 128)
    sll $a2, $s2, 2     # shift X value by 2 bits (byte offset)
    sll $a3, $s3, 7     # shift Y value by 7 bits 
    add $t2, $t0, $a1   # add the Y offset to $t0
    add $t2, $t2, $a0   # add the X offset to #t2
    add $t3, $t0, $a3   # real position for first half of pill
    add $t3, $t3, $a2   # real position for second half of pill
    
    addi $t7, $t2, 128
    lw $t8, 0($t7)
    bne $t8, 0x000000, reset_pill   # if collision detected, reset pill
    
    addi $t7, $t3, 128
    lw $t8, 0($t7)
    bne $t8, 0x000000, reset_pill   # if collision detected, reset pill
    jal draw_pill                   # redraw the pill since no interference and can be drawn there
    
    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous

reset_pill:
    # Draw current pill in final position
    move $t9, $s4       # first color
    sw $t9, 0($t2)      # draw first part
    move $t9, $s5       # second color  
    sw $t9, 0($t3)      # draw second part
       
    # Reset pill position and colors
    li $s0, 15      # x1 position for first part
    li $s1, 6       # y1 position for first part
    li $s2, 16      # x2 position for second part
    li $s3, 6       # y2 position for red part
    li $s4, 0       # color for first part
    li $s5, 0       # color for second part
    
    sw $s0, first_x_pill
    sw $s1, first_y_pill
    sw $s2, second_x_pill
    sw $s3, second_y_pill
    sw $s4, first_color
    sw $s5, second_color
    
    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous

##########################################################################
# KEYBOARD INPUT LOGIC
##########################################################################
keyboard_input:                    # A key is pressed
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x71, Q_input          # Check if the key q was pressed
    beq $a0, 0x73, S_input          # Check if the key s was pressed 
    beq $a0, 0x64, D_input          # Check if the key d was pressed
    beq $a0, 0x61, A_input          # Check if the key a was pressed
    beq $a0, 0x77, W_input          # Check if the key w was pressed
    b main

Q_input:
    li $v0, 10                   # Quit gracefully
    syscall

S_input:
    jal erase_prev              # erase the previous pill
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    sll $a0, $s0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
    sll $a1, $s1, 7     # shift the Y value by 7 bits (multiply by 128)
    sll $a2, $s2, 2     # shift X value by 2 bits (byte offset)
    sll $a3, $s3, 7     # shift Y value by 7 bits 
    add $t2, $t0, $a1   # add the Y offset to $t0
    add $t2, $t2, $a0   # add the X offset to #t2
    add $t3, $t0, $a3   # real position for first half of pill
    add $t3, $t3, $a2   # real position for second half of pill
    
    addi $t7, $t2, 128
    lw $t8, 0($t7)
    bne $t8, 0x000000, S_done   # bottom barrier reached
    
    addi $t7, $t3, 128
    lw $t8, 0($t7)
    bne $t8, 0x000000, S_done   # bottom barrier reached
    
    addi $s1, $s1, 1            # increment y1
    addi $s3, $s3, 1            # increment y2
    
    sw $s1, first_y_pill
    sw $s3, second_y_pill
    
    j main_draw

S_done:
    j main_draw                      # Return to main loop
    
D_input: 
    jal erase_prev
    
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    sll $a0, $s0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
    sll $a1, $s1, 7     # shift the Y value by 7 bits (multiply by 128)
    sll $a2, $s2, 2     # shift X value by 2 bits (byte offset)
    sll $a3, $s3, 7     # shift Y value by 7 bits 
    add $t2, $t0, $a1   # add the Y offset to $t0
    add $t2, $t2, $a0   # add the X offset to #t2
    add $t3, $t0, $a3   # real position for first half of pill
    add $t3, $t3, $a2   # real position for second half of pill
    
    addi $t7, $t2, 4
    lw $t8, 0($t7)
    bne $t8, 0x000000, D_done   # right barrier reached
    
    addi $t7, $t3, 4
    lw $t8, 0($t7)
    bne $t8, 0x000000, D_done   # right barrier reached
    
    addi $s0, $s0, 1            # move x1 to the right 1 position for top part of pill
    addi $s2, $s2, 1            # move x2 to the right position for top part of pill
    
    sw $s0, first_x_pill
    sw $s2, second_x_pill
    
    j main_draw
D_done:
    j main_draw

A_input: 
    jal erase_prev
    
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    sll $a0, $s0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
    sll $a1, $s1, 7     # shift the Y value by 7 bits (multiply by 128)
    sll $a2, $s2, 2     # shift X value by 2 bits (byte offset)
    sll $a3, $s3, 7     # shift Y value by 7 bits 
    add $t2, $t0, $a1   # add the Y offset to $t0
    add $t2, $t2, $a0   # add the X offset to #t2
    add $t3, $t0, $a3   # real position for first half of pill
    add $t3, $t3, $a2   # real position for second half of pill
    
    addi $t7, $t2, -4
    lw $t8, 0($t7)
    bne $t8, 0x000000, A_done   # left barrier reached
    
    addi $t7, $t3, -4
    lw $t8, 0($t7)
    bne $t8, 0x000000, A_done   # left barrier reached
    
    addi $s0, $s0, -1            # move x1 to the right 1 position for top part of pill
    addi $s2, $s2, -1           # move x2 to the right position for top part of pill
    
    sw $s0, first_x_pill
    sw $s2, second_x_pill
    
    j main_draw

A_done:
    j main_draw

W_input:
    jal erase_prev
    beq $s1, $s3, curr_pill_horizontal  # If y1 = y2, pill is horizontal
    beq $s0, $s2, vertical              # If x1 = x2, pill is vertical
    j main_draw
    

##########################################################################
# PILL FLIPPING LOGIC
##########################################################################
curr_pill_horizontal:
    blt $s0, $s2, curr_make_vertical_og     # pill is one step away from original config
    j curr_make_vertical_inverted           # pill will become inverted with next step since s2 < s0

curr_make_vertical_og:
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    addi $s1, $s1, -1                   # move top block up one position
    addi, $s2, $s2, -1                   # slide bottom block under the top one
    
    sw $s0, first_x_pill
    sw $s1, first_y_pill
    sw $s2, second_x_pill
    sw $s3, second_y_pill
    sw $s4, first_color
    sw $s5, second_color
    j main
    
curr_make_vertical_inverted:
    lw $s0, first_x_pill      # x1 position for first part
    lw $s3, second_y_pill       # y2 position for red part
    
    addi $s3, $s3, -1               # move top block up one row
    addi, $s0, $s0, -1               # slide bottom block under the top one
    
    sw $s0, first_x_pill
    sw $s3, second_y_pill
    j main
    
vertical:
    blt $s1, $s3, make_horizontal_og    # pill is in starting vertical position
    j make_horizontal_inverted          # pill is in inverted vertical position

make_horizontal_og:
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    
    addi $s0, $s0, 1 # move top pill down and to the right
    addi $s1, $s1, 1
    
    sw $s0, first_x_pill
    sw $s1, first_y_pill
    j main

make_horizontal_inverted:
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part

    addi $s2, $s2, 1 # move bottom pill down and to the right
    addi $s3, $s3, 1
    
    sw $s2, second_x_pill
    sw $s3, second_y_pill
    sw $s4, first_color
    sw $s5, second_color
    
    j main

##########################################################################
# ERASE PREVIOUS PILL
##########################################################################
erase_prev:
    addi $sp, $sp, -4   # update stack position
    sw $ra, 0($sp)      # write past $ra to stack to return later
    
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    
    li $t1, 0x000000    # load black color
    sll $a0, $s0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
    sll $a1, $s1, 7     # shift the Y value by 7 bits (multiply by 128)
    sll $a2, $s2, 2     # shift X value by 2 bits (byte offset)
    sll $a3, $s3, 7     # shift Y value by 7 bits 
    add $t2, $t0, $a1   # add the Y offset to $t0
    add $t2, $t2, $a0   # add the X offset to #t2
    add $t3, $t0, $a3 
    add $t3, $t3, $a2
    sw $t1, 0($t2) 
    sw $t1, 0($t3) 
    
    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous

##########################################################################
# DRAW THE PILL
##########################################################################
draw_pill:
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color
    
    beq $s4, 0, assign_color_first
    beq $s5, 0, assign_color_second
    addi $sp, $sp, -4   # update stack position
    sw $ra, 0($sp)      # write past $ra to stack to return later
    
    li $t1, 0x000000    # load black color
    
    sll $a0, $s0, 2     # shift the X value by 2 bits (multiply by 4 to get the byte offset)
    sll $a1, $s1, 7     # shift the Y value by 7 bits (multiply by 128)
    sll $a2, $s2, 2     # shift X value by 2 bits (byte offset)
    sll $a3, $s3, 7     # shift Y value by 7 bits 
    add $t2, $t0, $a1   # add the Y offset to $t0
    add $t2, $t2, $a0   # add the X offset to #t2
    add $t3, $t0, $a3 
    add $t3, $t3, $a2
    
    sw $s4, 0($t2)      # draw first pixel at position
    
    sw $s5, 0($t3)      # draw second pixel at position
    
    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous


assign_color_first:
    li $v0, 42          # syscall 42 is random int range
    li $a0, 0           # random generator ID (can be any value)
    li $a1, 3           # upper bound (exclusive) - so 0,1,2 possible
    syscall             # random number now in $a0
    
    beq $a0, 0, first_red
    beq $a0, 1, first_blue
    li $s4, 0xffff00    # yellow if $a0 is 2
    
    sw $s4, first_color


    j first_done
first_red:
    li $s4, 0xff0000    # red if $a0 is 0

    sw $s4, first_color
    
    j first_done
first_blue:
    li $s4, 0x0000ff    # blue if $a0 is 1
    sw $s4, first_color
    j first_done
    
first_done:
    j draw_pill

assign_color_second:
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    
    # Select second color based on random number in $a0
    beq $a0, 0, second_red
    beq $a0, 1, second_blue
    li $s5, 0xffff00    # yellow if $a0 is 2

    sw $s5, second_color
    
    j second_done
second_red:
    li $s5, 0xff0000    # red if $a0 is 0
    sw $s5, second_color
    j second_done
second_blue:
    li $s5, 0x0000ff    # blue if $a0 is 1
    sw $s5, second_color
second_done:
    j draw_pill


##########################################################################
# DRAW THE JAR
##########################################################################
draw_jar: 
    addi $sp, $sp, -4   # update stack position
    sw $ra, 0($sp)      # write past $ra to stack to return later
    
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

    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous

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

exit:
    li $v0, 10              # terminate the program gracefully
    syscall