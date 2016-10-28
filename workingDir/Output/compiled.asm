						.ORIG		x3000
						
RESET					LD			R5,RET_STACK_ADDRESS
						LD			R4,DATA_STACK_ADDRESS
												
						LEA			R6,COLD_START			; R6 holds the address to the next address (%esi equivalent, IP)
						
						JSR			NEXT

RET_STACK_ADDRESS		.FILL		RETURN_STACK
DATA_STACK_ADDRESS		.FILL		DATA_STACK

COLD_START				.FILL		code_QUIT
						
DOCOL					JSR			PUSHRSP_R6
						ADD			R3,R3,#1				; DOCOL is called at codeword in definition, so increment R3 to reach next location
						AND			R6,R3,R3				; Then line them up. R6 and R3 now both point to the first real word
						JSR			NEXT

RZ
                     LD         R0,RET_STACK_ADDRESS
                     JSR        PUSH_R0
                     JSR        NEXT
_DOCOL
                     LEA        R0,DOCOL
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
                     JSR        POP_R0
                     JSR        POP_R1
                     JSR        PUSH_R0
                     JSR        PUSH_R1
                     JSR        NEXT
DUP
                     LDR        R0,R4,#0
                     JSR        PUSH_R0
                     JSR        NEXT
OVER
                     LDR        R0,R4,#-1
                     JSR        PUSH_R0
                     JSR        NEXT
ROT
                     JSR        POP_R0
                     JSR        POP_R1
                     JSR        POP_R2
                     JSR        PUSH_R1
                     JSR        PUSH_R0
                     JSR        PUSH_R2
                     JSR        NEXT
NROT
                     JSR        POP_R0
                     JSR        POP_R1
                     JSR        POP_R2
                     JSR        PUSH_R0
                     JSR        PUSH_R2
                     JSR        PUSH_R1
                     JSR        NEXT
QDUP
                     LDR        R0,R4,#0
                     BRz        QDUP_skip
                     JSR        PUSH_R0
QDUP_skip            JSR        NEXT
TOR
                     JSR        POP_R3
                     JSR        PUSHRSP_R3
                     JSR        NEXT
FROMR
                     JSR        POPRSP_R3
                     JSR        PUSH_R3
                     JSR        NEXT
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
                     LDR        R1,R4,#0
                     ADD        R0,R0,R1
                     STR        R0,R4,#0
                     JSR        NEXT
SUBTRACT
                     JSR        POP_R0
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     LDR        R1,R4,#0
                     ADD        R0,R0,R1
                     STR        R0,R4,#0
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
NOTF
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
                     BRnp       EQUAL_false
                     ADD        R0,R0,#1
                     BRnzp      EQUAL_finish
EQUAL_false          AND        R0,R0,#0
EQUAL_finish         JSR        PUSH_R0
                     JSR        NEXT
NEQUAL
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRz        NEQUAL_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      NEQUAL_finish
NEQUAL_false         AND        R0,R0,#0
NEQUAL_finish        JSR        PUSH_R0
                     JSR        NEXT
LT
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRzp       LT_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      LT_finish
LT_false             AND        R0,R0,#0
LT_finish            JSR        PUSH_R0
                     JSR        NEXT
GT
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRnz       GT_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      GT_finish
GT_false             AND        R0,R0,#0
GT_finish            JSR        PUSH_R0
                     JSR        NEXT
LTE
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRp        LTE_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      LTE_finish
LTE_false            AND        R0,R0,#0
LTE_finish           JSR        PUSH_R0
                     JSR        NEXT
GTE
                     JSR        POP_R0
                     JSR        POP_R1
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     ADD        R0,R0,R1
                     BRn        GTE_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      GTE_finish
GTE_false            AND        R0,R0,#0
GTE_finish           JSR        PUSH_R0
                     JSR        NEXT
ZEQUAL
                     JSR        POP_R0
                     BRnp       ZEQUAL_false
                     ADD        R0,R0,#1
                     BRnzp      ZEQUAL_finish
ZEQUAL_false         AND        R0,R0,#0
ZEQUAL_finish        JSR        PUSH_R0
                     JSR        NEXT
ZNEQUAL
                     JSR        POP_R0
                     BRz        ZNEQUAL_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      ZNEQUAL_finish
ZNEQUAL_false        AND        R0,R0,#0
ZNEQUAL_finish       JSR        PUSH_R0
                     JSR        NEXT
ZLT
                     JSR        POP_R0
                     BRzp       ZLT_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      ZLT_finish
ZLT_false            AND        R0,R0,#0
ZLT_finish           JSR        PUSH_R0
                     JSR        NEXT
ZGT
                     JSR        POP_R0
                     BRnz       ZGT_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      ZGT_finish
ZGT_false            AND        R0,R0,#0
ZGT_finish           JSR        PUSH_R0
                     JSR        NEXT
ZLTE
                     JSR        POP_R0
                     BRp        ZLTE_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      ZLTE_finish
ZLTE_false           AND        R0,R0,#0
ZLTE_finish          JSR        PUSH_R0
                     JSR        NEXT
ZGTE
                     JSR        POP_R0
                     BRn        ZGTE_false
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     BRnzp      ZGTE_finish
ZGTE_false           AND        R0,R0,#0
ZGTE_finish          JSR        PUSH_R0
                     JSR        NEXT
DIVMOD
                     JSR        POP_R2
                     JSR        POP_R1
                     JSR        _DIVIDE
                     JSR        PUSH_R1
                     JSR        PUSH_R0
                     JSR        NEXT

_DIVIDE              ST         R7,DIV_R7

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

DIV_CLEANUP          LD         R7,DIV_R7
                     RET        

DIV_ZERO_RETURN      AND        R0,R0,#0
                     AND        R1,R1,#0
                     BRnzp      DIV_CLEANUP

DIV_ZERO_ERROR       LEA        R0,DIV_ZERO_ERR_MSG
                     PUTS       
                     HALT       
DIV_ZERO_ERR_MSG     .STRINGZ   "ZERO DENOMINATOR\n"

DIV_R0               .BLKW      1
DIV_R1               .BLKW      1
DIV_R2               .BLKW      1
DIV_R7               .BLKW      1
DIV_SIGN             .BLKW      1

SIGN_LOGIC           ST         R7,SIGN_CALLBACK

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

SIGN_CLEANUP         LD         R7,SIGN_CALLBACK
                     RET        

SIGN_FLIP            NOT        R3,R3
                     ADD        R3,R3,#1
                     RET        

SIGN_CALLBACK        .BLKW      1
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
                     LDR        R0,R2,#0
                     ADD        R0,R0,R1
                     STR        R0,R2,#0
                     JSR        NEXT
SUBSTORE
                     JSR        POP_R2
                     JSR        POP_R1
                     NOT        R1,R1
                     ADD        R1,R1,#1
                     LDR        R0,R2,#0
                     ADD        R0,R0,R1
                     STR        R0,R2,#0
                     JSR        NEXT
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
RDROP
                     ADD        R5,R5,#-1
                     JSR        PUSHRSP_R3
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
KEY
                     JSR        _KEY
                     JSR        PUSH_R0
                     JSR        NEXT

_KEY                 ST         R7,KEY_CB

                     LD         R1,var_KEYSOURCE
                     BRz        KEY_board


                     LDR        R0,R1,#0
                     BRz        KEY_eof

                     OUT        

                     ADD        R1,R1,#1
                     ST         R1,var_KEYSOURCE
                     BRnzp      KEY_cleanup

KEY_eof              AND        R1,R1,#0
                     ST         R1,var_KEYSOURCE
                     LD         R0,key_NL
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     BRnzp      KEY_cleanup


KEY_board            GETC       

                     LD         R1,key_NL
                     ADD        R1,R1,R0
                     BRz        KEY_cleanup_NL

                     LD         R1,key_TAB
                     ADD        R1,R1,R0
                     BRz        KEY_out

                     LD         R1,key_PRINTABLE
                     ADD        R1,R1,R0
                     BRn        KEY_cleanup

KEY_out              OUT        

KEY_cleanup          LD         R7,KEY_CB
                     RET        

KEY_cleanup_NL       ST         R0,var_DELAYED_NL
                     LD         R0,key_SPACE
                     OUT        
                     LD         R0,var_DELAYED_NL
                     BRnzp      KEY_cleanup

KEY_CB               .BLKW      1
key_TAB              .FILL      #-9
key_NL               .FILL      #-10
key_PRINTABLE        .FILL      #-32
key_SPACE            .FILL      #32
DELAYED_NL
                     LEA        R0,var_DELAYED_NL
                     JSR        PUSH_R0
                     JSR        NEXT
var_DELAYED_NL       .FILL      #0
KEYSOURCE
                     LEA        R0,var_KEYSOURCE
                     JSR        PUSH_R0
                     JSR        NEXT
var_KEYSOURCE        .FILL      #0
EMIT
                     JSR        POP_R0
                     OUT        
                     JSR        NEXT
EMITS
                     JSR        POP_R0
                     PUTS       
                     JSR        NEXT
DOTB
                     JSR        POP_R1
                     AND        R3,R3,#0
                     ADD        R3,R3,#1

DOTB_loop            AND        R0,R1,R3
                     BRnp       DOTB_one
                     LD         R0,char_ZERO
                     JSR        PUSH_R0
                     BRnzp      DOTB_incr
DOTB_one             LD         R0,char_ZERO
                     ADD        R0,R0,#1
                     JSR        PUSH_R0
DOTB_incr            ADD        R3,R3,R3
                     BRnp       DOTB_loop

                     ADD        R3,R3,#15
DOTB_outloop         JSR        POP_R0
                     OUT        
                     ADD        R3,R3,#-1
                     BRzp       DOTB_outloop

                     JSR        NEXT
char_ZERO            .FILL      #48
EXIT
                     JSR        POPRSP_R6
                     JSR        NEXT
LIT
                     LDR        R0,R6,#0
                     ADD        R6,R6,#1
                     JSR        PUSH_R0
                     JSR        NEXT
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

_WORD_start          JSR        _KEY

                     LD         R1,c_NEW_LINE
                     ADD        R2,R1,R0
                     BRnp       _WORD_skip_NL
                     NOT        R0,R1
                     ADD        R0,R0,#1
                     OUT        
                     AND        R1,R1,#0
                     ST         R1,var_DELAYED_NL

_WORD_skip_NL        LD         R1,c_BACKSLASH
                     ADD        R2,R1,R0
                     BRz        _WORD_skip_comments

                     LEA        R3,_WORD_start
                     JSR        _WORD_check_white

                     LD         R1,WORD_buffbot
                     STR        R0,R1,#0
                     ADD        R1,R1,#1
                     ST         R1,WORD_buffptr

_WORD_search         JSR        _KEY
                     LEA        R3,_WORD_cleanup
                     JSR        _WORD_check_white
                     LD         R1,WORD_buffptr
                     STR        R0,R1,#0
                     ADD        R1,R1,#1
                     ST         R1,WORD_buffptr
                     BRnzp      _WORD_search

_WORD_cleanup        LD         R2,WORD_buffbot
                     LD         R1,WORD_buffptr
                     NOT        R2,R2
                     ADD        R2,R2,#1
                     ADD        R1,R1,R2
                     NOT        R2,R2
                     ADD        R2,R2,#1
                     LD         R7,WORD_CB
                     RET        

_WORD_skip_comments  JSR        _KEY
                     LD         R1,c_NEW_LINE
                     ADD        R2,R1,R0
                     BRnp       _WORD_skip_comments
                     BRzp       _WORD_start

_WORD_check_white    LD         R1,c_TAB
                     ADD        R2,R1,R0
                     BRz        _WORD_check_white_l

                     LD         R1,c_SPACE
                     ADD        R2,R1,R0
                     BRz        _WORD_check_white_l

                     LD         R1,c_NEW_LINE
                     ADD        R2,R1,R0
                     BRz        _WORD_check_white_l

                     LD         R1,c_ESC
                     ADD        R2,R1,R0
                     BRz        _WORD_restart

                     LD         R1,c_BACKSPACE
                     ADD        R2,R1,R0
                     BRz        _WORD_restart

                     RET        
_WORD_check_white_l  JMP        R3

_WORD_restart        LD         R0,char_BLOCK
                     OUT        
                     LD         R0,c_SPACE
                     NOT        R0,R0
                     ADD        R0,R0,#1
                     OUT        
                     BRnzp      _WORD_start

c_BACKSLASH          .FILL      #-92
c_TAB                .FILL      #-9
c_NEW_LINE           .FILL      #-10
c_SPACE              .FILL      #-32
c_BACKSPACE          .FILL      #-8
c_ESC                .FILL      #-27
char_BLOCK           .FILL      #149

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
                     NOT        R3,R3
                     ADD        R3,R3,#1
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
                     NOT        R3,R3
                     ADD        R3,R3,#1
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
CHAR_zero            .FILL      #48
CHAR_neg_sign        .FILL      #45
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
TCFA
                     JSR        POP_R0
                     JSR        _TCFA
                     JSR        PUSH_R0
                     JSR        NEXT

_TCFA                AND        R1,R1,#0
                     ADD        R0,R0,#1
                     LDR        R1,R0,#0
                     LD         R2,F_LENMASK
                     AND        R1,R1,R2
                     ADD        R0,R0,#2
                     ADD        R0,R0,R1
                     RET        
PARSE_ERROR
                     LEA        R0,const_PARSE_ERROR
                     JSR        PUSH_R0
                     JSR        NEXT
const_PARSE_ERROR    .STRINGZ   "\nUNKNOWN WORD\n"
EXECUTE
                     JSR        POP_R3
                     LDR        R2,R3,#0
                     JMP        R2
EXECUTE_target       .BLKW      1
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
CREATE
                     JSR        POP_R0
                     JSR        POP_R1
                     LD         R2,var_HERE
                     LD         R3,var_LATEST
                     STR        R3,R2,#0
                     ADD        R2,R2,#1
                     STR        R0,R2,#0
                     ADD        R2,R2,#1

_CREATE_copy_loop    LDR        R3,R1,#0
                     STR        R3,R2,#0
                     ADD        R2,R2,#1
                     ADD        R1,R1,#1
                     ADD        R0,R0,#-1
                     BRp        _CREATE_copy_loop

                     STR        R0,R2,#0
                     ADD        R2,R2,#1

                     LD         R0,var_HERE
                     ST         R0,var_LATEST
                     ST         R2,var_HERE
                     JSR        NEXT
COMMA
                     JSR        POP_R0
                     JSR        _COMMA
                     JSR        NEXT

_COMMA               LD         R1,var_HERE
                     STR        R0,R1,#0
                     ADD        R1,R1,#1
                     ST         R1,var_HERE
                     RET        
LBRAC
                     AND        R0,R0,#0
                     ST         R0,var_STATE
                     JSR        NEXT
RBRAC
                     AND        R0,R0,#0
                     ADD        R0,R0,#1
                     ST         R0,var_STATE
                     JSR        NEXT
TICK
                     LDR        R0,R6,#0
                     ADD        R6,R6,#1
                     JSR        PUSH_R0
                     JSR        NEXT
BRANCH
                     LDR        R0,R6,#0
                     ADD        R6,R6,R0
                     JSR        NEXT
ZBRANCH
                     JSR        POP_R0
                     BRz        BRANCH
                     ADD        R6,R6,#1
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
HERE
                     LEA        R0,var_HERE
                     JSR        PUSH_R0
                     JSR        NEXT
var_HERE             .FILL      USER_DATA
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
						JSR			PUSHRSP_R6
						PUTS
						JSR			RESET

EMPTY_STACK_ERR			.STRINGZ	"STACK UNDERFLOW!\n"

EMPTY_STACK_RET			.BLKW		1

WORD_BUFFER				.BLKW		32

RETURN_STACK			.BLKW		1024

DATA_STACK				.BLKW		1024

name_END_OF_DICT     .FILL      #0
name_RZ              .FILL      name_END_OF_DICT
                     .FILL      #2
                     .STRINGZ   "R0"
code_RZ              .FILL      RZ
name__DOCOL          .FILL      name_RZ
                     .FILL      #5
                     .STRINGZ   "DOCOL"
code__DOCOL          .FILL      _DOCOL
name_SZ              .FILL      name__DOCOL
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
name_OVER            .FILL      name_DUP
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
name_QDUP            .FILL      name_NROT
                     .FILL      #4
                     .STRINGZ   "?DUP"
code_QDUP            .FILL      QDUP
name_TOR             .FILL      name_QDUP
                     .FILL      #2
                     .STRINGZ   ">R"
code_TOR             .FILL      TOR
name_FROMR           .FILL      name_TOR
                     .FILL      #2
                     .STRINGZ   "R>"
code_FROMR           .FILL      FROMR
name_INCR            .FILL      name_FROMR
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
name_ANDF            .FILL      name_SUBTRACT
                     .FILL      #3
                     .STRINGZ   "AND"
code_ANDF            .FILL      ANDF
name_OR              .FILL      name_ANDF
                     .FILL      #2
                     .STRINGZ   "OR"
code_OR              .FILL      OR
name_NOTF            .FILL      name_OR
                     .FILL      #4
                     .STRINGZ   "NOTB"
code_NOTF            .FILL      NOTF
name_NOR             .FILL      name_NOTF
                     .FILL      #3
                     .STRINGZ   "NOR"
code_NOR             .FILL      DOCOL
                     .FILL      code_OR
                     .FILL      code_NOTF
                     .FILL      code_EXIT
name_NAND            .FILL      name_NOR
                     .FILL      #4
                     .STRINGZ   "NAND"
code_NAND            .FILL      DOCOL
                     .FILL      code_ANDF
                     .FILL      code_NOTF
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
                     .FILL      code_NOTF
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
name_DIVMOD          .FILL      name_ZGTE
                     .FILL      #4
                     .STRINGZ   "/MOD"
code_DIVMOD          .FILL      DIVMOD
name_STORE           .FILL      name_DIVMOD
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
name_RDROP           .FILL      name_RSPSTORE
                     .FILL      #5
                     .STRINGZ   "RDROP"
code_RDROP           .FILL      RDROP
name_DSPFETCH        .FILL      name_RDROP
                     .FILL      #4
                     .STRINGZ   "DSP@"
code_DSPFETCH        .FILL      DSPFETCH
name_DSPSTORE        .FILL      name_DSPFETCH
                     .FILL      #4
                     .STRINGZ   "DSP!"
code_DSPSTORE        .FILL      DSPSTORE
name_KEY             .FILL      name_DSPSTORE
                     .FILL      #3
                     .STRINGZ   "KEY"
code_KEY             .FILL      KEY
name_DELAYED_NL      .FILL      name_KEY
                     .FILL      #10
                     .STRINGZ   "DELAYED_NL"
code_DELAYED_NL      .FILL      DELAYED_NL
name_KEYSOURCE       .FILL      name_DELAYED_NL
                     .FILL      #9
                     .STRINGZ   "KEYSOURCE"
code_KEYSOURCE       .FILL      KEYSOURCE
name_EMIT            .FILL      name_KEYSOURCE
                     .FILL      #4
                     .STRINGZ   "EMIT"
code_EMIT            .FILL      EMIT
name_EMITS           .FILL      name_EMIT
                     .FILL      #5
                     .STRINGZ   "EMITS"
code_EMITS           .FILL      EMITS
name_DOTB            .FILL      name_EMITS
                     .FILL      #2
                     .STRINGZ   ".B"
code_DOTB            .FILL      DOTB
name_EXIT            .FILL      name_DOTB
                     .FILL      #4
                     .STRINGZ   "EXIT"
code_EXIT            .FILL      EXIT
name_LIT             .FILL      name_EXIT
                     .FILL      #3
                     .STRINGZ   "LIT"
code_LIT             .FILL      LIT
name_LITSTRING       .FILL      name_LIT
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
name_TCFA            .FILL      name_FIND
                     .FILL      #4
                     .STRINGZ   ">CFA"
code_TCFA            .FILL      TCFA
name_PARSE_ERROR     .FILL      name_TCFA
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
name_CREATE          .FILL      name__F_LENMASK
                     .FILL      #6
                     .STRINGZ   "CREATE"
code_CREATE          .FILL      CREATE
name_COMMA           .FILL      name_CREATE
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
name_TICK            .FILL      name_RBRAC
                     .FILL      #1
                     .STRINGZ   "'"
code_TICK            .FILL      TICK
name_BRANCH          .FILL      name_TICK
                     .FILL      #6
                     .STRINGZ   "BRANCH"
code_BRANCH          .FILL      BRANCH
name_ZBRANCH         .FILL      name_BRANCH
                     .FILL      #7
                     .STRINGZ   "0BRANCH"
code_ZBRANCH         .FILL      ZBRANCH
name_STATE           .FILL      name_ZBRANCH
                     .FILL      #5
                     .STRINGZ   "STATE"
code_STATE           .FILL      STATE
name_BASE            .FILL      name_STATE
                     .FILL      #4
                     .STRINGZ   "BASE"
code_BASE            .FILL      BASE
name_HERE            .FILL      name_BASE
                     .FILL      #4
                     .STRINGZ   "HERE"
code_HERE            .FILL      HERE
name_LOAD            .FILL      name_HERE
                     .FILL      #4
                     .STRINGZ   "LOAD"
code_LOAD            .FILL      DOCOL
                     .FILL      code_FILELOC
                     .FILL      code_KEYSOURCE
                     .FILL      code_STORE
                     .FILL      code_EXIT
name_colo            .FILL      name_LOAD
                     .FILL      #1
                     .STRINGZ   ":"
code_colo            .FILL      DOCOL
                     .FILL      code_WORD
                     .FILL      code_CREATE
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
                     .FILL      code_TICK
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
name_QUIT            .FILL      name_IMMEDIATE
                     .FILL      #4
                     .STRINGZ   "QUIT"
code_QUIT            .FILL      DOCOL
                     .FILL      code_RZ
                     .FILL      code_RSPSTORE
                     .FILL      code_INTERPRET
                     .FILL      code_BRANCH
                     .FILL      #-2
                     .FILL      code_EXIT
name_quesIMMEDIATE   .FILL      name_QUIT
                     .FILL      #10
                     .STRINGZ   "?IMMEDIATE"
code_quesIMMEDIATE   .FILL      DOCOL
                     .FILL      code_INCR
                     .FILL      code_FETCH
                     .FILL      code__F_IMMED
                     .FILL      code_ANDF
                     .FILL      code_EXIT
name_quesHIDDEN      .FILL      name_quesIMMEDIATE
                     .FILL      #7
                     .STRINGZ   "?HIDDEN"
code_quesHIDDEN      .FILL      DOCOL
                     .FILL      code_INCR
                     .FILL      code_FETCH
                     .FILL      code__F_HIDDEN
                     .FILL      code_ANDF
                     .FILL      code_EXIT
name_INTERPRET       .FILL      name_quesHIDDEN
                     .FILL      #9
                     .STRINGZ   "INTERPRET"
code_INTERPRET       .FILL      DOCOL
                     .FILL      code_WORD
                     .FILL      code_OVER
                     .FILL      code_OVER
                     .FILL      code_FIND
                     .FILL      code_DUP
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
                     .FILL      code_quesIMMEDIATE
                     .FILL      code_ZBRANCH
                     .FILL      #5
                     .FILL      code_TCFA
                     .FILL      code_EXECUTE
                     .FILL      code_BRANCH
                     .FILL      #3
                     .FILL      code_TCFA
                     .FILL      code_COMMA
                     .FILL      code_BRANCH
                     .FILL      #26
                     .FILL      code_DROP
                     .FILL      code_NUMBER
                     .FILL      code_ZBRANCH
                     .FILL      #14
                     .FILL      code_DROP
                     .FILL      code_PARSE_ERROR
                     .FILL      code_EMITS
                     .FILL      code_KEYSOURCE
                     .FILL      code_FETCH
                     .FILL      code_ZBRANCH
                     .FILL      #5
                     .FILL      code_LIT
                     .FILL      #0
                     .FILL      code_KEYSOURCE
                     .FILL      code_STORE
                     .FILL      code_BRANCH
                     .FILL      #9
                     .FILL      code_STATE
                     .FILL      code_FETCH
                     .FILL      code_ZBRANCH
                     .FILL      #5
                     .FILL      code_TICK
                     .FILL      code_LIT
                     .FILL      code_COMMA
                     .FILL      code_COMMA
                     .FILL      code_DELAYED_NL
                     .FILL      code_FETCH
                     .FILL      code_ZBRANCH
                     .FILL      #8
                     .FILL      code_LIT
                     .FILL      #10
                     .FILL      code_EMIT
                     .FILL      code_LIT
                     .FILL      #0
                     .FILL      code_DELAYED_NL
                     .FILL      code_STORE
                     .FILL      code_EXIT
name_LATEST          .FILL      name_INTERPRET
                     .FILL      #6
                     .STRINGZ   "LATEST"
code_LATEST          .FILL      LATEST

USER_DATA				.BLKW		1
						.END
