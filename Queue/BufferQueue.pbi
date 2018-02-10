;   Description: Threadsafe FIFO-BufferQueue
;            OS: Mac, Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27824
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 NicTheQuick
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
CompilerIf #PB_Compiler_Processor<>#PB_Processor_x64
  CompilerError "X64 only!"
CompilerEndIf

XIncludeFile "../Thread/Monitor.pbi"

DeclareModule BufferQueue
  EnableExplicit
  
  DebugLevel 0
  
  CompilerIf Not #PB_Compiler_Thread
    CompilerError "Please activate the thread safe option!"
  CompilerEndIf
  
  #STRING_BUFFER_SIZE = 64
  
  Interface BufferQueue
    free.i()
    
    popAscii.a()
    popByte.b()
    popUnicode.u()
    popWord.w()
    popCharacter.c()
    popLong.l()
    popFloat.f()
    popDouble.d()
    popQuad.q()
    popInteger.i()
    popString.s(format.i = -1)
    
    popMemory.i(*buffer, length.i)
    
    pushAscii(a.a)
    pushByte(b.b)
    pushUnicode(u.u)
    pushWord(w.w)
    pushCharacter(c.c)
    pushLong(l.l)
    pushFloat(f.f)
    pushDouble(d.d)
    pushQuad(q.q)
    pushInteger(i.i)
    pushString(s.s, format.i = -1)
    
    pushMemory(*buffer, length.i)
  EndInterface
  
  Declare.i newBufferQueue(size.i = 4096)
EndDeclareModule

Module BufferQueue
  UseModule Monitor
  
  Structure BufferBlockS
    ;Pointer zum nächsten Bufferblock
    *next.BufferBlockS
    
    ;Pointer zum Buffer
    *buffer
    
    ;Größe des Buffers
    size.i
    
    ;Tatsächlich genutzter Buffer
    iWrite.i
    
    ;Position im ersten Block, von der als nächstes gelesen werden kann.
    iRead.i
    
    ;Lock um iWrite und iRead zu schützen
    *mutex.Mutex
    
    ;Monitor, wenn neue Daten anstehen
    *newDataCond.ConditionVariable
    
  EndStructure
  
  Structure BufferQueueS
    *vTable
    ;Lock für neue Blocks oder Löschen von Blocks
    *blockLock.Mutex
    
    ;Monitor, wenn ein neuer Block erstellt wird
    *newBlockCond.ConditionVariable
    
    ;Standardgröße für einen neuen Block
    defaultSize.i
    
    ;Pointer zum ersten Block (Leseblock)
    *first.BufferBlockS
    
    ;Pointer zum letzten Block (Schreibblock)
    *last.BufferBlockS
    
    *readLock.Mutex
  EndStructure
  
  ;{ BufferBlock
  Procedure.i BB_new(size.i)
    Protected *attr.BufferBlockS = AllocateMemory(SizeOf(BufferBlockS))
    If (Not *attr)
      ProcedureReturn #False
    EndIf
    
    With *attr
      \buffer = AllocateMemory(size)
      If (Not \buffer) : Goto end1 : EndIf
      
      \size = size
      \iWrite = 0
      \iRead = 0
      
      \mutex = newMutex()
      If (Not \mutex) : Goto end2 : EndIf
      
      \newDataCond = \mutex\newConditionVariable()
      If (Not \newDataCond) : Goto end3 : EndIf
      
      ProcedureReturn *attr
      
      end3:
      \mutex\free()
      
      end2:
      FreeMemory(\buffer)
      
      end1:
      FreeMemory(*attr)
      
      ProcedureReturn #False
    EndWith
  EndProcedure
  
  Procedure BB_free(*attr.BufferBlockS)
    With *attr
      \newDataCond\free()
      \mutex\free()
      FreeMemory(*attr)
    EndWith
  EndProcedure
  ;}
  
  ;{ BufferQueue
  Procedure.i newBufferQueue(defaultSize.i = 4096)
    If (defaultSize < 8)
      defaultSize = 8
    EndIf   
    Protected *attr.BufferQueueS = AllocateMemory(SizeOf(BufferBlockS))
    If (Not *attr)
      ProcedureReturn #False
    EndIf
    
    With *attr
      \vTable = ?vTable_BufferQueue
      \defaultSize = defaultSize
      \first = 0
      \last = 0
      ;\iWrite = 0
      ;\iRead = 0
      ;\availableBytes = 0
      
      \blockLock = newMutex()
      If (Not \blockLock) : Goto end1 : EndIf
      
      \newBlockCond = \blockLock\newConditionVariable()
      If (Not \newBlockCond) : Goto end2 : EndIf
      
      \readLock = newMutex()
      If (Not \readLock) : Goto end3 : EndIf
      
      ProcedureReturn *attr
      
      end3:
      \newBlockCond\free()
      
      end2:
      \blockLock\free()
      
      end1:
      FreeMemory(*attr)
      
      ProcedureReturn #False
    EndWith
  EndProcedure
  
  Procedure free(*attr.BufferQueueS)
    With *attr
      ;Iterate over blocks and free them
      Protected *bb.BufferBlockS = \first
      While *bb
        BB_free(*bb)
        *bb = *bb\next
      Wend
      
      \readLock\free()
      \newBlockCond\free()
      \blockLock\free()
    EndWith
  EndProcedure
  
  Procedure.i add(*attr.BufferQueueS, size.i = 0)
    With *attr
      If (size <= 0)
        size = \defaultSize
      EndIf
      If (size < 8)
        size = 8
      EndIf
      \blockLock\acquire()
      Protected *bb.BufferBlockS = BB_new(size)
      If (Not *bb)
        \blockLock\release()
        ProcedureReturn #False
      EndIf
      If (\last)   ;Gib dem aktuell noch letzten Block den Pointer vom neuen
        \last\next = *bb
      Else   ;Wenn noch gar nichts da war, dann setze den neuen Block als ersten
        \first = *bb
      EndIf
      ;Setze den neuen auf jeden Fall als letzten Block
      \last = *bb
      \newBlockCond\signal()
      \blockLock\release()
    EndWith
    
    ProcedureReturn *bb
  EndProcedure
  
  Macro popType(SMALL, TYPE)
    Procedure.SMALL   pop#TYPE(*this.BufferQueue)
      Protected value.SMALL
      *this\popMemory(@value, SizeOf(TYPE))
      ProcedureReturn value
    EndProcedure
  EndMacro
  
  popType(a, Ascii)
  popType(b, Byte)
  popType(u, Unicode)
  popType(w, Word)
  popType(c, Character)
  popType(l, Long)
  popType(f, Float)
  popType(d, Double)
  popType(q, Quad)
  popType(i, Integer)
  
  Procedure.i popMemory(*attr.BufferQueueS, *buffer, length.i)
    With *attr
      \readLock\acquire()
      Debug "    pop readLock acquired", 5
      
      \blockLock\acquire()
      While (Not \first)
        Debug "    pop wait 1", 5
        \newBlockCond\wait()
        Debug "    pop wait 2", 5
      Wend
      
      Protected *bb.BufferBlockS = \first
      
      *bb\mutex\acquire()
      Debug "    pop block mutex acquired", 5
      \blockLock\release()
      Debug "    pop blockLock released", 5
      
      Debug "    pop state: iWrite=" + *bb\iWrite + " iRead=" + *bb\iRead + " length=" + length, 5
      Protected pos.i = 0
      While pos < length
        Protected max.i = *bb\iWrite - *bb\iRead
        If (length - pos < max) : max = length - pos : EndIf
        
        If (max = 0)
          ;Es existiert noch kein Folgeblock, also warte bis neue Daten kommen
          If (Not *bb\next)
            Debug "    pop waiting for new data 1", 5
            *bb\newDataCond\wait()
            Debug "    pop waiting for new data arrived", 5
          Else
            Debug "    pop change to next block", 5
            Protected *previous.BufferBlockS = *bb
            *bb = *bb\next
            *bb\mutex\acquire()
            Debug "    pop next block mutex acquired", 5
            \first = *bb
            *previous\mutex\release()
            Debug "    pop old block mtex released", 5
            BB_free(*previous)
          EndIf
        Else
          ;Kopiere, was geht
          Debug "    pop copy what is possible", 5
          CopyMemory(*bb\buffer + *bb\iRead, *buffer + pos, max)
          *bb\iRead + max
          pos + max
        EndIf
      Wend
      
      Debug "    pop block mutex released", 5
      *bb\mutex\release()
      
      Debug "    pop readLock realeased", 5
      \readLock\release()
      
      ProcedureReturn length
    EndWith
  EndProcedure
  
  Procedure.s popString(*attr.BufferQueueS, format.i = -1)
    Protected s.s = Space(#STRING_BUFFER_SIZE)
    Protected *c.Character = @s, diff.i, i.i
    
    With *attr
      \readLock\acquire()
      
      If (format = -1)
        CompilerIf #PB_Compiler_Unicode
          format = #PB_Unicode
        CompilerElse
          format = #PB_Ascii
        CompilerEndIf
      EndIf
      
      If format = #PB_Unicode
        Repeat
          *c\c = popUnicode(*attr)
          If (*c\c = 0) : Break : EndIf
          *c + SizeOf(Character)
          i + 1
          If (i % #STRING_BUFFER_SIZE = 0)
            diff = *c - @s
            s + Space(#STRING_BUFFER_SIZE)
            *c = @s + diff
          EndIf
        ForEver
      ElseIf format = #PB_Ascii
        Repeat
          *c\c = popAscii(*attr)
          If (*c\c = 0) : Break : EndIf
          *c + SizeOf(Character)
          i + 1
          If (i % #STRING_BUFFER_SIZE = 0)
            diff = *c - @s
            s + Space(#STRING_BUFFER_SIZE)
            *c = @s + diff
          EndIf
        ForEver
      Else
      EndIf
      
      \readLock\release()
      
      ProcedureReturn s
    EndWith
  EndProcedure
  
  Macro pushType(SMALL, TYPE)
    Procedure   push#TYPE(*this.BufferQueue, SMALL.SMALL)
      ProcedureReturn *this\pushMemory(@SMALL, SizeOf(TYPE))
    EndProcedure
  EndMacro
  
  pushType(a, Ascii)
  pushType(b, Byte)
  pushType(u, Unicode)
  pushType(w, Word)
  pushType(c, Character)
  pushType(l, Long)
  pushType(f, Float)
  pushType(d, Double)
  pushType(q, Quad)
  pushType(i, Integer)
  
  Procedure pushMemory(*attr.BufferQueueS, *buffer, length.i)
    Protected *bb.BufferBlockS
    
    With *attr
      Protected newSize.i = \defaultSize
      If (length > newSize)
        newSize = length
      EndIf
      
      \blockLock\acquire()
      Debug "push blockLock acquired", 5
      ;Wenn kein Block vorhanden ist, erstelle einen
      If (Not \last)
        *bb = add(*attr, newSize)
        If (Not *bb)
          \blockLock\release()
          ProcedureReturn #False
        EndIf
        Debug "push new Block created", 5
        ;\newBlockCond\signal()
        
        Debug "push new block mutex acquired", 5
        *bb\mutex\acquire()
      Else
        \last\mutex\acquire()
        Debug "push last block mutex acquired", 5
        ;Wenn der restliche Platz im letzten Block nicht für den ganzen zu kopierenden Buffer ausreicht, erstelle einen neuen
        Debug "push size=" + \last\size + " iWrite=" + \last\iWrite + " length=" + length, 5
        If (\last\size - \last\iWrite < length)
          Protected *last.BufferBlockS = \last
          Debug "push add new Block", 5
          *bb = add(*attr, newSize)
          If (Not *bb)
            Debug "push last block mutex released", 5
            *last\mutex\release()
            Debug "push blockLock released", 5
            \blockLock\release()
            ProcedureReturn #False
          EndIf
          ;Signalisiere einem wartenden Thread, dass ein neuer Block vorhanden ist
          ;\newBlockCond\signal()
          
          ;Signalisiere einem wartenden Thread, dass er jetzt von dem zweitletzten Block lesen kann
          Debug "push signal new data", 5
          *last\newDataCond\signal()
          
          *bb\mutex\acquire()
          
          Debug "push last block mutex release", 5
          *last\mutex\release()
          
        Else
          *bb = \last
        EndIf
      EndIf
      
      Debug "push blockLock released", 5
      \blockLock\release()
      
      CopyMemory(*buffer, *bb\buffer + *bb\iWrite, length)
      *bb\iWrite + length
      
      *bb\newDataCond\signal()
      *bb\mutex\release()
    EndWith
  EndProcedure
  
  Procedure pushString(*this.BufferQueue, s.s, format.i = -1)
    Protected length.i
    
    If (format = -1)
      length = StringByteLength(s) + SizeOf(Character)
      *this\pushMemory(@s, length)
    Else
      CompilerIf #PB_Compiler_Unicode
        If (format = #PB_Unicode)
          *this\pushMemory(@s, Len(s) + SizeOf(Unicode))
        Else
          length = Len(s)
          Protected *mem = AllocateMemory(2 * length + 1)
          length = PokeS(*mem, s, -1, #PB_UTF8) + 1
          *this\pushMemory(*mem, length)
          FreeMemory(*mem)
        EndIf
      CompilerElse
        If (format = #PB_Unicode)
          length = Len(s)
          Protected *mem = AllocateMemory(SizeOf(Unicode) * (length + 1))
          length = PokeS(*mem, s, -1, #PB_Unicode) + SizeOf(Unicode)
          *this\pushMemory(*mem, length)
          FreeMemory(*mem)
        Else
          *this\pushMemory(@s, Len(s) + 1)
        EndIf
      CompilerEndIf
    EndIf
  EndProcedure
  
  DataSection
    vTable_BufferQueue:
    Data.i   @free(),
             @popAscii(), @popByte(), @popUnicode(), @popWord(),
             @popCharacter(), @popLong(), @popFloat(), @popDouble(),
             @popQuad(), @popInteger(), @popString(), @popMemory(),
             @pushAscii(), @pushByte(), @pushUnicode(), @pushWord(),
             @pushCharacter(), @pushLong(), @pushFloat(), @pushDouble(),
             @pushQuad(), @pushInteger(), @pushString(), @pushMemory()
  EndDataSection
  
  ;}
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  UseModule BufferQueue
  
  Procedure WriterThread(*bq.BufferQueue)
    Protected i.q
    For i = 1 To 4
      Debug "PUSH " + i
      *bq\pushQuad(i)
      Debug "PUSHED " + i
      ;Delay(10)
    Next
    *bq\pushQuad(0)
    
    Protected c.c
    For i = 1 To 10
      c = Random(90, 65)
      Debug "PUSH " + c
      *bq\pushCharacter(c)
      Debug "PUSHED " + c
    Next
    Debug "PUSH 0"
    *bq\pushCharacter(0)
    Debug "PUSHED 0"
    *bq\pushString("Hallo STARGÅTE")
    CompilerIf Not #PB_Compiler_Unicode
      *bq\pushAscii(0)
      Debug "!! ACTIVATE UNICODE TO RETRIEVE THE CORRECT TEXT"
    CompilerEndIf
  EndProcedure
  
  Procedure ReaderThread(*bq.BufferQueue)
    Protected i.q
    
    Repeat
      Debug "    POP"
      i = *bq\popQuad()
      Debug "    POPPED " + i
    Until i = 0
    
    Protected s.s
    Debug "    POP String"
    s = *bq\popString()
    Debug "    POPPED '" + s + "'"
    Debug "    POP String"
    s = *bq\popString(#PB_Unicode)
    Debug "    POPPED '" + s + "'"
  EndProcedure
  
  Define *bq.BufferQueue = newBufferQueue()
  
  Define reader.i = CreateThread(@ReaderThread(), *bq)
  
  Delay(100)
  Define writer.i = CreateThread(@WriterThread(), *bq)
  
  WaitThread(writer)
  WaitThread(reader)
  Debug "ENDE"
  
CompilerEndIf
