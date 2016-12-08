						.ORIG		x3000
						
RESET					LD			R5,RET_STACK_ADDRESS
						LD			R4,DATA_STACK_ADDRESS
						
						LD			R6,COLD_START			; R6 holds the address to the next address (%esi equivalent, IP)
						
						JSR			NEXT
						
RET_STACK_ADDRESS		.FILL		RETURN_STACK
DATA_STACK_ADDRESS		.FILL		DATA_STACK

COLD_START				.FILL		var_QP
						
DOCOL					JSR			PUSHRSP_R6				; Push the current IP onto the return stack
						ADD			R6,R3,#1				; R3 points at the location of DOCOL, make R6 point to the location after it
						JSR			NEXT

; Def looks like: link name dodat word data
DODAT					JSR			PUSHRSP_R6				; Push the current IP onto the return stack
						LDR			R6,R3,#1				; R3 points at the location of DODAT, make R6 point to the location defined by the cell after
						ADD			R0,R3,#2				; R0 will be the address of the first data item
						JSR			PUSH_R0					; push first data address onto stack
						JSR			NEXT

_DOCOL
                     LEA        R0,DOCOL
                     JSR        PUSH_R0
                     JSR        NEXT
_DODAT
                     LEA        R0,DODAT
                     JSR        PUSH_R0
                     JSR        NEXT
RZ
                     LD         R0,RET_STACK_ADDRESS
                     JSR        PUSH_R0
                     JSR        NEXT
SZ
                     LD         R0,DATA_STACK_ADDRESS
                     JSR        PUSH_R0
                     JSR        NEXT
FILELOC
                     LD         R0,_FILELOC
                     JSR        PUSH_R0
                     JSR        NEXT
_FILELOC             .FILL      x4000
DROP
                     ADD        R4,R4,#-1
                     JSR        NEXT
SWAP
                     LDR        R0,R4,#0
                     LDR        R1,R4,#-1
                     STR        R0,R4,#-1
                     STR        R1,R4,#0
                     JSR        NEXT
DUP
                     LDR        R0,R4,#0
                     JSR        PUSH_R0
                     JSR        NEXT
QDUP
                     LDR        R0,R4,#0
                     BRz        QDUP_skip
                     JSR        PUSH_R0
QDUP_skip            JSR        NEXT
OVER
                     LDR        R0,R4,#-1
                     JSR        PUSH_R0
                     JSR        NEXT
ROT
                     LDR        R0,R4,#0
                     LDR        R1,R4,#-1
                     LDR        R2,R4,#-2
                     STR        R2,R4,#0
                     STR        R0,R4,#-1
                     STR        R1,R4,#-2
                     JSR        NEXT
NROT
                     LDR        R0,R4,#0
                     LDR        R1,R4,#-1
                     LDR        R2,R4,#-2
                     STR        R1,R4,#0
                     STR        R2,R4,#-1
                     STR        R0,R4,#-2
                     JSR        NEXT
TOR
                     JSR        POP_R3
                     JSR        PUSHRSP_R3
                     JSR        NEXT
FROMR
                     JSR        POPRSP_R3
                     JSR        PUSH_R3
                     JSR        NEXT
DFROMR
                     JSR        POPRSP_R3
                     AND        R2,R3,R3
                     JSR        POPRSP_R3
                     JSR        PUSH_R3
                     JSR        PUSH_R2
                     JSR        NEXT
DTOR
                     JSR        _DTOR
                     JSR        NEXT

_DTOR                ST         R7,DTOR_CB

                     JSR        POP_R2
                     JSR        POP_R3
                     JSR        PUSHRSP_R3
                     AND        R3,R2,R2
                     JSR        PUSHRSP_R3

                     LD         R7,DTOR_CB
                     RET        
DTOR_CB              .BLKW      1
RFETCH
                     LDR        R0,R5,#0
                     JSR        PUSH_R0
                     JSR        NEXT
RDROP
                     ADD        R5,R5,#-1
                     JSR        PUSHRSP_R3
                     JSR        NEXT
STORE
                     JSR        POP_R0
                     JSR        POP_R1
                     STR        R1,R0,#0
                     JSR        NEXT
FETCH
                     JSR        POP_R0
                     LDR        R0,R0,#0
                     JSR        PUSH_R0
                     JSR        NEXT
ADDSTORE
                     JSR        POP_R2
                     JSR        POP_R1
_ADDSTORE            LDR        R0,R2,#0
                     ADD        R0,R0,R1
                     STR        R0,R2,#0
                     JSR        NEXT
SUBSTORE
                     JSR        POP_R2
                     JSR        POP_R1
                     NOT        R1,R1
                     ADD        R1,R1,#1
                     JSR        _ADDSTORE
RSPFETCH
                     AND        R0,R0,#0
                     ADD        R0,R0,R5
                     JSR        PUSH_R0
                     JSR        NEXT
RSPSTORE
                     JSR        POP_R0
                     AND        R5,R5,#0
                     ADD        R5,R5,R0
                     JSR        NEXT
DSPFETCH
                     AND        R0,R0,#0
                     ADD        R0,R0,R4
                     JSR        PUSH_R0
                     JSR        NEXT
DSPSTORE
                     JSR        POP_R0
                     AND        R4,R4,#0
                     ADD        R4,R4,R0
                     JSR        NEXT
ANDF
                     JSR        POP_R0
                     LDR        R1,R4,#0
                     AND        R0,R0,R1
                     STR        R0,R4,#0
                     JSR        NEXT
OR
                     JSR        POP_R0
                     LDR        R1,R4,#0
                     NOT        R0,R0
                     NOT        R1,R1
                     AND        R0,R0,R1
                     NOT        R0,R0
                     STR        R0,R4,#0
                     JSR        NEXT
INVERT
                     LDR        R0,R4,#0
                     NOT        R0,R0
                     STR        R0,R4,#0
                     JSR        NEXT
EQUAL
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRz        _EQUALITY_true
                     BRnzp      _EQUALITY_false

_EQUALITY_false      AND        R0,R0,#0
                     BRnzp      _EQUALITY_finish
_EQUALITY_true       AND        R0,R0,#0
                     ADD        R0,R0,#-1
_EQUALITY_finish     JSR        PUSH_R0
                     JSR        NEXT
NEQUAL
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRnp       _EQUALITY_true
                     BRnzp      _EQUALITY_false
LT
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRn        _EQUALITY_true
                     BRnzp      _EQUALITY_false
GT
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRp        _EQUALITY_true
                     BRnzp      _EQUALITY_false
LTE
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRnz       _EQUALITY_true
                     BRnzp      _EQUALITY_false
GTE
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRzp       _EQUALITY_true
                     BRnzp      _EQUALITY_false
ZEQUAL
                     JSR        POP_R0
                     BRz        _EQUALITY_true
                     BRnzp      _EQUALITY_false
ZNEQUAL
                     JSR        POP_R0
                     BRnp       _EQUALITY_true
                     BRnzp      _EQUALITY_false
ZLT
                     JSR        POP_R0
                     BRn        _EQUALITY_true
                     BRnzp      _EQUALITY_false
ZGT
                     JSR        POP_R0
                     BRp        _EQUALITY_true
                     BRnzp      _EQUALITY_false
ZLTE
                     JSR        POP_R0
                     BRnz       _EQUALITY_true
                     BRnzp      _EQUALITY_false
ZGTE
                     JSR        POP_R0
                     BRzp       _EQUALITY_true
                     BRnzp      _EQUALITY_false
INCR
                     LDR        R0,R4,#0
                     ADD        R0,R0,#1
                     STR        R0,R4,#0
                     JSR        NEXT
DECR
                     LDR        R0,R4,#0
                     ADD        R0,R0,#-1
                     STR        R0,R4,#0
                     JSR        NEXT
ADDF
                     JSR        POP_R0
_ADDF                LDR        R1,R4,#0
                     ADD        R0,R0,R1
                     STR        R0,R4,#0
                     JSR        NEXT
SUBTRACT
                     JSR        POP_R0
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     JSR        _ADDF
MULT
                     JSR        POP_R2
                     JSR        POP_R1
                     JSR        _MULTIPLY
                     JSR        PUSH_R3
                     JSR        NEXT

_MULTIPLY            ST         R7,MULT_CB

                     JSR        SIGN_LOGIC
                     ST         R3,MULT_SIGN

                     AND        R1,R1,R1
                     BRz        MULT_ZERO
                     AND        R2,R2,R2
                     BRz        MULT_ZERO

                     AND        R3,R3,#0

MULT_LOOP            ADD        R3,R3,R2
                     ADD        R1,R1,#-1
                     BRp        MULT_LOOP

                     LD         R0,MULT_SIGN
                     BRp        MULT_CLEANUP
                     NOT        R3,R3
                     ADD        R3,R3,#1

MULT_CLEANUP         LD         R7,MULT_CB
                     RET        

MULT_ZERO            AND        R3,R3,#0
                     BRnzp      MULT_CLEANUP

MULT_CB              .BLKW      1
MULT_SIGN            .BLKW      1
DIVMOD
                     JSR        POP_R2
                     JSR        POP_R1
                     JSR        _DIVIDE
                     JSR        PUSH_R1
                     JSR        PUSH_R0
                     JSR        NEXT

_DIVIDE              ST         R7,DIV_CB

                     AND        R2,R2,R2
                     BRz        DIV_ZERO_ERROR
                     AND        R1,R1,R1
                     BRz        DIV_ZERO_RETURN

                     JSR        SIGN_LOGIC

                     ST         R3,DIV_SIGN

                     NOT        R3,R2
                     ADD        R3,R3,#1

                     AND        R0,R0,#0

DIV_LOOP             ADD        R0,R0,#1
                     ADD        R1,R1,R3
                     BRp        DIV_LOOP

                     BRz        DIV_EVEN
                     ADD        R0,R0,#-1
                     ADD        R1,R1,R2
                     BRnzp      DIV_RETURN

DIV_EVEN             AND        R1,R1,#0

DIV_RETURN           LD         R3,DIV_SIGN
                     BRzp       DIV_CLEANUP
                     NOT        R0,R0
                     ADD        R0,R0,#1

DIV_CLEANUP          LD         R7,DIV_CB
                     RET        

DIV_ZERO_RETURN      AND        R0,R0,#0
                     AND        R1,R1,#0
                     BRnzp      DIV_CLEANUP

DIV_ZERO_ERROR       LEA        R0,DIV_ZERO_ERR_MSG
                     PUTS       
                     JSR        RESET
DIV_ZERO_ERR_MSG     .STRINGZ   "\nDivide by zero error! "

DIV_CB               .BLKW      1
DIV_SIGN             .BLKW      1

SIGN_LOGIC           ST         R7,SIGN_CB

                     AND        R3,R3,#0
                     ADD        R3,R3,#1

SIGN_TEST_R1         AND        R1,R1,R1
                     BRzp       SIGN_TEST_R2
                     JSR        SIGN_FLIP
                     NOT        R1,R1
                     ADD        R1,R1,#1

SIGN_TEST_R2         AND        R2,R2,R2
                     BRzp       SIGN_CLEANUP
                     JSR        SIGN_FLIP
                     NOT        R2,R2
                     ADD        R2,R2,#1

SIGN_CLEANUP         LD         R7,SIGN_CB
                     RET        

SIGN_FLIP            NOT        R3,R3
                     ADD        R3,R3,#1
                     RET        

SIGN_CB              .BLKW      1
BRANCH
                     LDR        R0,R6,#0
                     ADD        R6,R6,R0
                     JSR        NEXT
ZBRANCH
                     JSR        POP_R0
                     BRz        BRANCH
                     ADD        R6,R6,#1
                     JSR        NEXT
QDO
                     LDR        R0,R4,#0
                     LDR        R1,R4,#-1
                     NOT        R1,R1
                     ADD        R1,R1,#1
                     ADD        R1,R1,R0
                     BRnp       DO
                     ADD        R4,R4,#-2
                     BRnzp      BRANCH
DO
                     JSR        _DTOR
                     ADD        R6,R6,#1
                     JSR        NEXT
LEAVE
                     JSR        POPRSP_R3
                     JSR        POPRSP_R3
                     BRnzp      BRANCH
LOOP
                     LDR        R1,R5,#0
                     ADD        R1,R1,#1
_LOOP                STR        R1,R5,#0
                     LDR        R0,R5,#-1
                     NOT        R1,R1
                     ADD        R1,R1,#1

                     ADD        R1,R1,R0
                     BRp        BRANCH
                     ADD        R6,R6,#1

                     BRnzp      UNLOOP
pLOOP
                     LDR        R1,R5,#0
                     JSR        POP_R2
                     ADD        R1,R1,R2

                     JSR        _LOOP
I
                     LDR        R0,R5,#0
                     JSR        PUSH_R0
                     JSR        NEXT
J
                     LDR        R0,R5,#-2
                     JSR        PUSH_R0
                     JSR        NEXT
UNLOOP
                     JSR        POPRSP_R3
                     JSR        POPRSP_R3
                     JSR        NEXT
KEY
                     JSR        _KEY
                     JSR        PUSH_R0
                     JSR        NEXT

_KEY                 ST         R7,KEY_CB
                     ST         R1,KEY_R1
                     ST         R2,KEY_R2

_KEY_loop            GETC       
                     JSR        _VALID_CHAR
                     AND        R2,R2,R2
                     BRnp       _KEY_loop

                     LD         R7,KEY_CB
                     LD         R1,KEY_R1
                     LD         R2,KEY_R2
                     RET        

_VALID_CHAR          AND        R2,R2,#0

                     LD         R1,key_PRINTABLE
                     ADD        R1,R1,R0
                     BRzp       _V_CH_cleanup

                     LD         R1,key_ESC
                     ADD        R1,R1,R0
                     BRz        _V_CH_cleanup

                     LD         R1,key_BKSPC
                     ADD        R1,R1,R0
                     BRn        _V_CH_badchar

                     LD         R1,key_NL
                     ADD        R1,R1,R0
                     BRnz       _V_CH_cleanup

_V_CH_badchar        ADD        R2,R2,#1
_V_CH_cleanup        RET        

key_BKSPC            .FILL      #-8
key_ESC              .FILL      #-27
key_NL               .FILL      #-10
key_PRINTABLE        .FILL      #-32
KEY_CB               .BLKW      1
KEY_R1               .BLKW      1
KEY_R2               .BLKW      1
INPUT
                     JSR        _INPUT
                     JSR        PUSH_R0
                     JSR        NEXT

_INPUT               ST         R7,INPUT_CB
                     LD         R1,var_BIN
                     BRz        _KEY
                     LDR        R0,R1,#0

                     LD         R2,var_KEYECHO
                     BRz        INPUT_noecho
                     OUT        
INPUT_noecho         ADD        R1,R1,#1

                     ST         R1,var_BIN

INPUT_cleanup        LD         R7,INPUT_CB
                     RET        

INPUT_CB             .BLKW      1
PARSE
                     JSR        POP_R2
                     LD         R3,var_BIN
                     JSR        _PARSE
                     JSR        PUSH_R0
                     JSR        PUSH_R1
                     JSR        NEXT

_PARSE               AND        R1,R1,#0
                     NOT        R2,R2
                     ADD        R2,R2,#1
                     ST         R2,_PARSE_delim

_PARSE_loop          LDR        R0,R3,#0
                     ADD        R3,R3,#1
                     LD         R2,_PARSE_delim
                     ADD        R2,R2,R0
                     BRz        _PARSE_done
                     LD         R2,key_NL
                     ADD        R2,R2,R0
                     BRz        _PARSE_done
                     ADD        R1,R1,#1
_PARSE_noecho        BRnzp      _PARSE_loop

_PARSE_done          LD         R0,var_BIN
                     ST         R3,var_BIN
                     RET        

_PARSE_delim         .BLKW      1
KEYECHO
                     LEA        R0,var_KEYECHO
                     JSR        PUSH_R0
                     JSR        NEXT
var_KEYECHO          .FILL      #1
BIN
                     LEA        R0,var_BIN
                     JSR        PUSH_R0
                     JSR        NEXT
var_BIN              .FILL      #0
EMIT
                     JSR        POP_R0
                     OUT        
                     JSR        NEXT
EMITS
                     JSR        POP_R0
                     PUTS       
                     JSR        NEXT
BYE
                     HALT       
                     JSR        NEXT
EXIT
                     JSR        POPRSP_R6
                     JSR        NEXT
LIT
                     LDR        R0,R6,#0
                     ADD        R6,R6,#1
                     JSR        PUSH_R0
                     JSR        NEXT
LIT_XT
                     JSR        LIT
LITSTRING
                     LDR        R0,R6,#0
                     ADD        R6,R6,#1
                     AND        R1,R6,R6
                     ADD        R6,R6,R0
                     JSR        PUSH_R1
                     JSR        PUSH_R0
                     JSR        NEXT
WORD
                     JSR        _WORD
                     JSR        PUSH_R2
                     JSR        PUSH_R1
                     JSR        NEXT

_WORD                ST         R7,WORD_CB

_WORD_start          JSR        _INPUT

                     LD         R1,c_NEW_LINE
                     ADD        R2,R1,R0
                     BRnp       _WORD_skip_NL
                     NOT        R0,R1
                     ADD        R0,R0,#1
                     OUT        

_WORD_skip_NL        LEA        R3,_WORD_start
                     JSR        _WORD_check_white

                     LD         R1,WORD_buffbot
                     STR        R0,R1,#0
                     ADD        R1,R1,#1
                     ST         R1,WORD_buffptr

_WORD_search         JSR        _INPUT
                     LEA        R3,_WORD_cleanup
                     JSR        _WORD_check_white
                     LD         R1,WORD_buffptr
                     STR        R0,R1,#0
                     ADD        R1,R1,#1
                     ST         R1,WORD_buffptr
                     BRnzp      _WORD_search

_WORD_cleanup        LD         R2,WORD_buffbot
                     LD         R1,WORD_buffptr
                     NOT        R3,R2
                     ADD        R3,R3,#1
                     ADD        R1,R1,R3
                     LD         R7,WORD_CB
                     RET        

_WORD_check_white    LD         R1,c_TAB
                     ADD        R2,R1,R0
                     BRz        _WORD_check_white_l

                     LD         R1,c_SPACE
                     ADD        R2,R1,R0
                     BRz        _WORD_check_white_l

                     LD         R1,c_NEW_LINE
                     ADD        R2,R1,R0
                     BRz        _WORD_check_white_l

                     RET        

_WORD_check_white_l  JMP        R3

c_BACKSLASH          .FILL      #-92
c_TAB                .FILL      #-9
c_NEW_LINE           .FILL      #-10
c_SPACE              .FILL      #-32

WORD_CB              .BLKW      1
WORD_buffptr         .FILL      WORD_BUFFER
WORD_buffbot         .FILL      WORD_BUFFER
NUMBER
                     JSR        POP_R0
                     JSR        POP_R1
                     JSR        _NUMBER
                     JSR        PUSH_R2
                     JSR        PUSH_R0
                     JSR        NEXT

_NUMBER              ST         R7,NUMBER_CB

                     AND        R2,R2,#0
                     ST         R2,NUMBER_retval
                     AND        R0,R0,R0
                     BRnz       _NUMBER_return

                     LDR        R2,R1,#0
                     ADD        R1,R1,#1

                     LD         R3,CHAR_neg_sign
                     ADD        R3,R3,R2
                     ST         R3,NUMBER_sign
                     BRp        _NUMBER_process
                     ADD        R0,R0,#-1
                     BRp        _NUMBER_loop
                     ADD        R0,R0,#1
                     LD         R7,NUMBER_CB
                     LD         R2,NUMBER_retval
                     RET        

_NUMBER_loop         LD         R3,var_BASE
                     LD         R2,NUMBER_retval
                     ST         R0,NUMBER_length
                     AND        R0,R0,#0
_NUMBER_mult         ADD        R0,R0,R2
                     ADD        R3,R3,#-1
                     BRp        _NUMBER_mult
                     ST         R0,NUMBER_retval
                     LD         R0,NUMBER_length

                     LDR        R2,R1,#0
                     ADD        R1,R1,#1



_NUMBER_process      LD         R3,CHAR_zero
                     ADD        R3,R3,R2
                     BRn        _NUMBER_cleanup
                     ADD        R2,R3,#-10
                     BRn        _NUMBER_save
                     LD         R2,CHAR_subA
                     ADD        R3,R3,R2
                     BRn        _NUMBER_cleanup
                     ADD        R3,R3,#10

_NUMBER_save         LD         R2,var_BASE
                     NOT        R2,R2
                     ADD        R2,R2,#1
                     ADD        R2,R2,R3
                     BRzp       _NUMBER_cleanup


                     LD         R2,NUMBER_retval
                     ADD        R2,R2,R3
                     ST         R2,NUMBER_retval
                     ADD        R0,R0,#-1
                     BRp        _NUMBER_loop

_NUMBER_cleanup      LD         R2,NUMBER_retval
                     LD         R3,NUMBER_sign
                     BRnp       _NUMBER_return
                     NOT        R2,R2
                     ADD        R2,R2,#1

_NUMBER_return       AND        R3,R3,#0
                     ST         R3,NUMBER_sign
                     LD         R7,NUMBER_CB
                     RET        

NUMBER_CB            .BLKW      1
NUMBER_retval        .BLKW      1
NUMBER_sign          .FILL      #0
NUMBER_length        .BLKW      1
CHAR_zero            .FILL      #-48
CHAR_neg_sign        .FILL      #-45
CHAR_subA            .FILL      #-17
FIND
                     JSR        POP_R0
                     JSR        POP_R1
                     JSR        _FIND
                     JSR        PUSH_R2
                     JSR        NEXT

_FIND                ST         R7,FIND_CB
                     ST         R6,FIND_R6
                     ST         R5,FIND_R5
                     ST         R4,FIND_R4

                     LD         R2,var_LATEST

_FIND_loop           AND        R2,R2,R2
                     BRz        _FIND_fail

                     LDR        R3,R2,#1

                     LD         R4,F_HIDDEN
                     AND        R4,R4,R3
                     BRnp       _FIND_backtrack
                     LD         R4,F_LENMASK
                     AND        R4,R4,R3
                     NOT        R5,R4
                     ADD        R5,R5,#1
                     ADD        R5,R5,R0
                     BRnp       _FIND_backtrack

                     ST         R1,FIND_base
                     AND        R5,R2,R2
                     ADD        R5,R5,#2


_FIND_comp_loop      LDR        R6,R1,#0
                     LDR        R3,R5,#0
                     NOT        R3,R3
                     ADD        R3,R3,#1
                     ADD        R3,R3,R6
                     BRnp       _FIND_comp_fail
                     ADD        R1,R1,#1
                     ADD        R5,R5,#1
                     ADD        R4,R4,#-1
                     BRp        _FIND_comp_loop

                     BRnz       _FIND_end

_FIND_comp_fail      LD         R1,FIND_base

_FIND_backtrack      LDR        R2,R2,#0
                     BRnzp      _FIND_loop

_FIND_fail           AND        R3,R3,#0

_FIND_end            LD         R7,FIND_CB
                     LD         R6,FIND_R6
                     LD         R5,FIND_R5
                     LD         R4,FIND_R4
                     RET        

FIND_CB              .BLKW      1
FIND_R6              .BLKW      1
FIND_R5              .BLKW      1
FIND_R4              .BLKW      1
FIND_base            .BLKW      1
TXT
                     JSR        POP_R0
                     JSR        _TXT
                     JSR        PUSH_R0
                     JSR        NEXT

_TXT                 ADD        R0,R0,#1
                     LDR        R1,R0,#0
                     LD         R2,F_LENMASK
                     AND        R1,R1,R2
                     ADD        R0,R0,#2
                     ADD        R0,R0,R1
                     RET        
TCODE
                     JSR        POP_R0
_TCODE               JSR        _TXT
                     ADD        R0,R0,#1
                     JSR        PUSH_R0
                     JSR        NEXT
TBODY
                     JSR        POP_R0
_TBODY               JSR        _TXT
                     ADD        R0,R0,#2
                     JSR        PUSH_R0
                     JSR        NEXT
PARSE_ERROR
                     LEA        R0,const_PARSE_ERROR
                     JSR        PUSH_R0
                     JSR        NEXT
const_PARSE_ERROR    .STRINGZ   "\nUNKNOWN WORD"
EXECUTE
                     JSR        POP_R3
                     LDR        R2,R3,#0
                     JMP        R2
_F_IMMED
                     LD         R0,F_IMMED
                     JSR        PUSH_R0
                     JSR        NEXT
F_IMMED              .FILL      x80
_F_HIDDEN
                     LD         R0,F_HIDDEN
                     JSR        PUSH_R0
                     JSR        NEXT
F_HIDDEN             .FILL      x20
_F_LENMASK
                     LD         R0,F_LENMASK
                     JSR        PUSH_R0
                     JSR        NEXT
F_LENMASK            .FILL      x1f
_HEADER
                     JSR        _WORD
                     LD         R0,var_DP
                     LD         R3,var_LATEST
                     STR        R3,R0,#0
                     ADD        R0,R0,#1
                     STR        R1,R0,#0
                     ADD        R0,R0,#1

_CREATE_copy_loop    LDR        R3,R2,#0
                     STR        R3,R0,#0
                     ADD        R0,R0,#1
                     ADD        R2,R2,#1
                     ADD        R1,R1,#-1
                     BRp        _CREATE_copy_loop

                     STR        R1,R0,#0
                     ADD        R0,R0,#1

                     LD         R1,var_DP
                     ST         R1,var_LATEST
                     ST         R0,var_DP
                     JSR        NEXT
COMMA
                     JSR        POP_R0
                     JSR        _COMMA
                     JSR        NEXT

_COMMA               LD         R1,var_DP
                     STR        R0,R1,#0
                     ADD        R1,R1,#1
                     ST         R1,var_DP
                     RET        
LBRAC
                     AND        R0,R0,#0
                     ST         R0,var_STATE
                     JSR        NEXT
RBRAC
                     AND        R0,R0,#0
                     ADD        R0,R0,#-1
                     ST         R0,var_STATE
                     JSR        NEXT
STATE
                     LEA        R0,var_STATE
                     JSR        PUSH_R0
                     JSR        NEXT
var_STATE            .BLKW      1
BASE
                     LEA        R0,var_BASE
                     JSR        PUSH_R0
                     JSR        NEXT
var_BASE             .FILL      #10
QP
                     LEA        R0,var_QP
                     JSR        PUSH_R0
                     JSR        NEXT
var_QP               .FILL      code_BOOT
HERE
                     LD         R0,var_DP
                     JSR        PUSH_R0
                     JSR        NEXT
DP
                     LEA        R0,var_DP
                     JSR        PUSH_R0
                     JSR        NEXT
var_DP               .FILL      USER_DATA
LATEST
                     LEA        R0,var_LATEST
                     JSR        PUSH_R0
                     JSR        NEXT
var_LATEST           .FILL      name_LATEST

; <-- Other subroutines
NEXT					AND			R3,R6,R6				; Set R3 equal to R6
						ADD			R6,R6,#1				; Increment R6 (now points at next instruction)
						LDR			R3,R3,#0				; Load data at address -- this holds the next codeword
						LDR			R2,R3,#0				; Load address pointed to by next codeword
						JMP			R2						; Jump to that address
; -->						
				
; <-- POP subroutines
POP_R0					LD			R0,STACK_START
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R0,R4,#0				; Store the stack item in R0
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R0,R0,R0				; Make the nzp bits match
						RET

POP_R1					LD			R1,STACK_START
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R1,R1,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R1,R4,#0				; Store the stack item in R1
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R1,R1,R1				; Make the nzp bits match
						RET

POP_R2					LD			R2,STACK_START
						NOT			R2,R2
						ADD			R2,R2,#1
						ADD			R2,R2,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R2,R4,#0				; Store the stack item in R2
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R2,R2,R2				; Make the nzp bits match
						RET

POP_R3					LD			R3,STACK_START
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R3,R4,#0				; Store the stack item in R2
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R3,R3,R3				; Make the nzp bits match
						RET

POPRSP_R3				LD			R3,RETURN_STACK_START
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R5				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R3,R5,#0				; Store the stack item in R3
						ADD			R5,R5,#-1				; Shrink the stack
						AND			R3,R3,R3				; Make the nzp bits match
						RET
						
POPRSP_R6				LD			R6,RETURN_STACK_START
						NOT			R6,R6
						ADD			R6,R6,#1
						ADD			R6,R6,R5				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R6,R5,#0				; Store the stack item in R3
						ADD			R5,R5,#-1				; Shrink the stack
						RET
						
RETURN_STACK_START		.FILL		RETURN_STACK
STACK_START				.FILL		DATA_STACK
; END POP -->

; <-- PUSH subroutines
PUSH_R0					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R0,R4,#0				; Store in the stack
						RET
				
PUSH_R1					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R1,R4,#0				; Store in the stack
						RET
				
PUSH_R2					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R2,R4,#0				; Store in the stack
						RET

PUSH_R3					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R3,R4,#0				; Store in the stack
						RET
			
PUSHRSP_R3				ADD			R5,R5,#1				; Incrememt return stack pointer
						STR			R3,R5,#0				; Store in the stack
						RET
			
PUSHRSP_R6				ADD			R5,R5,#1				; Incrememt return stack pointer
						STR			R6,R5,#0				; Store in the stack
						RET
; END PUSH -->

EMPTY_STACK				LEA			R0,EMPTY_STACK_ERR
						ST			R7,EMPTY_STACK_RET
						PUTS
						AND			R2,R2,#0
						STI			R2,EMPTY_STACK_KEYSOURCE
						LD			R0,ABORT_addr
						JMP			R0

ABORT_addr				.FILL		RESET
EMPTY_STACK_KEYSOURCE	.FILL		var_BIN
EMPTY_STACK_ERR			.STRINGZ	"\nStack underflow! "

EMPTY_STACK_RET			.BLKW		1

WORD_BUFFER				.BLKW		32

RETURN_STACK			.BLKW		64

DATA_STACK				.BLKW		512

name_END_OF_DICT     .FILL      #0
name__DOCOL          .FILL      name_END_OF_DICT
                     .FILL      #5
                     .STRINGZ   "DOCOL"
code__DOCOL          .FILL      _DOCOL
name__DODAT          .FILL      name__DOCOL
                     .FILL      #5
                     .STRINGZ   "DODAT"
code__DODAT          .FILL      _DODAT
name_RZ              .FILL      name__DODAT
                     .FILL      #2
                     .STRINGZ   "R0"
code_RZ              .FILL      RZ
name_SZ              .FILL      name_RZ
                     .FILL      #2
                     .STRINGZ   "S0"
code_SZ              .FILL      SZ
name_FILELOC         .FILL      name_SZ
                     .FILL      #7
                     .STRINGZ   "FILELOC"
code_FILELOC         .FILL      FILELOC
name_DROP            .FILL      name_FILELOC
                     .FILL      #4
                     .STRINGZ   "DROP"
code_DROP            .FILL      DROP
name_SWAP            .FILL      name_DROP
                     .FILL      #4
                     .STRINGZ   "SWAP"
code_SWAP            .FILL      SWAP
name_DUP             .FILL      name_SWAP
                     .FILL      #3
                     .STRINGZ   "DUP"
code_DUP             .FILL      DUP
name_QDUP            .FILL      name_DUP
                     .FILL      #4
                     .STRINGZ   "?DUP"
code_QDUP            .FILL      QDUP
name_OVER            .FILL      name_QDUP
                     .FILL      #4
                     .STRINGZ   "OVER"
code_OVER            .FILL      OVER
name_ROT             .FILL      name_OVER
                     .FILL      #3
                     .STRINGZ   "ROT"
code_ROT             .FILL      ROT
name_NROT            .FILL      name_ROT
                     .FILL      #4
                     .STRINGZ   "-ROT"
code_NROT            .FILL      NROT
name_TOR             .FILL      name_NROT
                     .FILL      #2
                     .STRINGZ   ">R"
code_TOR             .FILL      TOR
name_FROMR           .FILL      name_TOR
                     .FILL      #2
                     .STRINGZ   "R>"
code_FROMR           .FILL      FROMR
name_DFROMR          .FILL      name_FROMR
                     .FILL      #3
                     .STRINGZ   "2R>"
code_DFROMR          .FILL      DFROMR
name_DTOR            .FILL      name_DFROMR
                     .FILL      #3
                     .STRINGZ   "2>R"
code_DTOR            .FILL      DTOR
name_RFETCH          .FILL      name_DTOR
                     .FILL      #2
                     .STRINGZ   "R@"
code_RFETCH          .FILL      RFETCH
name_RDROP           .FILL      name_RFETCH
                     .FILL      #5
                     .STRINGZ   "RDROP"
code_RDROP           .FILL      RDROP
name_STORE           .FILL      name_RDROP
                     .FILL      #1
                     .STRINGZ   "!"
code_STORE           .FILL      STORE
name_FETCH           .FILL      name_STORE
                     .FILL      #1
                     .STRINGZ   "@"
code_FETCH           .FILL      FETCH
name_ADDSTORE        .FILL      name_FETCH
                     .FILL      #2
                     .STRINGZ   "+!"
code_ADDSTORE        .FILL      ADDSTORE
name_SUBSTORE        .FILL      name_ADDSTORE
                     .FILL      #2
                     .STRINGZ   "-!"
code_SUBSTORE        .FILL      SUBSTORE
name_RSPFETCH        .FILL      name_SUBSTORE
                     .FILL      #4
                     .STRINGZ   "RSP@"
code_RSPFETCH        .FILL      RSPFETCH
name_RSPSTORE        .FILL      name_RSPFETCH
                     .FILL      #4
                     .STRINGZ   "RSP!"
code_RSPSTORE        .FILL      RSPSTORE
name_DSPFETCH        .FILL      name_RSPSTORE
                     .FILL      #4
                     .STRINGZ   "DSP@"
code_DSPFETCH        .FILL      DSPFETCH
name_DSPSTORE        .FILL      name_DSPFETCH
                     .FILL      #4
                     .STRINGZ   "DSP!"
code_DSPSTORE        .FILL      DSPSTORE
name_ANDF            .FILL      name_DSPSTORE
                     .FILL      #3
                     .STRINGZ   "AND"
code_ANDF            .FILL      ANDF
name_OR              .FILL      name_ANDF
                     .FILL      #2
                     .STRINGZ   "OR"
code_OR              .FILL      OR
name_INVERT          .FILL      name_OR
                     .FILL      #6
                     .STRINGZ   "INVERT"
code_INVERT          .FILL      INVERT
name_NOR             .FILL      name_INVERT
                     .FILL      #3
                     .STRINGZ   "NOR"
code_NOR             .FILL      DOCOL
                     .FILL      code_OR
                     .FILL      code_INVERT
                     .FILL      code_EXIT
name_NAND            .FILL      name_NOR
                     .FILL      #4
                     .STRINGZ   "NAND"
code_NAND            .FILL      DOCOL
                     .FILL      code_ANDF
                     .FILL      code_INVERT
                     .FILL      code_EXIT
name_XOR             .FILL      name_NAND
                     .FILL      #3
                     .STRINGZ   "XOR"
code_XOR             .FILL      DOCOL
                     .FILL      code_OVER
                     .FILL      code_OVER
                     .FILL      code_OR
                     .FILL      code_NROT
                     .FILL      code_NAND
                     .FILL      code_ANDF
                     .FILL      code_EXIT
name_XNOR            .FILL      name_XOR
                     .FILL      #4
                     .STRINGZ   "XNOR"
code_XNOR            .FILL      DOCOL
                     .FILL      code_XOR
                     .FILL      code_INVERT
                     .FILL      code_EXIT
name_EQUAL           .FILL      name_XNOR
                     .FILL      #1
                     .STRINGZ   "="
code_EQUAL           .FILL      EQUAL
name_NEQUAL          .FILL      name_EQUAL
                     .FILL      #2
                     .STRINGZ   "<>"
code_NEQUAL          .FILL      NEQUAL
name_LT              .FILL      name_NEQUAL
                     .FILL      #1
                     .STRINGZ   "<"
code_LT              .FILL      LT
name_GT              .FILL      name_LT
                     .FILL      #1
                     .STRINGZ   ">"
code_GT              .FILL      GT
name_LTE             .FILL      name_GT
                     .FILL      #2
                     .STRINGZ   "<="
code_LTE             .FILL      LTE
name_GTE             .FILL      name_LTE
                     .FILL      #2
                     .STRINGZ   ">="
code_GTE             .FILL      GTE
name_ZEQUAL          .FILL      name_GTE
                     .FILL      #2
                     .STRINGZ   "0="
code_ZEQUAL          .FILL      ZEQUAL
name_ZNEQUAL         .FILL      name_ZEQUAL
                     .FILL      #3
                     .STRINGZ   "0<>"
code_ZNEQUAL         .FILL      ZNEQUAL
name_ZLT             .FILL      name_ZNEQUAL
                     .FILL      #2
                     .STRINGZ   "0<"
code_ZLT             .FILL      ZLT
name_ZGT             .FILL      name_ZLT
                     .FILL      #2
                     .STRINGZ   "0>"
code_ZGT             .FILL      ZGT
name_ZLTE            .FILL      name_ZGT
                     .FILL      #3
                     .STRINGZ   "0<="
code_ZLTE            .FILL      ZLTE
name_ZGTE            .FILL      name_ZLTE
                     .FILL      #3
                     .STRINGZ   "0>="
code_ZGTE            .FILL      ZGTE
name_INCR            .FILL      name_ZGTE
                     .FILL      #2
                     .STRINGZ   "1+"
code_INCR            .FILL      INCR
name_DECR            .FILL      name_INCR
                     .FILL      #2
                     .STRINGZ   "1-"
code_DECR            .FILL      DECR
name_ADDF            .FILL      name_DECR
                     .FILL      #1
                     .STRINGZ   "+"
code_ADDF            .FILL      ADDF
name_SUBTRACT        .FILL      name_ADDF
                     .FILL      #1
                     .STRINGZ   "-"
code_SUBTRACT        .FILL      SUBTRACT
name_MULT            .FILL      name_SUBTRACT
                     .FILL      #1
                     .STRINGZ   "*"
code_MULT            .FILL      MULT
name_DIVMOD          .FILL      name_MULT
                     .FILL      #4
                     .STRINGZ   "/MOD"
code_DIVMOD          .FILL      DIVMOD
name_BRANCH          .FILL      name_DIVMOD
                     .FILL      #6
                     .STRINGZ   "BRANCH"
code_BRANCH          .FILL      BRANCH
name_ZBRANCH         .FILL      name_BRANCH
                     .FILL      #7
                     .STRINGZ   "0BRANCH"
code_ZBRANCH         .FILL      ZBRANCH
name_QDO             .FILL      name_ZBRANCH
                     .FILL      #5
                     .STRINGZ   "(?DO)"
code_QDO             .FILL      QDO
name_DO              .FILL      name_QDO
                     .FILL      #4
                     .STRINGZ   "(DO)"
code_DO              .FILL      DO
name_LEAVE           .FILL      name_DO
                     .FILL      #7
                     .STRINGZ   "(LEAVE)"
code_LEAVE           .FILL      LEAVE
name_LOOP            .FILL      name_LEAVE
                     .FILL      #6
                     .STRINGZ   "(LOOP)"
code_LOOP            .FILL      LOOP
name_pLOOP           .FILL      name_LOOP
                     .FILL      #7
                     .STRINGZ   "(+LOOP)"
code_pLOOP           .FILL      pLOOP
name_I               .FILL      name_pLOOP
                     .FILL      #1
                     .STRINGZ   "I"
code_I               .FILL      I
name_J               .FILL      name_I
                     .FILL      #1
                     .STRINGZ   "J"
code_J               .FILL      J
name_UNLOOP          .FILL      name_J
                     .FILL      #6
                     .STRINGZ   "UNLOOP"
code_UNLOOP          .FILL      UNLOOP
name_KEY             .FILL      name_UNLOOP
                     .FILL      #3
                     .STRINGZ   "KEY"
code_KEY             .FILL      KEY
name_INPUT           .FILL      name_KEY
                     .FILL      #5
                     .STRINGZ   "INPUT"
code_INPUT           .FILL      INPUT
name_PARSE           .FILL      name_INPUT
                     .FILL      #5
                     .STRINGZ   "PARSE"
code_PARSE           .FILL      PARSE
name_KEYECHO         .FILL      name_PARSE
                     .FILL      #7
                     .STRINGZ   "KEYECHO"
code_KEYECHO         .FILL      KEYECHO
name_BIN             .FILL      name_KEYECHO
                     .FILL      #3
                     .STRINGZ   ">IN"
code_BIN             .FILL      BIN
name_EMIT            .FILL      name_BIN
                     .FILL      #4
                     .STRINGZ   "EMIT"
code_EMIT            .FILL      EMIT
name_EMITS           .FILL      name_EMIT
                     .FILL      #5
                     .STRINGZ   "EMITS"
code_EMITS           .FILL      EMITS
name_BYE             .FILL      name_EMITS
                     .FILL      #3
                     .STRINGZ   "BYE"
code_BYE             .FILL      BYE
name_EXIT            .FILL      name_BYE
                     .FILL      #4
                     .STRINGZ   "EXIT"
code_EXIT            .FILL      EXIT
name_LIT             .FILL      name_EXIT
                     .FILL      #3
                     .STRINGZ   "LIT"
code_LIT             .FILL      LIT
name_LIT_XT          .FILL      name_LIT
                     .FILL      #6
                     .STRINGZ   "LIT_XT"
code_LIT_XT          .FILL      LIT_XT
name_LITSTRING       .FILL      name_LIT_XT
                     .FILL      #9
                     .STRINGZ   "LITSTRING"
code_LITSTRING       .FILL      LITSTRING
name_WORD            .FILL      name_LITSTRING
                     .FILL      #4
                     .STRINGZ   "WORD"
code_WORD            .FILL      WORD
name_NUMBER          .FILL      name_WORD
                     .FILL      #6
                     .STRINGZ   "NUMBER"
code_NUMBER          .FILL      NUMBER
name_FIND            .FILL      name_NUMBER
                     .FILL      #4
                     .STRINGZ   "FIND"
code_FIND            .FILL      FIND
name_TXT             .FILL      name_FIND
                     .FILL      #3
                     .STRINGZ   ">XT"
code_TXT             .FILL      TXT
name_TCODE           .FILL      name_TXT
                     .FILL      #5
                     .STRINGZ   ">CODE"
code_TCODE           .FILL      TCODE
name_TBODY           .FILL      name_TCODE
                     .FILL      #5
                     .STRINGZ   ">BODY"
code_TBODY           .FILL      TBODY
name_PARSE_ERROR     .FILL      name_TBODY
                     .FILL      #11
                     .STRINGZ   "PARSE_ERROR"
code_PARSE_ERROR     .FILL      PARSE_ERROR
name_EXECUTE         .FILL      name_PARSE_ERROR
                     .FILL      #7
                     .STRINGZ   "EXECUTE"
code_EXECUTE         .FILL      EXECUTE
name__F_IMMED        .FILL      name_EXECUTE
                     .FILL      #7
                     .STRINGZ   "F_IMMED"
code__F_IMMED        .FILL      _F_IMMED
name__F_HIDDEN       .FILL      name__F_IMMED
                     .FILL      #8
                     .STRINGZ   "F_HIDDEN"
code__F_HIDDEN       .FILL      _F_HIDDEN
name__F_LENMASK      .FILL      name__F_HIDDEN
                     .FILL      #9
                     .STRINGZ   "F_LENMASK"
code__F_LENMASK      .FILL      _F_LENMASK
name__HEADER         .FILL      name__F_LENMASK
                     .FILL      #6
                     .STRINGZ   "HEADER"
code__HEADER         .FILL      _HEADER
name_COMMA           .FILL      name__HEADER
                     .FILL      #1
                     .STRINGZ   ","
code_COMMA           .FILL      COMMA
name_LBRAC           .FILL      name_COMMA
                     .FILL      #129
                     .STRINGZ   "["
code_LBRAC           .FILL      LBRAC
name_RBRAC           .FILL      name_LBRAC
                     .FILL      #1
                     .STRINGZ   "]"
code_RBRAC           .FILL      RBRAC
name_STATE           .FILL      name_RBRAC
                     .FILL      #5
                     .STRINGZ   "STATE"
code_STATE           .FILL      STATE
name_BASE            .FILL      name_STATE
                     .FILL      #4
                     .STRINGZ   "BASE"
code_BASE            .FILL      BASE
name_QP              .FILL      name_BASE
                     .FILL      #2
                     .STRINGZ   "QP"
code_QP              .FILL      QP
name_HERE            .FILL      name_QP
                     .FILL      #4
                     .STRINGZ   "HERE"
code_HERE            .FILL      HERE
name_DP              .FILL      name_HERE
                     .FILL      #2
                     .STRINGZ   "DP"
code_DP              .FILL      DP
name_whac            .FILL      name_DP
                     .FILL      #129
                     .STRINGZ   "\\"
code_whac            .FILL      DOCOL
                     .FILL      code_LIT
                     .FILL      #10
                     .FILL      code_PARSE
                     .FILL      code_DROP
                     .FILL      code_DROP
                     .FILL      code_EXIT
name_colo            .FILL      name_whac
                     .FILL      #1
                     .STRINGZ   ":"
code_colo            .FILL      DOCOL
                     .FILL      code__HEADER
                     .FILL      code__DOCOL
                     .FILL      code_COMMA
                     .FILL      code_LATEST
                     .FILL      code_FETCH
                     .FILL      code_HIDDEN
                     .FILL      code_RBRAC
                     .FILL      code_EXIT
name_semi            .FILL      name_colo
                     .FILL      #129
                     .STRINGZ   ";"
code_semi            .FILL      DOCOL
                     .FILL      code_LBRAC
                     .FILL      code_LIT_XT
                     .FILL      code_EXIT
                     .FILL      code_COMMA
                     .FILL      code_LATEST
                     .FILL      code_FETCH
                     .FILL      code_HIDDEN
                     .FILL      code_EXIT
name_HIDDEN          .FILL      name_semi
                     .FILL      #6
                     .STRINGZ   "HIDDEN"
code_HIDDEN          .FILL      DOCOL
                     .FILL      code_INCR
                     .FILL      code_DUP
                     .FILL      code_FETCH
                     .FILL      code__F_HIDDEN
                     .FILL      code_XOR
                     .FILL      code_SWAP
                     .FILL      code_STORE
                     .FILL      code_EXIT
name_IMMEDIATE       .FILL      name_HIDDEN
                     .FILL      #137
                     .STRINGZ   "IMMEDIATE"
code_IMMEDIATE       .FILL      DOCOL
                     .FILL      code_LATEST
                     .FILL      code_FETCH
                     .FILL      code_INCR
                     .FILL      code_DUP
                     .FILL      code_FETCH
                     .FILL      code__F_IMMED
                     .FILL      code_XOR
                     .FILL      code_SWAP
                     .FILL      code_STORE
                     .FILL      code_EXIT
name_HIDDENques      .FILL      name_IMMEDIATE
                     .FILL      #7
                     .STRINGZ   "HIDDEN?"
code_HIDDENques      .FILL      DOCOL
                     .FILL      code_INCR
                     .FILL      code_FETCH
                     .FILL      code__F_HIDDEN
                     .FILL      code_ANDF
                     .FILL      code_EXIT
name_IMMEDIATEques   .FILL      name_HIDDENques
                     .FILL      #10
                     .STRINGZ   "IMMEDIATE?"
code_IMMEDIATEques   .FILL      DOCOL
                     .FILL      code_INCR
                     .FILL      code_FETCH
                     .FILL      code__F_IMMED
                     .FILL      code_ANDF
                     .FILL      code_EXIT
name_BOOT            .FILL      name_IMMEDIATEques
                     .FILL      #4
                     .STRINGZ   "BOOT"
code_BOOT            .FILL      DOCOL
                     .FILL      code_RZ
                     .FILL      code_RSPSTORE
                     .FILL      code_FILELOC
                     .FILL      code_BIN
                     .FILL      code_STORE
                     .FILL      code_INTERPRET
                     .FILL      code_BRANCH
                     .FILL      #-2
                     .FILL      code_EXIT
name_INTERPRET       .FILL      name_BOOT
                     .FILL      #9
                     .STRINGZ   "INTERPRET"
code_INTERPRET       .FILL      DOCOL
                     .FILL      code_WORD
                     .FILL      code_OVER
                     .FILL      code_OVER
                     .FILL      code_FIND
                     .FILL      code_QDUP
                     .FILL      code_ZBRANCH
                     .FILL      #21
                     .FILL      code_SWAP
                     .FILL      code_DROP
                     .FILL      code_SWAP
                     .FILL      code_DROP
                     .FILL      code_STATE
                     .FILL      code_FETCH
                     .FILL      code_ZBRANCH
                     .FILL      #5
                     .FILL      code_DUP
                     .FILL      code_IMMEDIATEques
                     .FILL      code_ZBRANCH
                     .FILL      #5
                     .FILL      code_TXT
                     .FILL      code_EXECUTE
                     .FILL      code_BRANCH
                     .FILL      #3
                     .FILL      code_TXT
                     .FILL      code_COMMA
                     .FILL      code_BRANCH
                     .FILL      #21
                     .FILL      code_NUMBER
                     .FILL      code_ZBRANCH
                     .FILL      #10
                     .FILL      code_DROP
                     .FILL      code_PARSE_ERROR
                     .FILL      code_EMITS
                     .FILL      code_LIT
                     .FILL      #0
                     .FILL      code_BIN
                     .FILL      code_STORE
                     .FILL      code_BRANCH
                     .FILL      #9
                     .FILL      code_STATE
                     .FILL      code_FETCH
                     .FILL      code_ZBRANCH
                     .FILL      #5
                     .FILL      code_LIT_XT
                     .FILL      code_LIT
                     .FILL      code_COMMA
                     .FILL      code_COMMA
                     .FILL      code_EXIT
name_LATEST          .FILL      name_INTERPRET
                     .FILL      #6
                     .STRINGZ   "LATEST"
code_LATEST          .FILL      LATEST

USER_DATA				.BLKW		1
						.END
