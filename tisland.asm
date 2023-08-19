//****************************
//  JC64dis version 2.6
//  
//  Source in KickAssembler format
//****************************

      .cpu _6502

.label zp02 = $02                 
.label zp0a = $0A                 
.label zp0c = $0C                 
.label zp0d = $0D                 
.label TILE_ATTR_PTR_LO = $21     
.label TILE_ATTR_PTR_HI = $22     
.label ROOM_DATA_PTR_LO = $23     
.label ROOM_DATA_PTR_HI = $24     
.label GFX_PTR_LO = $25           
.label GFX_PTR_HI = $26           
.label zp29 = $29                 
.label zp2a = $2A                 
.label zp31 = $31                 
.label zp32 = $32                 
.label zp33 = $33                 
.label PIRATE_SWORD_DISTANCE = $34
.label PIRATE_SWORD_DIRECTION = $35 
.label JSILVER_ENTRY_DELAY = $36  
.label zp3e = $3E                 
.label zp3f = $3F                 
.label ACTOR_SWORD_DISTANCE = $44 
.label zp54 = $54                 
.label PTR_LO = $57               
.label PTR_HI = $58               
.label zp59 = $59                 
.label SPRITE_NUMBER = $5C        
.label ROOM_NO = $5F              
.label SAVED_SPRITE_Y = $63       
.label SAVED_SPRITE_X = $64       
.label PICKABLE_POINT = $65       
.label MUSIC_TMP_LO = $9F         
.label MUSIC_TMP_HI = $A0         
.label SFX_PTR_LO = $DB           
.label SFX_PTR_HI = $DC           
.label SAVED_JSILVER_03_Y = $E0   
.label SAVED_JSILVER_03_X = $E1   
.label zpe2 = $E2                 
.label JSILVER_BITMAP_HI = $E3    
.label zpe4 = $E4                 
.label SPRITE_BYTE_POS = $FD      
.label BSS = $0337                
.label SFX_NOTE_INDEX = $033C     
.label SFX_TIMER = $033D          
.label SFX_DURATION = $033E       
.label SFX_NO = $033F             
.label ACTOR_LAST_Y = $0390       
.label ACTOR_LAST_X = $0391       
.label ACTOR_LAST_ROOM = $0392    
.label ACTOR_LAST_ROOM_START_Y = $0394 
.label ACTOR_LAST_ROOM_START_X = $0395 
.label ACTOR_ROOM_START = $0396   
.label ROOM_FLAGS = $03A0         
.label SCORE_LO = $03E0           
.label SCORE_HI = $03E1           
.label ACTOR_HAS_SWORD = $03E2    
.label ACTOR_SWORD_DIRECTION = $03E3 
.label ACTOR_HP = $03E4           
.label CHEST_NOT_FOUND = $03E7    
.label VISIBLE_SPRITE = $03E8     
.label SHFLAG = $0543             
.label LKP_INDEX = $07F6          
.label ATTRS = $0800              
.label SCORE_COLOR_ATTR = $0C70   
.label BASE_ADDR = $1000          

      *=$1001


// =======================================
// Basic program start
// =======================================
      .byte $0B, $10, $00, $00, $9E, $34, $31, $30 
      .byte $39, $00, $00, $00          

// ==========================
// Program start
// ==========================

START:
      lda  #$BB                         
      lda  #$00                         
W1011:
      sta  BSS,x                        
      dex                               
      bne  W1011                        
      jmp  MAIN                         

      .byte $00, $00, $00, $00, $00, $00

RESTORE_SCORE_PANEL_COLOR:
      ldx  #$00                         
      lda  #<SCORE_COLOR_ATTR           // Copies score panel color from BITMAP to $0c70
      sta  PTR_LO                       
      lda  #>SCORE_COLOR_ATTR           
      sta  PTR_HI                       
W102A:
      ldy  #$00                         
W102C:
      lda  BITMAP,x                     
      sta  (PTR_LO),y                   
      inx                               
      iny                               
      cpy  #$08                         // The score panel is 8 byte wide
      bne  W102C                        
      cpx  #$88                         // it has total $88 bytes, that means it is 17 character tall
W1039:
      bcs  W1042                        
      lda  #$28                         // goto next row
      jsr  ADD_TO_PTR                   
      bcs  W102A                        
W1042:
      rts                               

SWORD_05_GO_DIRECTION:
      jmp  (PTR_LO)                     

ADD_TO_PTR:
      clc                               
      adc  PTR_LO                       
      sta  PTR_LO                       
      lda  PTR_HI                       
      adc  #$00                         
      sta  PTR_HI                       
W1051:
      sec                               
      rts                               

SWORD_05_TRY_MOVE_DOWN:
      lda  SWORD_05_Y                   
      clc                               
      adc  #$02                         
      cmp  #$A8                         
      rts                               

SWORD_05_TRY_MOVE_UP:
      lda  SWORD_05_Y                   
      sec                               
      sbc  #$02                         
      cmp  #$02                         
      bcc  W1051                        
      clc                               
      rts                               

SWORD_05_TRY_MOVE_RIGHT:
      lda  SWORD_05_X                   
      clc                               
      adc  #$02                         
      cmp  #$F0                         
      rts                               

SWORD_05_TRY_MOVE_LEFT:
      lda  SWORD_05_X                   
      sec                               
      sbc  #$02                         
      cmp  #$02                         
      bcc  W1051                        
      clc                               
      rts                               


// =====================================
// Room flags:
//  Bits
//   7 = Pirate in room
//   6 = Pirate has sword
//   5 \ = Pirate no
//   4 / 
//   3 = Pickable item in room
//   2 \
//   1 | = pickable index
//   0 /
// =====================================

RESET_ROOM_FLAG:
      and  ROOM_FLAGS,x                 
      sta  ROOM_FLAGS,x                 
      rts                               

GET_SPR_ATTR_ADDR:
      lda  #<ATTRS                      
      sta  PTR_LO                       
      lda  #>ATTRS                      
      sta  PTR_HI                       
      lda  ACTOR_Y,x                    
      lsr                               
      lsr                               
      lsr                               
      beq  W109D                        
      tay                               
W1095:
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      dey                               
      bne  W1095                        
W109D:
      lda  ACTOR_X,x                    
      lsr                               
      lsr                               
      lsr                               
      jsr  ADD_TO_PTR                   
      rts                               


// =====================================
// Add to score and print score
// =====================================

ADD_TO_SCORE:
      sed                               
      clc                               
W10A9:
      adc  SCORE_LO,x                   
      sta  SCORE_LO,x                   
      lda  #$00                         
      dex                               
      bpl  W10A9                        
      cld                               

// =====================================
// Print score
// =====================================

PRINT_SCORE:
      ldx  #$17                         
      lda  SCORE_HI                     
      pha                               
      jsr  TO_DIGIT                     
      pla                               
      lsr                               
      lsr                               
      lsr                               
      lsr                               
      jsr  DRAW_SINGLE_DIGIT            
      lda  SCORE_LO                     
TO_DIGIT:
      and  #$0F                         

// =====================================
// Draw a single digit in A
// =====================================

DRAW_SINGLE_DIGIT:
      tay                               
      lda  DIGITS_LO,y                  // Score "digits" from $19a0
      sta  PTR_LO                       
      lda  #>DIGIT_0                    // >DIGIT_0
      sta  PTR_HI                       
      ldy  #$07                         
W10D7:
      lda  (PTR_LO),y                   
      sta  SCORE_DISPLAY_ADDR,x         
      dex                               
      dey                               
      bpl  W10D7                        
      rts                               

DIGITS_LO:
      .byte <DIGIT_0, <DIGIT_1, <DIGIT_2, <DIGIT_3, <DIGIT_4, <DIGIT_5, <DIGIT_6, <DIGIT_7 
      .byte <DIGIT_8, <DIGIT_9          
L10EB:                                  // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00     
BITS:
      .byte $01, $02, $04, $08, $10, $20, $40, $80 

// ======================================
// MAIN
// ======================================

MAIN:
      lda  #$00                         
      sta  SCORE_HI                     
      sta  SCORE_LO                     
      jsr  PRINT_SCORE                  
      lda  #$37                         // Turn on hires graphics
      sta  $FF06                        
      lda  $FF07                        
      ora  #$18                         // Turn on multicolor
      sta  $FF07                        
      lda  #$C8                         // Bitmap address $2000 (bank1). Colors at $0c00, Luma at $0800
      sta  $FF12                        
      lda  #$71                         
      sta  $FF16                        
      lda  #$00                         
      sta  $FF15                        
      sta  $FF19                        
      sta  $FF19                        
      ldx  #$03                         // Set global luminance ...
      lda  #>ATTRS                      
      sta  PTR_HI                       
      ldy  #<ATTRS                      
      sty  PTR_LO                       
W1137:
      lda  #$74                         // ... to $74 ?
W1139:
      sta  (PTR_LO),y                   
      iny                               
      bne  W1139                        
      inc  PTR_HI                       
      dex                               
      bpl  W1137                        
      jsr  RESTORE_SCORE_PANEL_COLOR    
GAME_OVER:
      jmp  GAME_TITLE                   

GAME_RESET:
      ldx  #$3F                         
W114B:
      lda  GAME_INITIAL_DATA,x          
      sta  ROOM_FLAGS,x                 
      dex                               
      bpl  W114B                        
      lda  #$00                         
      sta  TREASURE_CHEST_PLACE         // Hide the treasure chest
      ldx  #$27                         
      stx  SHIP_GATE_PLACE              // Close the ship enterance
      lda  #$38                         // Start room $38
      sta  ROOM_NO                      
      lda  #$05                         // Set HP to $05
      sta  ACTOR_HP                     
      lda  #$28                         // Actor start Y 40 ($28)
      sta  ACTOR_Y                      
      sta  ACTOR_LAST_Y                 
      sta  ACTOR_LAST_ROOM_START_Y      
      lda  #$D0                         // Actor start X 208 ($d0)
      sta  ACTOR_X                      
      sta  ACTOR_LAST_X                 
      sta  ACTOR_LAST_ROOM_START_X      
      lda  #$82                         // Actor color
      sta  SPRITE_00_COLOR              
      lda  #>ACTOR_RIGHT_00             
      sta  SPRITE_00_BITMAP_HI          
      lda  #<SPRITE_BITMAP_FRAME_08_LO  // This should point to the lower byte of the address $15a8
      sta  SPRITE_00_BITMAP_LO          
      lda  #$75                         // Actor luminance
      sta  SPRITE_00_LUM                
      lda  #$38                         // Start room $38
      sta  ACTOR_LAST_ROOM              
      sta  ACTOR_ROOM_START             
      jsr  IRQ_SETUP                    
      lda  #$FF                         
      sta  CHEST_NOT_FOUND              
      lda  #$00                         
      sta  SCORE_LO                     
      sta  SCORE_HI                     
      jsr  PRINT_SCORE                  
      jmp  REDRAW_ROOM                  

      *=$1200

JSILVER_ENTERS_THE_SCENE:
      lda  SHIP_GATE_PLACE              
      bne  W122B                        // Do nothing unless the gate to the ship is open
      ldx  #$03                         
      lda  VISIBLE_SPRITE               
      and  #$08                         // Sprite $03 is on? (John Silver)
      bne  JSILVER_MOVE                 
      dec  JSILVER_ENTRY_DELAY          // Decrease the timer until John Long Silver enters the scene
      bne  W122B                        
      lda  ACTOR_LAST_Y                 
      sta  JSILVER_03_Y                 // Make JS entry point to the same as actor's
      lda  ACTOR_LAST_X                 
      sta  JSILVER_03_X                 
      lda  #$73                         
      sta  SPRITE_03_LUM                
      jsr  SET_SPRITE_ON                // JS enters the scene
      jmp  ACTOR_J_SILVER_CHECK         

      .byte $10                         // garbage
      .byte $3F                         
W122B:
      rts                               

JSILVER_MOVE:
      lda  JSILVER_03_Y                 
      sta  SAVED_JSILVER_03_Y           
      lda  JSILVER_03_X                 
      sta  SAVED_JSILVER_03_X           
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw sprite $03 (John Silver)
      lda  #$01                         
      sta  zpe2                         
      lda  JSILVER_03_X                 
      sec                               
      sbc  ACTOR_X                      
      sta  zp31                         
      lda  JSILVER_03_Y                 
      sec                               
      sbc  ACTOR_Y                      
      cmp  zp31                         
      bcs  W1283                        
W1253:
      ldx  #$03                         
      ldy  #$01                         
      lda  JSILVER_03_X                 
      cmp  ACTOR_X                      
      beq  W127D                        
      bcs  W1262                        
      dey                               
W1262:
      lda  JSILVER_03_BITMAP_RIGHT,y    
      sta  JSILVER_BITMAP_HI            
      lda  #$08                         
      sta  zpe4                         
      clc                               
      lda  JSILVER_MOVE_RIGHT,y         
      adc  JSILVER_03_X                 
      sta  JSILVER_03_X                 
      jsr  CHECK_JSILVER_COLLISION      
      bcc  W12C2                        
      jsr  RESTORE_JSILVER_03_POS       
W127D:
      dec  zpe2                         
      bpl  W1283                        
      bmi  W12B1                        
W1283:
      ldx  #$03                         
      ldy  #$01                         
      lda  JSILVER_03_Y                 
      cmp  ACTOR_Y                      
      beq  W12AD                        
      bcs  W1292                        
      dey                               
W1292:
      lda  JSILVER_03_BITMAP_DOWN,y     
      sta  JSILVER_BITMAP_HI            
      lda  #$00                         
      sta  zpe4                         
      clc                               
      lda  JSILVER_MOVE_DOWN,y          
      adc  JSILVER_03_Y                 
      sta  JSILVER_03_Y                 
      jsr  CHECK_JSILVER_COLLISION      
      bcc  W12C2                        

// ======================================
// John Long Silver hits the obstacle
// ======================================

      jsr  RESTORE_JSILVER_03_POS       
W12AD:
      dec  zpe2                         
      bpl  W1253                        
W12B1:
      ldx  #$03                         
      jsr  DRAW_SPRITE                  // Draw sprite $03 (John Silver)
      rts                               

RESTORE_JSILVER_03_POS:
      lda  SAVED_JSILVER_03_Y           
      sta  JSILVER_03_Y                 
      lda  SAVED_JSILVER_03_X           
      sta  JSILVER_03_X                 
      rts                               

W12C2:
      lda  JSILVER_BITMAP_HI            
      sta  SPRITE_03_BITMAP_HI          
      lda  zpe4                         
      sta  W153B                        
      jmp  W12B1                        

CHECK_JSILVER_COLLISION:
      jsr  GET_SPR_ATTR_ADDR            
      ldx  #$02                         
W12D4:
      ldy  #$02                         
W12D6:
      lda  (PTR_LO),y                   
      beq  W12E0                        
      cmp  #$75                         // JS hits actor?
      beq  W12F8                        
      sec                               
      rts                               

W12E0:
      dey                               
      bpl  W12D6                        
      dex                               
      bmi  W12ED                        
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      bcs  W12D4                        
W12ED:
      clc                               
      rts                               

      .byte $00                         // possible garbage
JSILVER_03_BITMAP_RIGHT:
      .byte >JSILVER_RIGHT_00
JSILVER_03_BITMAP_LEFT:
      .byte >JSILVER_LEFT_00
JSILVER_03_BITMAP_DOWN:
      .byte >JSILVER_DOWN_00
JSILVER_03_BITMAP_UP:
      .byte >JSILVER_UP_00
JSILVER_MOVE_RIGHT:
      .byte $02
JSILVER_MOVE_LEFT:
      .byte $FE
JSILVER_MOVE_DOWN:
      .byte $02
JSILVER_MOVE_UP:
      .byte $FE
W12F8:
      jmp  ACTOR_DIE                    

      *=$1300


// ======================================
// Play music
// ======================================

MUSIC_PLAY:
      lda  #<MUSIC_00                   // Music0: $7c00
      sta  MUSIC_START_LO               
      lda  #>MUSIC_00                   
      sta  MUSIC_START_HI               
      lda  MUSIC_NUMBER                 
      beq  W1319                        
      lda  #<MUSIC_01                   // Music1: $7e81
      sta  MUSIC_START_LO               
      lda  #>MUSIC_01                   
      sta  MUSIC_START_HI               
W1319:
      lda  MUSIC_NUMBER                 
      cmp  #$02                         
      bne  W132A                        
      lda  #<MUSIC_02                   // Music2: $7f36
      sta  MUSIC_START_LO               
      lda  #>MUSIC_02                   
      sta  MUSIC_START_HI               
W132A:
      lda  MUSIC_NUMBER                 
      cmp  #$03                         
      bne  W133B                        
      lda  #<MUSIC_03                   // Music3: $7f73
      sta  MUSIC_START_LO               
      lda  #>MUSIC_03                   
      sta  MUSIC_START_HI               
W133B:
      lda  MUSIC_START_LO               
      sta  MUSIC_PTR_LO                 
      lda  MUSIC_START_HI               
      sta  MUSIC_PTR_HI                 
MUSIC_PLAY_LOOP:
      nop                               
      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$BF                         
      ora  #$30                         
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      lda  MUSIC_PTR_LO                 
      sta  MUSIC_TMP_LO                 
      lda  MUSIC_PTR_HI                 
      sta  MUSIC_TMP_HI                 
      ldy  #$00                         
      lda  (MUSIC_TMP_LO),y             
      cmp  #$01                         
      bne  W136D                        

// ======================================
// Finished playing music
// ======================================

      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$8F                         // Volume off
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      rts                               

W136D:
      cmp  #$FF                         
      bne  W137C                        
      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$EF                         
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      iny                               
      bne  W138A                        
W137C:
      sta  $FF0E                        // TED: Voice #1 frequency, bits 0-7
      iny                               
      lda  $FF12                        // TED: Bit 0-1 : Voice #1 frequency, bits 8 & 9
      and  #$FC                         
      ora  (MUSIC_TMP_LO),y             
      sta  $FF12                        // TED: Bit 0-1 : Voice #1 frequency, bits 8 & 9
W138A:
      iny                               
      lda  (MUSIC_TMP_LO),y             
      cmp  #$FF                         
      bne  W1399                        
      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$9F                         
      sta  $FF11                        // TED: Bits 0-3 : Volume control
W1399:
      sta  $FF0F                        // TED: Voice #2 frequency, bits 0-7
      iny                               
      lda  $FF10                        // TED: Voice #2 frequency, bits 8 & 9
      and  #$FC                         
      ora  (MUSIC_TMP_LO),y             
      sta  $FF10                        // TED: Voice #2 frequency, bits 8 & 9
      lda  MUSIC_PTR_LO                 
      clc                               
      adc  #$04                         
      sta  MUSIC_PTR_LO                 
      lda  MUSIC_PTR_HI                 
      adc  #$00                         
      sta  MUSIC_PTR_HI                 
      lda  #$01                         
      sta  MUSIC_R1                     
      sta  MUSIC_R0                     
W13C0:
      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$F0                         
      ora  MUSIC_R0                     
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      jsr  MUSIC_DELAY                  
      lda  MUSIC_R0                     
      clc                               
      adc  MUSIC_R1                     
      beq  W13E5                        
      cmp  #$07                         
      bne  W13E0                        
      ldx  #$FF                         
      stx  MUSIC_R1                     
W13E0:
      sta  MUSIC_R0                     
      bne  W13C0                        
W13E5:
      lda  MUSIC_NUMBER                 
      bne  W1408                        
      jmp  W13F8                        

      sta  $FF08                        // Possible garbage ...
      lda  $FF08                        
      cli                               
      and  #$80                         
      beq  W13FF                        // ... until here!
W13F8:
      lda  LKP_INDEX                    // Key scan index
      cmp  #$40                         
      beq  W1408                        // Play music until a key is pressed
W13FF:
      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$80                         
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      rts                               

W1408:
      jmp  MUSIC_PLAY_LOOP              

MUSIC_DELAY:
      ldx  #$08                         
W140D:
      ldy  #$00                         
W140F:
      dey                               
      bne  W140F                        
      dex                               
      bne  W140D                        
      rts                               

MUSIC_START_LO:
      .byte $73
MUSIC_START_HI:
      .byte $7F
MUSIC_PTR_LO:
      .byte $A7
MUSIC_PTR_HI:
      .byte $7F
MUSIC_R0:
      .byte $01
MUSIC_R1:
      .byte $FF
MUSIC_NUMBER:
      .byte $03
L141D:
      .byte $00, $00, $00               

// ======================================
// Pause game by pressing C= key
// ======================================

PAUSE_GAME:
      lda  SHFLAG                       // C= is down?
      and  #$02                         
      beq  W143C                        
W1427:
      lda  SHFLAG                       // C= is released ?
      and  #$02                         
      bne  W1427                        
W142E:
      lda  SHFLAG                       // C= is down?
      and  #$02                         
      beq  W142E                        
W1435:
      lda  SHFLAG                       // C= is released ?
      and  #$02                         
      bne  W1435                        
W143C:
      rts                               

      *=$1500

ACTOR_Y:
      .byte $28
NPC_01_Y:
      .byte $00
PIRATE_02_Y:
      .byte $68
JSILVER_03_Y:
      .byte $4E
NPC_04_Y:
      .byte $00
SWORD_05_Y:
      .byte $68
SWORD_06_Y:
      .byte $28
PICKABLE_07_Y:
      .byte $68
ACTOR_X:
      .byte $D0
NPC_01_X:
      .byte $00
PIRATE_02_X:
      .byte $8C
JSILVER_03_X:
      .byte $BA
NPC_04_X:
      .byte $00
SWORD_05_X:
      .byte $9E
SWORD_06_X:
      .byte $6E
PICKABLE_07_X:
      .byte $88
SPRITE_00_COLOR:
      .byte $82
SPRITE_01_COLOR:
      .byte $00
SPRITE_02_COLOR:
      .byte $62
SPRITE_03_COLOR:
      .byte $62
SPRITE_04_COLOR:
      .byte $00
SPRITE_05_COLOR:
      .byte $11
SPRITE_06_COLOR:
      .byte $11
SPRITE_07_COLOR:
      .byte $11
SPRITE_00_HEIGHT:
      .byte $15
SPRITE_01_HEIGHT:
      .byte $00
SPRITE_02_HEIGHT:
      .byte $15
SPRITE_03_HEIGHT:
      .byte $15
SPRITE_04_HEIGHT:
      .byte $00
SPRITE_05_HEIGHT:
      .byte $0D
SPRITE_06_HEIGHT:
      .byte $0D
SPRITE_07_HEIGHT:
      .byte $0D
SPRITE_00_BITMAP_HI:
      .byte >ACTOR_RIGHT_00
SPRITE_01_BITMAP_HI:                    // unused
      .byte $00
SPRITE_02_BITMAP_HI:
      .byte >PIRATE_FRAME_00
SPRITE_03_BITMAP_HI:
      .byte >JSILVER_LEFT_00
SPRITE_04_BITMAP_HI:                    // unused
      .byte $00
SPRITE_05_BITMAP_HI:
      .byte >SWORD_L_SHIFT_00
SPRITE_06_BITMAP_HI:
      .byte >SWORD_L_SHIFT_00
SPRITE_07_BITMAP_HI:
      .byte >SWORD_R_SHIFT_00
SPRITE_00_BITMAP_LO:                    // $15A8
      .byte <SPRITE_BITMAP_FRAME_08_LO
SPRITE_01_BITMAP_LO:                    // $1500
      .byte $00
SPRITE_02_BITMAP_LO:                    // $15A0
      .byte <SPRITE_BITMAP_FRAME_00_LO
SPRITE_03_BITMAP_LO:                    // $15A4
      .byte <SPRITE_BITMAP_FRAME_04_LO
SPRITE_04_BITMAP_LO:                    // $1500
      .byte $00
SPRITE_05_BITMAP_LO:                    // $15B0
      .byte <SWORD_BITMAP_FRAME_00_LO
SPRITE_06_BITMAP_LO:                    // $15B0
      .byte <SWORD_BITMAP_FRAME_00_LO
SPRITE_07_BITMAP_LO:                    // $15A0
      .byte <SPRITE_BITMAP_FRAME_00_LO
SPRITE_00_LUM:
      .byte $75
SPRITE_01_LUM:
      .byte $00
SPRITE_02_LUM:
      .byte $73
SPRITE_03_LUM:
      .byte $73
SPRITE_04_LUM:
      .byte $00
SPRITE_05_LUM:
      .byte $65
SPRITE_06_LUM:
      .byte $46
SPRITE_07_LUM:
      .byte $55
W1538:
      .byte $08, $08, $08               
W153B:
      .byte $08, $08                    
W153D:
      .byte $08, $08, $08               
ACTOR_BITMAP_HI:
      .byte >ACTOR_RIGHT_00, >ACTOR_LEFT_00, >ACTOR_DOWN_00, >ACTOR_UP_00 
ACTOR_SPEED_RIGHT:
      .byte $02
ACTOR_SPEED_LEFT:
      .byte $FE
ACTOR_SPEED_DOWN:
      .byte $02
ACTOR_SPEED_UP:
      .byte $FE
SWORD_POSITION_OFFSET:                  // Change sword X
      .byte $08, $08                    // Change sword X
      .byte $00                         // Change sword Y
      .byte $00                         // Change sword Y
L154C:                                  // possible garbage
      .byte $00, $00, $00, $00, $22, $AE, $00, $00 
      .byte $00, $00, $00, $00          

// ======================================
// Sprite rows
//
// Rows index
//  0 = Actor
//  1 = Unused ?
//  2 = Pirate
//  3 = J. Silver
//  4 = Unused ?
//  5 = Sword (actor)
//  6 = Sword (pirate)
//  7 = Pickable items
// ======================================

SPRITE_ROWS_TABLE:
      .byte $02, $02, $02, $02, $02, $01, $01, $02 

// ============================
// Game initial data will be transferred
// to real game data table when the
// game is started
// ============================

GAME_INITIAL_DATA:
      .byte $9B, $90, $C0, $C0, $E0, $9A, $E0, $E0 
      .byte $C0, $CC, $E0, $E0, $ED, $9D, $CC, $90 
      .byte $99, $ED, $EB, $C8, $9D, $90, $E0, $90 
      .byte $E0, $EC, $C0, $EA, $90, $CD, $EB, $C0 
      .byte $0D, $E0, $C9, $E0, $CD, $9C, $ED, $90 
      .byte $90, $EC, $CD, $90, $9D, $C0, $90, $90 
      .byte $C0, $90, $ED, $90, $90, $ED, $CB, $00 
      .byte $90, $E0, $0D, $CA, $0D, $C0, $E0, $C0 

// Game init data end

SPRITE_BITMAP_FRAME_00_LO:
      .byte <ACTOR_RIGHT_00
SPRITE_BITMAP_FRAME_01_LO:
      .byte <ACTOR_RIGHT_01
SPRITE_BITMAP_FRAME_02_LO:
      .byte <JSILVER_RIGHT_00
SPRITE_BITMAP_FRAME_03_LO:
      .byte <JSILVER_RIGHT_01
SPRITE_BITMAP_FRAME_04_LO:
      .byte <JSILVER_LEFT_00
SPRITE_BITMAP_FRAME_05_LO:
      .byte <JSILVER_LEFT_00
SPRITE_BITMAP_FRAME_06_LO:
      .byte <JSILVER_LEFT_01
SPRITE_BITMAP_FRAME_07_LO:
      .byte <JSILVER_LEFT_01
SPRITE_BITMAP_FRAME_08_LO:
      .byte <ACTOR_LEFT_00
SPRITE_BITMAP_FRAME_09_LO:
      .byte <ACTOR_LEFT_00
SPRITE_BITMAP_FRAME_10_LO:
      .byte <ACTOR_LEFT_01
SPRITE_BITMAP_FRAME_11_LO:
      .byte <ACTOR_LEFT_01
SPRITE_BITMAP_FRAME_12_LO:
      .byte <ACTOR_DOWN_00
SPRITE_BITMAP_FRAME_13_LO:
      .byte <ACTOR_DOWN_01
SPRITE_BITMAP_FRAME_14_LO:
      .byte <JSILVER_UP_00
SPRITE_BITMAP_FRAME_15_LO:
      .byte <JSILVER_UP_01
SWORD_BITMAP_FRAME_00_LO:               
      .byte <SWORD_R_SHIFT_00
SWORD_BITMAP_FRAME_01_LO:
      .byte <SWORD_R_SHIFT_01
SWORD_BITMAP_FRAME_02_LO:
      .byte <SWORD_R_SHIFT_02
SWORD_BITMAP_FRAME_03_LO:
      .byte <SWORD_R_SHIFT_03
L15B4:                                  // possible garbage
      .byte $00, $00, $00, $00, $27, $27, $27, $27 
      .byte $00, $00, $00, $00          

// ======================================
// Copy copyright message bitmap data
// ======================================

COPYRIGHT_PRINT:
      ldx  #$7F                         
W15C2:
      lda  COPYRIGHT_01,x               
      sta  COPYRIGHT_01_ADDR,x          
      lda  COPYRIGHT_02,x               
      sta  COPYRIGHT_02_ADDR,x          
      lda  COPYRIGHT_03,x               
      sta  COPYRIGHT_03_ADDR,x          
      dex                               
      bpl  W15C2                        
      lda  #$0F                         
      sta  W2A4F                        
      lda  #$F0                         
      sta  W2A57                        
      ldx  #$04                         
      lda  #$C0                         
W15E5:
      sta  COPYRIGHT_03_RIGHT,x         
      dex                               
      bpl  W15E5                        
      rts                               

      .byte $00                         // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
W15FD:
      jmp  DELAY                        


// ======================================
// Move actor
// ======================================

UPDATE_ACTOR:
      ldx  #$00                         
      stx  zp54                         
      lda  ACTOR_Y                      
      sta  SAVED_SPRITE_Y               
      lda  ACTOR_X                      
      sta  SAVED_SPRITE_X               
      sei                               
      lda  #$FD                         
      sta  $FF08                        
      lda  $FF08                        
      cli                               
      bmi  W161C                        
      inc  zp54                         
W161C:
      ldy  #$03                         
W161E:
      lsr                               
      bcc  W1626                        
      dey                               
      bpl  W161E                        
      bmi  W15FD                        
W1626:
      sty  ACTOR_DIRECTION              
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw actor
      ldy  ACTOR_DIRECTION              
      lda  ACTOR_BITMAP_HI,y            
      sta  zp0a                         
      lda  ACTOR_SPEED_RIGHT,y          
      ldx  SWORD_POSITION_OFFSET,y      
      stx  W1538                        
      clc                               
      adc  ACTOR_Y,x                    
      sta  ACTOR_Y,x                    
      ldx  #$00                         
      jsr  GET_SPR_ATTR_ADDR            
      ldx  #$02                         
W164D:
      ldy  #$02                         
W164F:
      lda  (PTR_LO),y                   
      beq  W1663                        
      cmp  #$74                         // Actor hit obstacle
      beq  ACTOR_HIT_OBSTACLE           
      cmp  #$55                         // Item to pickup
      beq  ACTOR_ITEM_PICKUP            
      cmp  #$46                         // Sword to pickup
      beq  ACTOR_SWORD_PICKUP           
      cmp  #$73                         // Actor hit pirate
      beq  W16BC                        
W1663:
      dey                               
      bpl  W164F                        
      dex                               
W1667:
      bmi  DRAW_ACTOR                   
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      bcs  W164D                        
DRAW_ACTOR:
      clc                               
      lda  zp0a                         
      adc  ACTOR_HAS_SWORD              
      sta  SPRITE_00_BITMAP_HI          
      ldx  #$00                         
      lda  #$01                         
      jsr  DRAW_SPRITE                  // Draw actor
      rts                               

ACTOR_HIT_OBSTACLE:
      lda  SAVED_SPRITE_Y               
      sta  ACTOR_Y                      
      lda  SAVED_SPRITE_X               
      sta  ACTOR_X                      
      jmp  DRAW_ACTOR                   

ACTOR_ITEM_PICKUP:
      txa                               
      pha                               
      tya                               
      pha                               
      ldx  #$07                         
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw sprite $07
      ldx  ROOM_NO                      
      lda  #$F7                         // = %11110111
      jsr  RESET_ROOM_FLAG              
      jsr  SFX_00_PLAY                  
      lda  PICKABLE_POINT               
      beq  W16D8                        
      cmp  #$05                         // Chest key found?
      bne  W16B0                        
      ldy  #$16                         
      sty  TREASURE_CHEST_PLACE         // Insert the treasure chest tile
W16B0:
      ldx  #$01                         
      jsr  ADD_TO_SCORE                 
W16B5:
      pla                               
      tax                               
      pla                               
      tay                               
      jmp  DRAW_ACTOR                   

W16BC:
      jmp  ACTOR_DIE                    


// =====================================
// THE ACTOR HAS PICKED UP THE SWORD
// =====================================

ACTOR_SWORD_PICKUP:
      lda  PIRATE_SWORD_DISTANCE        
      bne  W16BC                        // If the sword is still moving, then it hits the actor
      txa                               
      pha                               
      tya                               
      pha                               
      ldx  #$06                         
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw spritr $06
      ldx  ROOM_NO                      
      lda  #$BF                         // = %10111111
      jsr  RESET_ROOM_FLAG              // Actor has picked up the sword
      jsr  SFX_02_PLAY                  
W16D8:
      lda  #$01                         
      sta  ACTOR_HAS_SWORD              
      jmp  W16B5                        

      .byte $E2                         // possible garbage
      .byte $03, $A9, $00, $85, $D8, $68, $A8, $68 
      .byte $AA, $4C, $68, $16, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00


ACTOR_DIRECTION:
      .byte $00

// ======================================
// Game loop
// ======================================

GAME_LOOP:
      lda  #$80                         
      ldx  ACTOR_Y                      
      bpl  W1709                        
      lda  #$A0                         
W1709:
      sta  zp02                         
WAIT_BEAM1:
      lda  $FF1D                        // TED: Bits 0-7 : Vertical line bits 0-7
      cmp  zp02                         
      bcc  WAIT_BEAM1                   
      jsr  UPDATE_ACTOR                 
      jsr  CHECK_ACTOR_ROOM_EXIT        
      jsr  UPDATE_PIRATE                
      jsr  UPDATE_ACTOR_SWORD           
      jsr  CHECK_ACTOR_CHEST            
      lda  SHIP_GATE_PLACE              
      cmp  #$00                         
      bne  W173D                        
      ldx  #$80                         
      lda  JSILVER_03_Y                 
      bpl  W1731                        
      ldx  #$A0                         
W1731:
      stx  zp02                         
WAIT_BEAM2:
      lda  $FF1D                        // TED: Bits 0-7 : Vertical line bits 0-7
      cmp  zp02                         
      bcc  WAIT_BEAM2                   
      jsr  JSILVER_ENTERS_THE_SCENE     
W173D:
      jsr  CHECK_SHIP                   
      jsr  PAUSE_GAME                   
      jmp  GAME_LOOP                    

      .byte $00                         // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00                         

// ======================================
// Actor die
// ======================================

ACTOR_DIE:
      pla                               
      pla                               // Clear return address
      lda  ACTOR_LAST_ROOM_START_Y      
      sta  ACTOR_Y                      
      lda  ACTOR_LAST_ROOM_START_X      
      sta  ACTOR_X                      
      lda  ACTOR_ROOM_START             
      sta  ROOM_NO                      
      lda  #$00                         
      sta  ACTOR_HAS_SWORD              
      jsr  SFX_00_PLAY                  
      lda  ACTOR_LAST_ROOM_START_Y      
      sta  ACTOR_LAST_Y                 
      lda  ACTOR_LAST_ROOM_START_X      
      sta  ACTOR_LAST_X                 
      lda  ACTOR_ROOM_START             
      sta  ACTOR_LAST_ROOM              
      dec  ACTOR_HP                     
      beq  W1795                        
      jmp  REDRAW_ROOM                  

W1795:
      jmp  GAME_OVER                    

      .byte $00                         // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00 

// ======================================
// Play sfx 00
// ======================================

SFX_00_PLAY:
      ldx  #$00                         
      stx  SFX_NO                       
      lda  #$01                         
      sta  SFX_DURATION                 
      stx  SFX_TIMER                    
      lda  #$1F                         
      sta  SFX_NOTE_INDEX               
      lda  #$7F                         
      sta  $FF10                        // TED: Voice #2 frequency, bits 8 & 9
      lda  #$20                         
SFX_ENABLE_CHANNEL:
      ora  $FF11                        // TED: Bits 0-3 : Volume control
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      rts                               


// ======================================
// Play sfx 01
// ======================================

SFX_01_PLAY:
      ldx  #$01                         
      stx  SFX_NO                       
      lda  #$00                         
      sta  SFX_TIMER                    
      lda  #$00                         
      sta  SFX_DURATION                 
      lda  #$7F                         
      sta  $FF10                        // TED: Voice #2 frequency, bits 8 & 9
      lda  #$1F                         
      sta  SFX_NOTE_INDEX               
      lda  #$40                         
      jmp  SFX_ENABLE_CHANNEL           


// ======================================
// Play sfx 02
// ======================================

SFX_02_PLAY:
      ldx  #$02                         
      stx  SFX_NO                       
      lda  #$00                         
      sta  SFX_TIMER                    
      lda  #$00                         
      sta  SFX_DURATION                 
      lda  #$7F                         
      sta  $FF10                        // TED: Voice #2 frequency, bits 8 & 9
      lda  #$1F                         
      sta  SFX_NOTE_INDEX               
      lda  #$20                         
      jmp  SFX_ENABLE_CHANNEL           

      *=$1800

UPDATE_ACTOR_SWORD:
      ldy  ACTOR_SWORD_DISTANCE         
      bne  ACTOR_MOVE_SWORD             
      lda  zp54                         
      beq  W185E                        
      lda  ACTOR_HAS_SWORD              
      beq  W185E                        
      lda  ACTOR_Y                      
      sta  SWORD_05_Y                   
      lda  ACTOR_X                      
      sta  SWORD_05_X                   
      ldy  ACTOR_DIRECTION              
      sty  ACTOR_SWORD_DIRECTION        
      lda  SWORD_BITMAP_HI,y            
      sta  SPRITE_05_BITMAP_HI          
      lda  SWORD_BITMAP_LO,y            
      sta  SPRITE_05_BITMAP_LO          
      ldx  SWORD_POSITION_OFFSET,y      
      stx  W153D                        
      lda  SWORD_05_GO_DIRECTION_LO,y   
      sta  PTR_LO                       
      lda  #>SWORD_05_GO_DIRECTION      
      sta  PTR_HI                       
      ldy  #$08                         
W183C:
      jsr  SWORD_05_GO_DIRECTION        
      bcs  W185E                        
      sta  SWORD_05_Y,x                 
      dey                               
      bpl  W183C                        
      jsr  ACTOR_SWORD_CHECK            
      bcs  W185E                        
      lda  #$30                         
      sta  ACTOR_SWORD_DISTANCE         
      nop                               
      lda  #$00                         
      sta  ACTOR_HAS_SWORD              
      jsr  W18E2                        
      ldx  #$05                         
      jsr  DRAW_SPRITE                  // Draw sprite $05 (actor sword)
W185E:
      rts                               

ACTOR_MOVE_SWORD:
      ldx  #$05                         
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw sprite $05
      dec  ACTOR_SWORD_DISTANCE         
      beq  W185E                        
      ldy  ACTOR_SWORD_DIRECTION        
      lda  SWORD_05_GO_DIRECTION_LO,y   
      sta  PTR_LO                       
      lda  #>SWORD_05_GO_DIRECTION      
      sta  PTR_HI                       
      ldx  SWORD_POSITION_OFFSET,y      
      jsr  SWORD_05_GO_DIRECTION        
      bcs  W18B5                        
      sta  SWORD_05_Y,x                 
      jsr  ACTOR_SWORD_CHECK            
      bcs  W18B5                        
      ldx  #$05                         
      jsr  DRAW_SPRITE                  // Draw sprite $05 (actor sword)
      rts                               

      nop                               
      nop                               
      nop                               
ACTOR_SWORD_CHECK:
      ldx  #$05                         
      jsr  GET_SPR_ATTR_ADDR            
      ldx  #$01                         
W1896:
      ldy  #$02                         
W1898:
      lda  (PTR_LO),y                   
      beq  W18A6                        
      cmp  #$75                         
      beq  W18A6                        
      cmp  #$73                         // Sword hit pirate
      beq  PIRATE_KILLED                
      sec                               
      rts                               

W18A6:
      dey                               
      bpl  W1898                        
      dex                               
      bmi  W18B3                        
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      bcs  W1896                        
W18B3:
      clc                               
      rts                               

W18B5:
      lda  #$00                         
      sta  ACTOR_SWORD_DISTANCE         
      rts                               

PIRATE_KILLED:
      pla                               
      pla                               
      ldx  #$02                         
      lda  #$00                         
      sta  ACTOR_HAS_SWORD              
      jsr  DRAW_SPRITE                  // Undraw sprite $02
      lda  VISIBLE_SPRITE               
      and  #$FB                         // = %11111011 Turn off sprite $02
      sta  VISIBLE_SPRITE               
      ldx  ROOM_NO                      
      lda  #$7F                         // = %01111111
      jsr  RESET_ROOM_FLAG              // Remove pirate from the room
      jsr  SFX_01_PLAY                  
      ldx  #$01                         
      txa                               
      jsr  ADD_TO_SCORE                 
      lda  ACTOR_SWORD_DISTANCE         
      bne  W18B5                        
W18E2:
      ldx  #$00                         
      jsr  DRAW_SPRITE                  // Undraw actor
      dec  SPRITE_00_BITMAP_HI          // Actor does not hold sword anymore
      lda  #$01                         
      jsr  DRAW_SPRITE                  // Draw actor
      rts                               

      *=$1900

SWORD_L_SHIFT_00:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $C0, $30, $03, $00 
      .byte $FC, $03, $00, $FF, $FF, $C0, $3F, $FC 
      .byte $C0, $0F, $CC, $C0, $00, $03, $00 
SWORD_L_SHIFT_01:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $30, $0C, $00, $C0 
      .byte $3F, $00, $C0, $3F, $FF, $F0, $0F, $FF 
      .byte $30, $03, $F3, $30, $00, $00, $C0 
SWORD_L_SHIFT_02:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $0C, $03, $00, $30 
      .byte $0F, $C0, $30, $0F, $FF, $FC, $03, $FF 
      .byte $CC, $00, $FC, $CC, $00, $00, $30 
SWORD_L_SHIFT_03:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $03, $00, $C0, $0C 
      .byte $03, $F0, $0C, $03, $FF, $FF, $00, $FF 
      .byte $F3, $00, $3F, $33, $00, $00, $0C 

// end of sword shift left frames

      .byte $00, $00, $00, $00          // possible garbage

// ======================================
// Digits 0-9 for score
// ======================================

DIGIT_0:
      .byte $FD, $DD, $DD, $DD, $DD, $DD, $DD, $FD 
DIGIT_1:
      .byte $F5, $75, $75, $75, $75, $75, $75, $FD 
DIGIT_2:
      .byte $FD, $DD, $5D, $5D, $FD, $D5, $D5, $FD 
DIGIT_3:
      .byte $FD, $DD, $5D, $7D, $5D, $5D, $DD, $FD 
DIGIT_4:
      .byte $D5, $D5, $D5, $DD, $DD, $FD, $5D, $5D 
DIGIT_5:
      .byte $FD, $D5, $D5, $FD, $5D, $5D, $DD, $FD 
DIGIT_6:
      .byte $FD, $D5, $D5, $FD, $DD, $DD, $DD, $FD 
DIGIT_7:
      .byte $FD, $DD, $5D, $5D, $5D, $5D, $5D, $5D 
DIGIT_8:
      .byte $FD, $DD, $DD, $75, $DD, $DD, $DD, $FD 
DIGIT_9:
      .byte $FD, $DD, $DD, $DD, $FD, $5D, $5D, $FD 

// =====================================
// Wait approximatly 4080 CPU cycles
// and that is:
// total required cycles ~= 4080
// 4080/1760000 ~= 0.00231 s
// =====================================

DELAY:
      ldx  #$08                         
W19F2:
      ldy  #$FF                         
W19F4:
      dey                               
      bne  W19F4                        
      dex                               
      bne  W19F2                        
      rts                               

      *=$1A00


// ======================================
// Draw room tiled graphics

// Each room size is 32x24 characters, the
// tile size is 4x4 character, which then
// means the room size is 8x6 tiles 
// (48 ($30) bytes)
// =======================================


DRAW_ROOM:
      lda  ROOM_NO                      
      tax                               
      and  #$0F                         
      tay                               
      lda  ROOMS_DATA_HI,x              
      sta  ROOM_DATA_PTR_HI             
      lda  ROOMS_DATA_LO,y              
      sta  ROOM_DATA_PTR_LO             
      ldy  #$00                         
W1A12:
      tya                               
      and  #$07                         
      tax                               
      lda  TILE_TARGET_LO,x             
      sta  PTR_LO                       
      tya                               
      lsr                               
      lsr                               
      lsr                               
      tax                               
      lda  TILE_TARGET_HI,x             
      sta  PTR_HI                       
      lda  TILE_ATTR_TARGET_LO,y        
      sta  zp29                         
      sta  zp0c                         
      lda  TILE_ATTR_TARGET_HI,y        
      sta  zp2a                         
      sec                               
      sbc  #$04                         
      sta  zp0d                         
      sty  zp02                         
      lda  #$00                         
      sta  GFX_PTR_LO                   
      lda  (ROOM_DATA_PTR_LO),y         
      tax                               
      and  #$0F                         
      tay                               
      lda  TILE_ATTR_DATA_LO,y          
      sta  TILE_ATTR_PTR_LO             
      txa                               
      lsr                               
      lsr                               
      lsr                               
      lsr                               
      clc                               
      adc  #>TILE_ATTRIBUTES            // Base address of tiles ($7500)
      sta  TILE_ATTR_PTR_HI             
      txa                               
      lsr                               
      ror  GFX_PTR_LO                   
      clc                               
      adc  #>TILE_BITMAP_DATA           
      sta  GFX_PTR_HI                   
      txa                               
      beq  W1A5F                        
      lda  #$74                         
W1A5F:
      sta  zp31                         // This is actually the luminance

// ======================================
// Copy tile bitmap graphics
//
// The tile has the following format
// [ R0C0 ][ R0C1 ][ R0C2 ][ R0C3 ]
// [ R1C0 ][ R1C1 ][ R1C2 ][ R1C3 ]
// [ R2C0 ][ R2C1 ][ R2C2 ][ R2C3 ]
// [ R3C0 ][ R3C1 ][ R3C2 ][ R3C3 ]
// ======================================

      ldx  #$00                         
      lda  #$03                         
      sta  zp3e                         
      sta  zp3f                         
W1A69:
      ldy  #$00                         
W1A6B:
      lda  (GFX_PTR_LO,x)               
      sta  (PTR_LO),y                   
      inc  GFX_PTR_LO                   
      iny                               
      cpy  #$20                         
      bne  W1A6B                        
      dec  zp3f                         
      bmi  W1A8A                        
      clc                               
      lda  PTR_LO                       
      adc  #$40                         
      sta  PTR_LO                       
      lda  PTR_HI                       
      adc  #$01                         
      sta  PTR_HI                       // Add 320 ($140) to PTR = next row in the bitmap
      jmp  W1A69                        


// =====================================
// Copy tile attributes
// =====================================

W1A8A:
      ldy  #$00                         
W1A8C:
      lda  (TILE_ATTR_PTR_LO,x)         
      sta  (zp29),y                     // Set color attribute
      lda  zp31                         
      sta  (zp0c),y                     // Set luminance attribute
      inc  TILE_ATTR_PTR_LO             
      iny                               
      cpy  #$04                         
      bne  W1A8C                        
      dec  zp3e                         
      bmi  W1AB6                        
      clc                               
      lda  zp29                         
      adc  #$28                         
      sta  zp29                         
      sta  zp0c                         
      lda  zp2a                         
      adc  #$00                         
      sta  zp2a                         
      sec                               
      sbc  #$04                         
      sta  zp0d                         
      jmp  W1A8A                        

W1AB6:
      ldy  zp02                         
      iny                               
      cpy  #$30                         // All tiles rendered?
      beq  W1AC0                        
      jmp  W1A12                        

W1AC0:
      rts                               

      .byte $00                         // possible garbage
      .byte $00, $00, $00, $00, $00, $00

// ======================================
// Player sfx 03
// ======================================

SFX_03_PLAY:
      ldx  #$03                         
      stx  SFX_NO                       
      lda  #$00                         
      sta  SFX_DURATION                 
      lda  #$00                         
      sta  SFX_TIMER                    
      lda  #$7F                         
      sta  $FF10                        // TED: Voice #2 frequency, bits 8 & 9
      lda  #$07                         
      sta  SFX_NOTE_INDEX               
      lda  #$40                         
      jmp  SFX_ENABLE_CHANNEL           

      *=$1B00

ACTOR_SWORD_UP:
      .byte $00, $30, $00, $00, $3C, $00, $00, $FC 
      .byte $00, $00, $FC, $00, $00, $FC, $00, $00 
      .byte $F0, $00, $00, $F0, $00, $00, $30, $00 
      .byte $00, $30, $00, $00, $FC, $00, $00, $CF 
      .byte $00, $00, $CC, $C0, $00, $30, $C0 
ACTOR_SWORD_DOWN:
      .byte $00, $30, $C0, $00, $CC, $C0, $00, $CF 
      .byte $00, $00, $FC, $00, $00, $30, $00, $00 
      .byte $30, $00, $00, $F0, $00, $00, $F0, $00 
      .byte $00, $FC, $00, $00, $FC, $00, $00, $FC 
      .byte $00, $00, $3C, $00, $00, $30, $00 

// end of sword up and down frames

      .byte $00                         
BITMAP_ROW_HI:
      .byte $20, $21, $22, $23, $25, $26, $27, $28 
      .byte $2A, $2B, $2C, $2D, $2F, $30, $31, $32 
      .byte $34, $35, $36, $37, $39, $3A, $3B, $3C 
      .byte $3E                         
PICKABLE_00_COLOR:
      .byte $11
PICKABLE_01_COLOR:
      .byte $33
PICKABLE_02_COLOR:
      .byte $88
PICKABLE_03_COLOR:
      .byte $22
PICKABLE_04_COLOR:
      .byte $77
PICKABLE_05_COLOR:
      .byte $11
PICKABLE_BITMAP_HI:
      .byte >PICKABLE_00, >PICKABLE_01, >PICKABLE_02, >PICKABLE_03, >PICKABLE_04, >SWORD_R_SHIFT_00 
PICKABLE_BITMAP_LO:
      .byte $A2, $A3, $A0, $A1, $A2, $A0
PICKABLES_HEIGHT:
      .byte $15, $15, $15, $15, $15, $0D
PICKABLE_00:                            // key
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $3C, $00, $00, $CF, $00, $00, $C3 
      .byte $FF, $FF, $F3, $FF, $FF, $F3, $3C, $00 
      .byte $C3, $FF, $00, $CF, $FF, $00, $3C, $CC 
      .byte $00, $00, $C0, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
PICKABLE_01:                            // spade
      .byte $00, $55, $40, $00, $04, $00, $00, $04 
      .byte $00, $00, $04, $00, $00, $04, $00, $00 
      .byte $04, $00, $00, $04, $00, $00, $04, $00 
      .byte $00, $04, $00, $00, $04, $00, $00, $04 
      .byte $00, $00, $04, $00, $00, $04, $00, $01 
      .byte $55, $50, $01, $51, $50, $01, $51, $50 
      .byte $01, $51, $50, $01, $11, $10, $00, $40 
      .byte $40, $00, $11, $00, $00, $04, $00, $00 
PICKABLE_02:                            // barrel
      .byte $00, $00, $00, $00, $15, $40, $00, $55 
      .byte $50, $01, $55, $50, $01, $55, $54, $05 
      .byte $55, $54, $05, $55, $55, $15, $55, $55 
      .byte $10, $15, $55, $05, $45, $55, $15, $51 
      .byte $55, $15, $51, $55, $55, $54, $55, $55 
      .byte $54, $54, $55, $54, $54, $55, $54, $54 
      .byte $55, $54, $50, $14, $51, $50, $14, $51 
      .byte $40, $05, $45, $00, $01, $54, $00, $00 
PICKABLE_03:                            // skull
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $55, $40, $01 
      .byte $55, $50, $05, $55, $54, $05, $04, $14 
      .byte $04, $04, $04, $05, $15, $14, $05, $55 
      .byte $54, $05, $51, $54, $01, $51, $50, $00 
      .byte $55, $40, $00, $55, $40, $00, $44, $40 
      .byte $00, $11, $00, $00, $55, $40, $00, $15 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
PICKABLE_04:                            // cheese
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $50, $00 
      .byte $04, $50, $00, $15, $54, $01, $15, $14 
      .byte $05, $55, $15, $10, $01, $55, $55, $54 
      .byte $00, $11, $55, $15, $15, $45, $55, $55 
      .byte $45, $54, $55, $55, $54, $51, $55, $55 
      .byte $51, $54, $55, $15, $54, $55, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
SFX_NOTE_TABLE_LO:
      .byte <SFX_00, <SFX_01, <SFX_03, <SFX_02 
L1CC4:                                  // possible garbage
      .byte $C0, $D0, $E0, $F0, $00, $00, $00, $00 
      .byte $00, $00, $00, $00          
SFX_NOTE_TABLE_HI:
      .byte >SFX_00, >SFX_01, >SFX_03, >SFX_02 
L1CD4:                                  // possible garbage
      .byte $65, $65, $65, $65, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00          
SWORD_BITMAP_HI:
      .byte $1E, $19, $1B, $1B          
SWORD_BITMAP_LO:
      .byte <SWORD_BITMAP_FRAME_00_LO, <SWORD_BITMAP_FRAME_00_LO, $B8, $B4 
SWORD_05_GO_DIRECTION_LO:
      .byte <SWORD_05_TRY_MOVE_RIGHT, <SWORD_05_TRY_MOVE_LEFT, <SWORD_05_TRY_MOVE_DOWN, <SWORD_05_TRY_MOVE_UP 
      *=$1D00

PIRATE_FRAME_00:
      .byte $01, $43, $00, $05, $93, $C0, $04, $83 
      .byte $C0, $06, $A3, $C0, $1A, $20, $C0, $4A 
      .byte $A0, $C0, $02, $80, $C0, $0A, $83, $C0 
      .byte $2A, $A3, $00, $22, $8F, $00, $28, $BC 
      .byte $00, $2A, $F0, $00, $2A, $80, $00, $5A 
      .byte $80, $00, $55, $A0, $00, $55, $50, $00 
      .byte $54, $54, $00, $54, $54, $00, $50, $54 
      .byte $00, $50, $14, $00, $00, $15, $00, $00 
PIRATE_FRAME_01:
      .byte $00, $50, $00, $01, $64, $00, $01, $20 
      .byte $00, $01, $A8, $00, $06, $88, $00, $12 
      .byte $A8, $00, $00, $A0, $00, $02, $A0, $00 
      .byte $0A, $A8, $00, $08, $A8, $00, $08, $A8 
      .byte $00, $0A, $F8, $00, $0A, $F0, $F0, $06 
      .byte $BF, $F0, $05, $5F, $C0, $05, $54, $00 
      .byte $05, $14, $00, $05, $14, $00, $05, $14 
      .byte $00, $14, $14, $00, $14, $15, $00, $00 
PIRATE_FRAME_02:
      .byte $00, $14, $00, $00, $65, $00, $00, $21 
      .byte $00, $00, $A9, $00, $00, $8A, $40, $00 
      .byte $AA, $10, $00, $28, $00, $00, $2A, $00 
      .byte $00, $AA, $80, $00, $A8, $80, $00, $A8 
      .byte $80, $00, $BE, $80, $3C, $3D, $40, $3F 
      .byte $F5, $40, $0F, $D5, $40, $00, $51, $40 
      .byte $00, $51, $40, $00, $51, $40, $00, $51 
      .byte $40, $00, $51, $50, $01, $50, $50, $00 
PIRATE_FRAME_03:
      .byte $03, $05, $00, $0F, $19, $40, $0F, $08 
      .byte $40, $0F, $2A, $40, $0C, $22, $90, $0C 
      .byte $2A, $84, $0C, $0A, $00, $0F, $0A, $80 
      .byte $03, $2A, $A0, $03, $EA, $20, $00, $F8 
      .byte $A0, $00, $3E, $A0, $00, $0A, $50, $00 
      .byte $05, $50, $00, $05, $54, $00, $14, $54 
      .byte $00, $14, $54, $00, $14, $54, $00, $14 
      .byte $14, $00, $14, $14, $00, $54, $00, $FF 
SWORD_R_SHIFT_00:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $C0, $00, $00, $30, $03, $00 
      .byte $30, $0F, $C0, $FF, $FF, $C0, $CF, $FF 
      .byte $00, $CC, $FC, $00, $30, $00, $00 
SWORD_R_SHIFT_01:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $30, $00, $00, $0C, $00, $C0 
      .byte $0C, $03, $F0, $3F, $FF, $F0, $33, $FF 
      .byte $C0, $33, $3F, $00, $0C, $00, $00 
SWORD_R_SHIFT_02:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $0C, $00, $00, $03, $00, $30 
      .byte $03, $00, $FC, $0F, $FF, $FC, $0C, $FF 
      .byte $F0, $0C, $CF, $C0, $03, $00, $00 
SWORD_R_SHIFT_03:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $03, $00, $00, $00, $C0, $0C 
      .byte $00, $C0, $3F, $03, $FF, $FF, $03, $3F 
      .byte $FC, $03, $33, $F0, $00, $C0, $00 

// end of sword shift right frames

      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00          

// =====================================
// The positions for pirates in the room
// each byte contains both x and y
// coordinates in 8x8 pixel resolution
// if the room does not have a pirate
// then the value is $00
// =====================================

PIRATE_POSITIONS:
      .byte $E5, $39, $39, $55, $E5, $59, $59, $55 
      .byte $73, $E9, $35, $E9, $53, $59, $73, $77 
      .byte $D1, $35, $95, $79, $37, $E5, $D9, $33 
      .byte $99, $B5, $33, $53, $33, $39, $39, $33 
      .byte $00, $E3, $E3, $E3, $B3, $E3, $DB, $77 
      .byte $B1, $99, $53, $B1, $33, $E9, $95, $33 
      .byte $E9, $33, $33, $BB, $B9, $E3, $37, $00 
      .byte $97, $93, $00, $53, $00, $57, $E3, $37 

// =====================================
// Draw objects
// =====================================

DRAW_OBJECTS:
      lda  SHIP_GATE_PLACE              
      beq  W1F37                        // If ship gate is open, do not render any pickable item
      ldx  ROOM_NO                      
      lda  ROOM_FLAGS,x                 
      bpl  W1F34                        // Is pirate in room?

// =====================================
// Render pirate in the room
// =====================================

      pha                               
      and  #$30                         
      lsr                               
      lsr                               
      lsr                               
      lsr                               
      tay                               
      lda  PIRATE_COLORS,y              
      sta  SPRITE_02_COLOR              
      lda  #$73                         
      sta  SPRITE_02_LUM                
      pla                               
      tay                               
      and  #$40                         
      beq  W1F27                        
      lda  #$80                         
W1F27:
      sta  zp33                         
      tya                               
      pha                               
      lda  PIRATE_POSITIONS,x           
      ldx  #$02                         // Sprite $02 index (pirate)
      jsr  DRAW_ROOM_OBJECT             
      pla                               

// =====================================
// Render pickable object in the room
// =====================================

W1F34:
      tay                               
      and  #$08                         // %00001000 Pickable in room
W1F37:
      beq  W1F88                        
      tya                               
      and  #$07                         
      tay                               
      lda  PICKABLE_00_COLOR,y          
      sta  SPRITE_07_COLOR              
      lda  #$55                         
      sta  SPRITE_07_LUM                
      lda  PICKABLE_BITMAP_HI,y         
      sta  SPRITE_07_BITMAP_HI          
      lda  PICKABLE_BITMAP_LO,y         
      sta  SPRITE_07_BITMAP_LO          
      lda  PICKABLES_HEIGHT,y           
      sta  SPRITE_07_HEIGHT             
      lda  PICKABLES_POINTS,y           
      sta  PICKABLE_POINT               
      ldx  ROOM_NO                      
      lda  PICKABLE_POSITIONS,x         
      ldx  #$07                         // Sprite $07 index

DRAW_ROOM_OBJECT:
      pha                               
      and  #$F0                         // The high nibble contains x position
      sec                               
      sbc  #$08                         // substract $08 from x position (?)
      sta  ACTOR_X,x                    
      pla                               
      asl                               
      asl                               
      asl                               
      asl                               // The low nibble contains y position
      sec                               
      sbc  #$08                         // substract $08 from y position (?)
      sta  ACTOR_Y,x                    
      lda  VISIBLE_SPRITE               
      ora  BITS,x                       // Turn on sprite $02 or $07
      sta  VISIBLE_SPRITE               
      lda  #$01                         
      jsr  DRAW_SPRITE                  // Draw sprite $02 or $07
W1F88:
      rts                               

      .byte $00                         // possible garbage
      .byte $00, $00, $00, $00, $00, $00

// ======================================
// Checking actor hit treasure chest
// ======================================

CHECK_ACTOR_CHEST:
      lda  ROOM_NO                      
      bne  W1FD8                        
      lda  TREASURE_CHEST_PLACE         
      beq  W1FD8                        // Is "treasure chest" present ?
      lda  CHEST_NOT_FOUND              
      beq  W1FD8                        
      lda  ACTOR_Y                      
      cmp  #$78                         
      bcc  W1FD8                        
      lda  ACTOR_X                      
      cmp  #$78                         
      bcc  W1FD8                        
      cmp  #$D8                         
      bcs  W1FD8                        
      lda  #$00                         
      sta  SHIP_GATE_PLACE              // Open enterance to the ship
      sta  CHEST_NOT_FOUND              
      ldx  #$01                         
      lda  #$05                         
      jsr  ADD_TO_SCORE                 
      jsr  IRQ_RESTORE                  
      lda  #$01                         
      sta  MUSIC_NUMBER                 
      sta  MUSIC_NUMBER                 
      jsr  MUSIC_PLAY                   
      lda  #$03                         
      sta  MUSIC_NUMBER                 
      jsr  MUSIC_PLAY                   
      jsr  IRQ_SETUP                    
W1FD8:
      rts                               

      .byte $60                         // possible garbage
      .byte $60, $00, $00, $00, $00, $00

// ======================================
// The was game successfully finished
// ======================================

GAME_FINISHED:
      lda  #$03                         
      sta  MUSIC_NUMBER                 
      jsr  MUSIC_PLAY                   
      jmp  GAME_TITLE                   

      *=$2000

BITMAP:
      .byte $89, $89, $89, $89, $89, $89, $89, $89 
      .byte $89, $89, $89, $89, $87, $89, $89, $89 
      .byte $89, $89, $89, $87, $87, $87, $89, $89 
      .byte $89, $89, $89, $87, $87, $87, $87, $87 
      .byte $87, $87, $87, $87, $87, $87, $87, $87 
      .byte $89, $89, $87, $87, $87, $87, $89, $89 
      .byte $89, $89, $89, $87, $87, $87, $89, $89 
      .byte $89, $89, $89, $87, $87, $87, $89, $89 
      .byte $89, $89, $87, $87, $87, $87, $89, $89 
      .byte $89, $87, $87, $87, $87, $87, $89, $88 
      .byte $87, $87, $87, $87, $87, $87, $87, $87 
      .byte $89, $87, $87, $89, $89, $87, $89, $00 
      .byte $89, $87, $87, $87, $87, $87, $87, $00 
      .byte $89, $89, $89, $89, $87, $87, $87, $99 
      .byte $89, $89, $89, $89, $87, $87, $87, $89 
      .byte $89, $89, $89, $89, $89, $89, $89, $89 
      .byte $89, $89, $89, $89, $89, $89, $89, $89 
      .byte $00, $55, $55, $55, $11, $00, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $10, $50, $44 
      .byte $00, $00, $00, $00, $00, $04, $11, $10 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $0A, $2A, $2A, $AA, $A9 
      .byte $00, $00, $00, $00, $80, $A0, $A8, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $04, $15, $11, $00, $14 
      .byte $00, $00, $00, $00, $00, $40, $45, $15 
      .byte $00, $00, $00, $00, $00, $50, $44, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $20, $00, $16, $20, $00, $79, $20, $00 
      .byte $7A, $20, $00, $18, $20, $90, $1F, $AD 
      .byte $1C, $6E, $C9, $00, $D0, $15, $A2, $80 
      .byte $AD, $03, $15, $10, $02, $A2, $A0, $86 
      .byte $02, $AD, $1D, $FF, $C5, $02, $90, $F9 
      .byte $20, $00, $12, $20, $70, $79, $20, $20 
      .byte $14, $4C, $00, $17, $00, $00, $00, $00 
      .byte $00, $00, $00, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $9A, $9A, $AA, $6A, $66, $66, $66, $56 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $AA, $A5 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $56, $5A 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $05, $15, $10, $40, $00, $01, $05 
      .byte $15, $14, $44, $19, $59, $48, $48, $08 
      .byte $01, $40, $15, $05, $51, $16, $02, $08 
      .byte $40, $40, $14, $51, $41, $04, $40, $10 
      .byte $00, $00, $00, $00, $02, $0A, $2A, $A9 
      .byte $00, $00, $00, $0A, $9A, $A6, $A9, $6A 
      .byte $02, $0A, $2A, $AA, $AA, $AA, $A9, $66 
      .byte $A5, $99, $AA, $AA, $AA, $AA, $5A, $A6 
      .byte $AA, $6A, $AA, $6A, $5A, $AA, $A9, $AA 
      .byte $80, $A0, $A8, $AA, $A5, $5A, $AA, $AA 
      .byte $00, $00, $00, $00, $28, $AA, $AA, $A5 
      .byte $00, $00, $00, $00, $00, $80, $A0, $68 
      .byte $55, $41, $00, $14, $55, $41, $40, $00 
      .byte $14, $44, $51, $45, $54, $90, $80, $80 
      .byte $00, $01, $41, $54, $05, $54, $15, $19 
      .byte $50, $54, $44, $00, $00, $54, $45, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5D, $5D, $57, $55, $55, $55, $55, $55 
      .byte $5D, $D7, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $D5, $77, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $59, $55, $55 
      .byte $59, $59, $59, $59, $55, $55, $55, $56 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $14, $10, $00, $00, $00, $00, $00, $00 
      .byte $20, $20, $20, $20, $20, $20, $80, $82 
      .byte $08, $20, $20, $20, $80, $80, $80, $00 
      .byte $04, $04, $04, $04, $10, $00, $00, $00 
      .byte $A6, $0A, $2A, $2A, $AA, $AA, $00, $02 
      .byte $9A, $A6, $AA, $A9, $A6, $5A, $2A, $AA 
      .byte $9A, $9A, $6A, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $AA, $A9, $9A, $66, $A9, $A9, $AA, $AA 
      .byte $9A, $6A, $AA, $AA, $A9, $A6, $6A, $6A 
      .byte $80, $A0, $A8, $AA, $6A, $80, $A0, $A0 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $80, $80, $80, $80, $80, $80, $80, $80 
      .byte $08, $08, $08, $08, $08, $08, $08, $08 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $01, $06 
      .byte $00, $00, $00, $00, $00, $00, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $40, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $40 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $15 
      .byte $00, $00, $00, $00, $00, $00, $00, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $40 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $7D, $D7, $D5, $D5, $F7, $7D 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $75, $D5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $56, $5A, $5A, $6A, $6A, $6A, $AA, $AA 
      .byte $AA, $9A, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $01, $15 
      .byte $82, $82, $82, $88, $88, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $54, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $54 
      .byte $2A, $AA, $AA, $02, $0A, $2A, $00, $00 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $26, $0A 
      .byte $AA, $AA, $A9, $A6, $9A, $6A, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $96, $A9, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $00, $00, $00, $02 
      .byte $AA, $AA, $AA, $A9, $02, $0A, $2A, $AA 
      .byte $9A, $96, $69, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $6A, $80, $A0, $A8, $AA, $AA 
      .byte $00, $00, $01, $01, $01, $04, $15, $00 
      .byte $80, $80, $80, $90, $90, $54, $15, $01 
      .byte $08, $08, $09, $09, $15, $55, $14, $51 
      .byte $00, $00, $00, $00, $40, $10, $44, $00 
      .byte $1A, $1A, $6A, $6A, $6A, $6A, $1A, $15 
      .byte $95, $95, $A5, $A5, $A5, $A5, $A5, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $A6, $9A, $96, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $50, $50, $54, $54, $54, $54, $54, $54 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $66, $66, $66, $66, $66, $65, $65, $55 
      .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $02, $02, $02, $02, $02, $02, $02, $02 
      .byte $14, $51, $11, $11, $51, $11, $05, $00 
      .byte $00, $40, $40, $40, $40, $40, $00, $00 
      .byte $00, $00, $00, $00, $0A, $08, $08, $08 
      .byte $00, $00, $00, $00, $AA, $AA, $2A, $0A 
      .byte $00, $00, $00, $00, $A8, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $80, $A0 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $01, $01, $01, $02, $01, $01, $01, $01 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $56, $56, $56, $59, $65, $56, $56, $56 
      .byte $55, $55, $55, $95, $65, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $6A, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $95, $55, $55, $55, $55, $55, $55 
      .byte $56, $56, $5A, $5A, $5A, $6A, $6A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $02, $02, $0A, $0A, $22, $22, $82, $82 
      .byte $AA, $02, $02, $02, $02, $02, $02, $02 
      .byte $AA, $00, $00, $00, $00, $00, $00, $00 
      .byte $AA, $00, $00, $00, $00, $00, $00, $00 
      .byte $AA, $08, $08, $08, $08, $08, $08, $0A 
      .byte $08, $88, $28, $0A, $08, $08, $08, $08 
      .byte $00, $00, $00, $AA, $00, $00, $00, $00 
      .byte $20, $20, $20, $A0, $20, $20, $20, $28 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $01, $05, $05, $16, $16, $42, $0A, $2A 
      .byte $40, $50, $20, $A0, $80, $A0, $80, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $05, $05, $05, $05, $0A, $05, $05, $05 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $56, $56, $56, $56, $96, $96, $66, $66 
      .byte $55, $55, $55, $55, $59, $59, $65, $65 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $54, $54, $54, $54, $54, $54, $54, $94 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $65, $55, $55, $55, $55 
      .byte $68, $62, $4A, $6A, $6A, $6A, $6A, $6A 
      .byte $AA, $2A, $8A, $A2, $AA, $AA, $A6, $AA 
      .byte $AA, $AA, $AA, $9A, $65, $A9, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $88, $88, $AA, $88, $88, $8A, $88, $88 
      .byte $88, $88, $AA, $88, $88, $88, $AA, $95 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $AA 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $A8, $88, $88, $A8, $88, $88 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $2A, $2A, $2A, $28, $2B, $3F, $3F, $33 
      .byte $80, $A0, $AF, $AC, $00, $C0, $C0, $F0 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $05, $06, $06, $06, $16, $16, $15, $15 
      .byte $95, $56, $56, $56, $66, $99, $55, $55 
      .byte $55, $55, $55, $6A, $55, $55, $55, $55 
      .byte $5A, $5A, $56, $A9, $5A, $6A, $6A, $99 
      .byte $95, $95, $55, $55, $AA, $55, $55, $95 
      .byte $5A, $59, $59, $65, $A6, $59, $5A, $55 
      .byte $54, $54, $94, $54, $50, $90, $50, $50 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $A8, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $88, $88, $A8, $88, $88, $88, $88, $AA 
      .byte $95, $95, $95, $95, $95, $95, $95, $95 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $88, $88, $88, $88, $88, $A8 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $3C, $FC, $F0, $C0, $C0, $00, $00, $00 
      .byte $F0, $F0, $3C, $3C, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $15, $15, $15, $15, $15, $15, $15, $2A 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $56, $56, $55, $55, $55, $55, $55 
      .byte $99, $59, $59, $59, $59, $59, $59, $59 
      .byte $95, $65, $65, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $50, $50, $50, $50, $50, $50, $50, $50 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $5F, $7D, $75, $77, $75 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $66, $66, $66, $66, $66, $65, $65 
W2A4F:
      .byte $55, $6A, $6A, $6A, $6A, $6A, $6A, $6A 
W2A57:
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $0A, $2A, $2A, $AA 
      .byte $A9, $00, $00, $00, $00, $80, $A0, $A8 
      .byte $AA, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $0A, $2A, $2A, $AA 
      .byte $A9, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $65, $65, $65, $65, $65, $65, $65 
      .byte $65, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $6A 
      .byte $55, $40, $40, $40, $40, $40, $40, $80 
      .byte $40, $5F, $55, $55, $55, $55, $55, $57 
      .byte $55, $55, $75, $57, $55, $55, $55, $55 
      .byte $55, $55, $55, $75, $55, $55, $55, $55 
      .byte $55, $55, $55, $75, $55, $55, $55, $55 
      .byte $55, $5F, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $57 
      .byte $5D, $75, $55, $55, $55, $55, $55, $D5 
      .byte $75, $D5, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $95, $55, $55, $55, $55, $55 
      .byte $55                         
COPYRIGHT_01_ADDR:
      .byte $56, $56, $5A, $5A, $5A, $6A, $6A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $02, $0A, $2A, $A9 
      .byte $00, $00, $00, $0A, $9A, $A6, $A9, $6A 
      .byte $02, $0A, $2A, $AA, $AA, $AA, $A9, $66 
      .byte $A5, $99, $AA, $AA, $AA, $AA, $5A, $A6 
      .byte $AA, $6A, $AA, $6A, $5A, $AA, $A9, $AA 
      .byte $80                         
COPYRIGHT_03_RIGHT:
      .byte $A0, $A8, $AA, $A5, $5A, $AA, $AA, $00 
      .byte $00, $00, $00, $28, $AA, $AA, $A5, $00 
      .byte $00, $00, $00, $00, $80, $A0, $68, $00 
      .byte $00, $00, $00, $02, $0A, $2A, $A9, $00 
      .byte $00, $00, $0A, $9A, $A6, $A9, $6A, $02 
      .byte $0A, $2A, $AA, $AA, $AA, $A9, $66, $A5 
      .byte $99, $AA, $AA, $AA, $AA, $5A, $A6, $00 
      .byte $00, $00, $00, $01, $01, $01, $02, $A5 
      .byte $55, $55, $55, $55, $55, $55, $A5, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $99 
      .byte $65, $99, $65, $99, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $40 
      .byte $40, $40, $40, $00, $00, $00, $00, $55 
      .byte $55, $55, $55, $75, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $5D, $55, $55 
      .byte $55, $55, $55, $5D, $D5, $55, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $5D 
      .byte $5D, $57, $55, $55, $55, $55, $55, $5D 
      .byte $D7, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $D5, $77, $55, $55, $55, $55, $55 
      .byte $55, $55, $65, $55, $55, $55, $55, $68 
      .byte $62, $4A, $6A, $6A, $6A, $6A, $6A 
COPYRIGHT_02_ADDR:
      .byte $AA, $2A, $8A, $A2, $AA, $AA, $A6, $AA 
      .byte $AA, $AA, $AA, $9A, $65, $A9, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $A6, $0A, $2A, $2A, $AA, $AA, $00, $02 
      .byte $9A, $A6, $AA, $A9, $A6, $5A, $2A, $AA 
      .byte $9A, $9A, $6A, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $AA, $A9, $9A, $66, $A9, $A9, $AA, $AA 
      .byte $9A, $6A, $AA, $AA, $A9, $A6, $6A, $6A 
      .byte $80, $A0, $A8, $AA, $6A, $80, $A0, $A0 
      .byte $A6, $0A, $2A, $2A, $AA, $AA, $00, $02 
      .byte $9A, $A6, $AA, $A9, $A6, $5A, $2A, $AA 
      .byte $9A, $9A, $6A, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $01, $01, $01, $01, $01, $01, $01, $01 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $56, $56, $55, $65, $59, $56, $55 
      .byte $A5, $59, $55, $95, $65, $65, $95, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $6A, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $7D, $D7, $D5, $D5, $F7, $7D 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $75, $D5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $A8, $AA, $AA, $AA, $AA, $AA, $AA 
COPYRIGHT_03_ADDR:
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $2A, $AA, $AA, $02, $0A, $2A, $00, $00 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $26, $0A 
      .byte $AA, $AA, $A9, $A6, $9A, $6A, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $96, $A9, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $00, $00, $00, $02 
      .byte $AA, $AA, $AA, $A9, $02, $0A, $2A, $AA 
      .byte $9A, $96, $69, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $6A, $80, $A0, $A8, $AA, $AA 
      .byte $2A, $AA, $AA, $02, $0A, $2A, $00, $00 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $26, $0A 
      .byte $AA, $AA, $A9, $A6, $9A, $6A, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $96, $A9, $AA, $AA 
      .byte $05, $05, $05, $0A, $05, $05, $05, $05 
      .byte $55, $55, $55, $55, $55, $55, $55, $6A 
      .byte $55, $55, $55, $55, $55, $55, $95, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $5A 
      .byte $55, $55, $55, $55, $55, $55, $5A, $66 
      .byte $68, $54, $54, $54, $54, $54, $54, $54 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $5F, $7D, $75, $77, $75 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $9A, $98, $9A, $9A, $9A, $AA, $AA, $AA 
      .byte $6A, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $9A 
      .byte $00, $00, $00, $00, $80, $A0, $A8, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $05, $05, $05, $05, $15, $15, $16, $15 
      .byte $95, $95, $95, $69, $56, $56, $56, $96 
      .byte $55, $56, $59, $65, $65, $65, $65, $66 
      .byte $59, $66, $66, $66, $66, $66, $66, $59 
      .byte $66, $65, $65, $65, $65, $65, $65, $55 
      .byte $66, $69, $65, $65, $66, $59, $55, $55 
      .byte $54, $54, $54, $54, $50, $50, $50, $50 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $5F, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $57, $5D 
      .byte $75, $55, $55, $55, $55, $55, $D5, $75 
      .byte $D5, $55, $55, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $56, $56, $56, $56, $5A, $5A, $5A, $5A 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $6A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $66 
      .byte $AA, $6A, $AA, $6A, $5A, $AA, $A9, $AA 
      .byte $80, $A0, $A8, $AA, $A5, $5A, $AA, $AA 
      .byte $00, $00, $00, $00, $28, $AA, $AA, $A5 
      .byte $00, $00, $00, $00, $00, $80, $A0, $68 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $14, $65, $21, $A9, $8A, $AA, $28, $2A 
      .byte $00, $00, $00, $00, $40, $10, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $15, $15, $15, $15, $15, $15, $15, $29 
      .byte $69, $55, $55, $55, $55, $55, $55, $55 
      .byte $59, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $65 
      .byte $50, $50, $50, $A0, $50, $50, $50, $50 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5D, $5D, $57, $55, $55, $55, $55, $55 
      .byte $5D, $D7, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $D5, $77, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $5A, $5A, $5A, $5A, $56, $56, $5A, $5A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $A6, $AA, $AA, $AA, $AA, $AA, $6A 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $6A, $AA 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $AA, $A9, $9A, $66, $A9, $A9, $AA, $AA 
      .byte $9A, $6A, $AA, $AA, $A9, $A6, $6A, $6A 
      .byte $80, $A0, $A8, $AA, $6A, $80, $A0, $A0 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $3C, $3F, $0F, $00 
      .byte $AA, $A8, $A8, $BE, $3D, $F5, $D5, $51 
      .byte $80, $80, $80, $80, $40, $40, $40, $40 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $15, $15, $15, $15, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
SCORE_DISPLAY_ADDR:
      .byte $FD, $DD, $DD, $DD, $DD, $DD, $DD, $FD 
      .byte $FD, $DD, $DD, $DD, $DD, $DD, $DD, $FD 
      .byte $FD, $DD, $DD, $DD, $DD, $DD, $DD, $FD 
      .byte $99, $99, $66, $56, $59, $59, $65, $66 
      .byte $90, $90, $50, $50, $40, $40, $40, $40 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $7D, $D7, $D5, $D5, $F7, $7D 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $75, $D5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5A, $59, $59, $59, $59, $59, $55, $55 
      .byte $AA, $AA, $AA, $AA, $9A, $9A, $9A, $9A 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $99, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A8, $A0 
      .byte $AA, $AA, $AA, $AA, $00, $00, $00, $02 
      .byte $AA, $AA, $AA, $A9, $02, $0A, $2A, $AA 
      .byte $9A, $96, $69, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $6A, $80, $A0, $A8, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $01, $00, $00, $00 
      .byte $51, $51, $51, $51, $50, $00, $00, $00 
      .byte $40, $40, $40, $50, $50, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $A9, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $99, $59, $56, $55, $55, $55, $55, $55 
      .byte $80, $80, $40, $40, $40, $40, $40, $40 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $56, $56, $56, $56, $56, $56, $56, $56 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $AA, $AA, $6A, $AA, $AA, $AA 
      .byte $00, $02, $8A, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $9A, $A6, $A9, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $0A, $A6, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $0A, $A6, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $9A, $AA, $AA, $AA 
      .byte $AA, $AA, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $80, $60, $A8, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $9A, $A6, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A6, $99, $6A, $AA, $AA, $AA, $AA, $6A 
      .byte $A6, $99, $6A, $9A, $A6, $AA, $AA, $AA 
      .byte $6A, $9A, $AA, $AA, $AA, $AA, $A9, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $80, $A2, $AA, $AA, $A9, $AA, $AA, $AA 
      .byte $A0, $A8, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $82, $A2, $AA, $AA, $AA, $AA, $AA 
      .byte $28, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $0A, $2A, $AA, $AA, $AA, $A9, $A6, $9A 
      .byte $A8, $AA, $AA, $AA, $6A, $9A, $A6, $A9 
      .byte $55, $55, $55, $55, $55, $56, $56, $58 
      .byte $55, $55, $55, $55, $55, $AA, $2A, $08 
      .byte $55, $55, $55, $55, $55, $A5, $AA, $0A 
      .byte $55, $55, $55, $55, $55, $55, $A5, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $40, $40, $40, $40, $40, $40, $40, $40 
      .byte $00, $00, $00, $00, $00, $00, $00, $2A 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $56, $56, $56, $56, $55, $55, $55, $55 
      .byte $6A, $6A, $6A, $6A, $9A, $9A, $9A, $9A 
      .byte $AA, $A6, $AA, $AA, $AA, $AA, $A9, $A6 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $9A, $A6 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A9, $99 
      .byte $AA, $A9, $A9, $A9, $A9, $99, $99, $99 
      .byte $AA, $A9, $99, $99, $99, $99, $99, $99 
      .byte $A9, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $9A, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $AA, $AA, $A9, $99, $99, $99, $99 
      .byte $AA, $AA, $AA, $AA, $9A, $99, $99, $99 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $99 
      .byte $AA, $AA, $AA, $A6, $AA, $AA, $AA, $AA 
      .byte $AA, $A9, $A6, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $9A, $A6, $A9, $AA, $6A, $AA, $AA 
      .byte $AA, $9A, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $A2, $8A, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $2A, $8A, $AA, $AA, $AA, $A9, $99 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $99 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $9A 
      .byte $58, $58, $58, $56, $55, $15, $15, $05 
      .byte $0A, $08, $02, $AA, $56, $56, $56, $58 
      .byte $AA, $00, $AA, $00, $AA, $00, $AA, $0A 
      .byte $AA, $2A, $AA, $00, $AA, $0A, $AA, $AA 
      .byte $AA, $AA, $AA, $2A, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $A8, $AA, $80, $AA, $A8 
      .byte $82, $AA, $AA, $00, $AA, $08, $A8, $08 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5A, $5A, $5A, $5A, $5A, $5A, $6A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $9A, $AA, $AA, $A9 
      .byte $99, $99, $99, $99, $99, $99, $99, $AA 
      .byte $9A, $99, $99, $99, $99, $A5, $55, $55 
      .byte $99, $6A, $55, $55, $55, $55, $55, $55 
      .byte $99, $A5, $55, $55, $55, $55, $55, $55 
      .byte $AA, $55, $55, $55, $55, $55, $55, $55 
      .byte $99, $6A, $55, $55, $55, $55, $55, $55 
      .byte $99, $AA, $55, $55, $55, $55, $55, $55 
      .byte $AA, $55, $55, $55, $55, $55, $55, $55 
      .byte $A9, $5A, $55, $55, $55, $55, $55, $55 
      .byte $99, $99, $99, $99, $9A, $65, $55, $55 
      .byte $99, $99, $99, $99, $A9, $5A, $55, $55 
      .byte $99, $99, $99, $99, $99, $99, $A9, $5A 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $9A, $99, $99, $99, $99, $99, $99 
      .byte $AA, $A9, $99, $99, $99, $99, $99, $99 
      .byte $AA, $A9, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $9A 
      .byte $99, $99, $99, $99, $99, $99, $9A, $A5 
      .byte $99, $99, $99, $99, $99, $99, $A9, $5A 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $05, $01, $01, $00, $00, $00, $00, $00 
      .byte $5A, $6A, $AA, $00, $00, $00, $00, $00 
      .byte $AA, $AA, $A0, $00, $00, $00, $00, $00 
      .byte $AA, $02, $00, $00, $00, $00, $00, $00 
      .byte $AA, $AA, $00, $00, $00, $00, $00, $00 
      .byte $AA, $AA, $02, $00, $00, $00, $00, $00 
      .byte $AA, $AA, $AA, $02, $00, $00, $00, $00 
      .byte $A0, $20, $80, $80, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $95, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $99, $99, $99, $99 
      .byte $AA, $AA, $A6, $99, $99, $99, $99, $99 
      .byte $AA, $99, $99, $99, $99, $99, $95, $95 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $59, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $59, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $95, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $59, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $A9, $56, $55, $55, $55, $55, $55, $55 
      .byte $99, $A9, $56, $55, $55, $55, $55, $55 
      .byte $99, $9A, $A5, $55, $55, $55, $55, $55 
      .byte $AA, $95, $55, $55, $55, $55, $55, $55 
      .byte $A5, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $59, $5A, $59, $59, $69, $65, $A5, $65 
      .byte $56, $59, $99, $99, $99, $99, $65, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $50, $00 
      .byte $55, $55, $55, $55, $55, $45, $05, $05 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $55, $55, $55, $5F, $7D, $75, $77, $75 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $65, $65, $95 
      .byte $55, $55, $56, $55, $55, $55, $55, $95 
      .byte $55, $95, $A5, $95, $95, $95, $95, $55 
      .byte $55, $55, $55, $55, $55, $A9, $96, $A5 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $54, $54, $50, $50, $40, $40, $40, $00 
      .byte $00, $00, $03, $03, $0C, $0C, $0C, $0C 
      .byte $05, $15, $15, $15, $15, $15, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $57, $5D 
      .byte $75, $55, $55, $55, $55, $55, $D5, $75 
      .byte $D5, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $95, $99, $99, $66, $55, $55, $55, $55 
      .byte $9A, $95, $95, $55, $55, $55, $56, $55 
      .byte $69, $55, $95, $95, $95, $95, $A5, $95 
      .byte $99, $95, $A9, $96, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $54, $54, $54, $54 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0C, $0C, $0C, $03, $03, $00, $00 
      .byte $55, $15, $15, $15, $15, $15, $15, $05 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5D, $5D, $57, $55, $55, $55, $55, $55 
      .byte $5D, $D7, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $D5, $77, $55, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $56, $59, $56, $55, $65, $5A 
      .byte $55, $A5, $59, $55, $95, $65, $65, $95 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $75, $D5, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $7D, $D7, $D5, $D5, $F7, $7D 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $75, $D5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $01, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $16, $00, $9D, $30, $2C, $12, $12, $00 
      .byte $00, $00, $24, $30, $58, $17, $36, $00 
//
// ======================================
// Room tile data pointers
//
// The lowbyte is in "ROOM_DATA_HI" but the
// hibyte is shared among group of 16
// rooms in "ROOMS_DATA_LO" table
// =====================================

ROOMS_DATA_HI:
      .byte >ROOM_00, >ROOM_01, >ROOM_02, >ROOM_03, >ROOM_04, >ROOM_05, >ROOM_06, >ROOM_07 
      .byte >ROOM_08, >ROOM_09, >ROOM_10, >ROOM_11, >ROOM_12, >ROOM_13, >ROOM_14, >ROOM_15 
      .byte >ROOM_16, >ROOM_17, >ROOM_18, >ROOM_19, >ROOM_20, >ROOM_21, >ROOM_22, >ROOM_23 
      .byte >ROOM_24, >ROOM_25, >ROOM_26, >ROOM_27, >ROOM_28, >ROOM_29, >ROOM_30, >ROOM_31 
      .byte >ROOM_32, >ROOM_33, >ROOM_34, >ROOM_35, >ROOM_36, >ROOM_37, >ROOM_38, >ROOM_39 
      .byte >ROOM_40, >ROOM_41, >ROOM_42, >ROOM_43, >ROOM_44, >ROOM_45, >ROOM_46, >ROOM_47 
      .byte >ROOM_48, >ROOM_49, >ROOM_50, >ROOM_51, >ROOM_52, >ROOM_53, >ROOM_54, >ROOM_55 
      .byte >ROOM_56, >ROOM_57, >ROOM_58, >ROOM_59, >ROOM_60, >ROOM_61, >ROOM_62, >ROOM_63 
      .byte >ROOM_TITLE, >ROOM_TITLE    
ROOMS_DATA_LO:
      .byte <ROOM_00, <ROOM_01, <ROOM_02, <ROOM_03, <ROOM_04, <ROOM_05, <ROOM_06, <ROOM_07 
      .byte <ROOM_08, <ROOM_09, <ROOM_10, <ROOM_11, <ROOM_12, <ROOM_13, <ROOM_14, <ROOM_15 
TILE_TARGET_LO:
      .byte $00, $20, $40, $60, $80, $A0, $C0, $E0 
TILE_TARGET_HI:
      .byte $20, $25, $2A, $2F, $34, $39
TILE_ATTR_TARGET_LO:
      .byte $00, $04, $08, $0C, $10, $14, $18, $1C 
      .byte $A0, $A4, $A8, $AC, $B0, $B4, $B8, $BC 
      .byte $40, $44, $48, $4C, $50, $54, $58, $5C 
      .byte $E0, $E4, $E8, $EC, $F0, $F4, $F8, $FC 
      .byte $80, $84, $88, $8C, $90, $94, $98, $9C 
      .byte $20, $24, $28, $2C, $30, $34, $38, $3C 
TILE_ATTR_TARGET_HI:
      .byte $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C 
      .byte $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C 
      .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D 
      .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D 
      .byte $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E 
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
TILE_ATTR_DATA_LO:
      .byte $00, $10, $20, $30, $40, $50, $60, $70 
      .byte $80, $90, $A0, $B0, $C0, $D0, $E0, $F0 

// ====================================
// Draw sprite
//
// The sprite is always 3 characters (byte) 
// width, and sprites has variable height 
// defined in the table "SPRITES_ROWS_TABLE"
//
// Sprite number
//   0 = Actor
//   1 = Unused ?
//   2 = Pirate
//   3 = John Silver
//   4 = Unused ?
//   5 = Sword (Actor)
//   6 = Sword (Pirate)
//   7 = Pickable item (sword, treasure)
//
//  XR = Sprite number
//  Z = Flag ($00 = Erase, $01 = Draw)
// ====================================

DRAW_SPRITE:
      stx  SPRITE_NUMBER                
      php                               
      lda  SPRITE_ROWS_TABLE,x          
      sta  zp0c                         // Sprite rows
      plp                               
      bne  W3F33                        

// Erase sprite image

      jsr  GET_SPR_ATTR_ADDR            // Calculate LUMINANCE address
      ldx  zp0c                         
W3F20:
      ldy  #$02                         // Sprite is always 3 bytes wide
      lda  #$00                         
W3F24:
      sta  (PTR_LO),y                   // Set luminance to $00 which effectly means hide the bitmap data
      dey                               
      bpl  W3F24                        
      dex                               
      bmi  W3F71                        
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      bcs  W3F20                        

// Draw or erase sprite image

W3F33:
      lda  SPRITE_00_COLOR,x            
      sta  zp0d                         
      lda  SPRITE_00_LUM,x              
      sta  zp02                         
      jsr  GET_SPR_ATTR_ADDR            // Calculate LUMINANCE address
      clc                               
      adc  #$04                         
      sta  zp32                         // Calculate COLOR address
      lda  PTR_LO                       
      sta  zp31                         

// ===================================
// Set sprite luminance and color
// PTR = Luminance address
// DESTINATION = Color address
// zp02 = Luminance code
// SPRITE_COLOR = Sprite color code
// ===================================

      ldx  zp0c                         
W3F4B:
      ldy  #$02                         // Sprite attribute is always 3 byte wide
W3F4D:
      lda  zp02                         
      sta  (PTR_LO),y                   // Set sprite luminance
      lda  zp0d                         
      sta  (zp31),y                     // Set sprite color
      dey                               
      bpl  W3F4D                        
      dex                               
      bmi  W3F71                        
      clc                               
      lda  PTR_LO                       
      adc  #$28                         
      sta  PTR_LO                       
      sta  zp31                         
      lda  PTR_HI                       
      adc  #$00                         
      sta  PTR_HI                       // Add 40 to PTR = next attribute line
      clc                               
      adc  #$04                         
      sta  zp32                         // Update color attr address
      bpl  W3F4B                        

// =====================================
// Draw sprite image data
// =====================================

W3F71:
      ldx  SPRITE_NUMBER                
      lda  #>SPRITE_BITMAP_FRAME_00_LO  // The base address of sprite bitmap data pointer ($1500)
      sta  PTR_HI                       
      lda  ACTOR_X,x                    
      and  #$F8                         
      sta  SPRITE_BYTE_POS              
      txa                               
      clc                               
      adc  W1538,x                      
      tay                               
      lda  ACTOR_Y,y                    
      and  #$07                         
      lsr                               
      tay                               
      lda  SPRITE_00_BITMAP_LO,x        
      sta  PTR_LO                       
      lda  (PTR_LO),y                   
      sta  PTR_LO                       
      lda  SPRITE_00_BITMAP_HI,x        
      sta  PTR_HI                       
      lda  ACTOR_Y,x                    
      tay                               
      clc                               
      adc  SPRITE_00_HEIGHT,x           
      sta  zp02                         
      tya                               
      tax                               
DRAW_SPRITE_LOOP:
      txa                               
      and  #$1F                         
      tay                               
      clc                               
      lda  SPRITE_FINE_Y,y              
      adc  SPRITE_BYTE_POS              
      sta  zp31                         
      php                               
      txa                               
      lsr                               
      lsr                               
      lsr                               
      tay                               
      plp                               
      lda  BITMAP_ROW_HI,y              
      adc  #$00                         
      sta  zp32                         // zp31/zp32 pointer to the copy destination 
      stx  zp59                         
      ldy  #$00                         
      ldx  #$00                         
W3FC5:
      lda  (PTR_LO,x)                   
      inc  PTR_LO                       
      eor  (zp31),y                     // Draw or erase sprite bitmap
      sta  (zp31),y                     
      tya                               
      clc                               
      adc  #$08                         
      tay                               
      cmp  #$18                         
      bne  W3FC5                        
      ldx  zp59                         
      inx                               
      cpx  zp02                         
      bne  DRAW_SPRITE_LOOP             
      ldx  SPRITE_NUMBER                
      rts                               

SPRITE_FINE_Y:
      .byte $00, $01, $02, $03, $04, $05, $06, $07 
      .byte $40, $41, $42, $43, $44, $45, $46, $47 
      .byte $80, $81, $82, $83, $84, $85, $86, $87 
      .byte $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7 

// ======================================
// Start of tile graphics data
// Each tile has size of 128 bytes (4*32)
// ======================================

TILE_BITMAP_DATA:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $57, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $57, $55 
      .byte $55, $75, $57, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $75, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $75, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $5D, $55 
      .byte $55, $55, $55, $55, $5D, $D5, $55, $55 
      .byte $55, $55, $55, $55, $55, $75, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $5D, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $02, $0A, $2A, $AA, $AA, $AA, $AA 
      .byte $20, $28, $2A, $8A, $A2, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $2A, $82, $AA, $AA, $AA, $AA, $AA, $6A 
      .byte $6A, $5A, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $66 
      .byte $A9, $A6, $9A, $9A, $AA, $AA, $AA, $6A 
      .byte $95, $A5, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $A6, $9A, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $A6, $6A, $9A, $A6, $AA, $AA, $AA 
      .byte $9A, $A6, $AA, $AA, $AA, $A9, $AA, $AA 
      .byte $AA, $AA, $AA, $96, $69, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $6A, $9A, $A5, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $A5, $96 
      .byte $55, $55, $55, $5F, $7D, $75, $77, $75 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5F, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $57, $5D 
      .byte $75, $55, $55, $55, $55, $55, $D5, $75 
      .byte $D5, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5D, $5D, $57, $55, $55, $55, $55, $55 
      .byte $5D, $D7, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $D5, $77, $55, $55, $55, $55 
      .byte $55, $55, $7D, $D7, $D5, $D5, $F7, $7D 
      .byte $55, $55, $55, $55, $D5, $75, $5D, $57 
      .byte $55, $55, $55, $55, $55, $55, $75, $D5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $50, $00 
      .byte $55, $55, $55, $55, $55, $45, $05, $05 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $54, $54, $50, $50, $40, $40, $40, $00 
      .byte $00, $00, $03, $03, $0C, $0C, $0C, $0C 
      .byte $05, $15, $15, $15, $15, $15, $55, $55 
      .byte $55, $55, $55, $55, $54, $54, $54, $54 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0C, $0C, $0C, $03, $03, $00, $00 
      .byte $55, $15, $15, $15, $15, $15, $15, $05 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $75, $D5, $55, $55, $55, $55, $55 
      .byte $57, $55, $57, $5D, $75, $55, $55, $55 
      .byte $57, $DD, $77, $DD, $75, $75, $75, $55 
      .byte $55, $D5, $55, $75, $55, $5D, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $50, $40, $40, $40, $40, $40, $40, $40 
      .byte $01, $00, $00, $00, $0C, $0C, $00, $00 
      .byte $55, $55, $15, $05, $01, $00, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $55, $15 
      .byte $40, $50, $55, $50, $50, $54, $55, $55 
      .byte $00, $00, $40, $54, $01, $00, $40, $54 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $05, $05, $01, $01, $01, $00, $00, $00 
      .byte $5D, $77, $D5, $55, $55, $5D, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $45, $41, $50, $50, $54, $54, $54, $54 
      .byte $55, $55, $55, $55, $15, $05, $04, $00 
      .byte $55, $55, $50, $41, $41, $05, $05, $05 
      .byte $55, $55, $55, $55, $55, $55, $55, $54 
      .byte $54, $54, $50, $50, $40, $40, $00, $00 
      .byte $00, $02, $08, $08, $21, $81, $85, $15 
      .byte $05, $15, $55, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $55, $55, $55 
      .byte $5D, $77, $D5, $55, $55, $57, $55, $55 
      .byte $5D, $75, $5D, $55, $55, $55, $D5, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $5A 
      .byte $55, $55, $55, $55, $95, $95, $95, $A9 
      .byte $56, $56, $5A, $56, $56, $56, $6A, $56 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $65, $59, $56, $55, $55, $55, $55 
      .byte $95, $95, $95, $95, $95, $95, $95, $95 
      .byte $56, $56, $56, $AA, $56, $56, $56, $56 
      .byte $5A, $5A, $5A, $56, $56, $55, $55, $55 
      .byte $95, $A5, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $95, $95, $A5, $AA, $AA, $22, $22, $AA 
      .byte $56, $56, $56, $AA, $AA, $22, $22, $AA 
      .byte $55, $55, $55, $55, $59, $56, $55, $55 
      .byte $40, $40, $40, $55, $59, $66, $95, $55 
      .byte $00, $00, $00, $55, $59, $66, $95, $55 
      .byte $00, $00, $00, $55, $59, $66, $95, $55 
      .byte $55, $55, $95, $55, $55, $55, $A5, $55 
      .byte $55, $55, $56, $56, $6A, $56, $56, $56 
      .byte $55, $55, $55, $55, $A5, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $A9, $55, $55, $55, $55 
      .byte $56, $56, $AA, $56, $56, $56, $56, $56 
      .byte $55, $55, $A9, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $59, $65 
      .byte $55, $55, $55, $AA, $AA, $22, $22, $AA 
      .byte $56, $6A, $AA, $AA, $AA, $2A, $2A, $AA 
      .byte $55, $A6, $A9, $A5, $A5, $95, $95, $55 
      .byte $95, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $55, $59, $66, $95, $55 
      .byte $00, $01, $01, $55, $59, $66, $95, $55 
      .byte $55, $55, $55, $55, $55, $55, $95, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $59, $5A, $59, $59, $69, $65, $A5, $65 
      .byte $56, $59, $99, $99, $99, $99, $65, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $65, $65, $95 
      .byte $55, $55, $56, $55, $55, $55, $55, $95 
      .byte $55, $95, $A5, $95, $95, $95, $95, $55 
      .byte $55, $55, $55, $55, $55, $A9, $96, $A5 
      .byte $95, $99, $99, $66, $55, $55, $55, $55 
      .byte $9A, $95, $95, $55, $55, $55, $56, $55 
      .byte $69, $55, $95, $95, $95, $95, $A5, $95 
      .byte $99, $95, $A9, $96, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $56, $59, $56, $55, $65, $5A 
      .byte $55, $A5, $59, $55, $95, $65, $65, $95 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $04, $15, $11, $00, $14 
      .byte $00, $00, $00, $00, $00, $40, $45, $15 
      .byte $00, $00, $00, $00, $00, $50, $44, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $41, $00, $14, $55, $41, $40, $00 
      .byte $14, $44, $51, $45, $54, $90, $80, $80 
      .byte $00, $01, $41, $54, $05, $54, $15, $19 
      .byte $50, $54, $44, $00, $00, $54, $45, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $80, $80, $80, $80, $80, $80, $80, $80 
      .byte $08, $08, $08, $08, $08, $08, $08, $08 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $01, $01, $01, $04, $15, $00 
      .byte $80, $80, $80, $90, $90, $54, $15, $01 
      .byte $08, $08, $09, $09, $15, $55, $14, $51 
      .byte $00, $00, $00, $00, $40, $10, $44, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $05, $15, $15, $55, $56 
      .byte $00, $00, $00, $00, $01, $05, $15, $56 
      .byte $00, $00, $00, $05, $65, $59, $56, $95 
      .byte $01, $05, $15, $55, $55, $55, $56, $99 
      .byte $5A, $66, $55, $55, $55, $55, $A5, $59 
      .byte $59, $05, $15, $15, $55, $55, $00, $01 
      .byte $65, $59, $55, $56, $59, $A5, $15, $55 
      .byte $65, $65, $95, $55, $55, $55, $55, $55 
      .byte $56, $55, $55, $55, $55, $55, $55, $55 
      .byte $15, $55, $55, $01, $05, $15, $00, $00 
      .byte $55, $55, $55, $55, $55, $56, $19, $05 
      .byte $55, $55, $56, $59, $65, $95, $55, $55 
      .byte $55, $55, $55, $95, $69, $56, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $0A, $2A, $2A, $AA, $A9 
      .byte $00, $00, $00, $00, $02, $0A, $2A, $A9 
      .byte $00, $00, $00, $0A, $9A, $A6, $A9, $6A 
      .byte $02, $0A, $2A, $AA, $AA, $AA, $A9, $66 
      .byte $A5, $99, $AA, $AA, $AA, $AA, $5A, $A6 
      .byte $A6, $0A, $2A, $2A, $AA, $AA, $00, $02 
      .byte $9A, $A6, $AA, $A9, $A6, $5A, $2A, $AA 
      .byte $9A, $9A, $6A, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $2A, $AA, $AA, $02, $0A, $2A, $00, $00 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $26, $0A 
      .byte $AA, $AA, $A9, $A6, $9A, $6A, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $96, $A9, $AA, $AA 
      .byte $00, $00, $00, $00, $40, $50, $54, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $95, $55, $95, $A5, $55, $56, $55 
      .byte $40, $50, $54, $55, $5A, $A5, $55, $55 
      .byte $00, $00, $00, $00, $14, $55, $55, $5A 
      .byte $00, $00, $00, $00, $00, $40, $50, $94 
      .byte $55, $55, $55, $55, $56, $59, $65, $95 
      .byte $55, $56, $65, $99, $56, $56, $55, $55 
      .byte $65, $95, $55, $55, $56, $59, $95, $95 
      .byte $40, $50, $54, $55, $95, $40, $50, $50 
      .byte $55, $55, $55, $55, $00, $00, $00, $01 
      .byte $55, $55, $55, $56, $01, $05, $15, $55 
      .byte $65, $69, $96, $55, $55, $55, $55, $55 
      .byte $54, $55, $95, $40, $50, $54, $55, $55 
      .byte $00, $00, $00, $00, $80, $A0, $A8, $AA 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $AA, $6A, $AA, $6A, $5A, $AA, $A9, $AA 
      .byte $80, $A0, $A8, $AA, $A5, $5A, $AA, $AA 
      .byte $00, $00, $00, $00, $28, $AA, $AA, $A5 
      .byte $00, $00, $00, $00, $00, $80, $A0, $68 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $AA, $A9, $9A, $66, $A9, $A9, $AA, $AA 
      .byte $9A, $6A, $AA, $AA, $A9, $A6, $6A, $6A 
      .byte $80, $A0, $A8, $AA, $6A, $80, $A0, $A0 
      .byte $AA, $AA, $AA, $AA, $00, $00, $00, $02 
      .byte $AA, $AA, $AA, $A9, $02, $0A, $2A, $AA 
      .byte $9A, $96, $69, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $6A, $80, $A0, $A8, $AA, $AA 
      .byte $02, $02, $02, $02, $0A, $0A, $0A, $0A 
      .byte $00, $00, $00, $00, $00, $80, $80, $A0 
      .byte $00, $00, $00, $02, $02, $02, $0A, $0A 
      .byte $00, $00, $00, $00, $00, $00, $80, $80 
      .byte $09, $29, $2A, $26, $25, $25, $25, $26 
      .byte $80, $60, $60, $60, $A8, $A9, $AA, $AA 
      .byte $2A, $2A, $99, $99, $59, $69, $65, $55 
      .byte $80, $A0, $A0, $60, $60, $58, $94, $94 
      .byte $56, $56, $59, $59, $09, $15, $15, $15 
      .byte $A6, $66, $65, $65, $59, $56, $56, $59 
      .byte $95, $95, $A5, $A5, $60, $60, $58, $94 
      .byte $64, $55, $55, $55, $54, $00, $00, $00 
      .byte $55, $55, $55, $15, $00, $00, $00, $00 
      .byte $55, $55, $55, $55, $54, $00, $00, $00 
      .byte $55, $55, $55, $50, $00, $00, $00, $00 
      .byte $00, $40, $50, $14, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $55, $55 
      .byte $00, $22, $20, $08, $02, $02, $00, $50 
      .byte $80, $08, $82, $82, $08, $20, $80, $80 
      .byte $00, $00, $00, $00, $00, $00, $01, $15 
      .byte $55, $55, $55, $55, $55, $52, $55, $55 
      .byte $54, $55, $55, $55, $55, $55, $95, $44 
      .byte $05, $55, $55, $55, $55, $55, $45, $15 
      .byte $55, $55, $55, $55, $51, $45, $15, $55 
      .byte $55, $42, $54, $55, $55, $55, $55, $55 
      .byte $55, $55, $95, $05, $51, $55, $55, $55 
      .byte $55, $55, $95, $40, $55, $55, $55, $56 
      .byte $55, $45, $15, $55, $55, $59, $A5, $55 
      .byte $01, $00, $00, $00, $00, $00, $00, $00 
      .byte $55, $05, $00, $00, $00, $00, $00, $00 
      .byte $55, $55, $50, $00, $00, $00, $00, $00 
      .byte $55, $40, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $05, $55 
      .byte $00, $00, $00, $00, $01, $15, $55, $55 
      .byte $00, $00, $00, $05, $55, $55, $55, $55 
      .byte $00, $00, $00, $00, $40, $54, $55, $55 
      .byte $55, $55, $55, $50, $55, $55, $55, $56 
      .byte $55, $60, $45, $15, $55, $55, $65, $95 
      .byte $40, $55, $55, $55, $55, $55, $55, $50 
      .byte $55, $05, $55, $55, $55, $55, $55, $55 
      .byte $69, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $54, $51, $55, $55, $55, $54, $40 
      .byte $45, $15, $55, $55, $55, $41, $00, $00 
      .byte $15, $65, $59, $55, $55, $55, $15, $01 
      .byte $50, $00, $20, $08, $08, $02, $00, $00 
      .byte $00, $88, $22, $82, $88, $08, $A0, $20 
      .byte $00, $08, $20, $22, $22, $08, $02, $02 
      .byte $22, $82, $88, $08, $20, $20, $80, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $02, $02, $02, $02, $02, $02, $02, $02 
      .byte $14, $51, $11, $11, $51, $11, $05, $00 
      .byte $00, $40, $40, $40, $40, $40, $00, $00 
      .byte $02, $02, $0A, $0A, $22, $22, $82, $82 
      .byte $AA, $02, $02, $02, $02, $02, $02, $02 
      .byte $AA, $00, $00, $00, $00, $00, $00, $00 
      .byte $AA, $00, $00, $00, $00, $00, $00, $00 
      .byte $88, $88, $AA, $88, $88, $8A, $88, $88 
      .byte $88, $88, $AA, $88, $88, $88, $AA, $95 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $A8, $88, $88, $88, $88, $AA 
      .byte $95, $95, $95, $95, $95, $95, $95, $95 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $00, $00, $00, $00, $0A, $08, $08, $08 
      .byte $00, $00, $00, $00, $AA, $AA, $2A, $0A 
      .byte $00, $00, $00, $00, $A8, $AA, $AA, $AA 
      .byte $00, $00, $00, $00, $00, $00, $80, $A0 
      .byte $AA, $08, $08, $08, $08, $08, $08, $0A 
      .byte $08, $88, $28, $0A, $08, $08, $08, $08 
      .byte $00, $00, $00, $AA, $00, $00, $00, $00 
      .byte $20, $20, $20, $A0, $20, $20, $20, $28 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $AA 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $AA, $88, $88, $A8, $88, $88 
      .byte $88, $88, $A8, $88, $88, $A8, $88, $88 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $8A, $88, $88, $88, $88, $AA 
      .byte $88, $88, $88, $88, $88, $88, $88, $A8 
      .byte $FF, $22, $22, $22, $22, $22, $22, $22 
      .byte $FF, $22, $22, $22, $22, $22, $22, $22 
      .byte $FF, $22, $22, $22, $22, $22, $22, $22 
      .byte $FF, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $22, $22, $22, $22, $22, $22, $22, $FF 
      .byte $22, $22, $22, $22, $22, $22, $22, $FF 
      .byte $22, $22, $22, $22, $22, $22, $22, $FF 
      .byte $22, $22, $22, $22, $22, $22, $22, $FF 
      .byte $80, $A0, $88, $88, $88, $88, $88, $88 
      .byte $00, $01, $00, $05, $00, $05, $00, $05 
      .byte $00, $40, $00, $50, $00, $50, $00, $50 
      .byte $02, $0A, $22, $22, $22, $22, $22, $22 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $00, $01, $00, $51, $00, $40, $00, $40 
      .byte $00, $40, $00, $45, $00, $01, $00, $01 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $00, $50, $00, $54, $00, $55, $00, $14 
      .byte $00, $05, $00, $15, $00, $55, $00, $14 
      .byte $22, $22, $22, $22, $22, $22, $22, $22 
      .byte $88, $88, $88, $88, $88, $88, $A0, $80 
      .byte $00, $14, $00, $14, $00, $14, $00, $14 
      .byte $00, $14, $00, $14, $00, $14, $00, $14 
      .byte $22, $22, $22, $22, $22, $22, $0A, $02 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $AA, $A5, $99, $99, $99, $99, $99 
      .byte $00, $AA, $55, $55, $55, $55, $55, $55 
      .byte $00, $80, $90, $94, $94, $94, $94, $94 
      .byte $00, $00, $00, $01, $01, $06, $06, $1A 
      .byte $68, $49, $62, $A8, $29, $A2, $AA, $98 
      .byte $98, $8A, $A6, $8A, $28, $A6, $89, $A9 
      .byte $94, $94, $94, $90, $80, $40, $40, $40 
      .byte $2A, $25, $25, $25, $25, $25, $25, $25 
      .byte $AA, $55, $65, $65, $55, $55, $55, $55 
      .byte $A9, $59, $59, $59, $59, $59, $59, $59 
      .byte $40, $42, $48, $60, $62, $A2, $88, $08 
      .byte $95, $6A, $AA, $AA, $AA, $00, $00, $00 
      .byte $6A, $9A, $A6, $A9, $A6, $0A, $2A, $00 
      .byte $AA, $A9, $A6, $5A, $A9, $AA, $AA, $AA 
      .byte $96, $69, $AA, $AA, $5A, $A5, $AA, $00 
      .byte $00, $00, $00, $00, $00, $01, $01, $06 
      .byte $00, $00, $00, $11, $46, $55, $65, $55 
      .byte $00, $00, $11, $14, $55, $54, $55, $65 
      .byte $00, $00, $00, $00, $10, $40, $00, $40 
      .byte $00, $01, $05, $11, $01, $05, $25, $45 
      .byte $55, $95, $55, $59, $55, $55, $54, $95 
      .byte $55, $56, $55, $59, $55, $55, $56, $55 
      .byte $44, $50, $40, $50, $40, $01, $44, $90 
      .byte $05, $15, $09, $05, $15, $05, $15, $59 
      .byte $55, $55, $56, $55, $55, $55, $55, $16 
      .byte $95, $55, $56, $59, $55, $95, $55, $55 
      .byte $14, $50, $40, $44, $90, $54, $49, $55 
      .byte $55, $55, $16, $15, $11, $40, $04, $00 
      .byte $51, $65, $15, $44, $55, $15, $11, $00 
      .byte $95, $45, $51, $51, $15, $45, $54, $10 
      .byte $44, $50, $54, $10, $54, $44, $11, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $0A, $2A, $1A, $55 
      .byte $00, $00, $00, $A0, $A8, $A8, $95, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $01, $01, $05, $05, $15, $15, $15 
      .byte $55, $55, $59, $55, $65, $95, $95, $55 
      .byte $65, $59, $56, $56, $55, $65, $55, $95 
      .byte $40, $40, $50, $50, $94, $54, $65, $65 
      .byte $59, $55, $55, $15, $06, $01, $00, $00 
      .byte $59, $55, $65, $95, $55, $55, $15, $05 
      .byte $65, $59, $56, $55, $55, $55, $50, $40 
      .byte $59, $55, $54, $50, $40, $20, $08, $08 
      .byte $20, $22, $82, $80, $22, $22, $08, $00 
      .byte $08, $08, $20, $80, $00, $00, $00, $00 
      .byte $00, $20, $80, $82, $22, $08, $02, $02 
      .byte $20, $20, $80, $00, $08, $20, $80, $00 
      .byte $00, $00, $00, $03, $03, $0F, $0F, $0F 
      .byte $0F, $3F, $FF, $FF, $FF, $FF, $FF, $FF 
      .byte $C0, $F0, $FC, $FF, $FF, $FF, $FF, $FF 
      .byte $00, $00, $00, $00, $00, $C0, $C0, $C0 
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $03 
      .byte $CF, $03, $03, $C3, $FF, $FF, $FC, $FC 
      .byte $CF, $03, $03, $0F, $FF, $FF, $FF, $FF 
      .byte $C0, $C0, $C0, $C0, $C0, $C0, $C0, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $0F 
      .byte $FF, $FF, $CC, $CC, $FF, $3F, $0F, $00 
      .byte $FC, $FC, $CC, $CC, $FC, $F0, $C0, $03 
      .byte $00, $00, $00, $00, $00, $00, $00, $C0 
      .byte $3F, $0F, $00, $00, $0F, $3F, $0F, $00 
      .byte $F0, $F0, $0F, $FF, $FF, $F0, $00, $00 
      .byte $3F, $FF, $FF, $F0, $0F, $0F, $00, $00 
      .byte $F0, $C0, $00, $00, $C0, $F0, $C0, $00 
      .byte $55, $55, $54, $52, $52, $52, $52, $52 
      .byte $40, $00, $AA, $A8, $A2, $A2, $8A, $80 
      .byte $00, $AA, $AA, $02, $A8, $02, $AA, $00 
      .byte $15, $80, $AA, $AA, $28, $02, $8A, $2A 
      .byte $4A, $4A, $4A, $4A, $4A, $4A, $4A, $2A 
      .byte $8A, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $8A, $8A, $8A, $8A, $8A, $8A, $8A, $8A 
      .byte $AA, $AA, $AA, $AA, $AA, $A8, $AA, $AA 
      .byte $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A 
      .byte $AA, $AA, $AA, $A8, $AA, $AA, $AA, $AA 
      .byte $8A, $82, $28, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $40, $15, $45, $10, $15, $15, $40, $55 
      .byte $AA, $0A, $50, $51, $11, $15, $55, $55 
      .byte $AA, $AA, $00, $11, $11, $55, $55, $55 
      .byte $AA, $AA, $00, $11, $11, $55, $55, $55 
      .byte $55, $00, $AA, $0A, $AA, $AA, $80, $A2 
      .byte $55, $11, $80, $AA, $AA, $AA, $0A, $88 
      .byte $55, $11, $00, $AA, $AA, $AA, $0A, $02 
      .byte $55, $11, $01, $A0, $AA, $AA, $82, $00 
      .byte $A2, $8A, $8A, $2A, $2A, $0A, $AA, $AA 
      .byte $A8, $A8, $A0, $A2, $A2, $A8, $AA, $AA 
      .byte $A2, $A2, $0A, $A8, $88, $28, $AA, $AA 
      .byte $28, $80, $02, $A2, $A2, $02, $0A, $A0 
      .byte $AA, $AA, $AA, $96, $6A, $65, $69, $96 
      .byte $AA, $AA, $AA, $95, $9A, $9A, $9A, $95 
      .byte $AA, $AA, $AA, $AA, $6A, $6A, $6A, $AA 
      .byte $8A, $00, $AA, $AA, $AA, $A8, $A8, $A8 
      .byte $AA, $AA, $AA, $00, $11, $11, $55, $55 
      .byte $AA, $AA, $AA, $2A, $00, $11, $51, $55 
      .byte $AA, $AA, $A8, $AA, $00, $11, $11, $55 
      .byte $80, $2A, $00, $AA, $0A, $10, $11, $51 
      .byte $55, $55, $11, $00, $AA, $AA, $A8, $A0 
      .byte $55, $55, $11, $01, $A8, $AA, $2A, $0A 
      .byte $55, $55, $55, $11, $00, $AA, $AA, $A2 
      .byte $55, $55, $55, $11, $00, $AA, $AA, $28 
      .byte $A2, $A2, $A8, $AA, $8A, $00, $A0, $00 
      .byte $AA, $AA, $28, $88, $88, $28, $28, $AA 
      .byte $22, $22, $A2, $A2, $A2, $A2, $02, $02 
      .byte $00, $A2, $8A, $8A, $8A, $2A, $2A, $02 
      .byte $A8, $02, $2A, $2A, $2A, $AA, $AA, $AA 
      .byte $AA, $AA, $82, $00, $2A, $2A, $82, $A8 
      .byte $A8, $A2, $A0, $A2, $A2, $A2, $A2, $A2 
      .byte $AA, $AA, $AA, $A0, $80, $8A, $A0, $80 
      .byte $00, $A2, $0A, $AA, $AA, $00, $11, $55 
      .byte $28, $00, $82, $AA, $AA, $0A, $10, $51 
      .byte $A2, $A2, $A2, $82, $A2, $AA, $00, $11 
      .byte $28, $28, $00, $82, $AA, $AA, $00, $11 
      .byte $55, $55, $55, $11, $01, $A8, $AA, $AA 
      .byte $55, $55, $55, $55, $11, $00, $AA, $AA 
      .byte $55, $54, $55, $11, $00, $AA, $AA, $AA 
      .byte $01, $54, $04, $54, $01, $A8, $A8, $A8 
      .byte $28, $20, $A2, $A2, $80, $8A, $8A, $80 
      .byte $2A, $0A, $8A, $8A, $2A, $AA, $2A, $2A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A8 
      .byte $A8, $A8, $A8, $A8, $21, $21, $21, $A1 
      .byte $A0, $AA, $AA, $A2, $A2, $20, $22, $A2 
      .byte $AA, $AA, $AA, $AA, $2A, $08, $88, $88 
      .byte $A8, $A8, $A2, $A2, $02, $02, $A2, $A2 
      .byte $A1, $A1, $A1, $A1, $A1, $85, $85, $85 
      .byte $A2, $A2, $A2, $22, $AA, $AA, $0A, $50 
      .byte $88, $88, $28, $28, $AA, $AA, $AA, $00 
      .byte $A2, $A2, $02, $0A, $AA, $A8, $A8, $01 
      .byte $85, $85, $85, $15, $15, $55, $55, $55 
      .byte $55, $65, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $56, $6A 
      .byte $55, $55, $55, $56, $55, $55, $56, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $A9 
      .byte $55, $56, $56, $6A, $6A, $6A, $6A, $5A 
      .byte $AA, $AA, $AA, $AA, $99, $66, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A9 
      .byte $5A, $5A, $59, $59, $59, $59, $66, $66 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $A6, $AA, $AA, $AA, $AA 
      .byte $A6, $9A, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $66, $66, $59, $59, $59, $59, $59, $59 
      .byte $A6, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $99, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $65, $55, $55, $55, $55, $55 
      .byte $A5, $A9, $AA, $AA, $AA, $AA, $55, $96 
      .byte $55, $55, $56, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $AA, $AA, $AA, $AA, $AA, $AA, $A2 
      .byte $95, $95, $A5, $A5, $A5, $A9, $A9, $A9 
      .byte $9A, $A6, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $A6 
      .byte $AA, $AA, $AA, $9A, $66, $AA, $AA, $AA 
      .byte $AA, $AA, $A6, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A6, $A6, $A6, $A6, $99, $99, $99, $99 
      .byte $56, $56, $56, $56, $56, $56, $56, $56 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $AA, $AA, $6A, $AA, $AA, $AA 
      .byte $00, $02, $8A, $AA, $AA, $AA, $AA, $AA 
      .byte $56, $56, $56, $56, $55, $55, $55, $55 
      .byte $6A, $6A, $6A, $6A, $9A, $9A, $9A, $9A 
      .byte $AA, $A6, $AA, $AA, $AA, $AA, $A9, $A6 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $9A, $A6 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $5A, $5A, $5A, $5A, $5A, $5A, $6A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $9A, $AA, $AA, $A9 
      .byte $55, $95, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $99, $99, $99, $99 
      .byte $AA, $AA, $A6, $99, $99, $99, $99, $99 
      .byte $AA, $99, $99, $99, $99, $99, $95, $95 
      .byte $0A, $2A, $AA, $AA, $AA, $AA, $A9, $AA 
      .byte $6A, $9A, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $9A, $AA, $AA, $AA, $AA, $AA 
      .byte $95, $95, $95, $95, $95, $95, $95, $95 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $5A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $9A, $A6 
      .byte $96, $69, $AA, $AA, $AA, $AA, $AA, $A9 
      .byte $A5, $A5, $A5, $A5, $A5, $95, $95, $95 
      .byte $2A, $AA, $AA, $AA, $AA, $A9, $99, $99 
      .byte $AA, $AA, $AA, $AA, $A9, $99, $99, $99 
      .byte $AA, $AA, $AA, $AA, $9A, $9A, $99, $99 
      .byte $A9, $99, $99, $99, $99, $99, $95, $95 
      .byte $99, $99, $99, $99, $95, $55, $55, $55 
      .byte $99, $99, $99, $95, $55, $55, $55, $55 
      .byte $99, $99, $99, $59, $55, $55, $55, $55 
      .byte $95, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $66, $66, $66, $66, $66, $65, $65, $55 
      .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $55, $95, $55, $55, $55, $55, $55, $55 
      .byte $56, $56, $5A, $5A, $5A, $6A, $6A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $55, $55, $55, $65, $55, $55, $55, $55 
      .byte $68, $62, $4A, $6A, $6A, $6A, $6A, $6A 
      .byte $AA, $2A, $8A, $A2, $AA, $AA, $A6, $AA 
      .byte $AA, $AA, $AA, $9A, $65, $A9, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $A8, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $59, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $59, $55 
      .byte $A5, $AA, $AA, $AA, $AA, $9A, $69, $AA 
      .byte $55, $95, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $55, $55, $55, $95, $A5, $A9, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $95, $A5 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $AA, $AA, $A9, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $A5, $AA 
      .byte $AA, $6A, $AA, $AA, $AA, $AA, $8A, $02 
      .byte $AA, $A9, $A6, $9A, $6A, $AA, $AA, $AA 
      .byte $AA, $AA, $6A, $9A, $9A, $A6, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $68, $A0 
      .byte $55, $55, $55, $55, $55, $55, $56, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $56, $5A 
      .byte $55, $55, $55, $56, $5A, $6A, $AA, $AA 
      .byte $55, $56, $6A, $AA, $AA, $AA, $AA, $AA 
      .byte $5A, $A9, $A6, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $5A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $6A, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $68, $A0 
      .byte $9A, $66, $AA, $AA, $AA, $2A, $0A, $00 
      .byte $AA, $A9, $A6, $A6, $9A, $AA, $AA, $0A 
      .byte $6A, $9A, $A9, $A6, $9A, $AA, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $95, $A5, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $55, $55, $55, $55, $99, $AA, $AA, $AA 
      .byte $55, $55, $56, $6A, $AA, $AA, $AA, $AA 
      .byte $5A, $6A, $AA, $AA, $A9, $A6, $9A, $AA 
      .byte $A6, $99, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $9A, $66, $A9, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $6A, $AA 
      .byte $AA, $9A, $66, $A9, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $6A, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $5A 
      .byte $55, $55, $55, $55, $59, $5A, $9A, $AA 
      .byte $55, $55, $55, $A5, $A9, $AA, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $95, $A9 
      .byte $6A, $9A, $A6, $A9, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $9A, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $A9, $A6, $9A, $AA, $AA, $AA 
      .byte $AA, $6A, $9A, $A6, $A9, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $9A, $AA, $AA, $A8 
      .byte $AA, $AA, $AA, $AA, $AA, $8A, $02, $00 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $2A 
      .byte $AA, $AA, $A9, $A6, $9A, $AA, $AA, $AA 
      .byte $55, $55, $95, $55, $55, $55, $55, $55 
      .byte $AA, $A8, $A2, $9A, $9A, $9A, $9A, $9A 
      .byte $2A, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $AA, $AA, $AA, $AA, $A8, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $9A, $9A, $AA, $6A, $66, $66, $66, $56 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $AA, $A5 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $56, $5A 
      .byte $55, $55, $55, $55, $55, $59, $55, $55 
      .byte $59, $59, $59, $59, $55, $55, $55, $56 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $6A, $AA, $AA, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $56, $5A, $5A, $6A, $6A, $6A, $AA, $AA 
      .byte $AA, $9A, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $AA, $AA 
      .byte $AA, $AA, $9A, $AA, $AA, $AA, $A9, $A6 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $9A, $A6 
      .byte $95, $95, $95, $95, $95, $95, $A5, $A5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $9A, $6A, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $A5, $A5, $A5, $A5, $A5, $A9, $A9, $A9 
      .byte $55, $55, $95, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $29, $A9, $A9, $A9, $A9, $A5, $A5, $A5 
      .byte $55, $55, $95, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A9, $A6 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $6A 
      .byte $A5, $A5, $A5, $A5, $AA, $99, $99, $99 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $0A, $2A, $AA, $AA, $A6, $AA, $AA, $AA 
      .byte $AA, $AA, $A9, $A9, $A6, $A6, $A6, $A6 
      .byte $65, $65, $95, $95, $65, $65, $65, $65 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $6A, $9A, $A6, $A9, $AA, $AA 
      .byte $A6, $A6, $A6, $A5, $A5, $A5, $A5, $A5 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $65, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $9A, $AA, $AA, $AA 
      .byte $A9, $A9, $A9, $A9, $A9, $A9, $A9, $A9 
      .byte $55, $55, $56, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $6A, $95, $A5, $A6, $9A, $AA 
      .byte $AA, $AA, $6A, $9A, $A6, $AA, $AA, $AA 
      .byte $55, $55, $95, $95, $A5, $A5, $A5, $95 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $65, $A6, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $99, $99, $99, $99, $65, $65, $65, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $A6, $99, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $29, $89, $A9, $A9, $A9, $A9, $A9 
      .byte $95, $95, $95, $95, $95, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $65, $55 
      .byte $AA, $AA, $AA, $AA, $AA, $2A, $0A, $2A 
      .byte $89, $29, $A9, $A9, $A9, $AA, $AA, $AA 
      .byte $55, $55, $55, $55, $55, $56, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A9, $A6 
      .byte $AA, $6A, $AA, $AA, $AA, $AA, $6A, $9A 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $9A, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $A9, $A9, $A9, $A9, $AA, $AA, $AA 
      .byte $95, $95, $95, $95, $95, $95, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $A9, $A6, $9A, $6A 
      .byte $9A, $AA, $AA, $AA, $AA, $6A, $9A, $AA 
      .byte $55, $55, $95, $95, $95, $95, $A5, $A5 
      .byte $55, $55, $65, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $A6, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $6A 
      .byte $A5, $A5, $A5, $A5, $A5, $29, $A9, $A9 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A9, $A6 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $6A 
      .byte $A9, $A9, $A5, $A5, $55, $65, $65, $65 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $9A, $98, $9A, $9A, $9A, $AA, $AA, $AA 
      .byte $6A, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $9A 
      .byte $56, $56, $56, $56, $5A, $5A, $5A, $5A 
      .byte $AA, $AA, $AA, $AA, $AA, $A9, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $6A, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $66 
      .byte $5A, $5A, $5A, $5A, $56, $56, $5A, $5A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A9, $A6, $AA, $AA, $AA, $AA, $AA, $6A 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $6A, $AA 
      .byte $5A, $59, $59, $59, $59, $59, $55, $55 
      .byte $AA, $AA, $AA, $AA, $9A, $9A, $9A, $9A 
      .byte $AA, $AA, $AA, $AA, $AA, $A6, $99, $6A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A8, $A0 
      .byte $6A, $9A, $A6, $A9, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $0A, $A6, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $A8, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A9, $99 
      .byte $AA, $A9, $A9, $A9, $A9, $99, $99, $99 
      .byte $AA, $A9, $99, $99, $99, $99, $99, $99 
      .byte $A9, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $AA 
      .byte $9A, $99, $99, $99, $99, $A5, $55, $55 
      .byte $99, $6A, $55, $55, $55, $55, $55, $55 
      .byte $99, $A5, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $59, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $9A, $A6, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $A6, $99, $6A, $AA, $AA, $AA, $AA, $6A 
      .byte $A6, $99, $6A, $9A, $A6, $AA, $AA, $AA 
      .byte $9A, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $AA, $AA, $A9, $99, $99, $99, $99 
      .byte $AA, $AA, $AA, $AA, $9A, $99, $99, $99 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $99 
      .byte $A9, $5A, $55, $55, $55, $55, $55, $55 
      .byte $99, $99, $99, $99, $9A, $65, $55, $55 
      .byte $99, $99, $99, $99, $A9, $5A, $55, $55 
      .byte $99, $99, $99, $99, $99, $99, $A9, $5A 
      .byte $95, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $59, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $82, $A2, $AA, $AA, $AA, $AA, $AA 
      .byte $28, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $0A, $2A, $AA, $AA, $AA, $A9, $A6, $9A 
      .byte $A8, $AA, $AA, $AA, $6A, $9A, $A6, $A9 
      .byte $A8, $A2, $8A, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $2A, $8A, $AA, $AA, $AA, $A9, $99 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $9A, $99 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $9A 
      .byte $99, $99, $99, $99, $99, $99, $99, $9A 
      .byte $99, $99, $99, $99, $99, $99, $9A, $A5 
      .byte $99, $99, $99, $99, $99, $99, $A9, $5A 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $A5, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $55, $55, $55, $55, $55, $55, $55 
      .byte $6A, $9A, $AA, $AA, $AA, $AA, $A9, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $80, $A2, $AA, $AA, $A9, $AA, $AA, $AA 
      .byte $A0, $A8, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $A6, $AA, $AA, $AA, $AA 
      .byte $AA, $A9, $A6, $AA, $AA, $AA, $AA, $AA 
      .byte $6A, $9A, $A6, $A9, $AA, $6A, $AA, $AA 
      .byte $AA, $9A, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $9A, $99, $99, $99, $99, $99, $99 
      .byte $AA, $A9, $99, $99, $99, $99, $99, $99 
      .byte $AA, $A9, $99, $99, $99, $99, $99, $99 
      .byte $A9, $56, $55, $55, $55, $55, $55, $55 
      .byte $99, $A9, $56, $55, $55, $55, $55, $55 
      .byte $99, $9A, $A5, $55, $55, $55, $55, $55 
      .byte $AA, $95, $55, $55, $55, $55, $55, $55 
      .byte $0A, $A6, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $9A, $AA, $AA, $AA 
      .byte $AA, $AA, $A9, $AA, $AA, $AA, $AA, $AA 
      .byte $80, $60, $A8, $AA, $AA, $AA, $AA, $AA 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $AA, $55, $55, $55, $55, $55, $55, $55 
      .byte $99, $6A, $55, $55, $55, $55, $55, $55 
      .byte $99, $AA, $55, $55, $55, $55, $55, $55 
      .byte $AA, $55, $55, $55, $55, $55, $55, $55 
      .byte $59, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $00, $00, $00, $01, $00, $05, $00, $11 
      .byte $04, $44, $11, $01, $45, $11, $45, $44 
      .byte $50, $11, $14, $41, $14, $44, $11, $45 
      .byte $00, $00, $40, $10, $40, $10, $14, $40 
      .byte $10, $04, $11, $11, $04, $14, $01, $10 
      .byte $14, $41, $14, $11, $40, $90, $80, $A0 
      .byte $41, $14, $40, $11, $06, $08, $20, $20 
      .byte $04, $51, $44, $14, $11, $44, $10, $44 
      .byte $11, $04, $01, $04, $00, $00, $00, $00 
      .byte $28, $08, $0A, $0A, $02, $02, $02, $02 
      .byte $81, $80, $00, $00, $80, $80, $80, $00 
      .byte $11, $44, $10, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $15 
      .byte $02, $02, $02, $02, $0A, $0A, $15, $55 
      .byte $80, $80, $80, $80, $00, $90, $55, $40 
      .byte $00, $00, $00, $00, $00, $88, $28, $5A 
      .byte $00, $00, $00, $01, $01, $01, $05, $05 
      .byte $00, $00, $00, $00, $00, $40, $50, $51 
      .byte $04, $05, $15, $15, $15, $51, $55, $55 
      .byte $00, $00, $40, $40, $40, $50, $50, $50 
      .byte $05, $15, $15, $14, $15, $15, $15, $05 
      .byte $54, $44, $14, $55, $55, $55, $55, $15 
      .byte $54, $55, $51, $15, $15, $15, $14, $11 
      .byte $54, $14, $44, $54, $51, $55, $15, $55 
      .byte $51, $54, $55, $55, $55, $55, $45, $55 
      .byte $45, $51, $15, $55, $55, $45, $45, $51 
      .byte $45, $45, $45, $51, $51, $51, $14, $44 
      .byte $55, $55, $55, $11, $54, $54, $44, $50 
      .byte $55, $55, $15, $15, $05, $01, $00, $00 
      .byte $55, $54, $51, $45, $55, $55, $15, $01 
      .byte $55, $55, $15, $55, $55, $55, $50, $40 
      .byte $40, $00, $00, $40, $50, $04, $00, $00 
      .byte $FF, $88, $88, $88, $88, $88, $88, $88 
      .byte $FF, $88, $88, $88, $88, $88, $88, $88 
      .byte $FF, $88, $88, $88, $88, $88, $88, $88 
      .byte $FF, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $88 
      .byte $88, $88, $88, $88, $88, $88, $88, $FF 
      .byte $88, $88, $88, $88, $88, $88, $88, $FF 
      .byte $88, $88, $88, $88, $88, $88, $88, $FF 
      .byte $88, $88, $88, $88, $88, $88, $88, $FF 
      .byte $AA, $AA, $AA, $AA, $2A, $2A, $2A, $0A 
      .byte $AA, $AA, $AA, $9A, $66, $A9, $AA, $AA 
      .byte $AA, $A6, $99, $AA, $AA, $AA, $AA, $AA 
      .byte $A5, $A5, $A5, $95, $95, $95, $95, $A5 
      .byte $0A, $0A, $0A, $02, $02, $02, $02, $02 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A9, $AA 
      .byte $AA, $AA, $AA, $A6, $99, $6A, $AA, $AA 
      .byte $AA, $AA, $AA, $AA, $AA, $6A, $9A, $A6 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $AA, $AA, $AA, $2A, $02, $00, $00, $00 
      .byte $AA, $AA, $AA, $AA, $AA, $2A, $0A, $AA 
      .byte $A9, $AA, $AA, $AA, $AA, $AA, $AA, $AA 
      .byte $00, $00, $00, $02, $0A, $2A, $0A, $00 
      .byte $02, $0A, $2A, $AA, $AA, $AA, $AA, $0A 
      .byte $AA, $AA, $AA, $AA, $AA, $AA, $A0, $80 
      .byte $AA, $AA, $AA, $A9, $A6, $9A, $AA, $2A 
      .byte $00, $01, $05, $15, $55, $55, $55, $55 
      .byte $10, $14, $15, $45, $51, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $15, $41, $55, $55, $55, $55, $55, $95 
      .byte $95, $A5, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $65, $99 
      .byte $56, $59, $65, $65, $55, $55, $55, $95 
      .byte $6A, $5A, $56, $55, $55, $55, $55, $55 
      .byte $56, $59, $65, $55, $55, $55, $55, $55 
      .byte $56, $59, $95, $65, $59, $55, $55, $55 
      .byte $65, $59, $55, $55, $55, $56, $55, $55 
      .byte $55, $55, $55, $69, $96, $55, $55, $55 
      .byte $55, $55, $55, $55, $95, $65, $5A, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $56, $5A, $69 
      .byte $00, $00, $01, $00, $00, $15, $41, $00 
      .byte $00, $00, $40, $50, $14, $04, $44, $51 
      .byte $00, $00, $00, $00, $00, $10, $50, $44 
      .byte $00, $00, $00, $00, $00, $04, $11, $10 
      .byte $00, $05, $15, $10, $40, $00, $01, $05 
      .byte $15, $14, $44, $19, $59, $48, $48, $08 
      .byte $01, $40, $15, $05, $51, $16, $02, $08 
      .byte $40, $40, $14, $51, $41, $04, $40, $10 
      .byte $14, $10, $00, $00, $00, $00, $00, $00 
      .byte $20, $20, $20, $20, $20, $20, $80, $82 
      .byte $08, $20, $20, $20, $80, $80, $80, $00 
      .byte $04, $04, $04, $04, $10, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $01, $15 
      .byte $82, $82, $82, $88, $88, $55, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $54, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $54 
      .byte $00, $00, $00, $00, $00, $02, $02, $0A 
      .byte $00, $00, $0A, $2A, $AA, $AA, $AA, $AA 
      .byte $2A, $AA, $AA, $AA, $AA, $AA, $00, $00 
      .byte $00, $80, $A0, $A8, $A8, $A8, $A8, $05 
      .byte $0A, $2A, $2A, $2A, $A9, $A9, $A9, $A9 
      .byte $A5, $A5, $95, $95, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $15, $51, $55 
      .byte $55, $55, $55, $55, $45, $15, $55, $55 
      .byte $A9, $A5, $A5, $A5, $A5, $A5, $A0, $A0 
      .byte $5D, $5B, $55, $55, $55, $55, $00, $00 
      .byte $55, $55, $55, $54, $55, $55, $55, $00 
      .byte $55, $51, $15, $55, $55, $55, $55, $55 
      .byte $A0, $A8, $A8, $00, $00, $00, $00, $00 
      .byte $00, $08, $20, $80, $22, $0A, $02, $02 
      .byte $08, $20, $82, $88, $08, $20, $80, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $08, $20, $20, $08, $08, $02, $50 
      .byte $02, $80, $20, $82, $82, $28, $20, $A1 
      .byte $00, $00, $00, $00, $00, $00, $05, $55 
      .byte $00, $00, $00, $00, $00, $50, $54, $54 
      .byte $55, $55, $55, $55, $55, $55, $44, $51 
      .byte $55, $55, $55, $55, $55, $54, $15, $55 
      .byte $55, $55, $55, $45, $55, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $54, $54, $50 
      .byte $55, $55, $45, $57, $55, $55, $55, $54 
      .byte $55, $5D, $F5, $55, $55, $55, $50, $00 
      .byte $15, $55, $55, $54, $50, $00, $00, $88 
      .byte $40, $58, $08, $08, $20, $20, $20, $82 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $02, $02, $00, $00, $00, $00, $00, $00 
      .byte $08, $02, $82, $22, $20, $08, $08, $02 
      .byte $82, $02, $02, $08, $88, $88, $A0, $80 
      .byte $00, $00, $00, $00, $00, $00, $00, $01 
      .byte $00, $00, $00, $00, $40, $40, $40, $50 
      .byte $01, $05, $05, $15, $15, $55, $55, $55 
      .byte $00, $00, $00, $40, $40, $40, $50, $50 
      .byte $01, $01, $01, $05, $05, $05, $05, $05 
      .byte $91, $51, $45, $45, $15, $15, $15, $15 
      .byte $55, $55, $55, $55, $65, $55, $52, $55 
      .byte $54, $54, $94, $55, $55, $55, $55, $55 
      .byte $05, $14, $14, $11, $11, $45, $45, $05 
      .byte $55, $55, $55, $55, $54, $55, $56, $51 
      .byte $55, $45, $15, $55, $55, $55, $55, $55 
      .byte $55, $55, $55, $95, $55, $55, $45, $15 
      .byte $15, $15, $55, $54, $94, $29, $02, $00 
      .byte $49, $65, $15, $55, $55, $45, $55, $A5 
      .byte $54, $54, $54, $59, $51, $59, $65, $98 
      .byte $55, $95, $55, $55, $55, $55, $56, $60 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $0A, $02, $02, $02, $02, $02 
      .byte $00, $00, $A0, $80, $80, $80, $80, $55 
      .byte $00, $00, $00, $00, $00, $00, $54, $01 
      .byte $00, $01, $54, $00, $88, $88, $A8, $88 
      .byte $05, $50, $02, $A2, $82, $A2, $82, $82 
      .byte $00, $20, $20, $20, $20, $20, $28, $80 
      .byte $20, $88, $88, $88, $88, $88, $20, $01 
      .byte $88, $88, $00, $55, $00, $00, $00, $00 
      .byte $A0, $00, $55, $00, $00, $00, $00, $00 
      .byte $01, $54, $A0, $A0, $A0, $A0, $A0, $A0 
      .byte $54, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $01, $05 
      .byte $A0, $A0, $A0, $54, $51, $44, $15, $15 
      .byte $00, $00, $00, $00, $00, $40, $10, $55 
      .byte $00, $00, $00, $00, $00, $01, $01, $05 
      .byte $01, $15, $55, $55, $57, $5D, $55, $55 
      .byte $00, $70, $7C, $FF, $57, $57, $75, $5D 
      .byte $00, $00, $00, $00, $C0, $C0, $C0, $C0 
      .byte $05, $04, $15, $15, $15, $15, $55, $45 
      .byte $55, $55, $15, $55, $55, $57, $55, $55 
      .byte $57, $05, $45, $51, $55, $55, $D7, $7D 
      .byte $F0, $F0, $7C, $DC, $7F, $D7, $55, $55 
      .byte $45, $45, $45, $51, $51, $51, $51, $51 
      .byte $55, $55, $15, $44, $51, $55, $55, $55 
      .byte $55, $55, $55, $55, $55, $55, $55, $54 
      .byte $51, $45, $15, $55, $55, $45, $15, $51 
      .byte $51, $51, $44, $45, $85, $01, $00, $00 
      .byte $55, $55, $55, $55, $55, $55, $05, $00 
      .byte $55, $45, $51, $55, $55, $15, $15, $05 
      .byte $55, $55, $55, $55, $54, $50, $40, $00 
      .byte $00, $00, $00, $00, $01, $01, $05, $15 
      .byte $04, $15, $15, $45, $51, $55, $55, $55 
      .byte $00, $40, $50, $50, $54, $54, $55, $55 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $15, $55, $55, $55, $14, $15, $45, $45 
      .byte $55, $55, $55, $55, $55, $55, $54, $55 
      .byte $55, $55, $45, $55, $51, $55, $55, $55 
      .byte $00, $40, $50, $50, $54, $54, $54, $55 
      .byte $51, $51, $51, $51, $54, $54, $54, $51 
      .byte $55, $55, $45, $15, $55, $55, $55, $54 
      .byte $55, $45, $51, $55, $55, $55, $54, $51 
      .byte $55, $55, $45, $51, $55, $55, $55, $55 
      .byte $45, $45, $05, $09, $00, $02, $20, $00 
      .byte $55, $55, $55, $55, $95, $09, $20, $80 
      .byte $15, $55, $55, $55, $55, $54, $08, $82 
      .byte $55, $55, $55, $50, $40, $08, $20, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 

// ======================================
// End of tile graphics data
// ======================================


// ======================================
// Sprite bitmap data starts here $6000
// ======================================

// *=$6000

ACTOR_RIGHT_00:                         
      .byte $01, $40, $00, $05, $50, $00, $05, $20 
      .byte $00, $16, $A0, $00, $16, $80, $00, $42 
      .byte $A0, $00, $0A, $80, $00, $2A, $00, $00 
      .byte $2A, $80, $00, $2A, $A0, $00, $2A, $AF 
      .byte $00, $28, $AC, $00, $2B, $00, $00, $3F 
      .byte $C0, $00, $3F, $C0, $00, $33, $F0, $00 
      .byte $3C, $F0, $00, $FC, $F0, $00, $F0, $3C 
      .byte $00, $C0, $3C, $00, $C0, $00, $00, $00 
ACTOR_RIGHT_01:
      .byte $00, $14, $00, $00, $55, $00, $00, $52 
      .byte $00, $01, $6A, $00, $01, $68, $00, $04 
      .byte $2A, $00, $00, $A8, $00, $02, $A0, $00 
      .byte $02, $A8, $00, $02, $A8, $00, $02, $2A 
      .byte $00, $02, $8A, $C0, $02, $A3, $C0, $00 
      .byte $E8, $00, $03, $FC, $00, $03, $CC, $00 
      .byte $03, $CC, $00, $03, $CC, $00, $03, $CF 
      .byte $00, $03, $F3, $00, $03, $F3, $00, $00 
JSILVER_RIGHT_00:
      .byte $15, $45, $00, $15, $55, $00, $05, $48 
      .byte $00, $05, $A8, $00, $01, $A0, $00, $00 
      .byte $A8, $00, $01, $A0, $00, $05, $40, $00 
      .byte $05, $50, $00, $05, $54, $00, $05, $56 
      .byte $80, $15, $16, $00, $15, $40, $00, $15 
      .byte $50, $00, $55, $50, $00, $55, $F0, $00 
      .byte $3C, $30, $00, $3C, $30, $00, $F0, $0C 
      .byte $00, $F0, $0C, $00, $C0, $00, $00, $00 
JSILVER_RIGHT_01:
      .byte $01, $54, $50, $01, $55, $50, $00, $54 
      .byte $80, $00, $5A, $80, $00, $1A, $00, $00 
      .byte $0A, $80, $00, $1A, $00, $00, $54, $00 
      .byte $00, $55, $00, $00, $55, $00, $00, $47 
      .byte $00, $01, $45, $00, $01, $57, $00, $01 
      .byte $55, $00, $05, $55, $00, $05, $5C, $00 
      .byte $05, $CC, $00, $03, $CC, $00, $00, $FC 
      .byte $00, $00, $FC, $00, $00, $0C, $00, $00 
ACTOR_SWORD_RIGHT_00:
      .byte $01, $40, $00, $05, $50, $00, $05, $20 
      .byte $00, $16, $A0, $00, $16, $80, $03, $42 
      .byte $A0, $03, $0A, $80, $0F, $2A, $00, $0C 
      .byte $2A, $80, $3C, $2A, $A3, $F0, $2A, $AF 
      .byte $00, $28, $AC, $00, $2B, $00, $00, $3F 
      .byte $C0, $00, $3F, $C0, $00, $33, $F0, $00 
      .byte $3C, $F0, $00, $FC, $F0, $00, $F0, $3C 
      .byte $00, $C0, $3C, $00, $C0, $00, $00, $00 
ACTOR_SWORD_RIGHT_01:
      .byte $00, $14, $30, $00, $55, $30, $00, $52 
      .byte $3C, $01, $6A, $3C, $01, $68, $0C, $04 
      .byte $2A, $0C, $00, $A8, $0C, $02, $A0, $0C 
      .byte $02, $A8, $3C, $02, $AA, $30, $02, $2A 
      .byte $F0, $02, $8A, $C0, $02, $A3, $C0, $00 
      .byte $E8, $00, $03, $FC, $00, $03, $CC, $00 
      .byte $03, $CC, $00, $03, $CC, $00, $03, $CF 
      .byte $00, $03, $F3, $00, $03, $F3, $00, $00 
JSILVER_LEFT_00:
      .byte $05, $15, $40, $05, $55, $40, $02, $15 
      .byte $00, $02, $A5, $00, $00, $A4, $00, $02 
      .byte $A0, $00, $00, $A4, $00, $00, $15, $00 
      .byte $00, $55, $00, $00, $55, $00, $00, $D1 
      .byte $00, $00, $51, $40, $00, $D5, $40, $00 
      .byte $55, $40, $00, $55, $50, $00, $35, $50 
      .byte $00, $33, $50, $00, $33, $C0, $00, $3F 
      .byte $00, $00, $3F, $00, $00, $30, $00, $00 
JSILVER_LEFT_01:
      .byte $00, $51, $54, $00, $55, $54, $00, $21 
      .byte $50, $00, $2A, $50, $00, $0A, $40, $00 
      .byte $2A, $00, $00, $0A, $40, $00, $01, $50 
      .byte $00, $05, $50, $00, $15, $50, $02, $95 
      .byte $50, $00, $94, $54, $00, $01, $54, $00 
      .byte $05, $54, $00, $05, $55, $00, $0F, $55 
      .byte $00, $0C, $3C, $00, $0C, $3C, $00, $30 
      .byte $0F, $00, $30, $0F, $00, $00, $03, $00 
ACTOR_LEFT_00:
      .byte $00, $14, $00, $00, $55, $00, $00, $85 
      .byte $00, $00, $A9, $40, $00, $29, $40, $00 
      .byte $A8, $10, $00, $2A, $00, $00, $0A, $80 
      .byte $00, $2A, $80, $00, $AA, $80, $00, $A8 
      .byte $80, $03, $A2, $80, $03, $CA, $80, $00 
      .byte $2B, $00, $00, $3F, $C0, $00, $33, $C0 
      .byte $00, $33, $C0, $00, $33, $C0, $00, $F3 
      .byte $C0, $00, $CF, $C0, $00, $CF, $C0, $00 
ACTOR_LEFT_01:
      .byte $00, $01, $40, $00, $05, $50, $00, $08 
      .byte $50, $00, $0A, $94, $00, $02, $94, $00 
      .byte $0A, $81, $00, $02, $A0, $00, $00, $A8 
      .byte $00, $02, $A8, $00, $0A, $A8, $00, $FA 
      .byte $A8, $00, $3A, $28, $00, $00, $E8, $00 
      .byte $03, $FC, $00, $03, $FC, $00, $0F, $CC 
      .byte $00, $0F, $3C, $00, $0F, $3F, $00, $3C 
      .byte $0F, $00, $3C, $03, $00, $00, $03, $00 
JSILVER_DOWN_00:
      .byte $05, $15, $40, $05, $55, $40, $00, $85 
      .byte $40, $02, $A9, $00, $02, $28, $00, $02 
      .byte $A0, $00, $00, $A0, $00, $01, $54, $00 
      .byte $05, $55, $00, $05, $D4, $40, $05, $5D 
      .byte $40, $05, $EB, $40, $05, $69, $40, $05 
      .byte $D5, $40, $05, $55, $40, $01, $55, $50 
      .byte $03, $3D, $50, $0C, $3C, $00, $0C, $3C 
      .byte $00, $0C, $0F, $00, $00, $0F, $00, $00 
JSILVER_DOWN_01:
      .byte $01, $45, $50, $01, $55, $50, $00, $21 
      .byte $50, $00, $AA, $40, $00, $8A, $00, $00 
      .byte $A8, $00, $00, $28, $00, $00, $55, $00 
      .byte $01, $55, $40, $05, $75, $10, $05, $54 
      .byte $50, $05, $75, $F0, $01, $55, $A0, $01 
      .byte $75, $A0, $01, $55, $50, $00, $55, $50 
      .byte $00, $CF, $54, $00, $CF, $00, $00, $C3 
      .byte $C0, $00, $C3, $C0, $00, $C0, $00, $00 
ACTOR_SWORD_LEFT_00:
      .byte $0C, $14, $00, $0C, $55, $00, $3C, $85 
      .byte $00, $3C, $A9, $40, $30, $29, $40, $30 
      .byte $A8, $10, $30, $2A, $00, $30, $0A, $80 
      .byte $3C, $2A, $80, $0C, $AA, $80, $0F, $A8 
      .byte $80, $03, $A2, $80, $03, $CA, $80, $00 
      .byte $2B, $00, $00, $3F, $C0, $00, $33, $C0 
      .byte $00, $33, $C0, $00, $33, $C0, $00, $F3 
      .byte $C0, $00, $CF, $C0, $00, $CF, $C0, $00 
ACTOR_SWORD_LEFT_01:
      .byte $00, $01, $40, $00, $05, $50, $00, $08 
      .byte $50, $00, $0A, $94, $C0, $02, $94, $C0 
      .byte $0A, $81, $F0, $02, $A0, $30, $00, $A8 
      .byte $3C, $02, $A8, $0F, $CA, $A8, $00, $FA 
      .byte $A8, $00, $3A, $28, $00, $00, $E8, $00 
      .byte $03, $FC, $00, $03, $FC, $00, $0F, $CC 
      .byte $00, $0F, $3C, $00, $0F, $3F, $00, $3C 
      .byte $0F, $00, $3C, $03, $00, $00, $03, $00 
JSILVER_UP_00:
      .byte $05, $41, $40, $05, $55, $40, $01, $56 
      .byte $00, $01, $56, $00, $00, $56, $00, $00 
      .byte $5A, $00, $00, $28, $00, $00, $54, $00 
      .byte $01, $55, $00, $01, $55, $40, $01, $55 
      .byte $60, $05, $55, $40, $04, $45, $40, $05 
      .byte $55, $40, $05, $55, $40, $05, $55, $00 
      .byte $15, $73, $00, $03, $C3, $00, $03, $C3 
      .byte $00, $03, $F3, $00, $00, $03, $00, $FF 
JSILVER_UP_01:
      .byte $01, $50, $50, $01, $55, $50, $00, $55 
      .byte $80, $00, $55, $80, $00, $15, $80, $00 
      .byte $16, $80, $00, $0A, $00, $00, $15, $00 
      .byte $00, $55, $40, $00, $55, $50, $00, $55 
      .byte $58, $01, $55, $50, $01, $11, $50, $01 
      .byte $55, $50, $01, $55, $50, $05, $55, $40 
      .byte $05, $5C, $C0, $00, $F0, $C0, $00, $F0 
      .byte $30, $00, $FC, $30, $00, $3C, $00, $00 
ACTOR_DOWN_00:
      .byte $00, $50, $00, $01, $54, $00, $00, $85 
      .byte $00, $02, $A9, $00, $02, $28, $40, $02 
      .byte $A0, $00, $00, $A0, $00, $02, $A8, $00 
      .byte $0A, $AA, $00, $0A, $AA, $00, $08, $AA 
      .byte $80, $0A, $2A, $80, $0E, $A8, $80, $03 
      .byte $E8, $00, $03, $CC, $00, $0F, $3C, $00 
      .byte $0F, $3C, $00, $0F, $3C, $00, $0F, $3C 
      .byte $00, $0F, $CF, $00, $00, $0F, $00, $00 
ACTOR_DOWN_01:
      .byte $00, $50, $00, $01, $54, $00, $00, $85 
      .byte $10, $02, $A9, $40, $02, $28, $00, $02 
      .byte $A0, $00, $00, $A0, $00, $02, $A8, $00 
      .byte $0A, $AA, $00, $0A, $A2, $00, $2A, $8A 
      .byte $00, $28, $8A, $00, $22, $A8, $00, $02 
      .byte $FF, $00, $03, $FF, $00, $03, $F3, $00 
      .byte $03, $CF, $00, $03, $CF, $00, $03, $CF 
      .byte $00, $0F, $3C, $00, $0F, $00, $00, $00 
//
// =====================================
// The positions for the pickables in the
// room, each byte contains both x and y
// coordinates in character resolution (?)
// if the room does not have any pickable
// the value is $00
// =====================================

PICKABLE_POSITIONS:                     
      .byte $95, $00, $00, $00, $00, $B5, $00, $00 
      .byte $00, $55, $00, $00, $39, $B9, $93, $00 
      .byte $93, $75, $35, $D9, $D3, $00, $00, $00 
      .byte $00, $33, $00, $D9, $00, $B5, $53, $00 
      .byte $D5, $00, $97, $00, $37, $37, $35, $00 
      .byte $00, $95, $75, $00, $39, $00, $00, $00 
      .byte $00, $00, $D9, $00, $00, $77, $33, $00 
      .byte $00, $00, $35, $75, $97, $00, $00, $00 
PICKABLES_POINTS:
      .byte $05, $02, $03, $02, $02, $00
PIRATE_COLORS:
      .byte $52, $62, $72               

// =================================
// Turn sprite flag on
//
// XR = Sprite number
// =================================

SET_SPRITE_ON:
      lda  BITS,x                       
      ora  VISIBLE_SPRITE               
      sta  VISIBLE_SPRITE               
      rts                               

L64D3:                                  // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00     

// ======================================
//  Actor new Y position when enter room
//  Top, Bottom, Left, Right
// ======================================

ACTOR_NEW_ROOM_Y:
      .byte 4, 224, 4, 160              
NEW_ROOM_OFFSET:
      .byte $01, $FF, $08, $F8          
ACT0R_SWORD_DOWN_00:                    
      .byte $00, $50, $30, $01, $54, $30, $00, $85 
      .byte $3C, $02, $A9, $3C, $02, $28, $7C, $02 
      .byte $A0, $0C, $00, $A0, $0C, $02, $A8, $0C 
      .byte $0A, $AA, $3C, $0A, $AA, $BC, $08, $AA 
      .byte $A0, $0A, $28, $A0, $0E, $A8, $30, $03 
      .byte $E8, $00, $03, $CC, $00, $0F, $3C, $00 
      .byte $0F, $3C, $00, $0F, $3C, $00, $0F, $3C 
      .byte $00, $0F, $CF, $00, $00, $0F, $00, $00 
ACT0R_SWORD_DOWN_01:
      .byte $00, $50, $00, $01, $54, $00, $00, $85 
      .byte $10, $02, $A9, $40, $02, $28, $00, $02 
      .byte $A0, $00, $00, $A0, $00, $02, $A8, $00 
      .byte $0A, $AA, $00, $0A, $A2, $80, $2A, $8A 
      .byte $80, $2A, $8E, $80, $0F, $FC, $00, $FF 
      .byte $03, $00, $00, $3F, $00, $03, $F3, $00 
      .byte $03, $CF, $00, $03, $CF, $00, $03, $CF 
      .byte $00, $0F, $3C, $00, $0F, $00, $00, $00 
SFX_00:                                 // 32 notes
      .byte $40, $45, $4A, $50, $55, $5A, $60, $66 
      .byte $6C, $70, $74, $78, $7C, $80, $82, $84 
      .byte $86, $84, $82, $80, $7C, $78, $74, $70 
      .byte $6C, $68, $64, $60, $5C, $58, $54, $50 
SFX_01:                                 // 32 notes
      .byte $F0, $E8, $E0, $D8, $D0, $C8, $C4, $C0 
      .byte $BC, $B8, $B4, $B0, $AC, $A8, $A5, $A2 
SFX_02:                                 // 32 notes
      .byte $A0, $A2, $A4, $A6, $A8, $AB, $AD, $B0 
      .byte $B4, $B8, $BC, $C0, $C4, $C8, $CC, $D0 
SFX_03:                                 // 8 notes
      .byte $14, $18, $1C, $20, $24, $28, $2C, $30 
L65C8:                                  // possible garbage
      .byte $54, $58, $5C, $60, $64, $68, $6C, $70 
      .byte $84, $88, $8C, $90, $94, $98, $9C, $A0 
      .byte $B0, $B4, $B8, $BC, $C0, $C4, $C8, $CC 
      *=$6600

ACTOR_UP_00:
      .byte $00, $14, $00, $00, $55, $00, $01, $56 
      .byte $00, $01, $16, $00, $04, $56, $00, $00 
      .byte $5A, $00, $00, $28, $00, $00, $AA, $00 
      .byte $02, $AA, $80, $02, $AA, $88, $02, $AA 
      .byte $A8, $0A, $AA, $A8, $0A, $23, $A0, $03 
      .byte $FF, $C0, $03, $FF, $C0, $03, $F3, $C0 
      .byte $03, $CF, $C0, $03, $CF, $C0, $03, $C3 
      .byte $F0, $03, $F3, $F0, $00, $F0, $00, $FF 
ACTOR_UP_01:
      .byte $00, $50, $00, $01, $54, $00, $05, $58 
      .byte $00, $04, $58, $00, $11, $58, $00, $01 
      .byte $68, $00, $00, $A0, $00, $02, $A8, $00 
      .byte $0A, $AA, $00, $0A, $AA, $20, $0A, $AA 
      .byte $A0, $0A, $AA, $A0, $08, $8A, $80, $03 
      .byte $FE, $00, $03, $FF, $00, $03, $CF, $00 
      .byte $03, $CF, $00, $0F, $3F, $00, $0F, $3F 
      .byte $00, $0F, $CF, $C0, $00, $0F, $C0, $FF 

// =======================
// IRQ HANDLER
// =======================

IRQ_HANDLER:
      ldy  SFX_NOTE_INDEX               
      bmi  W66A8                        
      dec  SFX_TIMER                    
      bpl  W66A5                        
      lda  SFX_DURATION                 
      sta  SFX_TIMER                    
      dec  SFX_NOTE_INDEX               
      ldx  SFX_NO                       
      lda  SFX_NOTE_TABLE_LO,x          
      sta  SFX_PTR_LO                   
      lda  SFX_NOTE_TABLE_HI,x          
      sta  SFX_PTR_HI                   
      lda  (SFX_PTR_LO),y               
      sta  $FF0F                        // TED: Voice #2 frequency, bits 0-7
W66A5:
      jmp  $CE0E                        

W66A8:
      lda  $FF11                        // TED: Bits 0-3 : Volume control
      and  #$9F                         
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      jmp  $CE0E                        

      .byte $00                         // possible grabage
      .byte $00, $00, $00, $00          

// =========================
// IRQ SETUP
// =========================

IRQ_SETUP:
      ldx  #$02                         
      lda  #$00                         
W66BC:
      sta  SFX_TIMER,x                  
      dex                               
      bpl  W66BC                        
      stx  SFX_NOTE_INDEX               
      sei                               
      lda  #<IRQ_HANDLER                
      sta  $0314                        // IRQ Ram Vector
      lda  #>IRQ_HANDLER                
      sta  $0315                        // IRQ Ram Vector
      cli                               
      lda  #$08                         
      sta  $FF11                        // TED: Bits 0-3 : Volume control
      rts                               

      *=$6700

ACTOR_SWORD_UP_00:
      .byte $00, $54, $00, $00, $55, $00, $01, $56 
      .byte $00, $01, $16, $00, $04, $56, $00, $00 
      .byte $5A, $00, $00, $28, $00, $00, $AA, $00 
      .byte $02, $AA, $80, $F2, $AA, $80, $3E, $AA 
      .byte $A0, $0E, $AA, $A0, $02, $22, $C0, $00 
      .byte $BF, $C0, $03, $FF, $C0, $03, $F3, $C0 
      .byte $03, $CF, $C0, $03, $CF, $C0, $03, $C3 
      .byte $F0, $03, $F3, $F0, $00, $F0, $00, $FF 
ACTOR_SWORD_UP_01:
      .byte $00, $50, $C0, $01, $54, $C0, $05, $58 
      .byte $F0, $04, $58, $F0, $11, $58, $F0, $01 
      .byte $68, $30, $00, $A0, $30, $02, $AA, $30 
      .byte $0A, $A8, $F0, $0A, $A8, $F0, $0A, $AA 
      .byte $80, $0A, $AA, $C0, $08, $8A, $00, $03 
      .byte $FA, $00, $03, $FF, $00, $03, $CF, $00 
      .byte $03, $CF, $00, $0F, $3F, $00, $0F, $3F 
      .byte $00, $0F, $CF, $C0, $00, $0F, $C0, $FF 

// ======================================
// This is the graphics data for the
// right side of the letter "D" in 
// copyright word "LTD"
// ======================================

COPYRIGHT_03:
      .byte $33, $33, $33, $00, $00, $00, $00, $00 
      .byte $30, $33, $0C, $00, $00, $00, $00, $00 
      .byte $33, $33, $33, $00, $00, $00, $00, $00 
      .byte $30, $30, $3F, $00, $00, $00, $00, $00 
      .byte $33, $33, $33, $00, $00, $00, $00, $00 
      .byte $33, $33, $33, $00, $00, $00, $00, $00 
      .byte $33, $33, $33, $00, $00, $00, $00, $00 
      .byte $33, $0C, $0C, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $CC, $CC, $3C, $00, $00, $00, $00, $00 
      .byte $33, $33, $3C, $00, $00, $00, $00, $00 
      .byte $33, $33, $3F, $00, $00, $00, $00, $00 
      .byte $33, $33, $3C, $00, $00, $00, $00, $00 
      .byte $33, $33, $3C, $00, $00, $00, $00, $00 
      .byte $30, $30, $3F, $00, $00, $00, $00, $00 
      .byte $30, $30, $3F, $00, $00, $00, $00, $00 
//
// =====================================
// Room definitions
// =====================================

ROOM_00:
      .byte $09, $03, $01, $05, $01, $06, $01, $01 
      .byte $01, $01, $1E, $23, $24, $25, $26, $25 
      .byte $01, $03, $27, $00, $00, $00, $00, $00 
      .byte $01, $01, $2C, $00, $17, $3A, $3C, $3D 
      .byte $03, $01, $2C, $00, $3B     
TREASURE_CHEST_PLACE:                   // The place for the treasure chest
      .byte $00, $00, $00, $01, $01, $27, $00, $3A 
      .byte $3C, $3D, $3C               
ROOM_01:
      .byte $01, $01, $04, $01, $01, $01, $03, $01 
      .byte $25, $26, $23, $24, $25, $25, $26, $23 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $18, $0C, $0E, $0C, $0E, $0C, $0E, $0A 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $32, $0B, $0D, $0B, $0D, $3B, $0B, $0D 
ROOM_02:
      .byte $03, $01, $1A, $1B, $1C, $1D, $01, $01 
      .byte $25, $26, $23, $24, $1F, $01, $03, $01 
      .byte $00, $00, $0A, $37, $35, $26, $23, $24 
      .byte $37, $0A, $0A, $00, $00, $00, $37, $0A 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
ROOM_03:
      .byte $01, $01, $05, $01, $06, $01, $01, $01 
      .byte $1E, $25, $25, $26, $26, $25, $26, $1F 
      .byte $02, $0E, $00, $00, $00, $00, $0C, $02 
      .byte $0E, $00, $00, $0A, $00, $00, $00, $0C 
      .byte $00, $00, $00, $37, $00, $00, $00, $00 
      .byte $0B, $0D, $33, $19, $00, $00, $0B, $0D 
ROOM_04:
      .byte $01, $01, $01, $01, $01, $03, $01, $01 
      .byte $01, $04, $1E, $25, $25, $23, $24, $23 
      .byte $23, $24, $02, $00, $00, $00, $00, $00 
      .byte $0E, $0A, $00, $00, $0C, $0E, $0C, $0E 
      .byte $00, $00, $00, $00, $37, $00, $00, $00 
      .byte $36, $0D, $00, $17, $18, $00, $0A, $0B 
ROOM_05:
      .byte $01, $01, $1A, $1B, $1C, $1D, $01, $01 
      .byte $23, $24, $25, $25, $23, $24, $26, $25 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $0A, $37, $0C, $0E, $0C, $0E 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B 
ROOM_06:
      .byte $01, $03, $01, $01, $01, $03, $01, $01 
      .byte $25, $25, $26, $23, $24, $25, $23, $24 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $3B, $0C, $0E, $19, $0C, $0E 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0D, $0B, $0D, $0B, $0D, $0A, $00, $0A 
ROOM_07:
      .byte $01, $05, $01, $06, $01, $01, $01, $09 
      .byte $23, $24, $25, $26, $1F, $01, $03, $01 
      .byte $00, $00, $00, $00, $29, $01, $01, $01 
      .byte $0C, $0E, $00, $00, $2B, $03, $01, $01 
      .byte $00, $00, $37, $00, $29, $01, $01, $01 
      .byte $0A, $00, $17, $00, $28, $01, $03, $01 
ROOM_08:
      .byte $01, $03, $22, $00, $0A, $17, $18, $32 
      .byte $01, $01, $27, $00, $00, $00, $17, $18 
      .byte $01, $01, $2C, $02, $0A, $00, $00, $17 
      .byte $04, $01, $27, $02, $0E, $0A, $00, $00 
      .byte $01, $01, $20, $02, $00, $37, $00, $00 
      .byte $01, $03, $01, $27, $00, $32, $00, $0C 
ROOM_09:
      .byte $0C, $0E, $0C, $0E, $0C, $0E, $0C, $0E 
      .byte $02, $0E, $00, $00, $00, $00, $00, $00 
      .byte $0A, $32, $00, $00, $0B, $0D, $0B, $0D 
      .byte $00, $0A, $3B, $0B, $0D, $0B, $0D, $0B 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $38, $11, $11, $10, $10, $10, $11, $10 
ROOM_10:
      .byte $0C, $0E, $0C, $0E, $0C, $0E, $0C, $0E 
      .byte $00, $00, $37, $19, $0A, $00, $00, $00 
      .byte $0D, $00, $00, $00, $00, $00, $0B, $0D 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $10, $11, $11, $10, $10, $11, $11, $10 
ROOM_11:
      .byte $0C, $0E, $0C, $0E, $00, $00, $0C, $0E 
      .byte $00, $00, $37, $0A, $00, $00, $0A, $0A 
      .byte $0D, $00, $00, $00, $00, $00, $37, $0A 
      .byte $0B, $0D, $0B, $0D, $33, $3B, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $10, $10, $11, $10, $11, $11, $10, $39 
ROOM_12:
      .byte $37, $18, $00, $17, $17, $00, $18, $0A 
      .byte $17, $00, $00, $00, $00, $00, $00, $17 
      .byte $18, $00, $00, $00, $00, $00, $00, $18 
      .byte $0A, $32, $17, $18, $33, $18, $17, $0A 
      .byte $00, $00, $34, $15, $14, $00, $00, $00 
      .byte $0A, $00, $18, $17, $18, $00, $37, $0A 
ROOM_13:
      .byte $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B 
      .byte $0A, $00, $00, $00, $00, $00, $00, $00 
      .byte $37, $00, $00, $00, $00, $0A, $00, $3B 
      .byte $0C, $0E, $00, $00, $0C, $02, $0E, $0C 
      .byte $00, $00, $00, $00, $37, $00, $00, $00 
      .byte $0C, $0E, $00, $0A, $0C, $0E, $0C, $0E 
ROOM_14:
      .byte $0C, $0E, $0C, $0E, $0C, $0E, $00, $0B 
      .byte $00, $00, $00, $00, $00, $0A, $00, $0A 
      .byte $37, $00, $00, $00, $37, $00, $00, $0B 
      .byte $0E, $0C, $0E, $0C, $0E, $00, $00, $0A 
      .byte $00, $00, $00, $00, $00, $00, $00, $0B 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
ROOM_15:
      .byte $37, $00, $17, $00, $28, $03, $01, $01 
      .byte $17, $00, $0A, $00, $29, $01, $01, $01 
      .byte $33, $00, $37, $00, $2B, $04, $01, $01 
      .byte $0A, $00, $17, $00, $2A, $01, $01, $01 
      .byte $17, $00, $18, $00, $2B, $01, $03, $01 
      .byte $32, $00, $37, $00, $29, $01, $01, $01 
ROOM_16:
      .byte $01, $01, $01, $27, $00, $0A, $00, $19 
      .byte $03, $01, $01, $2C, $00, $37, $00, $19 
      .byte $01, $01, $01, $22, $00, $0A, $00, $00 
      .byte $01, $01, $04, $27, $00, $0C, $0E, $0C 
      .byte $01, $01, $1E, $02, $00, $00, $00, $3A 
      .byte $01, $03, $27, $02, $0E, $37, $00, $0A 
ROOM_17:
      .byte $38, $11, $10, $10, $11, $11, $10, $11 
      .byte $0A, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $0A 
      .byte $0A, $00, $34, $15, $14, $00, $0C, $02 
      .byte $37, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $0A, $00, $33, $0C, $0E, $0C 
ROOM_18:
      .byte $10, $10, $11, $11, $11, $10, $11, $10 
      .byte $00, $00, $0A, $00, $00, $00, $3A, $3C 
      .byte $0A, $00, $37, $00, $00, $00, $00, $00 
      .byte $02, $0E, $0C, $0E, $00, $0A, $00, $00 
      .byte $00, $00, $33, $00, $00, $19, $00, $0A 
      .byte $32, $00, $0B, $0D, $00, $37, $00, $19 
ROOM_19:
      .byte $10, $11, $11, $10, $10, $10, $11, $39 
      .byte $0A, $37, $0C, $0E, $37, $00, $0A, $0C 
      .byte $00, $00, $0C, $02, $0E, $00, $0C, $02 
      .byte $00, $00, $00, $0A, $00, $00, $00, $00 
      .byte $0A, $00, $00, $00, $37, $00, $00, $32 
      .byte $0E, $00, $0C, $0E, $0C, $0E, $3A, $3C 
ROOM_20:
      .byte $0A, $00, $0C, $02, $0E, $00, $0C, $0E 
      .byte $37, $00, $33, $00, $00, $00, $00, $0A 
      .byte $32, $00, $0A, $00, $37, $00, $00, $0A 
      .byte $00, $00, $00, $00, $00, $00, $0C, $0E 
      .byte $0E, $0C, $0E, $0C, $0E, $33, $00, $00 
      .byte $02, $02, $02, $02, $02, $0E, $00, $37 
ROOM_21:
      .byte $0D, $0A, $00, $0B, $0D, $0B, $0D, $0B 
      .byte $00, $37, $00, $00, $00, $00, $0B, $36 
      .byte $00, $0A, $00, $00, $00, $00, $00, $00 
      .byte $0B, $36, $0D, $0B, $0D, $0B, $0D, $0B 
      .byte $00, $00, $00, $00, $00, $00, $00, $0B 
      .byte $0B, $0D, $00, $3B, $0B, $0D, $00, $37 
ROOM_22:
      .byte $0B, $36, $0D, $0B, $0D, $0B, $36, $0D 
      .byte $0A, $00, $00, $00, $00, $00, $3A, $3C 
      .byte $00, $00, $00, $00, $00, $00, $00, $37 
      .byte $37, $00, $00, $3B, $3B, $00, $00, $0A 
      .byte $32, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $00, $0C 
ROOM_23:
      .byte $0A, $00, $17, $00, $28, $03, $01, $01 
      .byte $0D, $00, $18, $00, $2A, $01, $01, $01 
      .byte $37, $00, $0C, $0E, $29, $01, $01, $03 
      .byte $0E, $00, $00, $0C, $2A, $01, $01, $01 
      .byte $00, $00, $00, $00, $28, $05, $01, $06 
      .byte $0C, $0E, $00, $00, $29, $01, $01, $01 
ROOM_24:
      .byte $03, $01, $01, $01, $2C, $0E, $00, $0A 
      .byte $01, $01, $04, $01, $27, $00, $00, $0C 
      .byte $01, $01, $1E, $25, $0A, $00, $00, $3A 
      .byte $01, $01, $2C, $0E, $00, $00, $00, $37 
      .byte $01, $03, $2C, $0E, $00, $00, $00, $00 
      .byte $01, $01, $20, $02, $0E, $0C, $0E, $0C 
ROOM_25:
      .byte $0E, $0C, $0E, $00, $0C, $0E, $0C, $0E 
      .byte $0E, $00, $19, $00, $19, $3A, $3C, $3D 
      .byte $37, $00, $0C, $02, $0E, $00, $00, $00 
      .byte $0A, $00, $00, $00, $37, $00, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $0C, $0E, $32, $0B, $0D, $3A 
ROOM_26:
      .byte $0E, $00, $0A, $37, $00, $37, $00, $0A 
      .byte $33, $00, $00, $00, $00, $33, $00, $37 
      .byte $00, $00, $00, $00, $00, $00, $00, $37 
      .byte $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $38, $11, $11, $10, $11, $10, $11, $39 
ROOM_27:
      .byte $17, $00, $38, $10, $10, $11, $11, $10 
      .byte $18, $00, $00, $00, $00, $00, $00, $00 
      .byte $18, $17, $00, $00, $00, $0F, $0F, $0F 
      .byte $17, $00, $00, $00, $0F, $0F, $0F, $0F 
      .byte $00, $00, $00, $0B, $36, $0D, $00, $00 
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
ROOM_28:
      .byte $0F, $0F, $0F, $38, $11, $39, $00, $0F 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $38, $10, $10, $11, $10, $11, $11, $39 
      .byte $0F, $00, $00, $3B, $00, $00, $00, $0F 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
ROOM_29:
      .byte $0F, $0F, $00, $0A, $0A, $37, $00, $0A 
      .byte $00, $00, $00, $00, $37, $00, $00, $3B 
      .byte $37, $00, $00, $00, $32, $00, $32, $3A 
      .byte $36, $0D, $00, $00, $0B, $0D, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
ROOM_30:
      .byte $0A, $17, $37, $17, $0C, $0E, $00, $0C 
      .byte $18, $0A, $00, $00, $00, $00, $00, $00 
      .byte $17, $33, $00, $00, $00, $00, $00, $00 
      .byte $0E, $33, $34, $15, $14, $32, $0C, $0E 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $0C, $0E, $0F, $0F, $0F, $0F 
ROOM_31:
      .byte $0C, $0E, $00, $00, $28, $01, $01, $01 
      .byte $00, $00, $00, $00, $2A, $01, $03, $01 
      .byte $00, $0A, $00, $00, $2B, $01, $01, $01 
      .byte $0C, $02, $0E, $00, $28, $04, $01, $01 
      .byte $00, $00, $33, $00, $29, $01, $01, $03 
      .byte $0F, $00, $17, $00, $2B, $01, $01, $01 
ROOM_32:
      .byte $01, $01, $1E, $02, $0E, $0C, $0E, $0C 
      .byte $04, $01, $27, $02, $02, $00, $00, $00 
      .byte $01, $01, $20, $30, $02, $00, $00, $0A 
      .byte $01, $07, $08, $01          
SHIP_GATE_PLACE:                        // Place for the ship gate
      .byte $27, $00, $0C, $0E, $01, $01, $1E, $25 
      .byte $02, $00, $37, $00, $01, $03, $27, $02 
      .byte $3B, $00, $0C, $0E          
ROOM_33:
      .byte $0C, $0E, $0C, $0E, $0A, $0B, $0D, $0B 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0E, $0C, $0E, $0C, $0E, $0C, $0E, $0C 
      .byte $02, $02, $02, $02, $0E, $00, $00, $0A 
      .byte $00, $00, $00, $00, $17, $18, $00, $00 
      .byte $0A, $00, $37, $00, $18, $33, $00, $32 
ROOM_34:
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0F, $0F 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0E, $0C, $0E, $37, $0B, $0D, $0B, $0D 
      .byte $02, $02, $02, $0E, $00, $32, $00, $00 
      .byte $00, $00, $00, $33, $00, $32, $00, $0A 
      .byte $0B, $0D, $00, $37, $00, $0A, $00, $37 
ROOM_35:
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $37, $32, $3A, $3C 
      .byte $00, $00, $00, $00, $00, $00, $00, $0A 
      .byte $0A, $00, $00, $00, $00, $00, $00, $0A 
      .byte $0B, $0D, $0B, $0D, $37, $00, $0B, $0D 
ROOM_36:
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $37, $0A 
      .byte $0A, $00, $00, $00, $00, $0B, $0D, $0B 
      .byte $37, $00, $00, $00, $00, $00, $00, $00 
      .byte $32, $0B, $0D, $0B, $0D, $00, $00, $0B 
ROOM_37:
      .byte $38, $11, $10, $11, $10, $39, $3A, $3D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
      .byte $0D, $00, $00, $00, $00, $00, $00, $0B 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $38, $11, $10, $10, $11, $11, $11, $10 
ROOM_38:
      .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F 
      .byte $00, $00, $00, $00, $00, $17, $18, $0F 
      .byte $0A, $00, $00, $00, $00, $00, $00, $0F 
      .byte $0B, $0D, $0B, $0D, $00, $00, $00, $0F 
      .byte $00, $00, $32, $33, $00, $17, $00, $0F 
      .byte $39, $00, $0B, $0D, $00, $18, $00, $0F 
ROOM_39:
      .byte $0F, $00, $17, $00, $28, $01, $01, $01 
      .byte $0F, $00, $0A, $00, $29, $05, $01, $06 
      .byte $0F, $00, $18, $00, $2A, $01, $01, $01 
      .byte $0F, $00, $0A, $00, $2B, $03, $01, $01 
      .byte $0F, $00, $33, $00, $29, $01, $01, $01 
      .byte $0F, $00, $37, $00, $2B, $01, $01, $03 
ROOM_40:
      .byte $01, $01, $22, $37, $0A, $00, $37, $0A 
      .byte $01, $03, $27, $0C, $0E, $00, $00, $37 
      .byte $01, $01, $27, $0E, $00, $00, $0C, $0E 
      .byte $01, $01, $2C, $00, $00, $00, $00, $37 
      .byte $04, $01, $27, $00, $00, $0A, $00, $00 
      .byte $01, $01, $2C, $00, $0C, $0E, $0C, $0E 
ROOM_41:
      .byte $0A, $00, $0A, $00, $34, $14, $00, $0A 
      .byte $0D, $00, $0A, $00, $00, $00, $00, $0B 
      .byte $33, $00, $37, $32, $00, $00, $3A, $3C 
      .byte $36, $0D, $0B, $0D, $0B, $0D, $0B, $36 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $0C, $0E, $3B, $0C, $0E, $33 
ROOM_42:
      .byte $0E, $37, $00, $0A, $00, $37, $00, $3A 
      .byte $0C, $0E, $00, $00, $00, $00, $00, $00 
      .byte $0E, $0C, $0E, $00, $00, $00, $00, $37 
      .byte $0C, $0E, $0C, $0E, $0C, $0E, $0C, $0E 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
ROOM_43:
      .byte $37, $0B, $0D, $33, $0A, $00, $37, $0A 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0A, $00, $00, $00, $00, $00, $0B, $0D 
      .byte $0B, $0D, $0B, $0D, $00, $00, $00, $32 
      .byte $00, $00, $00, $33, $00, $00, $0B, $0D 
      .byte $18, $17, $00, $18, $17, $00, $32, $32 
ROOM_44:
      .byte $0A, $0B, $0D, $0B, $0D, $00, $00, $33 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0D, $00, $00, $00, $00, $00, $00, $3A 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
      .byte $32, $00, $00, $00, $00, $00, $00, $00 
      .byte $37, $00, $37, $3B, $0A, $00, $0A, $3A 
ROOM_45:
      .byte $0E, $0C, $0E, $0C, $0E, $0C, $0E, $0C 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $32, $3A, $3D, $3C 
      .byte $37, $00, $00, $00, $00, $00, $00, $3A 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0A, $00, $0B, $0D 
ROOM_46:
      .byte $0A, $00, $0C, $0E, $00, $17, $00, $37 
      .byte $00, $00, $00, $18, $00, $18, $00, $0A 
      .byte $37, $00, $00, $17, $00, $00, $00, $0C 
      .byte $32, $00, $00, $17, $00, $00, $00, $33 
      .byte $00, $00, $00, $18, $33, $00, $00, $37 
      .byte $0C, $0E, $0C, $0E, $32, $37, $00, $0A 
ROOM_47:
      .byte $0F, $00, $0A, $00, $28, $01, $01, $03 
      .byte $0F, $00, $37, $00, $2A, $04, $01, $01 
      .byte $0F, $00, $0C, $0E, $2B, $01, $01, $01 
      .byte $37, $00, $0C, $0E, $29, $01, $04, $01 
      .byte $0A, $00, $00, $00, $2A, $01, $01, $01 
      .byte $0A, $00, $17, $00, $2B, $03, $01, $01 
ROOM_48:
      .byte $01, $01, $22, $00, $0B, $0D, $0B, $0D 
      .byte $01, $03, $27, $00, $00, $00, $00, $00 
      .byte $01, $01, $20, $2F, $2E, $30, $30, $2D 
      .byte $01, $01, $1E, $26, $23, $24, $26, $23 
      .byte $03, $01, $27, $00, $00, $00, $00, $00 
      .byte $01, $01, $2C, $00, $37, $0C, $0E, $0A 
ROOM_49:
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $32, $00, $00, $0A, $00, $00, $00, $0A 
      .byte $37, $00, $0C, $02, $0E, $00, $0C, $02 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
ROOM_50:
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
      .byte $00, $00, $00, $32, $00, $00, $00, $3A 
      .byte $0A, $00, $00, $00, $00, $3A, $3C, $3D 
      .byte $02, $0E, $00, $00, $00, $17, $3A, $3C 
      .byte $00, $00, $00, $37, $00, $00, $00, $18 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $36 
ROOM_51:
      .byte $18, $17, $00, $18, $17, $00, $3A, $3C 
      .byte $17, $00, $00, $17, $00, $00, $00, $18 
      .byte $17, $00, $19, $19, $00, $3B, $00, $18 
      .byte $33, $00, $19, $19, $00, $00, $00, $17 
      .byte $18, $00, $00, $18, $00, $00, $00, $17 
      .byte $17, $18, $00, $17, $18, $00, $17, $33 
ROOM_52:
      .byte $17, $00, $0B, $36, $0D, $00, $0B, $0D 
      .byte $17, $00, $00, $37, $00, $00, $00, $00 
      .byte $18, $00, $0B, $36, $0D, $00, $00, $0A 
      .byte $18, $00, $00, $00, $00, $00, $0B, $36 
      .byte $17, $00, $00, $00, $00, $00, $00, $00 
      .byte $17, $18, $33, $32, $0B, $0D, $0B, $0D 
ROOM_53:
      .byte $0B, $0D, $0B, $0D, $37, $00, $0A, $0B 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0A, $0B, $0D, $34, $15, $14, $3A, $3D 
      .byte $0B, $0D, $00, $00, $00, $00, $37, $0A 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
ROOM_54:
      .byte $0D, $0B, $0D, $00, $37, $37, $00, $0A 
      .byte $00, $00, $0B, $0D, $00, $00, $00, $0B 
      .byte $0B, $36, $0D, $00, $00, $00, $00, $0A 
      .byte $32, $00, $00, $00, $0C, $0E, $0C, $02 
      .byte $00, $00, $00, $17, $00, $00, $00, $00 
      .byte $0B, $0D, $0B, $0D, $37, $0C, $0E, $0C 
ROOM_55:
      .byte $0A, $00, $37, $00, $28, $01, $01, $01 
      .byte $17, $00, $18, $00, $29, $05, $01, $06 
      .byte $18, $00, $33, $00, $2B, $01, $01, $01 
      .byte $32, $00, $0A, $00, $2B, $01, $03, $01 
      .byte $00, $00, $33, $00, $29, $01, $01, $01 
      .byte $37, $00, $37, $00, $29, $03, $01, $01 
ROOM_56:
      .byte $01, $03, $27, $00, $37, $0C, $0E, $0A 
      .byte $01, $01, $22, $00, $12, $13, $00, $00 
      .byte $01, $03, $22, $00, $00, $0C, $0E, $0C 
      .byte $03, $01, $2C, $0E, $00, $00, $00, $00 
      .byte $01, $01, $20, $2D, $31, $2E, $30, $2F 
      .byte $09, $01, $01, $01, $04, $01, $01, $03 
ROOM_57:
      .byte $0B, $0D, $0B, $36, $36, $0D, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0E, $00, $00, $00, $00, $00, $00, $37 
      .byte $00, $00, $0C, $0E, $0C, $0E, $00, $00 
      .byte $31, $2E, $2E, $2D, $2E, $30, $30, $2D 
      .byte $01, $03, $01, $01, $05, $01, $06, $01 
ROOM_58:
      .byte $0B, $0D, $0B, $0D, $37, $3A, $3C, $3D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0A, $00, $00, $0A, $00, $00, $00, $37 
      .byte $00, $00, $0C, $02, $0E, $00, $00, $00 
      .byte $30, $31, $2E, $2F, $2F, $2D, $31, $31 
      .byte $01, $04, $01, $01, $01, $01, $03, $01 
ROOM_59:
      .byte $18, $17, $00, $18, $17, $00, $17, $33 
      .byte $00, $00, $00, $0B, $0D, $00, $00, $00 
      .byte $0C, $0E, $37, $00, $00, $33, $0C, $0E 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $2F, $30, $30, $2F, $30, $2D, $31, $2E 
      .byte $01, $01, $03, $01, $01, $01, $04, $01 
ROOM_60:
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $3A, $3C 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0C, $0E, $0C, $0E, $0C, $0E, $0C, $0E 
      .byte $00, $00, $00, $00, $00, $19, $0C, $0E 
      .byte $2D, $31, $31, $31, $31, $31, $2E, $30 
      .byte $01, $01, $05, $01, $06, $01, $01, $01 
ROOM_61:
      .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $0A, $37, $0C, $0E, $37, $0A, $3A, $3C 
      .byte $37, $00, $00, $00, $00, $00, $00, $00 
      .byte $31, $31, $31, $2E, $30, $30, $30, $2F 
      .byte $01, $04, $01, $01, $01, $03, $01, $01 
ROOM_62:
      .byte $0B, $0D, $37, $0A, $0B, $0D, $0B, $0D 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $38, $11, $11, $10, $10, $11, $10, $11 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $2D, $31, $31, $2E, $2F, $30, $30, $2F 
      .byte $01, $03, $01, $01, $01, $03, $01, $01 
ROOM_63:
      .byte $33, $00, $0A, $00, $2A, $03, $01, $01 
      .byte $00, $00, $37, $00, $29, $01, $01, $03 
      .byte $10, $10, $39, $00, $28, $01, $01, $01 
      .byte $00, $00, $00, $00, $29, $01, $03, $01 
      .byte $31, $2E, $2F, $30, $21, $01, $01, $01 
      .byte $01, $03, $01, $01, $04, $01, $01, $09 
ROOM_TITLE:                             // The room rendered during title screen
      .byte $01, $1A, $1B, $1C, $1D, $01, $01, $01 
      .byte $1E, $26, $25, $26, $23, $24, $25, $1F 
      .byte $27, $19, $00, $00, $00, $00, $00, $29 
      .byte $2C, $0A, $17, $0B, $0D, $0F, $0A, $2B 
      .byte $20, $2F, $30, $31, $30, $2D, $2E, $21 
      .byte $09, $01, $01, $01, $05, $01, $06, $01 

// =============================
// GAME TITLE
// =============================

GAME_TITLE:
      lda  #$40                         // The "Title" room
      sta  ROOM_NO                      
      jsr  DRAW_ROOM                    
      jsr  COPYRIGHT_PRINT              
      jsr  IRQ_RESTORE                  
W743D:
      lda  #$00                         
      sta  MUSIC_NUMBER                 
      jsr  MUSIC_PLAY                   
      sei                               
      lda  #$FD                         
      sta  $FF08                        // Wait for "FIRE"
      lda  $FF08                        
      cli                               
      bpl  W7458                        
      lda  LKP_INDEX                    
      cmp  #$40                         
      beq  W743D                        // ... or any key pressed
W7458:
      lda  #$03                         
      sta  MUSIC_NUMBER                 
      jsr  MUSIC_PLAY                   
      ldx  #$F9                         
      txs                               
      jmp  GAME_RESET                   

L7466:                                  // possible garbage
      .byte $00, $00, $00, $FF, $58, $30, $F1, $4C 
      .byte $49, $11, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00                    


IRQ_RESTORE:
      sei                               
      lda  #$0E                         
      sta  $0314                        // IRQ Ram Vector
      lda  #$CE                         
      sta  $0315                        // IRQ Ram Vector
      cli                               
      lda  #$08                         // Max sound level
      sta  $FF11                        // TED: Bits 0-3 : Volume control
W74B1:
      lda  LKP_INDEX                    // Key scan index
      cmp  #$40                         
      bne  W74B1                        
      rts                               

      *=$7500


// ====================================
// Tiles graphics is starting here
// Each tile has 4x4=16 bytes for attrs
// NOTE: This must be page aligned! ($7500)
// ====================================

TILE_ATTRIBUTES:
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $61, $61, $61, $61, $61, $61, $61, $61 
      .byte $68, $68, $68, $68, $68, $68, $68, $68 
      .byte $68, $68, $68, $68, $61, $61, $61, $61 
      .byte $68, $68, $68, $68, $68, $68, $68, $68 
      .byte $68, $68, $68, $68, $61, $61, $61, $61 
      .byte $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F 
      .byte $6F, $6F, $6F, $6F, $6F, $6F, $6F, $6F 
      .byte $58, $58, $58, $58, $58, $58, $58, $58 
      .byte $58, $58, $58, $58, $58, $58, $58, $58 
      .byte $5F, $5F, $5F, $5F, $5F, $5F, $5F, $5F 
      .byte $5F, $5F, $5F, $5F, $5F, $5F, $5F, $5F 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $5F, $5F, $5F, $5F, $5F, $5F, $5F, $5F 
      .byte $5F, $5F, $5F, $5F, $5F, $5F, $5F, $5F 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $41, $41, $41, $41, $41, $41, $41, $41 
      .byte $41, $41, $41, $41, $41, $41, $41, $41 
      .byte $E1, $E5, $E5, $E1, $E1, $E1, $E1, $E1 
      .byte $E1, $E1, $E1, $E1, $E1, $E1, $E1, $E1 
      .byte $E1, $E1, $E1, $E1, $E1, $E1, $E1, $E1 
      .byte $E1, $E1, $E1, $E1, $E5, $E5, $E5, $E5 
      .byte $00, $28, $28, $28, $98, $98, $98, $98 
      .byte $98, $58, $98, $98, $98, $58, $98, $98 
      .byte $98, $98, $98, $98, $98, $98, $98, $98 
      .byte $98, $98, $98, $98, $98, $98, $98, $98 
      .byte $33, $33, $33, $33, $33, $33, $33, $33 
      .byte $33, $33, $33, $33, $33, $33, $33, $33 
      .byte $33, $22, $22, $33, $33, $22, $22, $33 
      .byte $33, $22, $22, $33, $33, $22, $22, $33 
      .byte $00, $89, $89, $89, $87, $97, $87, $89 
      .byte $89, $89, $89, $85, $97, $97, $97, $97 
      .byte $52, $52, $52, $52, $52, $52, $52, $52 
      .byte $52, $52, $52, $52, $52, $52, $52, $52 
      .byte $11, $11, $11, $11, $11, $11, $11, $11 
      .byte $15, $15, $15, $15, $15, $15, $15, $15 
      .byte $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C 
      .byte $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $63, $63, $63, $63, $63, $63, $63, $63 
      .byte $61, $67, $67, $67, $67, $97, $97, $97 
      .byte $67, $97, $97, $97, $67, $97, $97, $97 
      .byte $61, $61, $61, $61, $67, $67, $67, $67 
      .byte $67, $97, $97, $97, $97, $97, $97, $67 
      .byte $67, $67, $97, $97, $67, $67, $97, $97 
      .byte $67, $67, $97, $97, $67, $67, $67, $67 
      .byte $97, $97, $97, $67, $97, $97, $97, $67 
      .byte $67, $67, $67, $67, $67, $67, $67, $61 
      .byte $61, $67, $67, $97, $61, $67, $97, $97 
      .byte $67, $67, $97, $97, $61, $97, $97, $97 
      .byte $61, $61, $61, $61, $67, $67, $67, $67 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $61, $61, $61, $61, $67, $67, $67, $67 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $61, $61, $61, $61, $67, $67, $67, $67 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $67, $67, $67, $67, $97, $97, $97, $97 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $61, $67, $97, $97, $61, $67, $97, $97 
      .byte $61, $67, $97, $97, $61, $67, $97, $97 
      .byte $97, $97, $67, $61, $97, $97, $67, $61 
      .byte $97, $97, $67, $61, $97, $97, $67, $61 
      .byte $97, $67, $67, $61, $97, $67, $61, $61 
      .byte $97, $67, $61, $61, $97, $97, $67, $61 
      .byte $97, $97, $67, $61, $97, $67, $67, $61 
      .byte $97, $67, $61, $61, $97, $97, $61, $61 
      .byte $97, $67, $67, $61, $97, $97, $67, $61 
      .byte $97, $97, $67, $61, $97, $97, $67, $61 
      .byte $61, $67, $97, $97, $67, $97, $97, $97 
      .byte $67, $97, $97, $97, $67, $67, $97, $97 
      .byte $97, $97, $97, $97, $67, $67, $67, $67 
      .byte $67, $67, $67, $67, $61, $61, $61, $61 
      .byte $97, $97, $97, $97, $67, $67, $67, $67 
      .byte $67, $67, $67, $67, $61, $61, $61, $61 
      .byte $97, $97, $97, $97, $97, $67, $67, $67 
      .byte $67, $67, $67, $67, $67, $67, $67, $67 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $67, $67, $67, $67, $67, $67, $67, $67 
      .byte $97, $97, $97, $97, $67, $67, $67, $67 
      .byte $67, $67, $67, $67, $61, $61, $61, $61 
      .byte $55, $55, $55, $55, $58, $58, $58, $58 
      .byte $58, $58, $58, $58, $58, $58, $58, $51 
      .byte $15, $15, $15, $15, $15, $15, $15, $15 
      .byte $15, $15, $15, $15, $15, $15, $15, $15 
      .byte $33, $33, $33, $33, $33, $33, $33, $33 
      .byte $33, $33, $33, $33, $33, $33, $33, $33 
      .byte $97, $97, $97, $67, $97, $97, $97, $97 
      .byte $97, $97, $97, $97, $97, $97, $97, $97 
      .byte $F5, $F5, $F5, $F5, $F5, $F5, $F5, $F5 
      .byte $F5, $F5, $F5, $F5, $F5, $F5, $F5, $F5 
      .byte $55, $55, $55, $55, $55, $58, $58, $58 
      .byte $58, $58, $58, $58, $58, $58, $58, $58 
      .byte $68, $68, $68, $68, $68, $68, $68, $68 
      .byte $68, $68, $68, $68, $68, $65, $65, $65 
      .byte $65, $65, $65, $65, $65, $65, $65, $65 
      .byte $65, $65, $65, $65, $65, $65, $65, $65 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $00, $89, $89, $89, $82, $82, $82, $82 
      .byte $82, $82, $89, $89, $00, $55, $59, $55 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $99, $99, $99, $99, $99, $99, $99, $99 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 

// ======================
// Check the exits from room
// ======================

CHECK_ACTOR_ROOM_EXIT:
      ldx  #$00                         
      ldy  #$03                         
      lda  ACTOR_Y                      
      cmp  #$02                         
      bcc  EXIT_FROM_ROOM               
      dey                               
      cmp  #$A6                         
      bcs  EXIT_FROM_ROOM               
      dey                               
      ldx  #$08                         
      lda  ACTOR_X                      
      cmp  #$02                         
      bcc  EXIT_FROM_ROOM               
      dey                               
      cmp  #$E6                         
      bcs  EXIT_FROM_ROOM               
      rts                               


// ===============================
// Exit from room:
//  
//   YR	Direction
//    3   Top   
//    2   Bottom
//    1   Left
//    0   Right
// ===============================

EXIT_FROM_ROOM:
      stx  zp02                         
      ldx  #$02                         
W7924:
      lda  ACTOR_LAST_Y,x               
      sta  ACTOR_LAST_ROOM_START_Y,x    
      dex                               
      bpl  W7924                        
      ldx  zp02                         
      lda  ACTOR_NEW_ROOM_Y,y           
      sta  ACTOR_Y,x                    
      lda  NEW_ROOM_OFFSET,y            
      clc                               
      adc  ROOM_NO                      
      sta  ROOM_NO                      
      sta  ACTOR_LAST_ROOM              
      lda  ACTOR_Y                      
      sta  ACTOR_LAST_Y                 
      lda  ACTOR_X                      
      sta  ACTOR_LAST_X                 
      jsr  DRAW_ROOM                    
      ldx  #$00                         
      stx  VISIBLE_SPRITE               // Turn off all sprites
      stx  PIRATE_SWORD_DISTANCE        
      stx  ACTOR_SWORD_DISTANCE         
      lda  #$01                         
      jsr  DRAW_SPRITE                  // Draw actor
      jsr  DRAW_OBJECTS                 
      lda  #$40                         // Wait for 64 frames (~1s) before John Long Silver enters to scene
      sta  JSILVER_ENTRY_DELAY          
W7964:
      rts                               

L7965:                                  // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00               

// ======================================
// Checks is the player reached the ship
// for escape
// ======================================

CHECK_SHIP:
      lda  ROOM_NO                      
      cmp  #$20                         
      bne  W7964                        
      lda  ACTOR_X                      
      cmp  #$90                         
      bcs  W7964                        
      ldx  #$01                         
      lda  #$05                         
      sed                               
      clc                               
      adc  ACTOR_HP                     
      cld                               
      jsr  ADD_TO_SCORE                 
      jsr  IRQ_RESTORE                  
      lda  #$02                         
      sta  MUSIC_NUMBER                 
      jsr  MUSIC_PLAY                   
      jmp  GAME_FINISHED                

      .byte $20, $00, $13, $4C          // possible garbage
      .byte $E0, $1F, $00, $00          


REDRAW_ROOM:
      lda  #$00                         
      sta  PIRATE_SWORD_DISTANCE        
      sta  ACTOR_SWORD_DISTANCE         
      sta  VISIBLE_SPRITE               // Turn off all sprites
      jsr  DRAW_ROOM                    
      ldx  #$00                         
      lda  #$01                         
      jsr  DRAW_SPRITE                  // Draw actor
      jsr  DRAW_OBJECTS                 
      lda  #$40                         // Wait for 64 frames (~1s) before John Long Silver enters to scene
      sta  JSILVER_ENTRY_DELAY          
      jmp  GAME_LOOP                    

      .byte $00, $00, $00               


ACTOR_J_SILVER_CHECK:
      jsr  GET_SPR_ATTR_ADDR            
      ldx  #$02                         
W79C5:
      ldy  #$02                         
W79C7:
      lda  (PTR_LO),y                   
      cmp  #$75                         // Actor hit ?
      beq  W79E0                        
      dey                               
      bpl  W79C7                        
      dex                               
      bmi  W79DA                        
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      bcs  W79C5                        
W79DA:
      ldx  #$03                         
      jsr  DRAW_SPRITE                  // Draw sprite $03 (John Silver)
      rts                               

W79E0:
      ldx  #$00                         
      jsr  DRAW_SPRITE                  // Undraw actor
      jsr  W79DA                        
      jmp  ACTOR_DIE                    

      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00          
W79FF:
      rts                               

UPDATE_PIRATE:
      lda  VISIBLE_SPRITE               
      and  #$04                         // Sprite $02 is visible ?
      beq  W79FF                        // If not visble, then exit
      dec  PIRATE_ANIM_TIMER            
      bpl  W7A34                        
      lda  #$07                         
      sta  PIRATE_ANIM_TIMER            
      ldx  #$02                         
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw sprite $02
      lda  PIRATE_02_X                  
      tay                               
      clc                               
      adc  #$02                         
      sta  zp02                         
      and  #$07                         
      beq  W7A29                        
      lda  zp02                         // possible garbage
      bne  W7A2C                        
W7A29:
      tya                               
      and  #$F8                         
W7A2C:
      sta  PIRATE_02_X                  
      lda  #$01                         
      jsr  DRAW_SPRITE                  // Draw sprite $02
W7A34:
      ldy  PIRATE_SWORD_DISTANCE        
      bne  W7A9F                        
      lda  zp33                         
      bpl  W7A9E                        

// ======================================
// Checks if the pirate wants to throw the sword
// ======================================

      sec                               
      lda  PIRATE_02_Y                  
      tay                               
      sbc  #$0A                         
      cmp  ACTOR_Y                      
      bcs  W7A9E                        
      tya                               
      adc  #$0A                         
      cmp  ACTOR_Y                      
      bcc  W7A9E                        
      sty  SWORD_06_Y                   
      lda  PIRATE_02_X                  
      sta  SWORD_06_X                   
      cmp  ACTOR_X                      
      bcs  W7A6D                        
      adc  #$40                         
      bcs  PIRATE_THROWS_SWORD_R        
      cmp  ACTOR_X                      
      bcc  W7A9E                        

// ======================================
// The pirate throws the sword right
// ======================================

PIRATE_THROWS_SWORD_R:
      ldy  #>SWORD_R_SHIFT_00           
      lda  #$02                         
      bne  PIRATE_THROWS_SWORD          
W7A6D:
      sbc  #$40                         
      bcc  PIRATE_THROWS_SWORD_L        
      cmp  ACTOR_X                      
      bcs  W7A9E                        

// ======================================
// The pirate throws the sword left
// ======================================

PIRATE_THROWS_SWORD_L:
      ldy  #>SWORD_L_SHIFT_00           
      lda  #$FE                         
PIRATE_THROWS_SWORD:
      sty  SPRITE_06_BITMAP_HI          
      sta  PIRATE_SWORD_DIRECTION       
      ldx  #$0A                         
      asl                               
      bcc  W7A86                        
      ldx  #$F4                         
W7A86:
      txa                               
      clc                               
      adc  SWORD_06_X                   
      sta  SWORD_06_X                   
      lda  #$46                         
      sta  SPRITE_06_LUM                
      lda  #$30                         
      sta  PIRATE_SWORD_DISTANCE        
      ldx  #$06                         
      jsr  DRAW_SPRITE                  // Draw sprite $06
      lsr  zp33                         
W7A9E:
      rts                               

W7A9F:
      dey                               
      sty  PIRATE_SWORD_DISTANCE        
      ldx  #$06                         
      lda  #$00                         
      jsr  DRAW_SPRITE                  // Undraw sprite $06
      lda  SWORD_06_X                   
      sta  zp0a                         
      clc                               
      adc  PIRATE_SWORD_DIRECTION       
      cmp  #$01                         
      bcc  PIRATE_SWORD_STOP            
      cmp  #$F0                         
      bcs  PIRATE_SWORD_STOP            
      sta  SWORD_06_X                   
      jsr  GET_SPR_ATTR_ADDR            
      ldx  #$01                         
W7AC1:
      ldy  #$02                         
W7AC3:
      lda  (PTR_LO),y                   
      beq  W7ACD                        
      cmp  #$75                         // Sword hit actor?
      beq  W7AF8                        
      bne  PIRATE_SWORD_STOP            
W7ACD:
      dey                               
      bpl  W7AC3                        
      dex                               
      bmi  DRAW_PIRATE_SWORD            
      lda  #$28                         
      jsr  ADD_TO_PTR                   
      bcs  W7AC1                        
DRAW_PIRATE_SWORD:
      ldx  #$06                         
      jsr  DRAW_SPRITE                  // Draw sprite $06
      rts                               

PIRATE_SWORD_STOP:
      lda  zp0a                         
      sta  SWORD_06_X                   
      lda  SWORD_06_Y                   
      clc                               
      adc  #$05                         
      sta  SWORD_06_Y                   
      lda  #$00                         
      sta  PIRATE_SWORD_DISTANCE        
      jsr  SFX_03_PLAY                  
      jmp  DRAW_PIRATE_SWORD            

W7AF8:
      jmp  ACTOR_DIE                    

      *=$7B00

COPYRIGHT_01:
      .byte $30, $30, $33, $33, $30, $30, $0F, $00 
      .byte $0C, $CC, $0C, $0C, $CC, $0C, $F0, $00 
      .byte $0C, $33, $30, $30, $30, $33, $0C, $00 
      .byte $3C, $33, $33, $3C, $33, $33, $3F, $00 
      .byte $33, $3F, $3F, $33, $33, $33, $33, $00 
      .byte $00, $03, $03, $0F, $03, $03, $00, $00 
      .byte $03, $03, $03, $C3, $03, $03, $03, $00 
      .byte $33, $F3, $F3, $33, $33, $33, $33, $00 
      .byte $C0, $30, $30, $C0, $30, $30, $30, $00 
      .byte $CC, $FC, $FC, $CC, $CC, $CC, $CC, $00 
      .byte $C3, $CC, $CC, $CC, $CC, $CC, $C3, $00 
      .byte $0F, $CC, $0C, $0F, $0C, $CC, $0C, $00 
      .byte $03, $CC, $CC, $0C, $CC, $CC, $C3, $00 
      .byte $03, $C3, $C3, $C3, $C3, $C3, $03, $00 
      .byte $0F, $03, $03, $03, $03, $03, $F3, $00 
      .byte $CF, $0C, $0C, $0C, $0C, $0C, $0F, $00 
COPYRIGHT_02:
      .byte $00, $00, $00, $00, $33, $3F, $3F, $33 
      .byte $00, $00, $00, $00, $0C, $33, $30, $30 
      .byte $00, $00, $00, $00, $33, $3F, $3F, $33 
      .byte $00, $00, $00, $00, $30, $30, $30, $30 
      .byte $00, $00, $00, $00, $33, $33, $33, $0C 
      .byte $00, $00, $00, $00, $33, $33, $33, $0C 
      .byte $00, $00, $00, $00, $33, $33, $33, $0C 
      .byte $00, $00, $00, $00, $33, $33, $33, $33 
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00, $00, $00, $30, $CC, $C0, $C0 
      .byte $00, $00, $00, $00, $3C, $33, $33, $33 
      .byte $00, $00, $00, $00, $33, $33, $33, $33 
      .byte $00, $00, $00, $00, $3C, $33, $33, $33 
      .byte $00, $00, $00, $00, $3C, $33, $33, $33 
      .byte $00, $00, $00, $00, $30, $30, $30, $30 
      .byte $00, $00, $00, $00, $3F, $30, $30, $3C 
MUSIC_00:
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $95, $03, $AB, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $71, $03, $95, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $56, $03, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $2A, $03, $56, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $95, $03, $AB, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $71, $03, $95, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $56, $03, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $FF, $00, $FF, $00 
      .byte $2A, $03, $56, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $95, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $A0, $03, $A2, $03 
      .byte $54, $02, $95, $03, $8E, $03, $90, $03 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $71, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $7F, $01, $81, $03, $FF, $00, $FF, $00 
      .byte $C0, $02, $81, $03, $FF, $00, $FF, $00 
      .byte $C5, $01, $8F, $03, $80, $03, $82, $03 
      .byte $E3, $02, $8F, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $2A, $03, $FF, $00, $FF, $00 
      .byte $53, $02, $55, $02, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $95, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $A0, $03, $A2, $03 
      .byte $54, $02, $95, $03, $8E, $03, $90, $03 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $71, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $7F, $01, $81, $03, $FF, $00, $FF, $00 
      .byte $C0, $02, $81, $03, $FF, $00, $FF, $00 
      .byte $C5, $01, $8F, $03, $80, $03, $82, $03 
      .byte $E3, $02, $8F, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $2A, $03, $FF, $00, $FF, $00 
      .byte $53, $02, $55, $02, $FF, $00, $FF, $00 
      .byte $A9, $00, $71, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $71, $03, $80, $03, $82, $03 
      .byte $54, $02, $71, $03, $80, $03, $82, $03 
      .byte $A9, $00, $71, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $56, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $56, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $7F, $01, $81, $03, $FF, $00, $FF, $00 
      .byte $C0, $02, $81, $03, $FF, $00, $FF, $00 
      .byte $C5, $01, $8F, $03, $80, $03, $82, $03 
      .byte $E3, $02, $8F, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $2A, $03, $FF, $00, $FF, $00 
      .byte $53, $02, $56, $02, $FF, $00, $FF 

// ====================================
// I think this is a bug in the program
// since changing this byte will 
// corrupt the title music data, 
// but luckily it does not cause any
// problems ;-)
// ====================================

PIRATE_ANIM_TIMER:                      
      .byte $05, $A9, $00, $71, $03, $FF, $00, $FF 
      .byte $00, $54, $02, $71, $03, $FF, $00, $FF 
      .byte $00, $A9, $00, $71, $03, $80, $03, $82 
      .byte $03, $54, $02, $71, $03, $80, $03, $82 
      .byte $03, $A9, $00, $71, $03, $FF, $00, $FF 
      .byte $00, $54, $02, $56, $03, $FF, $00, $FF 
      .byte $00, $A9, $00, $56, $03, $FF, $00, $FF 
      .byte $00, $54, $02, $71, $03, $FF, $00, $FF 
      .byte $00, $7F, $01, $81, $03, $FF, $00, $FF 
      .byte $00, $C0, $02, $81, $03, $FF, $00, $FF 
      .byte $00, $C5, $01, $8F, $03, $80, $03, $82 
      .byte $03, $E3, $02, $8F, $03, $FF, $00, $FF 
      .byte $00, $A9, $00, $95, $03, $FF, $00, $FF 
      .byte $00, $54, $02, $2A, $03, $FF, $00, $FF 
      .byte $00, $A9, $00, $2A, $03, $FF, $00, $FF 
      .byte $00, $53, $02, $56, $02, $FF, $00, $FF 
      .byte $00, $01                    
MUSIC_01:
      .byte $A9, $00, $71, $03, $FF, $00, $FF, $00 
      .byte $53, $02, $55, $02, $80, $03, $82, $03 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $56, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $56, $03, $FF, $00, $FF, $00 
      .byte $7F, $01, $60, $03, $FF, $00, $FF, $00 
      .byte $BF, $02, $C1, $02, $55, $03, $57, $03 
      .byte $BF, $02, $60, $03, $FF, $00, $FF, $00 
      .byte $C5, $01, $42, $03, $FF, $00, $FF, $00 
      .byte $E3, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $42, $03, $8F, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $71, $03, $FF, $00, $FF, $00 
      .byte $53, $02, $55, $02, $80, $03, $82, $03 
      .byte $54, $02, $71, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $56, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $56, $03, $FF, $00, $FF, $00 
      .byte $7F, $01, $42, $03, $FF, $00, $FF, $00 
      .byte $42, $03, $60, $03, $FF, $00, $FF, $00 
      .byte $E3, $02, $95, $03, $FF, $00, $FF, $00 
      .byte $56, $03, $95, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $54, $02, $01     
MUSIC_02:
      .byte $94, $03, $96, $03, $8E, $03, $90, $03 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $2A, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $71, $03, $5F, $03, $61, $03 
      .byte $A9, $00, $56, $03, $70, $03, $72, $03 
      .byte $54, $02, $95, $03, $8E, $03, $90, $03 
      .byte $A9, $00, $95, $03, $01     
MUSIC_03:
      .byte $7F, $01, $81, $03, $70, $03, $72, $03 
      .byte $C0, $02, $81, $03, $FF, $00, $FF, $00 
      .byte $C5, $01, $8F, $03, $80, $03, $82, $03 
      .byte $E3, $02, $8F, $03, $FF, $00, $FF, $00 
      .byte $A9, $00, $95, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $2A, $03, $FF, $00, $FF, $00 
      .byte $54, $02, $95, $03, $01     
L7FA8:                                  // possible garbage
      .byte $00, $00, $00, $00, $00, $00, $00, $00 
      .byte $00, $00                    
