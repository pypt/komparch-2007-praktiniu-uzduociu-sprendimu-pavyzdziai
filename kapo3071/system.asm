write Macro eilute
  mov ah, 09h
  lea dx, eilute
  int 21h
endm

writeln Macro
  mov dl, 13
  mov ah, 02h
  int 21h
  mov dl, 10
  int 21h
endm

halt Macro
  mov ah, 4ch
  int 21h
endm

fileermsg Macro
  fileerrormsg db 'Error in file system $', 13, 10
endm

fileerror Macro
  write fileerrormsg
  halt
endM

stderror Macro
  local pav
  jnc pav
  fileerror
  pav:
endM


