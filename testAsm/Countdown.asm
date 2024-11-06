setup:
    MOV R0, #30         ; User input for Starting Value
    MOV R1, #5          ; User input for Length of Time (number of clocks)

outerloop:
    MOV R2, R1          ; Resets inner loop

innerloop:
    CMP R2, R2, #1      ; Decrements inner counter
    B.ne innerloop      ; Repeats inner loop until R2 = 0
    CMP R0, R0, #1      ; Decrements outter counter
    B.ne outerloop      ; Repeats outter loop until R0 = 0
    B exit              ; Exit program

exit:
    HALT