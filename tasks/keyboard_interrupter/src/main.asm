  .model tiny
  .386
  .code
  org 100h
;  locals
_1:
  jmp start
int9:
  push AX
  push DI
  push ES
  in AL, 60h    ;����. ��� ������� �� ��

  mov SI, tail
  mov [SI], AL
  inc SI
  cmp SI, offset head
  jne next2
    mov tail, offset buffer
    jmp end2
  next2:
    mov tail, SI
  end2:

  pop ES
  pop DI
  in AL, 61h
  mov AH, AL
  or AL, 80h
  out 61h, AL
  xchg AH, AL
  out 61h, AL
  mov AL, 20h
  out 20H, AL
  pop AX
  iret
bad:
        db 0eah
int9old dd 0
buffer  db 10 dup(?)
head    dw ?
tail    dw ?
msg     db "Yes! You made it! Flag is the entered code", 0Dh, 0Ah, 24h
state   db 22
graph   db 01Ch, 00Fh, 02Ch, 010h, 00Ah, 019h, 030h, 02Eh, 017h, 00Eh
        db 003h, 01Bh, 01Fh, 021h, 028h, 027h, 012h, 02Dh, 022h, 015h
        db 01Fh, 016h, 027h, 031h, 011h, 020h, 02Dh, 021h, 029h, 015h
        db 004h, 016h, 023h, 020h, 015h, 013h, 01Dh, 029h, 031h, 028h
        db 016h, 027h, 012h, 02Fh, 022h, 01Bh, 013h, 001h, 020h, 01Dh
        db 01Eh, 02Ch, 018h, 000h, 026h, 01Ah, 019h, 00Eh, 025h, 009h
        db 02Eh, 01Ah, 00Eh, 00Dh, 00Bh, 005h, 025h, 00Ah, 018h, 02Ch
        db 02Ch, 00Eh, 017h, 026h, 010h, 014h, 006h, 000h, 008h, 009h
        db 000h, 025h, 030h, 02Ch, 017h, 006h, 02Eh, 009h, 00Ah, 010h
        db 00Eh, 01Eh, 018h, 00Ah, 00Dh, 01Ch, 005h, 00Fh, 030h, 00Ch
        db 00Eh, 01Ch, 000h, 019h, 00Fh, 010h, 030h, 009h, 00Ch, 026h
        db 017h, 018h, 007h, 00Fh, 01Ah, 00Ah, 01Eh, 00Dh, 00Ch, 009h
        db 025h, 00Ah, 017h, 026h, 02Ch, 01Ch, 00Dh, 000h, 01Ah, 00Fh
        db 009h, 005h, 026h, 02Ch, 018h, 00Fh, 030h, 017h, 025h, 008h
        db 019h, 010h, 01Eh, 018h, 01Ch, 025h, 00Ah, 008h, 026h, 00Ch
        db 02Eh, 00Ah, 018h, 01Ch, 030h, 025h, 000h, 017h, 00Dh, 008h
        db 00Ch, 009h, 030h, 02Ch, 026h, 018h, 008h, 01Ah, 01Ch, 00Fh
        db 027h, 024h, 01Dh, 003h, 022h, 013h, 01Bh, 028h, 02Fh, 016h
        db 01Fh, 02Fh, 028h, 002h, 016h, 01Bh, 015h, 003h, 020h, 001h
        db 015h, 027h, 029h, 004h, 003h, 028h, 02Fh, 016h, 01Fh, 012h
        db 009h, 006h, 030h, 007h, 01Ah, 005h, 00Dh, 00Ch, 00Ah, 008h
        db 01Bh, 013h, 01Dh, 029h, 031h, 003h, 01Fh, 02Fh, 028h, 027h
        db 015h, 001h, 020h, 012h, 013h, 003h, 01Bh, 004h, 023h, 027h
        db 010h, 026h, 000h, 009h, 00Dh, 01Eh, 030h, 01Ah, 02Ch, 005h
        db 010h, 009h, 025h, 02Ch, 00Fh, 017h, 00Eh, 01Ch, 030h, 000h
        db 006h, 00Dh, 01Ah, 000h, 00Ch, 017h, 00Fh, 005h, 00Eh, 030h
        db 005h, 00Fh, 010h, 00Dh, 00Eh, 017h, 02Eh, 018h, 030h, 00Ah
        db 01Fh, 01Dh, 028h, 027h, 023h, 015h, 02Fh, 020h, 016h, 021h
        db 025h, 010h, 008h, 030h, 01Eh, 02Eh, 017h, 026h, 009h, 00Dh
        db 02Fh, 022h, 031h, 011h, 020h, 01Fh, 029h, 001h, 012h, 013h
        db 00Eh, 025h, 00Ah, 00Ch, 026h, 00Fh, 030h, 005h, 009h, 00Dh
        db 004h, 01Bh, 016h, 02Dh, 002h, 021h, 011h, 02Fh, 023h, 020h
        db 012h, 001h, 031h, 022h, 002h, 01Dh, 01Bh, 003h, 01Fh, 004h
        db 016h, 020h, 01Dh, 02Dh, 022h, 003h, 027h, 01Bh, 015h, 02Fh
        db 003h, 029h, 023h, 01Fh, 013h, 012h, 028h, 001h, 016h, 01Bh
        db 016h, 01Fh, 01Dh, 031h, 015h, 013h, 02Fh, 012h, 028h, 001h
        db 029h, 013h, 01Dh, 028h, 023h, 012h, 016h, 02Ah, 02Dh, 027h
        db 02Ch, 018h, 019h, 000h, 02Eh, 01Ah, 01Ch, 010h, 009h, 008h
        db 009h, 00Fh, 00Dh, 01Ah, 019h, 010h, 006h, 017h, 00Ah, 005h
        db 003h, 001h, 023h, 004h, 011h, 022h, 016h, 02Fh, 02Dh, 013h
        db 027h, 016h, 01Dh, 01Bh, 020h, 023h, 029h, 001h, 002h, 011h
        db 015h, 003h, 01Bh, 01Fh, 021h, 028h, 016h, 027h, 022h, 011h
        db 02Bh, 021h, 020h, 012h, 01Fh, 004h, 029h, 02Dh, 016h, 003h
        db 004h, 02Ah, 028h, 01Bh, 02Fh, 015h, 009h, 02Dh, 001h, 003h
        db 00Dh, 01Eh, 017h, 025h, 00Eh, 00Ah, 00Ch, 006h, 009h, 01Ch
        db 003h, 004h, 022h, 020h, 01Fh, 031h, 016h, 002h, 013h, 001h
        db 017h, 02Ch, 00Dh, 00Ah, 01Eh, 009h, 000h, 008h, 00Eh, 005h
        db 021h, 013h, 027h, 003h, 023h, 004h, 001h, 01Bh, 01Fh, 011h
        db 026h, 006h, 02Eh, 025h, 01Ch, 005h, 019h, 01Ah, 008h, 009h
        db 029h, 021h, 020h, 012h, 015h, 02Dh, 022h, 01Bh, 013h, 004h

start:

  mov head, offset buffer
  mov tail, offset buffer

setint9:
  ; save old int
  mov AX, 3509h
  int 21h
  mov word ptr int9old, BX
  mov word ptr int9old[2], ES 
  ; set new int
  mov AX, 2509h
  lea DX, int9 
  int 21h

whiletrue:
  mov DI, head
  mov SI, tail
  cmp DI, SI
  je whiletrue

  mov AL, [DI]  ; AL = scan-code
  inc DI        ; DI++
  cmp DI, offset head
  jne next1
    mov head, offset buffer
    jmp end1
  next1:
    mov head, DI
  end1:


  cmp AL, 81h   ; if AL = ESC
  je _esc       ; break

  cmp AL, 0Bh    ; if AL > '0'
  ja whiletrue  ; continue

  cmp AL, 02    ; if AL < '1'
  jl whiletrue  ; continue

;  call print

  push DI BX AX
  xor BX, BX
  mov BL, AL
  xor AX, AX
  mov AL, state
  mov BH, 10
  mul BH
  mov BH, 0
  mov DI, AX
  add DI, offset graph
  add DI, BX
  sub DI, 2

  mov AL, byte ptr [DI]
  mov state, AL
  
  cmp AL, 20
  jne noexit

  lea DX, msg   ; print msg
  mov AH, 9
  int 21h

  noexit:

  pop AX BX DI


  jmp whiletrue

_esc:


setoldint9:
  push DS
  mov AX, 2509h
  mov DX, word ptr int9old
  mov DS, word ptr int9old[2]
  int 21h
  pop DS

  ret

;print:
;  ; in: AL
;  ; out: none
;  push DX
;
;  ; print 1st symbol
;  push AX
;  and AL, 0f0h
;  shr AL, 4
;  call printhex
;  pop AX
;
;  ; print 2nd symbol
;  push AX
;  and AL, 0fh
;  call printhex
;
;  mov DL, 0Dh
;  int 21h
;  mov DL, 0Ah
;  int 21h
;  pop AX
;
;  pop DX
;  ret
;
;printhex:
;  cmp AL, 10
;  sbb AL, 69h
;  das
;  mov DL, AL
;  mov AH, 2
;  int 21h    
;  ret
end _1  