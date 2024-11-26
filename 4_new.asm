.data
displayaddress: .word 0x10008000
backupDisplay: .space 16384
keyboardAddress: .word 0xffff0000
first_x_pill: .word 15
first_y_pill: .word 6
second_x_pill: .word 16
second_y_pill: .word 6
first_color: .word 0
second_color: .word 0
next_first_color: .word 0
next_second_color: .word 0
next_first_color2: .word 0
next_second_color2: .word 0
next_first_color3: .word 0
next_second_color3: .word 0
next_first_color4: .word 0
next_second_color4: .word 0
next_first_color5: .word 0
next_second_color5: .word 0
saved_first_color: .word 0
saved_second_color: .word 0
viruses_drawn: .byte 0

.text
restart:
lw $t0, displayaddress

main:
    addi $t1, $zero, 0
    lw $t7, keyboardAddress        # Load keyboard base address
    lw $t8, 0($t7)                # Load first word from keyboard
    beq $t8, 1, keyboard_input    # If first word 1, key is pressed
    
    blt $t1, 2, gravity_easy
    bge $t1, 2, gravity_hard
    
main_draw:
    jal check_bottom
    jal draw_jar
    jal draw_pill
    jal draw_next_pill
    jal check_viruses
    
    li $v0, 32                    # syscall for sleep
    li $a0, 50                    # sleep for 50 milliseconds
    syscall
    
    addi $t1, $t1, 1
    
    j main                        # Loop back to main

gravity_easy:
    li $v0, 32
    li $a0, 200                    # sleep for 50 milliseconds
    syscall
    jal S_input
    j main

gravity_hard:
    li $v0, 32
    li $a0, 50                    # sleep for 50 milliseconds
    syscall
    jal S_input
    j main

##########################################################################
# CHECK FOR VIRUSES
##########################################################################
check_viruses:
    li $t1, 6       # start x
    li $t2, 5       # start y
    li $t5, 0       # red counter
    li $t6, 0       # blue counter
    li $t7, 0       # green counter
   
virus_loop_y:
    li $t1, 6      
   
virus_loop_x:
    sll $t9, $t1, 2     
    sll $t8, $t2, 7     
    add $t3, $t0, $t8   
    add $t3, $t3, $t9  
    lw $t4, 0($t3)
   
    beq $t4, 0xCC0000, count_red
    beq $t4, 0x0000CC, count_blue
    beq $t4, 0x00CC00, count_green
    j continue_check
   
count_red:
    addi $t5, $t5, 1
    j continue_check
   
count_blue:
    addi $t6, $t6, 1
    j continue_check
   
count_green:
    addi $t7, $t7, 1
   
continue_check:
    addi $t1, $t1, 1    
    blt $t1, 24, virus_loop_x   # stop searching at x = 24
   
    addi $t2, $t2, 1    
    blt $t2, 22, virus_loop_y   # stop searching at y = 22
    
clear_indicators:
    li $t1, 15      
    li $t2, 25      

    li $t4, 0x000000    
   
    sll $t9, $t1, 2     
    sll $t8, $t2, 7     
    add $t3, $t0, $t8   
    add $t3, $t3, $t9
    sw $t4, 0($t3)
   
    addi $t1, $t1, 2
    sll $t9, $t1, 2     
    add $t3, $t0, $t8   
    add $t3, $t3, $t9
    sw $t4, 0($t3)
   
    addi $t1, $t1, 2
    sll $t9, $t1, 2     
    add $t3, $t0, $t8   
    add $t3, $t3, $t9
    sw $t4, 0($t3)
    j draw_indicators

draw_indicators:
    beq $t5, $zero, check_blue   
    li $t1, 15
    li $t2, 25
    sll $t9, $t1, 2     
    sll $t4, $t2, 7     
    add $t3, $t0, $t4   
    add $t3, $t3, $t9   
    li $t4, 0xCC0000    # red 
    sw $t4, 0($t3)
   
check_blue:
    beq $t6, $zero, check_green   
    li $t1, 17
    li $t2, 25
    sll $t9, $t1, 2     
    sll $t4, $t2, 7     
    add $t3, $t0, $t4   
    add $t3, $t3, $t9   
    li $t4, 0x0000CC    # blue
    sw $t4, 0($t3)
   
check_green:
    beq $t7, $zero, check_win      
    li $t1, 19
    li $t2, 25
    sll $t9, $t1, 2     
    sll $t4, $t2, 7     
    add $t3, $t0, $t4   
    add $t3, $t3, $t9   
    li $t4, 0x00CC00    # green
    sw $t4, 0($t3)

check_win:
    bne $t5, $zero, done  
    bne $t6, $zero, done  


done:
    jr $ra
    
you_win:
    li $t2, 16384        
    li $t3, 0             
    
clear_screen_win:
    beq $t3, $t2, write_you_win  
    add $t4, $t0, $t3     
    sw $zero, 0($t4)      
    addi $t3, $t3, 4      
    j clear_screen_win

write_you_win:
    li $t1, 0xffffff    
    
    # draw Y
    li $a0, 4           
    li $a1, 2           
    li $a2, 4          
    jal vert_setup      
    
    li $a0, 8           
    li $a1, 2           
    li $a2, 4          
    jal vert_setup
    
    li $a0, 6           
    li $a1, 5           
    li $a2, 4          
    jal vert_setup
    
    li $a0, 4           
    li $a1, 5           
    li $a2, 5         
    jal horz_setup 
    
    
    
    # draw O
    li $a0, 10          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup   
    
    li $a0, 13          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup
    
    li $a0, 10          
    li $a1, 2           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 10          
    li $a1, 8           
    li $a2, 3           
    jal horz_setup
    
    # draw U
    li $a0, 15          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup   
    
    li $a0, 18          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup
    
    li $a0, 15          
    li $a1, 8           
    li $a2, 3           
    jal horz_setup
    
    # draw W
    li $a0, 4           
    li $a1, 12           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 8          
    li $a1, 12           
    li $a2, 7          
    jal vert_setup 
    
    li $a0, 6           
    li $a1, 16           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 5           
    li $a1, 17           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 7           
    li $a1, 17           
    li $a2, 1          
    jal vert_setup
    
    # draw I
    li $a0, 10          
    li $a1, 12           
    li $a2, 7           
    jal vert_setup
    
    # draw N
    li $a0, 12          
    li $a1, 12           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 16          
    li $a1, 12           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 13          
    li $a1, 13           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 14          
    li $a1, 14           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 15          
    li $a1, 15           
    li $a2, 1          
    jal vert_setup

    li $v0, 32
    li $a0, 2000
    syscall


    li $t2, 16384        
    li $t3, 0            
    
clear_screen_press_r:
    beq $t3, $t2, draw_press_r  
    add $t4, $t0, $t3     
    sw $zero, 0($t4)      
    addi $t3, $t3, 4      
    j clear_screen_press_r

draw_press_r:
    li $t1, 0xffffff      
    
    # draw p
    li $a0, 2           
    li $a1, 7           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 2           
    li $a1, 7           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 2           
    li $a1, 10          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 5           
    li $a1, 7           
    li $a2, 4          
    jal vert_setup
    
    # draw r
    li $a0, 7           
    li $a1, 7           
    li $a2, 7          
    jal vert_setup
    li $a0, 7           
    li $a1, 7           
    li $a2, 3           
    jal horz_setup
    li $a0, 7          
    li $a1, 10          
    li $a2, 3           
    jal horz_setup
    li $a0, 10           
    li $a1, 7           
    li $a2, 4           
    jal vert_setup
    li $a0, 8          
    li $a1, 11          
    li $a2, 1           
    jal horz_setup
    li $a0, 9          
    li $a1, 12          
    li $a2, 1           
    jal horz_setup
    li $a0, 10          
    li $a1, 13          
    li $a2, 1           
    jal horz_setup
    
    # draw e
    li $a0, 12          
    li $a1, 7           
    li $a2, 7           
    jal vert_setup      
    
    li $a0, 12          
    li $a1, 7           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 10           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 13           
    li $a2, 4           
    jal horz_setup
    
    # draw s
    li $a0, 17          
    li $a1, 7           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 10           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 7           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 20          
    li $a1, 10           
    li $a2, 4           
    jal vert_setup
    
    # draw s
    li $a0, 22          
    li $a1, 7           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 10           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 7           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 25          
    li $a1, 10           
    li $a2, 4           
    jal vert_setup

    # draw left quote
    li $a0, 9          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
    li $a0, 11          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
    # draw R
    li $a0, 13          
    li $a1, 19           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 13          
    li $a1, 19           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 13          
    li $a1, 22          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 16          
    li $a1, 19           
    li $a2, 4          
    jal vert_setup
    
    li $a0, 14          
    li $a1, 23          
    li $a2, 1          
    jal vert_setup
    
    li $a0, 15          
    li $a1, 24          
    li $a2, 1          
    jal vert_setup
    
    li $a0, 16          
    li $a1, 25          
    li $a2, 1          
    jal vert_setup
    
    # draw right quote
    li $a0, 18          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
    li $a0, 20          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
win_loop:
    lw $t7, 0xffff0000       
    beq $t7, 0, win_loop   
    
    lw $t7, 0xffff0004       
    beq $t7, 0x71, quit_game     # q pressed
    beq $t7, 0x72, reset_game    # r pressed
    j win_loop

    jr $ra

##########################################################################
# Music
##########################################################################

down_music:
    li $v0, 31 # play midi async
    li $a0, 50
    li $a1, 50
    li $a2, 81 # instrument 81
    li $a3, 30 # volume = 30/127
    syscall
    
    j S_input
    
left_music:
    li $v0, 31 # play midi async
    li $a0, 50
    li $a1, 50
    li $a2, 91 # instrument 81
    li $a3, 30 # volume = 30/127
    syscall
    
    j A_input
    
right_music:
    li $v0, 31          # Play MIDI asynchronously
    li $a0, 100          # Some argument, check if correct (note or sound parameter)
    li $a1, 100          # Some argument, check if correct (note duration or other)
    li $a2, 81         # Instrument (e.g., 101 for MIDI instrument)
    li $a3, 100          # Volume (0-127)
    syscall
    
    j D_input            # Jump to D_done after playing sound
    
turn_music:
    li $v0, 31 # play midi async
    li $a0, 50
    li $a1, 50
    li $a2, 72 # instrument 81
    li $a3, 30 # volume = 30/127
    syscall
    
elimination_music:
    li $v0, 31 # play midi async
    li $a0, 50
    li $a1, 50
    li $a2, 60 # instrument 81
    li $a3, 30 # volume = 30/127
    syscall


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
    
check_horz_again:   
    li $t4, 20              # restart from y = 20
    li $s7, 0               # stores if any matches were found
    
check_row:
    beq $t4, 5, check_matches_complete    
    
    li $t5, 6              # left pointer starts x = 6
    li $t6, 6              # right pointer starts x = 6
    
    
    sll $t7, $t4, 7        # get y row value
    add $t7, $t7, $t0      # loads t7 with current row value
    
    j look_for_consecutive

check_matches_complete:
    beq $s7, 1, check_horz_again    # if we found matches, check again
    
    lw $ra, 0($sp)     
    addi $sp, $sp, 4    
    jr $ra              # only return when no more matches 
    
look_for_consecutive:
    beq $t6, 24, next_row        # reached end of row, so go to next
    
    sll $t8, $t5, 2     
    add $t8, $t7, $t8   
    lw $t9, 0($t8)      # get color at left pointer
    
    beq $t9, 0x000000, move_pointers_same_row # no color here -- move both pointers to next location
    
    
    sll $t8, $t6, 2    
    add $t8, $t7, $t8  
    lw $t1, 0($t8)      # get color at right pointer
    
    andi $s0, $t9, 0xff      # left pointer blue (Applies a mask see lecture video to get rightmost bits for green)
    andi $s1, $t1, 0xff     # right pointer blue
    sub $s2, $s0, $s1        # calculate blue difference
    li $s3, -52              # lower bound (-52)
    blt $s2, $s3, check_match_length # if signed difference < -52, not a virus
    li $s3, 52               # upper bound (52)
    bgt $s2, $s3, check_match_length # if signed difference > 52, not a virus

    srl $t9, $t9, 8
    srl $t1, $t1, 8
    andi $s0, $t9, 0xff                 # left pointer green (Applies a mask see lecture video to get rightmost bits for green)
    andi $s1, $t1, 0xff                 # right pointer green
    sub $s2, $s0, $s1                   # calculate red difference
    li $s3, -52                         # lower bound (-52)
    blt $s2, $s3, check_match_length    # if signed difference < -52, not a virus
    li $s3, 52                          # upper bound (52)
    bgt $s2, $s3, check_match_length    # if signed difference > 52, not a virus

    srl $t9, $t9, 8
    srl $t1, $t1, 8
    andi $s0, $t9, 0xff                # left pointer red
    andi $s1, $t1, 0xff                 # right pointer red
    sub $s2, $s0, $s1                   # calculate red difference (Applies a mask see lecture video to get rightmost bits for green)
    li $s3, -52                         # lower bound (-52)
    blt $s2, $s3, check_match_length    # if signed difference < -52, not a virus
    li $s3, 52                          # upper bound (52)
    bgt $s2, $s3, check_match_length    # if signed difference > 51, not a virus

    addi $t6, $t6, 1         # Color matches, move on
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
    
    li $s7, 1                  # found a match
    
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
    
    beq $t4, 0x0000ff, check_below  # pill blue
    beq $t4, 0x00ff00, check_below  # pill green 
    beq $t4, 0xff0000, check_below  # pill red
    j next_position                  # Not a pill color, skip 
   
check_below:
    addi $t5, $t3, 128
    lw $t6, 0($t5)      
    bne $t6, 0x000000, next_position  # if position below not black
   
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
   
    jal check_horz_four
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
    
    andi $s0, $t9, 0xff      # left pointer blue (Applies a mask see lecture video to get rightmost bits for green)
    andi $s1, $t1, 0xff      # right pointer blue
    sub $s2, $s0, $s1        # calculate blue difference
    li $s3, -51              # lower bound (-10)
    blt $s2, $s3, vert_check_match_length # if signed difference < -51, not a virus
    li $s3, 51               # upper bound (10)
    bgt $s2, $s3, vert_check_match_length # if signed difference > 51, not a virus

    srl $t9, $t9, 8
    srl $t1, $t1, 8
    andi $s0, $t9, 0xff                 # left pointer green (Applies a mask see lecture video to get rightmost bits for green)
    andi $s1, $t1, 0xff                 # right pointer green
    sub $s2, $s0, $s1                   # calculate red difference
    li $s3, -51                        # lower bound (-10)
    blt $s2, $s3, vert_check_match_length    # if signed difference < -51, not a virus
    li $s3, 51                          # upper bound (10)
    bgt $s2, $s3, vert_check_match_length    # if signed difference > 51, not a virus

    srl $t9, $t9, 8
    srl $t1, $t1, 8
    andi $s0, $t9, 0xff                 # left pointer red
    andi $s1, $t1, 0xff                 # right pointer red
    sub $s2, $s0, $s1                   # calculate red difference (Applies a mask see lecture video to get rightmost bits for green)
    li $s3, -51                         # lower bound (-10)
    blt $s2, $s3, vert_check_match_length    # if signed difference < -51, not a virus
    li $s3, 51                          # upper bound (10)
    bgt $s2, $s3, vert_check_match_length    # if signed difference > 51, not a virus
    
    # bne $t9, $t1, vert_check_match_length   # colors arent same, so then check if long enough
    
    addi $t6, $t6, -1   # colors match so move top 
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
   
   lw $t9, 0($t8)      # get current pixel color
   beq $t9, 0xffffff, column_done
   beq $t9, 0x000000, vert_next_position  # if black, skip
   
   # Check if pure color
   beq $t9, 0x0000FF, check_below_vert  # pill color blue 
   beq $t9, 0x00FF00, check_below_vert  # pill color green
   beq $t9, 0xFF0000, check_below_vert  # pill color red
   j vert_next_position            # Not pill color, skip
   
check_below_vert:
   addi $t3, $t8, 128  
   lw $t4, 0($t3)      
   bne $t4, 0x000000, vert_next_position  # if not black below, cant drop
   
   sw $t9, 0($t3)      # move color down
   sw $zero, 0($t8)    # clear original position
   addi $t1, $t1, 1
   j drop_loop         # check column again
    
vert_next_position:
    addi $t1, $t1, -1    # move up one row
    j drop_loop
    
column_done:
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
    
    li $t2, 6           
    sll $t2, $t2, 7
    
    # Check (15,5)
    li $t1, 15          
    sll $t1, $t1, 2     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    lw $t4, 0($t3)      # get color
    beq $t4, 0x000000, continue  # if black, continue 
    addi $t6, $t6, 1    
    
    # Check (16,5)
    li $t1, 16          # x = 16
    sll $t1, $t1, 2     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    lw $t4, 0($t3)      # get color
    beq $t4, 0x000000, continue  # if black, continue
    addi $t6, $t6, 1    
    
    beq $t6, 2, game_over   # both positions are filled, end game
    j continue

continue:
    lw $ra, 0($sp)     
    addi $sp, $sp, 4    
    jr $ra              
    
game_over:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
      
    li $t2, 16384        
    li $t3, 0             
    
clear_screen_game_over:
    beq $t3, $t2, write_game_over  
    add $t4, $t0, $t3     
    sw $zero, 0($t4)      
    addi $t3, $t3, 4      
    j clear_screen_game_over

write_game_over:
    li $t1, 0xffffff
    
    # draw G
    li $a0, 2           
    li $a1, 2           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 2           
    li $a1, 2           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 2           
    li $a1, 8           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 5           
    li $a1, 5           
    li $a2, 4          
    jal vert_setup
    
    # draw A
    li $a0, 7         
    li $a1, 2           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 10        
    li $a1, 2           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 7          
    li $a1, 2           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 7          
    li $a1, 5          
    li $a2, 3           
    jal horz_setup   
    
    # draw M
    li $a0, 12         
    li $a1, 2           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 16        
    li $a1, 2           
    li $a2, 7          
    jal vert_setup 
    
    li $a0, 13          
    li $a1, 3           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 14          
    li $a1, 4           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 15          
    li $a1, 3          
    li $a2, 1          
    jal vert_setup
    
    # draw E
    li $a0, 18          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup      
    
    li $a0, 18          
    li $a1, 2           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 18          
    li $a1, 5           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 18          
    li $a1, 8           
    li $a2, 4           
    jal horz_setup

    # draw O
    li $a0, 2          
    li $a1, 13           
    li $a2, 7           
    jal vert_setup   
    
    li $a0, 5          
    li $a1, 13           
    li $a2, 7           
    jal vert_setup
    
    li $a0, 2          
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 2          
    li $a1, 19           
    li $a2, 3           
    jal horz_setup      
    
    # draw V
    li $a0, 7         
    li $a1, 13           
    li $a2, 6          
    jal vert_setup      
    
    li $a0, 10        
    li $a1, 13           
    li $a2, 6          
    jal vert_setup
    
    li $a0, 8          
    li $a1, 19           
    li $a2, 2           
    jal horz_setup
    
    # draw E
    li $a0, 12          
    li $a1, 13           
    li $a2, 7           
    jal vert_setup      
    
    li $a0, 12          
    li $a1, 13           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 16           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 19           
    li $a2, 4           
    jal horz_setup
    
    # draw R
    li $a0, 17           
    li $a1, 13           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 17           
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 16          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 20           
    li $a1, 13           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 18           
    li $a1, 17           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 19           
    li $a1, 18           
    li $a2, 1          
    jal vert_setup
    
    li $a0, 20           
    li $a1, 19           
    li $a2, 1          
    jal vert_setup

    li $v0, 32
    li $a0, 2000
    syscall
   
    li $t2, 16384        
    li $t3, 0            
    
clear_screen_again:
    beq $t3, $t2, draw_press_R  
    add $t4, $t0, $t3     
    sw $zero, 0($t4)      
    addi $t3, $t3, 4      
    j clear_screen_again

draw_press_R:
    li $t1, 0xffffff      
    
    # draw p
    li $a0, 2           
    li $a1, 7           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 2           
    li $a1, 7           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 2           
    li $a1, 10          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 5           
    li $a1, 7           
    li $a2, 4          
    jal vert_setup
    
    # draw r
    li $a0, 7           
    li $a1, 7           
    li $a2, 7          
    jal vert_setup
    li $a0, 7           
    li $a1, 7           
    li $a2, 3           
    jal horz_setup
    li $a0, 7          
    li $a1, 10          
    li $a2, 3           
    jal horz_setup
    li $a0, 10           
    li $a1, 7           
    li $a2, 4           
    jal vert_setup
    li $a0, 8          
    li $a1, 11          
    li $a2, 1           
    jal horz_setup
    li $a0, 9          
    li $a1, 12          
    li $a2, 1           
    jal horz_setup
    li $a0, 10          
    li $a1, 13          
    li $a2, 1           
    jal horz_setup
    
    # draw e
    li $a0, 12          
    li $a1, 7           
    li $a2, 7           
    jal vert_setup      
    
    li $a0, 12          
    li $a1, 7           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 10           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 13           
    li $a2, 4           
    jal horz_setup
    
    # draw s
    li $a0, 17          
    li $a1, 7           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 10           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 7           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 20          
    li $a1, 10           
    li $a2, 4           
    jal vert_setup
    
    # draw s
    li $a0, 22          
    li $a1, 7           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 10           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 7           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 25          
    li $a1, 10           
    li $a2, 4           
    jal vert_setup

    # draw left quote
    li $a0, 9          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
    li $a0, 11          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
    # draw R
    li $a0, 13          
    li $a1, 19           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 13          
    li $a1, 19           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 13          
    li $a1, 22          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 16          
    li $a1, 19           
    li $a2, 4          
    jal vert_setup
    
    li $a0, 14          
    li $a1, 23          
    li $a2, 1          
    jal vert_setup
    
    li $a0, 15          
    li $a1, 24          
    li $a2, 1          
    jal vert_setup
    
    li $a0, 16          
    li $a1, 25          
    li $a2, 1          
    jal vert_setup
    
    # draw right quote
    li $a0, 18          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
    li $a0, 20          
    li $a1, 19           
    li $a2, 2           
    jal vert_setup
    
game_over_loop:
    lw $t7, 0xffff0000       
    beq $t7, 0, game_over_loop   
    
    lw $t7, 0xffff0004       
    beq $t7, 0x71, quit_game # q pressed
    beq $t7, 0x72, reset_game # r pressed
    j game_over_loop

quit_game:
    li $v0, 10  
    syscall

reset_game:
    la $t0, displayaddress
    lw $t0, 0($t0)    
    li $t1, 16384    # full bitmap size is 64*64*4 (4 bits per address)  
    li $t2, 0x000000
reset_display:
    sw $t2, 0($t0) 
    addi $t0, $t0, 4   
    addi $t1, $t1, -4  
    bgtz $t1, reset_display
    
reset_everything:
    la $t0, first_x_pill
    li $t1, 15
    sw $t1, 0($t0)     
    
    la $t0, first_y_pill
    li $t1, 6
    sw $t1, 0($t0)     
    
    la $t0, second_x_pill
    li $t1, 16
    sw $t1, 0($t0)     
    
    la $t0, second_y_pill
    li $t1, 6
    sw $t1, 0($t0)     
    
    la $t0, first_color
    sw $zero, 0($t0)
    
    la $t0, second_color
    sw $zero, 0($t0)
    
    la $t0, next_first_color
    sw $zero, 0($t0)
    
    la $t0, next_second_color
    sw $zero, 0($t0)
    
    la $t0, next_first_color2
    sw $zero, 0($t0)
    
    la $t0, next_second_color2
    sw $zero, 0($t0)
    
    la $t0, next_first_color3
    sw $zero, 0($t0)
    
    la $t0, next_second_color3
    sw $zero, 0($t0)
    
    la $t0, next_first_color4
    sw $zero, 0($t0)
    
    la $t0, next_second_color4
    sw $zero, 0($t0)
    
    la $t0, next_first_color5
    sw $zero, 0($t0)
    
    la $t0, next_second_color5
    sw $zero, 0($t0)
    
    la $t0, saved_first_color
    sw $zero, 0($t0)
    
    la $t0, saved_second_color
    sw $zero, 0($t0)
    
    la $t0, viruses_drawn
    sb $zero, 0($t0)
    
    la $t0, backupDisplay
    li $t1, 16384      
    li $t2, 0x000000   
reset_backup_loop:
    sw $t2, 0($t0)     
    addi $t0, $t0, 4   
    addi $t1, $t1, -4
    bgtz $t1, reset_backup_loop
    
    j restart

    

##########################################################################
# KEYBOARD INPUT LOGIC
##########################################################################
keyboard_input:                    # any key is pressed
    lw $a0, 4($t7)                  # load second word from keyboard
    beq $a0, 0x71, Q_input          # check if the key q was pressed
    beq $a0, 0x73, down_music          # check if the key s was pressed 
    beq $a0, 0x64, right_music          # check if the key d was pressed
    beq $a0, 0x61, left_music          # check if the key a was pressed
    beq $a0, 0x77, W_input          # check if the key w was pressed
    beq $a0, 0x66, F_input          # check if the key f was pressed
    beq $a0, 0x70, P_input          # check if the key p was pressed
    j main
    
P_input:
    la $t0, displayaddress    
    lw $t0, 0($t0)            
    la $t1, backupDisplay      
    li $t2, 16384             # total to count
    li $t3, 0                 # count so far
    
save_display:
    beq $t3, $t2, clear_screen  
    add $t4, $t0, $t3        
    add $t5, $t1, $t3         # address to save to
    lw $t6, 0($t4)           # get pixel from bitmap
    sw $t6, 0($t5)           # save to backup
    addi $t3, $t3, 4         
    j save_display

clear_screen:
    la $t0, displayaddress    
    lw $t0, 0($t0)            
    li $t2, 16384             
    li $t3, 0                 
    
clear_pause_loop:
    beq $t3, $t2, draw_paused  
    add $t4, $t0, $t3         
    sw $zero, 0($t4)          
    addi $t3, $t3, 4         # clear screen
    j clear_pause_loop
    
draw_paused:
    addi $sp, $sp, -4
    sw $ra, 0($sp)      # Save return address
    
    li $t1, 0xFFFFFF    # White color for text
    
    # draw p
    li $a0, 2           
    li $a1, 2           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 2           
    li $a1, 2           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 2           
    li $a1, 5          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 5           
    li $a1, 2           
    li $a2, 4          
    jal vert_setup      
    
    # draw a
    li $a0, 7         
    li $a1, 2           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 10        
    li $a1, 2           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 7          
    li $a1, 2           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 7          
    li $a1, 5          
    li $a2, 3           
    jal horz_setup   
    
    # draw u
    li $a0, 12         
    li $a1, 2           
    li $a2, 7          
    jal vert_setup      
    
    li $a0, 15        
    li $a1, 2           
    li $a2, 7          
    jal vert_setup 
    
    li $a0, 12          
    li $a1, 8          
    li $a2, 3           
    jal horz_setup 
    
    # draw s
    li $a0, 17          
    li $a1, 2           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 5           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 8           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 2           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 20          
    li $a1, 5           
    li $a2, 4           
    jal vert_setup 
    
    # draw e
    li $a0, 22          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup      
    
    li $a0, 22          
    li $a1, 2           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 5           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 8           
    li $a2, 4           
    jal horz_setup
    
    # draw d
    li $a0, 27          
    li $a1, 2           
    li $a2, 7           
    jal vert_setup   

    li $a0, 30          
    li $a1, 3           
    li $a2, 5           
    jal vert_setup
    
    li $a0, 27          
    li $a1, 2           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 27          
    li $a1, 8           
    li $a2, 3           
    jal horz_setup
    
    # draw p
    li $a0, 2           
    li $a1, 13           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 2           
    li $a1, 13           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 2           
    li $a1, 16          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 5           
    li $a1, 13           
    li $a2, 4          
    jal vert_setup
    
    # draw r
    li $a0, 7           
    li $a1, 13           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 7           
    li $a1, 13           
    li $a2, 3           
    jal horz_setup
    
    li $a0, 7          
    li $a1, 16          
    li $a2, 3           
    jal horz_setup
    
    li $a0, 10           
    li $a1, 13           
    li $a2, 4           
    jal vert_setup
    
    li $a0, 8          
    li $a1, 17          
    li $a2, 1           
    jal horz_setup
    
    li $a0, 9          
    li $a1, 18          
    li $a2, 1           
    jal horz_setup
    
    li $a0, 10          
    li $a1, 19          
    li $a2, 1           
    jal horz_setup
    
    # draw e
    li $a0, 12          
    li $a1, 13           
    li $a2, 7           
    jal vert_setup      
    
    li $a0, 12          
    li $a1, 13           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 16           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 12          
    li $a1, 19           
    li $a2, 4           
    jal horz_setup
    
    # draw s
    li $a0, 17          
    li $a1, 13           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 16           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 19           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 17          
    li $a1, 13           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 20          
    li $a1, 16           
    li $a2, 4           
    jal vert_setup
    
    # draw s
    li $a0, 22          
    li $a1, 13           
    li $a2, 4           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 16           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 19           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 22          
    li $a1, 13           
    li $a2, 4           
    jal vert_setup      
    
    li $a0, 25          
    li $a1, 16           
    li $a2, 4           
    jal vert_setup
    
    # draw left quote
    li $a0, 9          
    li $a1, 22           
    li $a2, 2           
    jal vert_setup
    
    li $a0, 11          
    li $a1, 22           
    li $a2, 2           
    jal vert_setup
    
    # draw P
    li $a0, 13          
    li $a1, 22           
    li $a2, 7          
    jal vert_setup
    
    li $a0, 13          
    li $a1, 22           
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 13          
    li $a1, 25          
    li $a2, 3           
    jal horz_setup      
    
    li $a0, 16          
    li $a1, 22           
    li $a2, 4          
    jal vert_setup
    
    # draw right quote
    li $a0, 18          
    li $a1, 22           
    li $a2, 2           
    jal vert_setup
    
    li $a0, 20          
    li $a1, 22           
    li $a2, 2           
    jal vert_setup
    
    
    j wait_for_unpause  

wait_for_unpause:
    lw $t7, 0xffff0000       
    beq $t7, 0, wait_for_unpause
    
    lw $t8, 0xffff0004       # check key press, keep waiting if not p
    bne $t8, 0x70, wait_for_unpause
    
    # p was pressed, so unpause
    la $t0, displayaddress    
    lw $t0, 0($t0)            
    la $t1, backupDisplay      
    li $t2, 16384             
    li $t3, 0                
    
restore_from_pause:
    beq $t3, $t2, pause_done  
    add $t4, $t0, $t3         
    add $t5, $t1, $t3         
    lw $t6, 0($t5)           # load from backup
    sw $t6, 0($t4)           # save to bitmap
    addi $t3, $t3, 4
    j restore_from_pause

pause_done:
    j main

F_input:
    lw $t2, saved_first_color
    beq $t2, $zero, save_color
    j remove_saved_color
    
save_color:
    lw $s0, first_color
    lw $s1, second_color
    sw $s0, saved_first_color
    sw $s1, saved_second_color
    jal erase_prev
    jal update_colors
    
    li $t1, 28          
    li $t2, 19          
    sll $t1, $t1, 2     
    sll $t2, $t2, 7     
    add $t3, $t0, $t2  
    add $t3, $t3, $t1   # point (28, 19)
    
    lw $t4, saved_first_color
    sw $t4, 0($t3)
    
    li $t1, 29           
    sll $t1, $t1, 2 
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   # point (29, 19)
    
    lw $t4, saved_second_color
    sw $t4, 0($t3)
    
    j main_draw
    
remove_saved_color:
    lw $t1, saved_first_color
    lw $t2, saved_second_color
    
    lw $t3, next_first_color4
    lw $t4, next_second_color4
    sw $t3, next_first_color5
    sw $t4, next_second_color5
    
    lw $t3, next_first_color3
    lw $t4, next_second_color3
    sw $t3, next_first_color4
    sw $t4, next_second_color4

    lw $t3, next_first_color2
    lw $t4, next_second_color2
    sw $t3, next_first_color3
    sw $t4, next_second_color3
    
    lw $t3, next_first_color
    lw $t4, next_second_color
    sw $t3, next_first_color2
    sw $t4, next_second_color2
    
    lw $t3, first_color
    lw $t4, second_color
    sw $t3, next_first_color
    sw $t4, next_second_color
    
    sw $t1, first_color
    sw $t2, second_color
   
    sw $zero, saved_first_color
    sw $zero, saved_second_color
    
    jal erase_prev
    
    li $t1, 15    
    li $t2, 6     
    li $t3, 16    
    li $t4, 6     

    sw $t1, first_x_pill
    sw $t2, first_y_pill
    sw $t3, second_x_pill  
    sw $t4, second_y_pill
   
    li $t1, 28          
    li $t2, 19          
    sll $t1, $t1, 2     
    sll $t2, $t2, 7     
    add $t3, $t0, $t2  
    add $t3, $t3, $t1   # point (28, 19)
    
    sw $zero, 0($t3)
    
    li $t1, 29           
    sll $t1, $t1, 2 
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   # point (29, 19)
    
    sw $zero, 0($t3)
   
   j main_draw


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
    # bne $t8, 0x000000, right_music
    
    addi $t7, $t3, 4
    lw $t8, 0($t7)
    bne $t8, 0x000000, D_done   # right barrier reached
    # bne $t8, 0x000000, right_music
    
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
    lw $s0, first_x_pill
    lw $s1, first_y_pill
    sll $t1, $s0, 2     
    sll $t2, $s1, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, -128  
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    lw $s2, second_x_pill
    lw $s3, second_y_pill
    sll $t1, $s2, 2     
    sll $t2, $s3, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, -128  
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip

    lw $s1, first_y_pill       # y1 position for first part
    lw $s2, second_x_pill      # x2 position for second part
    
    addi $s1, $s1, -1                   # move top block up one position
    addi, $s2, $s2, -1                   # slide bottom block under the top one
    
    sw $s1, first_y_pill
    sw $s2, second_x_pill
    j main
    
curr_make_vertical_inverted:
    lw $s0, first_x_pill
    lw $s1, first_y_pill
    sll $t1, $s0, 2     
    sll $t2, $s1, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, -128  
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    lw $s2, second_x_pill
    lw $s3, second_y_pill
    sll $t1, $s2, 2     
    sll $t2, $s3, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, -128  
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
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
    # check space to right of top segment
    sll $t1, $s0, 2     
    sll $t2, $s1, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, 4    
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    # check space to right of bottom segment
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
    # check space to right of top segment
    sll $t1, $s0, 2     
    sll $t2, $s1, 7     
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   
    addi $t3, $t3, 4    
    lw $t4, 0($t3)      # get color
    bne $t4, 0x000000, main_draw  # if not black, can't flip
    
    # check space to right of bottom segment
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
    lw $s6, next_first_color
    lw $s7, next_second_color
    
    beq $s4, 0, update_colors
    beq $s5, 0, update_colors
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

update_colors:
    li $t1, 15    
    li $t2, 6     
    li $t3, 16    
    li $t4, 6     

    sw $t1, first_x_pill
    sw $t2, first_y_pill
    sw $t3, second_x_pill  
    sw $t4, second_y_pill
    
    lw $s0, next_first_color
    lw $s1, next_second_color
    sw $s0, first_color
    sw $s1, second_color
    
    lw $s0, next_first_color2
    lw $s1, next_second_color2
    sw $s0, next_first_color
    sw $s1, next_second_color
    
    lw $s0, next_first_color3
    lw $s1, next_second_color3
    sw $s0, next_first_color2
    sw $s1, next_second_color2
    
    lw $s0, next_first_color4
    lw $s1, next_second_color4
    sw $s0, next_first_color3
    sw $s1, next_second_color3
    
    lw $s0, next_first_color5
    lw $s1, next_second_color5
    sw $s0, next_first_color4
    sw $s1, next_second_color4
    
    # Generate new color for next_first_color4
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    
    beq $a0, 0, next_first_red
    beq $a0, 1, next_first_blue
    li $s6, 0x00ff00    # green
    j next_first_done
    
next_first_red:
    li $s6, 0xff0000    # red 
    j next_first_done
    
next_first_blue:
    li $s6, 0x0000ff    # blue 
    j next_first_done
    
next_first_done:
    sw $s6, next_first_color5
    
    # Generate new color for next_second_color4
    li $v0, 42
    li $a0, 0
    li $a1, 3
    syscall
    
    beq $a0, 0, next_second_red
    beq $a0, 1, next_second_blue
    li $s7, 0x00ff00    # green 
    j next_second_done
    
next_second_red:
    li $s7, 0xff0000    # red 
    j next_second_done
    
next_second_blue:
    li $s7, 0x0000ff    # blue 
    j next_second_done

next_second_done:
    sw $s7, next_second_color5

    j draw_pill
    
draw_next_pill:
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
    
    
    li $t1, 28          
    li $t2, 7          
    sll $t1, $t1, 2     
    sll $t2, $t2, 7     
    add $t3, $t0, $t2  
    add $t3, $t3, $t1   # point (28, 7)
    
    lw $t4, next_first_color
    sw $t4, 0($t3)
    
    li $t1, 29           
    sll $t1, $t1, 2 
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   # point (29, 7)
    
    lw $t4, next_second_color
    sw $t4, 0($t3)

    li $t1, 28          
    li $t2, 9          
    sll $t1, $t1, 2     
    sll $t2, $t2, 7     
    add $t3, $t0, $t2  
    add $t3, $t3, $t1   # point (28, 9)
    
    lw $t4, next_first_color2
    sw $t4, 0($t3)
    
    li $t1, 29           
    sll $t1, $t1, 2 
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   # point (29, 9)
    
    lw $t4, next_second_color2
    sw $t4, 0($t3)

    li $t1, 28          
    li $t2, 11          
    sll $t1, $t1, 2     
    sll $t2, $t2, 7     
    add $t3, $t0, $t2  
    add $t3, $t3, $t1   # point (28, 11)
    
    lw $t4, next_first_color3
    sw $t4, 0($t3)
    
    li $t1, 29           
    sll $t1, $t1, 2 
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   # point (29, 11)
    
    lw $t4, next_second_color3
    sw $t4, 0($t3)

    li $t1, 28          
    li $t2, 13          
    sll $t1, $t1, 2     
    sll $t2, $t2, 7     
    add $t3, $t0, $t2  
    add $t3, $t3, $t1   # point (28, 13)
    
    lw $t4, next_first_color4
    sw $t4, 0($t3)
    
    li $t1, 29           
    sll $t1, $t1, 2 
    add $t3, $t0, $t2   
    add $t3, $t3, $t1   # point (29, 13)
    
    lw $t4, next_second_color4
    sw $t4, 0($t3)
    
    
    
    sw $t4, 0($t3)
    
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
    li $t7, 0x00CC00            # green otherwise
    j draw_pixel
    
set_red:
    li $t7, 0xCC0000            # set color to red
    j draw_pixel
set_blue:
    li $t7, 0x0000CC            # set color to blue
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
    
    # draws jar for next pills coming
    addi $a0, $zero, 26  
    addi $a1, $zero, 7   
    addi $a2, $zero, 9  
    li $t1, 0xffffff  
    jal vert_setup
    
    addi $a0, $zero, 31  
    addi $a1, $zero, 7   
    addi $a2, $zero, 9   
    li $t1, 0xffffff     
    jal vert_setup
    
    addi $a0, $zero, 27  
    addi $a1, $zero, 15  
    addi $a2, $zero, 4   
    li $t1, 0xffffff     
    jal horz_setup
    
    #### draws mini jar for save
    addi $a0, $zero, 26  
    addi $a1, $zero, 19   
    addi $a2, $zero, 3  
    li $t1, 0xffffff  
    jal vert_setup
    
    addi $a0, $zero, 31  
    addi $a1, $zero, 19   
    addi $a2, $zero, 3  
    li $t1, 0xffffff  
    jal vert_setup
    
    addi $a0, $zero, 26  
    addi $a1, $zero, 21  
    addi $a2, $zero, 5   
    li $t1, 0xffffff     
    jal horz_setup
    
    # draw virus container
    addi $a0, $zero, 13    # X coordinate 
    addi $a1, $zero, 23    # Y coordinate (start)
    addi $a2, $zero, 5     # Height (3 units)
    li $t1, 0xffffff       # White color
    jal vert_setup
   
   # Draw right vertical line at x=20
    addi $a0, $zero, 21   
    addi $a1, $zero, 23   
    addi $a2, $zero, 5    
    jal vert_setup
   
   # Draw bottom horizontal line
   addi $a0, $zero, 14    # X coordinate (start)
   addi $a1, $zero, 27    # Y coordinate 
   addi $a2, $zero, 7     # Width (7 units)
   jal horz_setup
   
   # Draw top horizontal line
   addi $a0, $zero, 14   
   addi $a1, $zero, 23   
   addi $a2, $zero, 7    
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
