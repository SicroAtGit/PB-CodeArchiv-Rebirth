; Description: PBKDF2 Hash for passwords
; Author: TroaX
; Date: 12-11-2015
; PB-Version: 5,40
; OS: Windows, Linux, Mac
; English-Forum: 
; French-Forum: 
; German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29268
;-----------------------------------------------------------------------------

; PB_PBKDF2 1.0
; Author: TroaX
; Crossplattform Include
; PB 5.40 LTS
; Special Thanks to NicTheQuick and GPI for the XOR-Procedure

; Begin Module
DeclareModule PB_PBKDF2
  #PWLib_NoSalt = ""
  #PWLib_NoPepper = ""
  #PWLib_WrongCipherDepth = "WDEPTH"
  #PWLib_CipherDepth_256 = 256
  #PWLib_CipherDepth_384 = 384
  #PWLib_CipherDepth_512 = 512
  
  ; Hash-Operation for a Password with fixed Pepper
  Declare.s HashPassword(pwstring.s,pepperstring.s,saltstring.s,shadepth.w,count.i)
  
  ; Hash-Operation for a Password with a Pepper from a Pepperlist (Array)
  Declare.s HashPasswordPepperlist(pwstring.s,saltstring.s,shadepth.w,count.i, Array Pepperlist.s(1))
  
  ; Fills a String-Array with one Dimension with Random Strings (Please save this List in a File or in a Database for Reuse)
  Declare   GeneratePepperlist(Array Pepperlist.s(1),stringlength.i)
  
  ; Compare a Password with static Pepper (Pleasse use the same count and depth like the HashPassword-Procedure)
  Declare.i ComparePassword(hashstring.s,pwstring.s,pepperstring.s,shadepth.w,count.i)
  
  ; Compare a Password with a Pepper from the Papperlist (Pleasse use the same count and depth like the HashPasswordPepperlist-Procedure)
  Declare.i ComparePasswordPepperlist(hashstring.s,pwstring.s,shadepth.w,count.i,Array Pepperlist.s(1))
  
  ; Generates a Random String with the given length
  Declare.s GenerateRandomString(length.i)
EndDeclareModule

Module PB_PBKDF2
  UseSHA3Fingerprint()
  
  ; Init Xor-Operation
  Procedure HexInit()
    Global Dim HexTable.a(127)
    Protected i.i
    For i='0' To '9'
      HexTable(i)=(i-'0')
    Next
    For i='a' To 'f'
      HexTable(i)=(i-'a'+10)
    Next
    For i='A' To 'F'
      HexTable(i)=(i-'A'+10)
    Next
    For i=0 To 15
      HexTable(i)=Asc(Hex(i))
    Next
  EndProcedure
  
  HexInit()
  
  ; Xor-Operation for 2 Hexadecimal-Strings
  Procedure XorHash(*retchar.character,*achar.character,*bchar.character)
    Protected value
    While *achar\c>0
      *retchar\c=HexTable((HexTable(*achar\c&$7f)) ! (HexTable(*bchar\c&$7f)))
      *achar+SizeOf(character)
      *bchar+SizeOf(character)
      *retchar+SizeOf(character)
    Wend
  EndProcedure
  
  ; Basic Hash-Procedure
  Procedure.s IterateHashing(pwstring.s,pepperstring.s,saltstring.s,shadepth.w,count.i)
    Define validdepth.i
    Define substring.s
    Define hashedstring.s
    Define prestring.s
    Select shadepth
      Case #PWLib_CipherDepth_256
        validdepth = #True
      Case #PWLib_CipherDepth_384
        validdepth = #True
      Case #PWLib_CipherDepth_512
        validdepth = #True
      Default
        validdepth = #False
    EndSelect
    If validdepth
      prestring = pepperstring + pwstring + saltstring
      Define *buffer = AllocateMemory(Len(prestring) * 6)
      bytes = PokeS(*buffer, prestring, -1, #PB_UTF8)
      hashedstring = Fingerprint(*buffer, bytes, #PB_Cipher_SHA3,shadepth)
      If count > 0
        Define x.i
        For x = 0 To count
          bytes.i = PokeS(*buffer, hashedstring, -1, #PB_UTF8)
          substring = Fingerprint(*buffer, bytes, #PB_Cipher_SHA3,shadepth)
          XorHash(@hashedstring, @hashedstring, @substring)
        Next
      EndIf
    Else
      ProcedureReturn #PWLib_WrongCipherDepth
    EndIf
    FreeMemory(*buffer)
    ProcedureReturn hashedstring
  EndProcedure
  
  ; Generate Random String without Specialchars
  Procedure.s GenerateRandomString(length.i)
    Define ReturnString.s = ""
    Dim ranchar.c(2)
    Define x.i
    For x = 1 To length
      ranchar(0) = Random(57,48)
      ranchar(1) = Random(90,65)
      ranchar(2) = Random(122,97)
      ReturnString = ReturnString + Chr(ranchar(Random(2,0)))
    Next
    ProcedureReturn ReturnString
  EndProcedure
  
  ; Compare Password and Hashstring
  Procedure.i ComparePassword(hashstring.s,pwstring.s,pepperstring.s,shadepth.w,count.i)
    Define hashpart.s = StringField(hashstring,1,".")
    Define saltpart.s = StringField(hashstring,2,".")
    Define hashedstring.s = IterateHashing(pwstring,pepperstring,saltpart,shadepth,count)
    If hashedstring = hashpart
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ; Compare Password and Hashstring with Pepperlist
  Procedure.i ComparePasswordPepperlist(hashstring.s,pwstring.s,shadepth.w,count.i,Array Pepperlist.s(1))
    Define hashpart.s = StringField(hashstring,1,".")
    Define saltpart.s = StringField(hashstring,2,".")
    Define pepperlistsize.i = ArraySize(Pepperlist())
    Define x.i
    For x = 0 To pepperlistsize
      Define hashedstring.s = IterateHashing(pwstring,Pepperlist(x),saltpart,shadepth,count)
      If hashedstring = hashpart
        ProcedureReturn #True
      EndIf
    Next
    ProcedureReturn #False
  EndProcedure
  
  ; Hash-Procedure with inserted Salt
  Procedure.s HashPassword(pwstring.s,pepperstring.s,saltstring.s,shadepth.w,count.i)
    
    If saltstring = #PWLib_NoSalt
      ProcedureReturn IterateHashing(pwstring,pepperstring,saltstring,shadepth,count)
    Else
      ProcedureReturn IterateHashing(pwstring,pepperstring,saltstring,shadepth,count) + "." + saltstring
    EndIf
  EndProcedure
  
  ; Hash-Procedure to extends the Basic-Procedure with a Papperlist
  Procedure.s HashPasswordPepperlist(pwstring.s,saltstring.s,shadepth.w,count.i, Array Pepperlist.s(1))
    If ArraySize(Pepperlist()) > 0
      Define size.i = ArraySize(Pepperlist())
      Define randomentry.i = Random(size,0)
    Else
      randomentry.i = 0
    EndIf
    If saltstring = #PWLib_NoSalt
      ProcedureReturn IterateHashing(pwstring,Pepperlist(randomentry),saltstring,shadepth,count)
    Else
      ProcedureReturn IterateHashing(pwstring,Pepperlist(randomentry),saltstring,shadepth,count) + "." + saltstring
    EndIf
  EndProcedure
  
  ; Generate a Random Pepperlist
  Procedure GeneratePepperlist(Array Pepperlist.s(1),stringlength.i)
    Define listsize.i = ArraySize(Pepperlist())
    Define x.i
    For x = 0 To listsize
      Pepperlist(x) = GenerateRandomString(stringlength)
    Next
  EndProcedure
EndModule

;- Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  OpenConsole()
  ;XIncludeFile "pwlib10.pbi"
  
  UseModule PB_PBKDF2
  
  Define password.s = "HelloSprite!"
  
  Define hash_1.s
  hash_1  = HashPassword(password,"","",#PWLib_CipherDepth_256,500)
  Define hash_2.s
  hash_2 = HashPassword(password,"","",#PWLib_CipherDepth_256,1000)
  
  PrintN("Hash with  500 Iterationen: " + hash_1)
  PrintN("Hash with 1000 Iterationen: " + hash_2)
  
  PrintN("Passwort: " + Str(ComparePassword(hash_1,password,"",#PWLib_CipherDepth_256,500)))
  PrintN("Passwort: " + Str(ComparePassword(hash_1,"Falsches Passwort","",#PWLib_CipherDepth_256,500)))
  PrintN("Passwort: " + Str(ComparePassword(hash_2,password,"",#PWLib_CipherDepth_256,1000)))
  
  Input()
  ;Hash with  500 Iterationen: EAD0C3C28BD1B25EB736590BB51ADFF15B1FB3367FBC2559A807199F92DBFBC8
  ;Hash with 1000 Iterationen: 42C60F05CA2B00797F6743311AEF76EABA5FE255DC4E18F7D2B24AE264B59AD4
  ;Passwort: 1
  ;Passwort: 0
  ;Passwort: 1
  
CompilerEndIf


; IDE Options = PureBasic 5.40 LTS (Windows - x64)
; CursorPosition = 215
; Folding = ---
; EnableUnicode
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant