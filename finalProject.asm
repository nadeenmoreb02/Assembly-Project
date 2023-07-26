;Raghad Aqel-1203384
;Dana Akesh-1201112 
;Nadeen Moreb-1203437 
.model small
.data
    MsgEnterN DB "Enter N : ", "$" 
    MsgEnterNumber DB "Enter Number : ", "$"  
    MsgEnterSize DB "Enter Size in Bytes (From 01 to 99) : ", "$"
    MgInValidLength DB "Length Exceed the Allocated Bytes, Try Again", 0ah, 0dh, "$"
    MgInValidChar DB "InValid Character Enter, Try Again", 0ah, 0dh, "$" 
    MsgSum DB "SUM = ", "$" 
    MsgAvg DB "AVG = ", "$"
    N DB 0
    Length DB 0
    ReadStr DB 100, 200 DUP(0)
    Number DB 1000 DUP(0)
    SUM DB 200 DUP(0)
    AVG DB 200 DUP(0) 
    Temp DB 200 DUP(0)

.code
    MOV AX, @data
    MOV DS, AX

    CALL GetNFromUser
    
    CALL GetLengthFromUser
    
    CALL PrintNewLine
          
    CALL GetInputFromUser
    
    CALL CalculateSUM
    
    CALL PrintSUM
    
    CALL PrintNewLine
    
    CALL CalculateAVG
     
    CALL PrintAVG
    
    MOV AH, 04CH
    INT 21H
    
    
    ;Printing NewLine
    PROC PrintNewLine
        MOV DL, 0AH
        MOV AH, 02H
        INT 21H
        MOV DL, 0DH
        INT 21H
    RET
    
    ;Getting N from user N can be 1 to 9
    PROC GetNFromUser
        EnterN:
        
        CALL PrintNewLine
        
        MOV DX, OFFSET MsgEnterN
        MOV AH, 09H
        INT 21H
        
        ;Character Input from User
        MOV AH, 01H
        INT 21H
        CMP AL, '1'
        JL EnterN
        CMP AL, '9'
        JG EnterN
        SUB AL, '0'
        MOV N, AL
    RET 
    
    
    ;Getting the size of each number and the size can be 01 to 99
    PROC GetLengthFromUser
        EnterLength:
        
            CALL PrintNewLine
            
            MOV DX, OFFSET MsgEnterSize
            MOV AH, 09H
            INT 21H
            
            ;Taking first character input
            MOV AH, 01H
            INT 21H
            CMP AL, '0'
            JL EnterLength
            CMP AL, '9'
            JG EnterLength
            SUB AL, '0'
            
            MOV BL, AL
            ;taking second character input
            MOV AH, 01H
            INT 21H
            CMP AL, '0'
            JL EnterLength
            CMP AL, '9'
            JG EnterLength
            SUB AL, '0'
            ;storing full number which is between 1-99 in length
            XCHG AL, BL
            XOR AH, 0
            MOV CL, 10
            MUL CL
            ADD AL, BL
            CMP AL, 0
            JE EnterLength
            MOV Length, AL 
    RET
    
    ;Getting Input From User and Store Memory
    PROC GetInputFromUser
        ;Set CX to N
        XOR CH, CH
        MOV CL, N
        
        InputLoop:
            PUSH CX
            
        RetakeInput: 
            ;Print Enter Number Message
            MOV DX, OFFSET MsgEnterNumber
            MOV AH, 09H
            INT 21H
            
            ;Read a Line
            MOV DX, OFFSET ReadStr
            MOV AH, 0AH
            INT 21H
            
            CALL PrintNewLine
            ;Check Length
            MOV SI, OFFSET ReadStr
            INC SI
            MOV AL, Length
            SHL AL, 1
            CMP [SI], AL
            JBE LengthChecked
            ;Retake input is length exceed
            MOV DX, OFFSET MgInValidLength
            MOV AH, 09H
            INT 21H
            
            JMP RetakeInput
            
        LengthChecked: 
            ;Check Chars
            XOR CH, CH
            MOV CL, [SI]
            INC SI
            MOV BH, CL
        CharCheck:
            ;Jump if In-Valid Char found
            CMP [SI], '0'
            JB InValidChar
            CMP [SI], '9'
            JA InValidChar
            INC SI
            Loop CharCheck
            
            JMP CharChecked
            
        InValidChar:
            ;Print Message for invalid character and retake input
            MOV DX, OFFSET MgInValidChar
            MOV AH, 09H
            INT 21H
            
            JMP RetakeInput
            
        CharChecked:
            ;Store number in memory
            POP CX
            ;Getting address of current variable in array by adding Length*CurrentNumber to base address
            XOR AH, AH
            MOV AL, N
            MOV BL, CL
            SUB AL, BL
            MOV BL, Length
            MUL BL
            MOV DI, OFFSET Number
            
            ADD DI, AX
            
            XOR AX, AX
            MOV AL, Length
            SHR BH, 1
            SUB AL, BH
            ADD DI, AX
            
            PUSH CX
            ;Check if input has odd digit or even
            MOV SI, OFFSET ReadStr
            INC SI
            MOV AL, [SI]
            MOV CL, [SI]
            INC SI
            AND AL, 1
            CMP AL, 0
            ;start moving if input has even digit
            JE StartMoving
            
            ;get first digit from input and store in memory
            DEC DI
            MOV AL, [SI]
            SUB AL, '0'
            MOV [DI], AL
            INC SI
            INC DI
            DEC CL
            CMP CX, 1
            JB EndMoving
            ;start moving by getting 2 digits every time and store it in single byte in memory
        StartMoving:  
            ;getting first digit
            MOV AL, [SI]
            SUB AL, '0'
            ROL AL, 4
            ;getting second digit and adding it to first digit to make current byte as 2 digits
            INC SI
            MOV BL, [SI]
            SUB BL, '0'
            ADD AL, BL
            ;storing current byte and moving to next 2 byte
            MOV [DI], AL
            INC SI
            INC DI
            DEC CL
            Loop StartMoving
            
        EndMoving:
            POP CX
            Loop InputLoop
    RET 
    
    ;Procedure to Calculate SUM
    PROC CalculateSUM
        XOR CH, CH
        MOV CL, N
        
        StartSum:
            PUSH CX
            ;getting address of current number for sum
            XOR AH, AH
            MOV AL, N
            MOV BL, CL
            SUB AL, BL
            MOV BL, Length
            MUL BL
            MOV DI, OFFSET Number
            ADD DI, AX
            
            ;moving to the last byte of address becuasse sum operation is performed from right side
            XOR AH, AH
            MOV AL, Length
            ADD DI, AX
            SUB DI, 1
            
            ;getting address of sum variable
            MOV SI, OFFSET SUM
            XOR AH, AH
            MOV AL, Length
            ADD SI, AX
            MOV DL, 0
            ;start sum
            XOR CH, CH
            MOV CL, Length
        SUMCurrent:
            ;getting  byte of sum and spliting its digit in al and ah
            XOR AH, AH
            MOV AL, [SI]
            ROL AX, 4
            ROL AL, 4
            
            ;getting byte of current number and spliting it digits in bl and bh
            XOR BH, BH
            MOV BL, [DI]
            ROL BX, 4
            ROL BL, 4
            
            ;adding bl to al and bh to ah also adding carry from last byte
            ADD AL, BL
            ADD AL, DL
            MOV DL, 0
            CMP AL, 9
            JNG SkipCarry
            ;if al+bl>9 than set a carry for next byte and subtract 10 from al
            SUB AL, 10
            MOV DL, 1
            
        SkipCarry:
            ;adding bh to ah and any carry from bl+al
            ADD AH, BH
            ADD AH, DL
            MOV DL, 0
            CMP AH, 9
            JNG SkipCarry2
            ;if bh+ah>9 also than set carry for next byte and subtract 10 from ah
            SUB AH, 10
            MOV DL, 1
            
        SkipCarry2:
            ;not merger ah and al as single byte 
            ROL AL, 4
            ROR AX, 4
            ;store current byte to al
            MOV [SI], AL
            ;decrement si and di to get previous byte for addition
            DEC SI
            DEC DI
            
            LOOP SUMCurrent
            ;add any carry from left most byte opration
            ;which sometimes can cause an extra byte in result 
            MOV AL, [SI]
            ROL AX, 4
            ROR AL, 4
            ADD AL, DL
            CMP AL, 9
            JNG SkipCarry3
            
            SUB AL, 0AH
            ADD AH, 1
            
        SkipCarry3:
            ROL AL, 4
            ROR AX, 4
            MOV [SI], AL    
            
            POP CX
            Loop StartSum
    RET
    
    ;Procedure to PrintSUM
    PROC PrintSUM
        ;printing message
        MOV DX, OFFSET MsgSum
        MOV AH, 09H
        INT 21H
        ;loading sum address
        MOV SI, OFFSET SUM
        XOR CH, CH
        MOV CL, Length
        ADD CL, 1
        ;skip left side zeros
        SkipZeros:
            MOV DL, [SI]
            CMP DL, 0
            JNE StartPrintingSUM
            INC SI
            DEC CL
            JMP SkipZeros
        ;print actual number    
        StartPrintingSUM: 
            ;load current byte to dl
            XOR DH, DH
            MOV DL, [SI]
            ;each byte has 2 digits so split currrent digits in dh and dl in reverse order 
            ;so dl has first digit and dh has second digit
            ROR DX, 4
            ;print first digit
            ADD DL, '0'
            MOV AH, 02h
            INT 21H
            ;geting second digit in dl and print it
            MOV DL, 0
            ROL DX, 4
            ADD DL, '0'
            MOV AH, 02h
            INT 21H
            ;increment si and loop until all bytes of sum are not printed
            INC SI
            
            LOOP StartPrintingSUM
    RET
    
    ;Procedure to calculate Average
    PROC CalculateAVG
        ;load sum address and a temporary location we had used
        MOV SI, OFFSET SUM
        MOV DI, OFFSET Temp
        MOV CH, 0
        MOV CL, Length
        INC CX 
        ;adjust bytes by spliting all bytes of sum to 2 byte and store it in a temorary location temp
        AdjustSUM:
            MOV AH, 0
            MOV AL, [SI]
            ROL AX, 4
            ROR AL, 4
            ;get single byte from sum split it and store in temp as 2 bytes
            MOV [DI], AH
            INC DI
            MOV [DI], AL
            INC SI
            INC DI
            LOOP AdjustSUM 
            
        ;loading addresses    
        MOV SI, OFFSET Temp
        MOV DI, OFFSET AVG
        ;loading length and muliply by 2 because now we have splitted all bytes
        XOR CH, CH
        MOV CL, Length
        ADD CL, 1
        SHL CX, 1
        
        MOV AX, 0
        PUSH AX
        Average:
            ;get current digit or byte
            MOV BH, 0
            MOV BL, [SI]
            ;get last remainder from stack
            POP AX
            PUSH CX
            ;multiply last remainder to 10 and add current digit 
            MOV DX, 0
            MOV CX, 10
            MUL CX
            
            ADD AX, BX
            ;if after adding to current digit the answer is still less than N than leave current avg space as 0 and push current 
            ;value to stack for the next digit and move to next
            MOV BH, 0
            MOV BL, N
            CMP BX, AX
            JNG DivThis
            ;move next if cannot divide now byt putting current value to stack
            INC SI 
            INC DI
            POP CX
            PUSH AX
            LOOP Average
            
        DivThis:
            ;divide current value with the N
            DIV BX
            ;saving current answer
            MOV [DI], AL 
            ;moving remainder to ax
            MOV AX, DX
            ;pushing current remainder to stack for next operation and moving to next
            INC SI
            INC DI
            POP CX
            PUSH AX
            Loop Average
        ;move $ to last byte to indicate that the answer has been finished
        MOV [DI], '$'
        POP AX
    RET
    
    ;Procedure to Print Average
    PROC PrintAVG
        ;printing message
        MOV DX, OFFSET MsgAvg
        MOV AH, 09H
        INT 21H
        ;locading address of avg
        MOV SI, OFFSET AVG
        ;skipping zeros if any
        SkipZerosForAVG:
            MOV DL, [SI]
            CMP DL, 0
            JNE StartPrintingAVG
            INC SI
            JMP SkipZerosForAVG 
        ;print actual value of avg    
        StartPrintingAVG:
            ;loading current byte and compare with $
            MOV DL, [SI]
            CMP DL, '$'
            ;jump outside of loop if current byte is $ because we know it is the terminating symbol of avg we had written
            JE AVGPrinted
            ;print current digit if it is not $
            ADD DL, '0'
            MOV AH, 02h
            INT 21H
            ;increament si and go to next digit
            INC SI
            JMP StartPrintingAVG
            
        AVGPrinted:
    RET
    
        