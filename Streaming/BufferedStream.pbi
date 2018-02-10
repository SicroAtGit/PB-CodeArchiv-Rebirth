;   Description: Read and write bytes from stream (like BuffedInputStream in Java)
;            OS: Mac, Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=26604
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 NicTheQuick
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

CompilerIf #PB_Compiler_Thread=#False
  CompilerError "Threadsafe needed!"
CompilerEndIf

DeclareModule BufferedStream
  EnableExplicit
  
  DebugLevel 0
  
  Prototype.i BufferedStream_Prototype_free(*this)
  
  Interface BufferedStream
    free.i()
    
    close.i()                  ;Close the stream.
    isClosed.i()               ;Tell whether the stream was closed or not.
    
    writeBlock(*memory, size.i)      ;Write bytes into the stream.
    writeA(ascii.i)                  ;Write a single Ascii character.
    writeC(character.i)              ;Write a single Character.
    
    readBlock.i(*memory, size.i)   ;Read bytes into a buffer.
    readA.a()
    readB.b()
    readC.c()
    readD.d()
    readF.f()
    readI.i()
    readL.l()
    readQ.q()
    readU.u()
    readW.w()
    CompilerIf #PB_Compiler_Thread
      readS.s()
      readLine.s(bufferSize.i = 1024)   ;Read a line of text.
    CompilerEndIf
    
    bytesAvailable.i()               ;Tell how many bytes are available in the buffer.
    skip.i(bytes.i)                  ;Skip bytes.
  EndInterface
  
  Declare.i newBufferedStream(bufferSize.i = 1024)
  
EndDeclareModule

Module BufferedStream
  
  Structure BufferedStreamS
    *vTable
    beforeFree.BufferedStream_Prototype_free
    hSemaphoreNotEmpty.i
    hSemaphoreNotFull.i
    readerWaits.i
    writerWaits.i
    hMutex.i
    *buffer
    bufferSize.i
    writePos.i
    readPos.i
    bytesAvailable.i
    closed.i
    skip.i
  EndStructure
  
  Procedure newBufferedStream(bufferSize.i = 1024)
    Protected *this.BufferedStreamS = AllocateMemory(SizeOf(BufferedStreamS))
    
    If (bufferSize < 1)
      bufferSize = 1
    EndIf
    
    If (Not *this)
      ProcedureReturn #False
    EndIf
    
    With *this
      \vTable = ?vTable_BufferedStream
      \bufferSize = bufferSize
      \buffer = AllocateMemory(bufferSize, #PB_Memory_NoClear)
      If (Not \buffer)
        FreeMemory(*this)
        ProcedureReturn #False
      EndIf
      
      \hSemaphoreNotEmpty = CreateSemaphore(0)
      \hSemaphoreNotFull = CreateSemaphore(1)
      \readerWaits = #True
      \writerWaits = #False
      \hMutex = CreateMutex()
      \readPos = 0
      \writePos = 0
      \closed = #False
      \skip = 0
      \bytesAvailable = 0
      \beforeFree = 0
    EndWith
    
    ProcedureReturn *this
  EndProcedure
  
  Procedure.i free(*this.BufferedStreamS)
    Protected *thisI.BufferedStream = *this
    With *this
      If (\beforeFree)
        If (Not \beforeFree(*this))
          ProcedureReturn #False
        EndIf
      EndIf
      *thisI\close()
      LockMutex(\hMutex)
      FreeMemory(\buffer)
      FreeSemaphore(\hSemaphoreNotEmpty)
      FreeSemaphore(\hSemaphoreNotFull)
      UnlockMutex(\hMutex)
      FreeMutex(\hMutex)
    EndWith
    FreeMemory(*this)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure close(*this.BufferedStreamS)
    With *this
      LockMutex(\hMutex)
      \closed = #True
      If (\readerWaits)
        SignalSemaphore(\hSemaphoreNotEmpty)
      EndIf
      UnlockMutex(\hMutex)
    EndWith
  EndProcedure
  
  Procedure.i isClosed(*this.BufferedStreamS)
    Protected isClosed.i
    With *this
      LockMutex(\hMutex)
      isClosed = \closed
      UnlockMutex(\hMutex)
    EndWith
    
    ProcedureReturn isClosed
  EndProcedure
  
  Procedure.i writeBlock(*this.BufferedStreamS, *memory.Byte, size.i) ;returns the bytes written to the stream
    Protected bytesFree.i, *write.Byte, initSize.i = size
    
    With *this
      LockMutex(\hMutex)
      
      If (\closed)
        UnlockMutex(\hMutex)
        ProcedureReturn 0
      EndIf
      
      If (\skip > 0)
        If (size > \skip)
          *memory + (size - \skip)
          size - \skip
        Else
          \skip - size
          UnlockMutex(\hMutex)
          ProcedureReturn size
        EndIf
      EndIf
      
      *write = \buffer + \writePos
      
      While size > 0
        While (\bytesAvailable = \bufferSize)
          \writerWaits = #True
          UnlockMutex(\hMutex)
          WaitSemaphore(\hSemaphoreNotFull)
          LockMutex(\hMutex)
          If (\closed)
            \writerWaits = #False
            UnlockMutex(\hMutex)
            ProcedureReturn initSize - size
          EndIf
        Wend
        \writerWaits = #False
        
        bytesFree = \bufferSize - \bytesAvailable
        While bytesFree > 0 And size > 0
          *write\b = *memory\b
          *write + 1
          *memory + 1
          bytesFree - 1
          size - 1
          \writePos + 1
          If (\writePos = \bufferSize)
            \writePos = 0
            *write = \buffer
          EndIf
        Wend
        
        \bytesAvailable  = \bufferSize - bytesFree
        
        If (\readerWaits)
          SignalSemaphore(\hSemaphoreNotEmpty)
        EndIf
      Wend
      
      UnlockMutex(\hMutex)
    EndWith
    
    ProcedureReturn size
  EndProcedure
  
  Procedure.i writeA(*this.BufferedStreamS, ascii.i)
    With *this
      LockMutex(\hMutex)
      
      If (\closed)
        UnlockMutex(\hMutex)
        ProcedureReturn #False
      EndIf
      
      If (\skip > 0)
        \skip - 1
        UnlockMutex(\hMutex)
        ProcedureReturn #True
      EndIf
      
      While (\bytesAvailable = \bufferSize)
        \writerWaits = #True
        UnlockMutex(\hMutex)
        WaitSemaphore(\hSemaphoreNotFull)
        LockMutex(\hMutex)   
      Wend
      \writerWaits = #False
      
      PokeA(\buffer + \writePos, ascii)
      \writePos = (\writePos + 1) % \bufferSize
      \bytesAvailable + 1
      
      If (\readerWaits)
        SignalSemaphore(\hSemaphoreNotEmpty)
      EndIf
      
      UnlockMutex(\hMutex)
    EndWith
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i writeC(*this.BufferedStream, character.i)
    CompilerIf #PB_Compiler_Unicode
      ProcedureReturn *this\writeBlock(@character, SizeOf(Character))
    CompilerElse
      ProcedureReturn *this\writeA(character)
    CompilerEndIf
  EndProcedure
  
  Procedure.i readBlock(*this.BufferedStreamS, *memory.Byte, size.i) ;returns the bytes read from the stream.
    Protected *read.Byte, initSize.i = size
    
    Debug "readBlock: before lock", 5
    
    With *this
      LockMutex(\hMutex)
      Debug "readBlock: lock", 5
      
      *read = \buffer + \readPos
      While size > 0
        While (\bytesAvailable = 0)
          If (\closed)
            UnlockMutex(\hMutex)
            ProcedureReturn 0
          EndIf
          \readerWaits = #True
          UnlockMutex(\hMutex)
          WaitSemaphore(\hSemaphoreNotEmpty)
          LockMutex(\hMutex)
        Wend
        \readerWaits = #False
        
        While \bytesAvailable > 0 And size > 0
          *memory\b = *read\b
          *memory + 1
          *read + 1
          \bytesAvailable - 1
          size - 1
          \readPos + 1
          If (\readPos = \bufferSize)
            \readPos = 0
            *read = \buffer
          EndIf
        Wend
        
        If (\writerWaits)
          SignalSemaphore(\hSemaphoreNotFull)
        EndIf
      Wend
      
      UnlockMutex(\hMutex)
      
    EndWith
    
    ProcedureReturn initSize - size
  EndProcedure
  
  Procedure.a readA(*this.BufferedStreamS)
    Protected ascii.a
    With *this
      LockMutex(\hMutex)
      While (\bytesAvailable = 0)
        If (\closed)
          ;TODO
          UnlockMutex(\hMutex)
          ProcedureReturn #False
        EndIf
        \readerWaits = #True
        UnlockMutex(\hMutex)
        WaitSemaphore(\hSemaphoreNotEmpty)
        LockMutex(\hMutex)
      Wend
      \readerWaits = #False
      
      ascii = PeekA(\buffer + \readPos)
      \readPos  = (\readPos + 1) % \bufferSize
      \bytesAvailable - 1
      
      If (\writerWaits)
        SignalSemaphore(\hSemaphoreNotFull)
      EndIf
      UnlockMutex(\hMutex)
    EndWith
    
    ProcedureReturn ascii
  EndProcedure
  
  Procedure.b readB(*this.BufferedStream)
    ProcedureReturn *this\readA()
  EndProcedure
  
  Procedure.c readC(*this.BufferedStream)
    CompilerIf #PB_Compiler_Unicode
      Protected c.c
      *this\readBlock(@c, SizeOf(Character))
      ProcedureReturn c
    CompilerElse
      ProcedureReturn *this\readA()
    CompilerEndIf
  EndProcedure
  
  Macro readType(SMALL, TYPE)
    Procedure.SMALL Read#SMALL(*this.BufferedStream)
      Protected value.SMALL
      *this\readBlock(@value, SizeOf(TYPE))
      ProcedureReturn value
    EndProcedure
  EndMacro
  
  readType(d, Double)
  readType(f, Float)
  readType(i, Integer)
  readType(l, Long)
  readType(q, Quad)
  readType(u, Unicode)
  readType(w, Word)
  
  CompilerIf #PB_Compiler_Thread
    Procedure.s readS(*this.BufferedStream, bufferSize.i = 1024)
      Protected result.s, char.c, *r.Character, rLength.i
      
      If (bufferSize < 1)
        bufferSize = 1
      EndIf
      
      With *this
        result = Space(bufferSize)
        *r = @result
        rLength = 0
        Repeat
          If (\readBlock(@char, SizeOf(Character)) <> SizeOf(Character))
            Break
          EndIf
          
          If (char = 0)      ;String wurde mit 0 terminiert
            Break
          EndIf
          
          *r\c = char
          *r + SizeOf(Character)
          rLength + 1
          If (rLength % bufferSize = 0)
            result + Space(bufferSize)
            *r = @result + rLength * SizeOf(Character)
          EndIf
        ForEver
        *r\c = 0
      EndWith
      
      ProcedureReturn result
    EndProcedure
    
    Procedure.s readLine(*this.BufferedStream, bufferSize.i = 1024)
      Protected result.s, char.c, *r.Character, rLength.i, last13.c = #False
      
      Debug "readLine", 6
      
      If (bufferSize < 1)
        bufferSize = 1
      EndIf
      
      Debug "readLine2", 6
      
      With *this
        Debug "readLine3", 6
        result = Space(bufferSize)
        Debug "readLine4", 6
        *r = @result
        rLength = 0
        Debug "readLine5", 6
        Repeat
          Debug "before readBlock", 5
          If (\readBlock(@char, SizeOf(Character)) <> SizeOf(Character))
            Break
          EndIf
          Debug "after readBlock", 5
          
          Select char
            Case 0      ;String wurde mit 0 terminiert
              Break
            Case 10      ;LF wurde gelesen
              If (last13)
                *r - SizeOf(Character)
              EndIf
              Break
            Case 13    ;CR wurde gelesen, aber vielleicht kommt noch ein LF
              last13 = #True
            Default
              last13 = #False
          EndSelect
          
          *r\c = char
          *r + SizeOf(Character)
          rLength + 1
          If (rLength % bufferSize = 0)
            result + Space(bufferSize)
            *r = @result + rLength * SizeOf(Character)
          EndIf
        ForEver
        *r\c = 0
      EndWith
      
      ProcedureReturn result
    EndProcedure
  CompilerEndIf
  
  Procedure.i bytesAvailable(*this.BufferedStreamS)
    Protected bytes.i = 0
    With *this
      LockMutex(\hMutex)
      bytes = \bytesAvailable
      UnlockMutex(\hMutex)
    EndWith
    
    ProcedureReturn bytes
  EndProcedure
  
  Procedure.i skip(*this.BufferedStreamS, bytes.i)
    If (bytes <= 0)
      ProcedureReturn #False
    EndIf
    With *this
      LockMutex(\hMutex)
      \skip + bytes
      If (\skip > \bytesAvailable)
        \skip - \bytesAvailable
        \readPos = \writePos
        \bytesAvailable = 0
      Else
        \bytesAvailable - \skip
        \skip = 0
        \readPos = (\readPos + \skip) % \bufferSize
      EndIf
      If (\writerWaits)
        SignalSemaphore(\hSemaphoreNotFull)
      EndIf
      UnlockMutex(\hMutex)
    EndWith
  EndProcedure
  
  DataSection
    vTable_BufferedStream:
    Data.i @free(),
           @close(), @isClosed(),
           @writeBlock(), @writeA(), @writeC(),
           @readBlock(), @readA(), @readB(), @readC(),
           @readD(), @readF(), @readI(), @readL(),
           @readQ(), @readU(), @readW()
    CompilerIf #PB_Compiler_Thread
      Data.i @readS(), @readLine()
    CompilerEndIf
    Data.i @bytesAvailable(), @skip()
  EndDataSection
EndModule


;-Example
;=============================================== E X A M P L E ===============================================
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseModule BufferedStream
  
  Global a.i = #False
  
  ;Schreibt zufällige Buchstaben in den Stream und manchmal einen Zeilenumbruch im Windows-Stil
  Procedure FillThread(bs.BufferedStream)
    Protected i.i, c.c
    
    ;Schreibe die ersten 10 Zeichen, die übersprungen werden sollen
    For i = 0 To 9
      bs\writeC('0' + i)
    Next
    
    ;Schreibe ab jetzt Zufallsbuchstaben
    For i = 1 To 100
      c = Asc(Mid("abcdefghijklmnopqrstuvwxyz ", Random(26) + 1, 1))
      If (Random(10) = 0)
        bs\WriteC(13)
        Debug "FillThread: write CR"
        bs\WriteC(10)
        Debug "FillThread: write LF"
      Else
        bs\WriteC(c)
        Debug "FillThread: write='" + Chr(c) + "' (" + c + ")"
      EndIf
      ;Delay aktivieren, wenn man die Ausgaben von ReadLines nicht erst am Schluss sehen will
      ;Delay(1)
    Next
    bs\close()
    Debug "FillThread: STREAM CLOSED"
    a = #True
  EndProcedure
  
  ;Lies die Zeilen aus bis der Stream geschlossen wird und keine Bytes mehr da sind.
  Procedure ReadLines(bs.BufferedStream)
    Protected line.s
    
    ;Überspringe die ersten 10 Zeichen beim Auslesen
    bs\skip(10 * SizeOf(Character))
    
    While (Not bs\isClosed()) Or (bs\bytesAvailable() > 0)
      ;Lies eine Zeile aus
      line = bs\readLine()
      Debug "ReadLines: '" + line + "'"
    Wend
    
    Debug "ReadLines: END OF STREAM"
  EndProcedure
  
  ;Stream mit Standard-Puffergröße von 1024 Bytes erstellen
  Define bs.BufferedStream = newBufferedStream()
  Define.i t1, t2
  
  ;Threads erstellen, die in den Stream schreiben bzw. aus ihm lesen
  t1 = CreateThread(@FillThread(), bs)
  t2 = CreateThread(@ReadLines(), bs)
  
  WaitThread(t1)
  Debug "Thread 1 ended."
  WaitThread(t2)
  Debug "Thread 2 ended."
  
CompilerEndIf
