;   Description: Fast crc32
;        Author: Helle
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27925&start=20#p333768
; -----------------------------------------------------------------------------


; Windows7/64, PureBasic 5.40 LTS (x64)
; "Helle" Klaus Helbing, 05.12.2015
; CRC32 mit PCLMULQDQ ohne PB-CRC32
; Basierend auf: http://stuff.mit.edu/afs/sipb/contrib/linux/arch/x86/crypto/crc32-pclmul_asm.S
; Lizenz beachten!

; Licenz from https://stuff.mit.edu/afs/sipb/contrib/linux/arch/x86/crypto/crc32-pclmul_asm.S
; /* GPL HEADER START
;  *
;  * DO Not ALTER Or REMOVE COPYRIGHT NOTICES Or This FILE HEADER.
;  *
;  * This program is free software; you can redistribute it and/or modify
;  * it under the terms of the GNU General Public License version 2 only,
;  * As published by the Free Software Foundation.
;  *
;  * This program is distributed in the hope that it will be useful, but
;  * WITHOUT ANY WARRANTY; without even the implied warranty of
;  * MERCHANTABILITY Or FITNESS For A PARTICULAR PURPOSE.  See the GNU
;  * General Public License version 2 For more details (a copy is included
;  * in the LICENSE file that accompanied This code).
;  *
;  * You should have received a copy of the GNU General Public License
;  * version 2 along With This program; If not, see http://www.gnu.org/licenses
;  *
;  * Please  visit http://www.xyratex.com/contact If you need additional
;  * information Or have any questions.
;  *
;  * GPL HEADER End
;  */


Procedure.l CRC32_CL(Mem, Laenge)
  CompilerIf #PB_Compiler_Processor=#PB_Processor_x64    
    
    !MOV r9,[p.v_Laenge]
    !OR r9,r9                            ;erstmal Test, ob Länge = 0
    !JNZ Laenge_OK                        ;nicht 0
    !MOV rax,r9 
    ProcedureReturn                       ;Rückgabewert = 0 für Länge = 0
    
    !Laenge_OK:
    ;Test auf PCLMULQDQ
    !MOV eax,1
    !CPUID
    !MOV eax,0FFFFFFFFh                  ;Initialisierungswert für CRC32
    !TEST ecx,2
    !JNZ CL_OK                            ;kann losgehen! Auskommentieren für Test ohne PCLMULQDQ
    
    !LEA r10,[CRC_Table]                 ;die CPU bringts nicht, also konventionell
    !MOV r8,[p.v_Mem]
    !@@:
    !MOVZX rcx,byte[r8]
    !XOR cl,al
    !SHR rax,8
    !XOR eax,dword[r10+rcx*4]
    !INC r8
    !DEC r9                              ;Länge
    !JNZ @b
    !NOT eax                             ;wegen Polynomial Reversed
    ProcedureReturn
    
    !CL_OK:
    !AND r9,0FFFFFFFFFFFFFFC0h           ;Länge < 40?
    !JZ less_64                           ;ja, konventionell weiter
    
    !MOVD xmm0,eax                       ;eax = 0FFFFFFFFh  Initialisierungswert für CRC32
    !MOV r8,[p.v_Mem]
    !MOVDQA xmm1,[r8]
    !MOVDQA xmm2,[r8+10h]
    !MOVDQA xmm3,[r8+20h]
    !MOVDQA xmm4,[r8+30h]
    !PXOR xmm1,xmm0
    
    !SUB r9,40h
    !ADD r8,40h
    
    !MOVDQA xmm0,[Lconstant_R2R1]
    
    !loop_64:
    !PREFETCHNTA [r8+0c0h]               ;Cache "vorfüllen"
    !MOVDQA xmm5,xmm1
    !MOVDQA xmm6,xmm2
    !MOVDQA xmm7,xmm3
    !MOVDQA xmm8,xmm4
    
    !PCLMULQDQ xmm1,xmm0,00h
    !PCLMULQDQ xmm2,xmm0,00h
    !PCLMULQDQ xmm3,xmm0,00h
    !PCLMULQDQ xmm4,xmm0,00h
    
    !PCLMULQDQ xmm5,xmm0,11h
    !PCLMULQDQ xmm6,xmm0,11h
    !PCLMULQDQ xmm7,xmm0,11h
    !PCLMULQDQ xmm8,xmm0,11h
    
    !PXOR xmm1,xmm5
    !PXOR xmm2,xmm6
    !PXOR xmm3,xmm7
    !PXOR xmm4,xmm8
    
    !PXOR xmm1,[r8]
    !PXOR xmm2,[r8+10h]
    !PXOR xmm3,[r8+20h]
    !PXOR xmm4,[r8+30h]
    
    !SUB r9,40h
    !ADD r8,40h
    !CMP r9,40h
    !JGE loop_64
    
    !MOVDQA xmm0,[Lconstant_R4R3]
    !PREFETCHNTA [r8]
    
    !MOVDQA xmm5,xmm1
    !PCLMULQDQ xmm1,xmm0,00h
    !PCLMULQDQ xmm5,xmm0,11h
    !PXOR xmm1,xmm5
    !PXOR xmm1,xmm2
    
    !MOVDQA xmm5,xmm1
    !PCLMULQDQ xmm1,xmm0,00h
    !PCLMULQDQ xmm5,xmm0,11h
    !PXOR xmm1,xmm5
    !PXOR xmm1,xmm3
    
    !MOVDQA xmm5,xmm1
    !PCLMULQDQ xmm1,xmm0,00h
    !PCLMULQDQ xmm5,xmm0,11h
    !PXOR xmm1,xmm5
    !PXOR xmm1,xmm4
    
    !PCLMULQDQ xmm0,xmm1,01h
    !PSRLDQ xmm1,08h
    !PXOR xmm1,xmm0
    
    !MOVDQA xmm2,xmm1
    
    !MOVDQA xmm0,[Lconstant_R5]
    !MOVDQA xmm3,[Lconstant_mask32]
    
    !PSRLDQ xmm2,04h
    !PAND xmm1,xmm3
    !PCLMULQDQ xmm1,xmm0,00h
    !PXOR xmm1,xmm2
    
    !MOVDQA xmm0,[Lconstant_RUpoly]
    
    !MOVDQA xmm2,xmm1
    !PAND xmm1,xmm3
    !PCLMULQDQ xmm1,xmm0,10h
    !PAND xmm1,xmm3
    !PCLMULQDQ xmm1,xmm0,00h
    !PXOR xmm1,xmm2
    !PEXTRD eax,xmm1,01h                 ;eax ist CRC32 (bis hierher)
    !less_64:                              ;Rest (max.63 Bytes)
    
    !MOV r8,[p.v_Mem]
    !MOV r9,[p.v_Laenge]
    !ADD r8,r9
    !AND r9,3fh                          ;möglicher Rest
    !JZ NoRest                            ;kein Rest
    !LEA r10,[CRC_Table]                 ;die restlichen Bytes mit Tabelle
    !SUB r8,r9
    !@@:
    !MOVZX rcx,byte[r8]
    !XOR cl,al
    !SHR rax,8
    !XOR eax,dword[r10+rcx*4]
    !INC r8
    !DEC r9
    !JNZ @b
    !NoRest:
    !NOT eax                             ;wegen Polynomial Reversed
    ProcedureReturn
  CompilerElse
    !MOV eax,[p.v_Laenge]
    !OR eax,eax                          ;erstmal Test, ob Länge = 0
    !JNZ Laenge_OK                        ;nicht 0
    ProcedureReturn                       ;Rückgabewert = 0 für Länge = 0
    
    !Laenge_OK:
    ;Test auf PCLMULQDQ
    !MOV eax,1
    !CPUID
    !MOV eax,0FFFFFFFFh                  ;Initialisierungswert für CRC32
    
    !TEST ecx,2
    !JNZ CL_OK                            ;kann losgehen! Auskommentieren für Test ohne PCLMULQDQ
    
    !LEA ecx,[CRC_Table]                 ;die CPU bringts nicht, also konventionell
    !MOV eax,[p.v_Mem]
    !MOV edx,[p.v_Laenge]
    !PUSH ebx
    !MOV ebx,ecx
    !PUSH esi
    !MOV esi,eax
    !MOV eax,0FFFFFFFFh                  ;Initialisierungswert für CRC32
    !@@:
    !MOVZX ecx,byte[esi]
    !XOR cl,al
    !SHR eax,8
    !XOR eax,dword[ebx+ecx*4]
    !INC esi
    !DEC edx                             ;Länge
    !JNZ @b
    
    !POP esi
    !POP ebx
    !NOT eax                             ;wegen Polynomial Reversed
    ProcedureReturn
    
    !CL_OK:
    !MOV eax,0FFFFFFFFh                  ;Initialisierungswert für CRC32
    !MOV edx,[p.v_Laenge]
    !AND edx,0FFFFFFC0h                  ;Länge < 40h?
    !JZ less_64                           ;ja, konventionell weiter
    
    !MOVD xmm5,eax                       ;eax = 0FFFFFFFFh  Initialisierungswert für CRC32
    !MOV ecx,[p.v_Mem]
    !MOVDQA xmm0,[ecx]
    !MOVDQA xmm1,[ecx+10h]
    !MOVDQA xmm2,[ecx+20h]
    !MOVDQA xmm3,[ecx+30h]
    !PXOR xmm0,xmm5
    
    !SUB edx,40h
    !ADD ecx,40h
    
    !loop_64:
    !PREFETCHNTA [ecx+0c0h]              ;Cache "vorfüllen"
    
    !MOVDQA xmm4,xmm0
    !MOVDQA xmm5,xmm1
    !MOVDQA xmm6,xmm2
    !MOVDQA xmm7,xmm3
    
    !PCLMULQDQ xmm0,[Lconstant_R2R1],00h
    !PCLMULQDQ xmm1,[Lconstant_R2R1],00h
    !PCLMULQDQ xmm2,[Lconstant_R2R1],00h
    !PCLMULQDQ xmm3,[Lconstant_R2R1],00h
    
    !PCLMULQDQ xmm4,[Lconstant_R2R1],11h
    !PCLMULQDQ xmm5,[Lconstant_R2R1],11h
    !PCLMULQDQ xmm6,[Lconstant_R2R1],11h
    !PCLMULQDQ xmm7,[Lconstant_R2R1],11h
    
    !PXOR xmm0,xmm4
    !PXOR xmm1,xmm5
    !PXOR xmm2,xmm6
    !PXOR xmm3,xmm7
    
    !PXOR xmm0,[ecx]
    !PXOR xmm1,[ecx+10h]
    !PXOR xmm2,[ecx+20h]
    !PXOR xmm3,[ecx+30h]
    
    !SUB edx,40h
    !ADD ecx,40h
    !CMP edx,40h
    !JGE loop_64
    
    !MOVDQA xmm6,[Lconstant_R4R3]
    !PREFETCHNTA [ecx]
    
    !MOVDQA xmm4,xmm0
    !PCLMULQDQ xmm0,xmm6,00h
    !PCLMULQDQ xmm4,xmm6,11h
    !PXOR xmm0,xmm4
    !PXOR xmm0,xmm1
    
    !MOVDQA xmm4,xmm0
    !PCLMULQDQ xmm0,xmm6,00h
    !PCLMULQDQ xmm4,xmm6,11h
    !PXOR xmm0,xmm4
    !PXOR xmm0,xmm2
    
    !MOVDQA xmm4,xmm0
    !PCLMULQDQ xmm0,xmm6,00h
    !PCLMULQDQ xmm4,xmm6,11h
    !PXOR xmm0,xmm4
    !PXOR xmm0,xmm3
    
    !PCLMULQDQ xmm6,xmm0,01h
    !PSRLDQ xmm0,08h
    !PXOR xmm0,xmm6
    
    !MOVDQA xmm1,xmm0
    
    !MOVDQA xmm6,[Lconstant_R5]
    !MOVDQA xmm2,[Lconstant_mask32]
    
    !PSRLDQ xmm1,04h
    !PAND xmm0,xmm2
    !PCLMULQDQ xmm0,xmm6,00h
    !PXOR xmm0,xmm1
    
    !MOVDQA xmm6,[Lconstant_RUpoly]
    
    !MOVDQA xmm1,xmm0
    !PAND xmm0,xmm2
    !PCLMULQDQ xmm0,xmm6,10h
    !PAND xmm0,xmm2
    !PCLMULQDQ xmm0,xmm6,00h
    !PXOR xmm0,xmm1
    
    !less_64:                              ;Rest (max.63 Bytes)
    !LEA ecx,[CRC_Table]                 ;die restlichen Bytes mit Tabelle
    !MOV eax,[p.v_Mem]
    !MOV edx,[p.v_Laenge]
    !PUSH ebx
    !MOV ebx,ecx
    !PUSH esi
    !MOV esi,eax
    
    !PEXTRD eax,xmm0,01h                 ;eax ist CRC32 (bis hierher)
    
    !ADD esi,edx
    !AND edx,3fh                         ;möglicher Rest
    !JZ NoRest                            ;kein Rest
    !SUB esi,edx
    !@@:
    !MOVZX ecx,byte[esi]
    !XOR cl,al
    !SHR eax,8
    !XOR eax,dword[ebx+ecx*4]
    !INC esi
    !DEC edx
    !JNZ @b
    
    !NoRest:
    !POP esi
    !POP ebx
    !NOT eax                             ;wegen Polynomial Reversed
    ProcedureReturn
  CompilerEndIf
  
  
  
  ;Konstanten
  !Align 16
  !Lconstant_R2R1:
  !dq 0000000154442BD4h, 00000001C6E41596h
  !Lconstant_R4R3:
  !dq 00000001751997D0h, 00000000CCAA009Eh
  !Lconstant_R5:
  !dq 0000000163CD6124h, 0000000000000000h
  !Lconstant_mask32:
  !dq 00000000FFFFFFFFh, 0000000000000000h
  !Lconstant_RUpoly:
  !dq 00000001DB710641h, 00000001F7011641h
  
  !CRC_Table:
  !dd 0
  !dd 077073096h, 0EE0E612Ch, 0990951BAh, 0076DC419h, 0706AF48Fh
  !dd 0E963A535h, 09E6495A3h, 00EDB8832h, 079DCB8A4h, 0E0D5E91Eh
  !dd 097D2D988h, 009B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
  !dd 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh, 01ADAD47Dh
  !dd 06DDDE4EBh, 0F4D4B551h, 083D385C7h, 0136C9856h, 0646BA8C0h
  !dd 0FD62F97Ah, 08A65C9ECh, 014015C4Fh, 063066CD9h, 0FA0F3D63h
  !dd 08D080DF5h, 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h
  !dd 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh, 035B5A8FAh
  !dd 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h, 032D86CE3h, 045DF5C75h
  !dd 0DCD60DCFh, 0ABD13D59h, 026D930ACh, 051DE003Ah, 0C8D75180h
  !dd 0BFD06116h, 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
  !dd 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h, 02F6F7C87h
  !dd 058684C11h, 0C1611DABh, 0B6662D3Dh, 076DC4190h, 001DB7106h
  !dd 098D220BCh, 0EFD5102Ah, 071B18589h, 006B6B51Fh, 09FBFE4A5h
  !dd 0E8B8D433h, 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h
  !dd 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h, 06B6B51F4h
  !dd 01C6C6162h, 0856530D8h, 0F262004Eh, 06C0695EDh, 01B01A57Bh
  !dd 08208F4C1h, 0F50FC457h, 065B0D9C6h, 012B7E950h, 08BBEB8EAh
  !dd 0FCB9887Ch, 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
  !dd 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h, 04ADFA541h
  !dd 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh, 04369E96Ah, 0346ED9FCh
  !dd 0AD678846h, 0DA60B8D0h, 044042D73h, 033031DE5h, 0AA0A4C5Fh
  !dd 0DD0D7CC9h, 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h
  !dd 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh, 05EDEF90Eh
  !dd 029D9C998h, 0B0D09822h, 0C7D7A8B4h, 059B33D17h, 02EB40D81h
  !dd 0B7BD5C3Bh, 0C0BA6CADh, 0EDB88320h, 09ABFB3B6h, 003B6E20Ch
  !dd 074B1D29Ah, 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
  !dd 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h, 0E40ECF0Bh
  !dd 09309FF9Dh, 00A00AE27h, 07D079EB1h, 0F00F9344h, 08708A3D2h
  !dd 01E01F268h, 06906C2FEh, 0F762575Dh, 0806567CBh, 0196C3671h
  !dd 06E6B06E7h, 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh
  !dd 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h, 0D6D6A3E8h
  !dd 0A1D1937Eh, 038D8C2C4h, 04FDFF252h, 0D1BB67F1h, 0A6BC5767h
  !dd 03FB506DDh, 048B2364Bh, 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h
  !dd 041047A60h, 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
  !dd 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h, 0CC0C7795h
  !dd 0BB0B4703h, 0220216B9h, 05505262Fh, 0C5BA3BBEh, 0B2BD0B28h
  !dd 02BB45A92h, 05CB36A04h, 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh
  !dd 05BDEAE1Dh, 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah
  !dd 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h, 095BF4A82h
  !dd 0E2B87A14h, 07BB12BAEh, 00CB61B38h, 092D28E9Bh, 0E5D5BE0Dh
  !dd 07CDCEFB7h, 00BDBDF21h, 086D3D2D4h, 0F1D4E242h, 068DDB3F8h
  !dd 01FDA836Eh, 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
  !dd 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch, 08F659EFFh
  !dd 0F862AE69h, 0616BFFD3h, 0166CCF45h, 0A00AE278h, 0D70DD2EEh
  !dd 04E048354h, 03903B3C2h, 0A7672661h, 0D06016F7h, 04969474Dh
  !dd 03E6E77DBh, 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h
  !dd 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h, 0BDBDF21Ch
  !dd 0CABAC28Ah, 053B39330h, 024B4A3A6h, 0BAD03605h, 0CDD70693h
  !dd 054DE5729h, 023D967BFh, 0B3667A2Eh, 0C4614AB8h, 05D681B02h
  !dd 02A6F2B94h, 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh
EndProcedure


;-Example
CompilerIf #PB_Compiler_IsMainFile
  UseCRC32Fingerprint()
  
  ;Test
  A$ = "The quick brown fox jumps over the lazy dog."
  LA = Len(A$)*SizeOf(character)
  Faktor = 9999999
  Buffer = AllocateMemory(LA * (Faktor + 1) + 16)
  
  If Buffer
    BufferA = Buffer
    If BufferA & $0F                     ;muss Alignment 16 sein!
      BufferA = Buffer + 16 - (BufferA & $0F)
    EndIf
    
    For i = 0 To Faktor
      PokeS(BufferA + (i * LA), A$)
    Next
    Length = LA * (Faktor + 1)
    
    Time_CL_A = ElapsedMilliseconds()
    CRC32 = CRC32_CL(BufferA, Length)              ;5FCF543F für obige Werte
    Time_CL_E = ElapsedMilliseconds() - Time_CL_A  ;24ms für i7-6700K@4.7GHz und DDR4/2400
    
    Time_pb_A = ElapsedMilliseconds()
    crc32_pb=Val("$"+Fingerprint(BufferA,Length,#PB_Cipher_CRC32))
    Time_pb_E = ElapsedMilliseconds() - Time_pb_A  
    
    CL$ = "CRC32_CL = " + Hex(CRC32 & $FFFFFFFF) + "  in " + Str(Time_CL_E) + " ms"+Chr(10)
    cl$ + "CRC32_PB = " + Hex(crc32_pb & $FFFFFFFF) + "  in " + Str(Time_pb_E) + " ms"
    
    FreeMemory(Buffer)
    MessageRequester("CRC32 ohne PB für " + Str(Length) + " Bytes", CL$)
  EndIf
CompilerEndIf
