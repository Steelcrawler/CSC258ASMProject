.data
displayaddress: .word 0x10008000
keyboardAddress: .word 0xffff0000
first_x_pill: .word 15
first_y_pill: .word 6
first_color: .word 0
second_x_pill: .word 16
second_y_pill: .word 6
second_color: .word 0
viruses_drawn: .byte 0

.text
lw $t0, displayaddress

main:
    lw $t7, keyboardAddress        # Load keyboard base address
    lw $t8, 0($t7)                # Load first word from keyboard
    beq $t8, 1, keyboard_input    # If first word 1, key is pressed
    
main_draw:
    jal check_bottom
    jal draw_jar
    jal draw_pill
    
    li $v0, 32                    # syscall for sleep
    li $a0, 50                    # sleep for 50 milliseconds
    syscall
    
    j main                        # Loop back to main
    

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
    
    sll $a0, $s0, 2     
    sll $a1, $s1, 7     
    sll $a2, $s2, 2     
    sll $a3, $s3, 7     
    add $t2, $t0, $a1   
    add $t2, $t2, $a0   # real position for first half of pill
    add $t3, $t0, $a3   
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
    move $t9, $s4       # first color
    sw $t9, 0($t2)      # draw first part
    move $t9, $s5       # second color  
    sw $t9, 0($t3)      # draw second part
    jal check_horz_four
    jal check_vert_four
    jal check_end_condition
    
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
    
    lw $ra, 0($sp)      
    addi $sp, $sp, 4    
    jr $ra              
    
##########################################################################
# CHECK IF 4 IN A ROW HORIZONTALLY
##########################################################################
check_horz_four:
    addi $sp, $sp, -4   
    sw $ra, 0($sp)
    
check_horz_again:           # restart checking
    li $t4, 20              # restart fromy y = 20
    li $s7, 0               # stores if any matches were found
    
check_row:
    beq $t4, 5, check_matches_complete    # Changed from check_done
    
    li $t5, 7              # left pointer starts x = 7
    li $t6, 7              # right pointer starts x = 7
    
    sll $t7, $t4, 7        # get y row value
    add $t7, $t7, $t0      # loads t7 with current row value
    
    j look_for_consecutive

check_matches_complete:
    beq $s7, 1, check_horz_again    # If we found matches, check again
    
    lw $ra, 0($sp)     
    addi $sp, $sp, 4    
    jr $ra              # only return when no more matches 
    
check_done:
    lw $ra, 0($sp)     
    addi $sp, $sp, 4    
    jr $ra              # return to previous point
    
look_for_consecutive:
    beq $t6, 24, next_row        # reached end of row, so go to next
    
    
    sll $t8, $t5, 2     
    add $t8, $t7, $t8   
    lw $t9, 0($t8)      # Get color at left pointer
    
    beq $t9, 0x000000, move_pointers_same_row # No color here -- move both pointers to next location
    
    
    sll $t8, $t6, 2    
    add $t8, $t7, $t8  
    lw $t1, 0($t8)      # Get color at right pointer
    
    bne $t9, $t1, check_match_length    # Reached the end of a potential sequence -- check length
    
    addi $t6, $t6, 1 # Otherwise color matches so move right pointer again
    j look_for_consecutive

check_match_length:
    sub $t8, $t6, $t5   # right pointer loc - left pointer loc
    
    bge $t8, 4, horz_prepare_match   # sequence is long enough so need to remove it now
    
    move $t5, $t6       # otherwise, move left pointer past this sequence that is too short
    
    j look_for_consecutive

horz_prepare_match:
    addi $t6, $t6, -1   # remove last nonmatching position
    move $a0, $t4       # y position
    move $a1, $t5       # start x position
    move $a2, $t6       # end x position 
    j handle_horz_match
    
move_pointers_same_row:
    addi $t5, $t5, 1    # move left pointer right
    addi $t6, $t6, 1    # move right pointer right
    j look_for_consecutive
    
next_row:
    addi $t4, $t4, -1   # move up one row
    j check_row

handle_horz_match:
    addi $sp, $sp, -4          
    sw $ra, 0($sp)             
    addi $sp, $sp, -4          
    sw $t4, 0($sp)             
    addi $sp, $sp, -4          
    sw $t5, 0($sp)             
    addi $sp, $sp, -4  
    sw $t6, 0($sp)             
    
    li $s7, 1                  # Found a match
    
    jal clear_horz_consecutive
    

    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $ra, 0($sp)
    addi $sp, $sp, 4        # load all the values back
    move $t5, $t6              # move left pointer to right pointer location
    
    j look_for_consecutive      # go back to search

clear_horz_consecutive:
    addi $sp, $sp, -4   
    sw $ra, 0($sp)      
    
    sll $a1, $a1, 2     # convert left x to bitmap coords
    sll $a2, $a2, 2     # convert right x to bitmap coords
    addi $a2, $a2, 4    # NOTE!!! a1 and a2 can safely be changed because they are never used without being set after but sus code so rip u ig
    
    sll $t1, $a0, 7     
    add $t1, $t1, $t0  
    
    move $t2, $a1       # t2 is current pixel being cleared
    
clear_loop:
    beq $t2, $a2, clear_done    # if right position (+1 inherently) reached, then done
    
    add $t3, $t1, $t2   # get current coordinate
    
    li $t4, 0x000000    
    sw $t4, 0($t3)      # erase
    
    addi $t2, $t2, 4    # move to next pixel
    j clear_loop
    
clear_done:
    jal drop_everything_above   # need to drop everything above

    lw $ra, 0($sp)      
    addi $sp, $sp, 4    
    jr $ra          # go back to original location
    
##########################################################################
# DROPPING EVERYTHING AFTER HORIZONTAL CLEAR
##########################################################################
drop_everything_above:
    addi $sp, $sp, -4
    sw $ra, 0($sp)      
    
    addi $t1, $a0, -1  
    li $t2, 6           # stop at y = 6
    
drop_columns:
    beq $a1, $a2, drop_done     # dropped all columns
    
    move $t1, $a0       # start from current row
    addi $t1, $t1, -1   # move one row up
    
check_column:
    ble $t1, $t2, next_column       # stop if reached y = 6
    
    sll $t3, $t1, 7     
    add $t3, $t3, $t0   
    add $t3, $t3, $a1   # get current position coordinates
    
    lw $t4, 0($t3)      # get the color at that position
    
    beq $t4, 0x000000, next_position    # if black, move to next position, nothing to move
    
    addi $t5, $t3, 128
    lw $t6, 0($t5)      
    bne $t6, 0x000000, next_position  # if position below not black, nothing to move
    

    sw $t4, 0($t5)      # move pixel down
    sw $zero, 0($t3)    # clear original position
    j check_column      # check this column again
    
next_position:
    addi $t1, $t1, -1   # move up one row
    j check_column
    
next_column:
    addi $a1, $a1, 4    # move to next x position
    j drop_columns
    
drop_done:
    lw $ra, 0($sp)      
    addi $sp, $sp, 4    
    jr $ra

##########################################################################
# VERTICAL CHECKING
##########################################################################
check_vert_four:
   addi $sp, $sp, -4   
   sw $ra, 0($sp)      
   
check_vert_again:           
   li $t4, 7              # restart checking from x  = 7
   li $s7, 0              # reset value storing if we found a match
   j vert_check_row
   
vert_check_row:
   beq $t4, 24, vert_check_done    
   
   li $t5, 20             # bottom pointer
   li $t6, 20             # top pointer 
   
   sll $t7, $t4, 2     
   add $t7, $t7, $t0      # gives you current x offset 
   
   j vert_look_for_consecutive
   
vert_check_done:
   beq $s7, 1, check_vert_again    # if match exists, restart check
   
   lw $ra, 0($sp)      
   addi $sp, $sp, 4    
   jr $ra               # done so go back to where we were
    
vert_look_for_consecutive:
    beq $t6, 5, vert_next_column        # reached top of the column (y = 5) so next column
    
    sll $t8, $t5, 7     
    add $t8, $t7, $t8   
    lw $t9, 0($t8)      # get color
    
    beq $t9, 0x000000, vert_move_pointers   # if this point is black, then just move both the pointers
    
    sll $t8, $t6, 7     
    add $t8, $t7, $t8   
    lw $t1, 0($t8)      # get color from top pointer
    
    bne $t9, $t1, vert_check_match_length   # colors arent same, so then check if long enough
    
    addi $t6, $t6, -1   # colors match so move top o
    j vert_look_for_consecutive

vert_check_match_length:
    sub $t8, $t5, $t6   # top loc - bottom loc
    
    bge $t8, 4, vert_prepare_input_params  # if length >= 4, then remove
    
    move $t5, $t6       # otherwise move bottom pointer to top
    
    j vert_look_for_consecutive
    
vert_move_pointers:
    addi $t5, $t5, -1    # move top pointer up
    addi $t6, $t6, -1    # move both pointers up
    j vert_look_for_consecutive
    
vert_next_column:
    addi $t4, $t4, 1    # move to next column
    j vert_check_row

vert_prepare_input_params:
    addi $t6, $t6, 1    # adjust top position by 1
    move $a0, $t4       # x position
    move $a1, $t6       # start y position (top)     
    move $a2, $t5       # end y position (bottom)    
    j vert_handle_match

vert_handle_match:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4
    sw $t5, 0($sp)
    addi $sp, $sp, -4
    sw $t6, 0($sp)      # store everything just in case DONT REMOVE IT BREAKS EVERYTHING BUT I DONT CARE ENOUGH TO FIGURE OUT WHY
    
    jal vert_clear_consecutive
    
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    move $t5, $t6              # move bottom pointer to current top pointer
    li $s7, 1
    
    j vert_look_for_consecutive

vert_clear_consecutive:
    addi $sp, $sp, -4   
    sw $ra, 0($sp)      
    
    sll $t1, $a0, 2     # convert to coordinates
    
    move $t2, $a1       # $t2 stores current pixel to clear
    
vert_clear_loop:
    bgt $t2, $a2, vert_clear_done    # if we've gone past top of section to erase, done
    
    sll $t3, $t2, 7     
    add $t3, $t3, $t0  
    add $t3, $t3, $t1   # calculate current position
    
    sw $zero, 0($t3)    # erase pixel
    
    addi $t2, $t2, 1    # move up one position
    j vert_clear_loop
    
vert_clear_done:
    jal drop_vertical
    
    lw $ra, 0($sp)      
    addi $sp, $sp, 4    
    jr $ra

#####################################################################################
# DROPS EVERYTHING AFTER VERTICAL CLEAR
#####################################################################################
drop_vertical:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4
    sw $t5, 0($sp)
    addi $sp, $sp, -4
    sw $t6, 0($sp)
    addi $sp, $sp, -4
    sw $t7, 0($sp)
    addi $sp, $sp, -4
    sw $t8, 0($sp)
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    
    addi $t7, $a0, -1   # left column
    jal drop_column
    
    move $t7, $a0       # center column
    jal drop_column
    
    addi $t7, $a0, 1    # right column
    jal drop_column
    
    lw $t9, 0($sp)
    addi $sp, $sp, 4
    lw $t8, 0($sp)
    addi $sp, $sp, 4
    lw $t7, 0($sp)
    addi $sp, $sp, 4
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

drop_column:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t1, $a2       # starting at top y position
    addi $t1, $t1, -1    # start at position 1 above the last pixel removed
    
    
drop_loop:
    beq $t1, 5, column_done    # finished if at top position in jar
    
    sll $t3, $t7, 2     
    sll $t8, $t1, 7     
    add $t8, $t8, $t0   
    add $t8, $t8, $t3   # get address of current pixel
    
    lw $t9, 0($t8)      # Get current pixel color
    beq $t9, 0xffffff, column_done
    beq $t9, 0x000000, vert_next_position  # If black, skip
    
    addi $t3, $t8, 128  # address of position below
    lw $t4, 0($t3)      # color below
    bne $t4, 0x000000, vert_next_position  # if not black below, cant drop
    
    # Drop the pixel
    sw $t9, 0($t3)      # move color down
    sw $zero, 0($t8)    # clear original position
    addi $t1, $t1, 1
    j drop_loop         # check column again
    
vert_next_position:
    addi $t1, $t1, -1    # move up one row
    j drop_loop
    
column_done:
    # Restore registers
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

##########################################################################
# CHECK END CONDITION LOGIC
##########################################################################
check_end_condition:
    addi $sp, $sp, -4   
    sw $ra, 0($sp)      
    
    li $t6, 0           # counter for filled positions
    
    li $t2, 6           # y = 5
    sll $t2, $t2, 7
    
    # Check (15,5)
    li $t1, 15          # x = 15
    sll $t1, $t1, 2     
    add $t3, $t0, $t2   # y offset
    add $t3, $t3, $t1   # add x
    lw $t4, 0($t3)      # get color
    beq $t4, 0x000000, continue  # if black, continue 
    addi $t6, $t6, 1    # increment counter
    
    # Check (16,5)
    li $t1, 16          # x = 16
    sll $t1, $t1, 2     
    add $t3, $t0, $t2   # y offset
    add $t3, $t3, $t1   # add x
    lw $t4, 0($t3)      # get color
    beq $t4, 0x000000, continue  # if black, continue
    addi $t6, $t6, 1    # increment counter
    
    beq $t6, 2, game_over   # both positions are filled, end game
    j continue

continue:
    lw $ra, 0($sp)     
    addi $sp, $sp, 4    
    jr $ra              # jump to previous point in program
    
game_over:
    li $v0, 10    
    syscall             # quit the program
    

##########################################################################
# KEYBOARD INPUT LOGIC
##########################################################################
keyboard_input:                    # any key is pressed
    lw $a0, 4($t7)                  # load second word from keyboard
    beq $a0, 0x71, Q_input          # check if the key q was pressed
    beq $a0, 0x73, S_input          # check if the key s was pressed 
    beq $a0, 0x64, D_input          # check if the key d was pressed
    beq $a0, 0x61, A_input          # check if the key a was pressed
    beq $a0, 0x77, W_input          # check if the key w was pressed
    b main

Q_input:
    li $v0, 10                   # quit
    syscall

S_input:
    jal erase_prev              # erase the previous pill
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    lw $s3, second_y_pill       # y2 position for red part
    lw $s4, first_color       # color for first part
    lw $s5, second_color       # color for second part
    
    sll $a0, $s0, 2     
    sll $a1, $s1, 7    
    sll $a2, $s2, 2     
    sll $a3, $s3, 7     
    add $t2, $t0, $a1   
    add $t2, $t2, $a0  
    add $t3, $t0, $a3   # real position in bitmap for first half of pill
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
    
    sll $a0, $s0, 2     
    sll $a1, $s1, 7     
    sll $a2, $s2, 2     
    sll $a3, $s3, 7     
    add $t2, $t0, $a1   
    add $t2, $t2, $a0  
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
    
    sll $a0, $s0, 2     
    sll $a1, $s1, 7    
    sll $a2, $s2, 2     
    sll $a3, $s3, 7     
    add $t2, $t0, $a1   
    add $t2, $t2, $a0   
    add $t3, $t0, $a3   # real position in bitmap for first half of pill
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
    # Check space to right of top segment
    sll $t1, $s0, 2     
    sll $t2, $s1, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, 4    
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    # Check space to right of bottom segment
    sll $t1, $s2, 2     
    sll $t2, $s3, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, 4    
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    lw $s0, first_x_pill      # x1 position for first part
    lw $s1, first_y_pill       # y1 position for first part
    
    addi $s0, $s0, 1 # move top pill down and to the right
    addi $s1, $s1, 1
    
    sw $s0, first_x_pill
    sw $s1, first_y_pill
    j main

make_horizontal_inverted:
    # Check space to right of top segment
    sll $t1, $s0, 2     
    sll $t2, $s1, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, 4    
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    # Check space to right of bottom segment
    sll $t1, $s2, 2     
    sll $t2, $s3, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, 4    
    lw $t4, 0($t3)     
    bne $t4, 0x000000, main_draw  # if not black, can't flip

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
    sll $a0, $s0, 2     
    sll $a1, $s1, 7     
    sll $a2, $s2, 2     
    sll $a3, $s3, 7     
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
    
    sll $a0, $s0, 2     
    sll $a1, $s1, 7     
    sll $a2, $s2, 2     
    sll $a3, $s3, 7     
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
    li $v0, 42          
    li $a0, 0           
    li $a1, 3           
    syscall             
    
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
    addi $sp, $sp, -4   
    sw $ra, 0($sp)     
    
    lb $t8, viruses_drawn       # if viruses have already been drawn
    bne $t8, $zero, draw_jar_walls  # skip if already drawn viruses
    
    li $t9, 3                   # number of viruses to draw
    
draw_virus_loop:
    li $v0, 42                  
    li $a0, 0                   
    li $a1, 17                  
    syscall
    addi $t1, $a0, 7            # random x between 7 and 22
    
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    addi $t2, $a0, 15           # random y location between 15 and 20
    
    # random color 
    li $v0, 42
    li $a0, 0
    li $a1, 3       
    syscall
    
    beq $a0, 0, set_red
    beq $a0, 1, set_blue
    li $t7, 0xffff00            # Yellow otherwise
    j draw_pixel
    
set_red:
    li $t7, 0xff0000            # set color to red
    j draw_pixel
set_blue:
    li $t7, 0x0000ff            # set color to blue
    j draw_pixel
    
draw_pixel:
    sll $t6, $t1, 2             
    sll $t5, $t2, 7             
    add $t5, $t5, $t6           
    add $t5, $t5, $t0           # calculate location
    
    sw $t7, 0($t5)              # drw virus
    
    addi $t9, $t9, -1           # reduce virus counter
    bgtz $t9, draw_virus_loop   # continue counter not 0
    
    li $t8, 1
    sb $t8, viruses_drawn       # otherwise, all viruses have been drawn


draw_jar_walls:
    addi $a0, $zero, 14 # Set X coordinate for starting point of line
    addi $a1, $zero, 2  # Set Y coordinate for starting point of line
    addi $a2, $zero, 3  # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal vert_setup
    
    addi $a0, $zero, 17 # Set X coordinate for starting point of line
    addi $a1, $zero, 2  # Set Y coordinate for starting point of line
    addi $a2, $zero, 3  # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal vert_setup
    
    addi $a0, $zero, 6  # Set X coordinate for starting point of line
    addi $a1, $zero, 5  # Set Y coordinate for starting point of line
    addi $a2, $zero, 16 # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal vert_setup
    
    addi $a0, $zero, 24 # Set X coordinate for starting point of line
    addi $a1, $zero, 5  # Set Y coordinate for starting point of line
    addi $a2, $zero, 16 # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal vert_setup
    
    addi $a0, $zero, 6  # Set X coordinate for starting point of line
    addi $a1, $zero, 5  # Set Y coordinate for starting point of line
    addi $a2, $zero, 9  # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal horz_setup
    
    addi $a0, $zero, 17 # Set X coordinate for starting point of line
    addi $a1, $zero, 5  # Set Y coordinate for starting point of line
    addi $a2, $zero, 8  # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal horz_setup
    
    addi $a0, $zero, 6  # Set X coordinate for starting point of line
    addi $a1, $zero, 21 # Set Y coordinate for starting point of line
    addi $a2, $zero, 19 # Set length of line
    li $t1, 0xffffff    # Set color of line
    jal horz_setup
    
    lw $ra, 0($sp)      # read from stack
    addi $sp, $sp, 4    # move stack pointer back to starting position
    jr $ra              # jump to previous

##########################################################################
# VERTICAL LINE DRAWING FUNCTION
##########################################################################
vert_setup:
    sll $a0, $a0, 2     
    sll $a1, $a1, 7     
    add $t2, $t0, $a1   
    add $t2, $t2, $a0   
    
    sll $a2, $a2, 7     
    add $t3, $t2, $a2   

draw_vert_line:
    sw $t1, 0($t2)          # draw pixel at current location
    addi $t2, $t2, 128        # move down one location
    beq $t2, $t3, end_draw_vert_line  # drawn all pixels
    j draw_vert_line
end_draw_vert_line:
    jr $ra

##########################################################################
# HORIZONTAL LINE DRAWING FUNCTION
##########################################################################
horz_setup:
    sll $a0, $a0, 2     
    sll $a1, $a1, 7     
    add $t2, $t0, $a1   
    add $t2, $t2, $a0   
    sll $a2, $a2, 2     
    add $t3, $t2, $a2

draw_horz_line:
        sw $t1, 0($t2)          # draw pixel at current location
        addi $t2, $t2, 4        # move one pixel to the right
        beq $t2, $t3, end_draw_horz_line  # break out of loop
        j draw_horz_line
end_draw_horz_line:
    jr $ra

exit:
    li $v0, 10              # terminate the program
    syscall