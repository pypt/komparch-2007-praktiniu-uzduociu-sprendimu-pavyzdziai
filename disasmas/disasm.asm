title disasm;Disassembler for COM files

masm
model small
  include macro.inc
.stack 1000h
.data
  include data.inc
  include instr.inc
.code
start:
   mov ax, @data
   mov ds, ax

.486

   call open_input_file
   call open_output_file
  ; call write_output

   main_loop:
      mov no_cmd, 0
      call read_from_file
      call disasembleriuok

      cmp no_cmd, 0    ;pasitikrinu, ar sia komanda reikia spausdinti
      jne praleisti1
 
      cmp length_of_found_command, 0
      jne viskas_ok
      call neatpazinta_komanda
      viskas_ok:
      inc o_line_number
      call write_output
      
      praleisti1:
      xor ax, ax
      mov al, o_code_masininis[0]
      add o_command_number, ax

      call persok_duomenis ;persoku duomenu segmenta

   jmp main_loop

  call close_output_file

   mov ah, 4ch
   int 21h

include failai.inc
include math.inc
include disasm1.inc
include nagr.inc

end start