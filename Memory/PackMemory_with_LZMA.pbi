;   Description: Pack and unpack into memory with custom LZMA.
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28131
; ----------------------------------------------------------------------------- 

; MIT License
; 
; Copyright (c) 2014 Bisonte
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

;GPI: 
; - fix CRC32Fingerprint For 5.4
; - changed global to threaded (LastErrorID, PBM_Init)

DeclareModule PBM
  
  ;:--------------------------------------------------------------------------
  ;:- Modul   : PB PackMemory (PBM)
  ;:- Author  : George Bisonte
  ;:- Date    : 18. June 2014
  ;:- PB      : 5.22 LTS
  ;:- OS      : Windows/Linux/MacOS
  ;:-           Use it at your own risk
  ;:-------------------------------------------------------------------------- 
  
  Declare   InitPBM()
  Declare   PackMemory(*Memory)
  Declare   UnPackMemory(*Memory)
  Declare.s GetLastErrorMSG()
  
EndDeclareModule
Module        PBM
  
  UseCRC32Fingerprint()
  Macro CRC32Fingerprint(a,b)
    Val("$"+Fingerprint(a,b, #PB_Cipher_CRC32))
  EndMacro
  
  
  ;:--------------------------------------------------------------------------
  ;:- Modul   : PB PackMemory (PBM)
  ;:- Author  : George Bisonte
  ;:- Date    : 18. June 2014
  ;:- PB      : 5.22 LTS
  ;:- OS      : Windows/Linux/MacOS
  ;:-           Use it at your own risk
  ;:--------------------------------------------------------------------------
  
  EnableExplicit
  
  #PBM_PackMagic = 27197109
  #PBM_MaxLong   = ((1024*1024*1024)*2)-1
  
  Structure pbm_pack_header
    Magic.l                 ; Kennung ob es ein mit diesem Modul gepackter Speicher ist
    UnCompressedSize.l      ; Die Originalgroesse des Speicher. (Auf 2GB limitiert wegen ZIP)
    CRC32.l                 ; Die CRC32 Checksumme des Originalspeichers
  EndStructure
  
  Threaded LastErrorID
  Threaded PBM_Init = #False
  
  Procedure   InitPBM()
    
    If PBM_Init = #False
      LastErrorID  = 0
      UseLZMAPacker()
      PBM_Init = #True
    EndIf
    
    ProcedureReturn PBM_Init
    
  EndProcedure
  
  Procedure   PackMemory(*Memory)
    
    Protected *Header.pbm_pack_header
    Protected *Buffer, *Output
    Protected CompressedSize.l
    
    If Not PBM_Init : LastErrorID = 100 : ProcedureReturn #Null : EndIf
    
    If Not *Memory ; Kein gültiger Speicher
      LastErrorID = 1
      ProcedureReturn #Null
    EndIf
    
    If MemorySize(*Memory) => #PBM_MaxLong ; Der übergebene Speicher ist groesser als 2GB
      LastErrorID = 7
      ProcedureReturn #Null
    EndIf
    
    *Header = AllocateMemory(SizeOf(pbm_pack_header))
    If Not *Header ; Der Header konnte nicht reserviert werden
      LastErrorID = 2
      ProcedureReturn #Null
    EndIf
    
    *Header\Magic             = #PBM_PackMagic
    *Header\UnCompressedSize  = MemorySize(*Memory)
    *Header\CRC32             = CRC32Fingerprint(*Memory, MemorySize(*Memory))
    
    *Buffer = AllocateMemory(MemorySize(*Memory))
    If Not *Buffer ; Zwischenpuffer konnte nicht reserviert werden
      LastErrorID = 6
      FreeMemory(*Header)
      ProcedureReturn #Null
    EndIf
    
    CompressedSize = CompressMemory(*Memory, MemorySize(*Memory), *Buffer, MemorySize(*Buffer), #PB_PackerPlugin_Lzma)
    
    If CompressedSize = 0
      CompressedSize = *Header\UnCompressedSize
      CopyMemory(*Memory, *Buffer, *Header\UnCompressedSize)
    EndIf
    If CompressedSize > 0
      *Output = AllocateMemory(CompressedSize + SizeOf(pbm_pack_header))
      If Not *Output ; Ausgabespeicher konnte nicht reserviert werden
        LastErrorID = 4
        FreeMemory(*Buffer)
        FreeMemory(*Header)
        ProcedureReturn #Null
      EndIf
      CopyMemory(*Header, *Output, SizeOf(pbm_pack_header))
      CopyMemory(*Buffer, *Output + SizeOf(pbm_pack_header), CompressedSize)
      FreeMemory(*Buffer)
      FreeMemory(*Header)
      FreeMemory(*Memory)
      LastErrorID = 0
      ProcedureReturn *Output
    EndIf
    
    If *Header : FreeMemory(*Header) : EndIf
    If *Output : FreeMemory(*Output) : EndIf
    If *Buffer : FreeMemory(*Buffer) : EndIf
    
    LastErrorID = -1
    
    ProcedureReturn #Null ; Letzte Ausfahrt
    
  EndProcedure
  Procedure   UnPackMemory(*Memory)
    
    Protected *Header.pbm_pack_header
    Protected *Output
    Protected RealSize.l
    Protected CRC32.l
    
    If Not PBM_Init : LastErrorID = 100 : ProcedureReturn #Null : EndIf
    
    If Not *Memory ; Kein gültiger Speicher
      LastErrorID = 1
      ProcedureReturn #Null
    EndIf
    
    *Header = AllocateMemory(SizeOf(pbm_pack_header))
    If Not *Header ; Der Header konnte nicht reserviert werden
      LastErrorID = 2
      ProcedureReturn #Null
    EndIf
    
    CopyMemory(*Memory, *Header, SizeOf(pbm_pack_header))
    
    If *Header\Magic <> #PBM_PackMagic ; Speicher wurde nicht mit PBM gepackt
      LastErrorID = 3
      FreeMemory(*Header)
      ProcedureReturn #Null
    EndIf
    
    If *Header\UnCompressedSize > 0
      *Output = AllocateMemory(*Header\UnCompressedSize)
      If Not *Output ; Ausgabespeicher konnte nicht reserviert werden
        LastErrorID = 4
        FreeMemory(*Header)
        ProcedureReturn #Null
      EndIf
      If MemorySize(*Memory) - SizeOf(pbm_pack_header) = *Header\UnCompressedSize
        RealSize = *Header\UnCompressedSize
        CopyMemory(*Memory + SizeOf(pbm_pack_header), *Output, *Header\UnCompressedSize)
      Else
        RealSize = UncompressMemory(*Memory + SizeOf(pbm_pack_header), MemorySize(*Memory) - SizeOf(pbm_pack_header), *Output, *Header\UnCompressedSize, #PB_PackerPlugin_Lzma)
      EndIf
      CRC32=CRC32Fingerprint(*Output, *Header\UnCompressedSize)
      If RealSize <> *Header\UnCompressedSize Or CRC32 <> *Header\CRC32
        ; Fehler beim Entpacken. Speicher evt. nicht mehr ok.
        LastErrorID = 5
        FreeMemory(*Header)
        FreeMemory(*Output)
        ProcedureReturn #Null
      EndIf
      FreeMemory(*Header)
      FreeMemory(*Memory)
      LastErrorID = 0
      ProcedureReturn *Output
    EndIf
    
    If *Output : FreeMemory(*Output) : EndIf
    If *Header : FreeMemory(*Header) : EndIf
    
    LastErrorID = -1
    
    ProcedureReturn #Null
    
  EndProcedure
  Procedure.s GetLastErrorMSG()
    
    Protected Result.s = ""
    Select LastErrorID
      Case 0    : Result = "Ok."
      Case 1    : Result = "*Memory nicht initialisiert."
      Case 2    : Result = "Header konnte nicht initialisiert werden." 
      Case 3    : Result = "*Memory ist nicht mit PBM gepackt worden."
      Case 4    : Result = "*Ausgabespeicher konnte nicht initalisiert werden."
      Case 5    : Result = "Speicher nicht korrekt (CRC32 ERROR)."
      Case 6    : Result = "Zwischenspeicher konnte nicht initialisiert werden."
      Case 7    : Result = "Zu packender Speicher >2GB"
      Case 100  : Result = "InitPBM() muss ausgeführt worden sein."
      Default
        Result = "unkown"
    EndSelect
    
    ProcedureReturn Result
    
  EndProcedure
  Procedure   GetLastErrorID()
    ProcedureReturn LastErrorID 
  EndProcedure
  
EndModule

;-Example

CompilerIf #PB_Compiler_IsMainFile
  
  ; Die Drei Speicher
  Define *Original, *Gepackt, *Entpackt
  ; Und der Rest
  Define Event, pSize
  
  ; kleine Prozedur um ein File in den Speicher zu laden
  Procedure ReadToMemory(File.s)
    
    Protected *Memory = #Null
    Protected fHnd
    
    fHnd = ReadFile(#PB_Any, File)
    If fHnd
      If Lof(fHnd) > 0
        *Memory = AllocateMemory(Lof(fHnd))
        If *Memory
          ReadData(fHnd, *Memory, Lof(fHnd))
        EndIf 
        CloseFile(fHnd)
        ProcedureReturn *Memory
      EndIf
    EndIf
    
    ProcedureReturn *Memory
    
  EndProcedure
  
  PBM::InitPBM() ; Initialisierung (wegen UseLZMAPacker)
  
  ; Wir holen uns ein Bild aus dem Netz
  
    
  ; Bild in den Speicher holen
  *Original = ReadToMemory(#PB_Compiler_Home+"Examples\Sources\Data\PureBasicLogo.bmp")
  
  If *Original
    *Gepackt = PBM::PackMemory(*Original) ; Einpacken
    Debug PBM::GetLastErrorMSG()          ; Letzte Nachricht holen
    If *Gepackt
      pSize = MemorySize(*Gepackt) ; Die gepackte Groesse
      
      *Entpackt = PBM::UnPackMemory(*Gepackt)
      Debug PBM::GetLastErrorMSG() ; Letzte Nachricht holen
      If *Entpackt
        CatchImage(1, *Entpackt)
      EndIf
    EndIf
  EndIf
  
  If Not IsImage(1)
    End ; Irgendetwas stimmt nicht
  EndIf
  
  ; *Original und *Gepackt sind nicht mehr gültig !!! Da der Speicher intern freigegeben wurde !!!
  
  ; Den Speicher vom Bild brauchen wir nicht mehr
  FreeMemory(*Entpackt)
  
  ; Nun das Fenster um das Ergebnis zu zeigen
  
  OpenWindow(0, 0, 0, 640, 480, "TestWin", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  
  TextGadget(0, 10, 10, 200, 20, "Original : " + Str(FileSize(GetTemporaryDirectory() + "Bild.bmp")))
  TextGadget(1, 10, 40, 200, 20, "Gepackt  : " + Str(pSize))
  
  CanvasGadget(2, 10, 70, ImageWidth(1)/4, ImageHeight(1)/4)
  StartDrawing(CanvasOutput(2))
  DrawImage(ImageID(1), 0, 0, ImageWidth(1)/4, ImageHeight(1)/4)
  StopDrawing()
  
  Repeat
    Event = WaitWindowEvent()
    
  Until Event = #PB_Event_CloseWindow
  
CompilerEndIf
