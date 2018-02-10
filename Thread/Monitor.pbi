;   Description: Adds monitor or condition variables (http://en.wikipedia.org/wiki/Monitor_%28synchronization%29#Monitor_implemented_using_semaphores)
;            OS: Mac, Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27822
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


DeclareModule Monitor
  EnableExplicit
  
  
  Interface ConditionVariable
    free()
    wait()
    signal()
    broadcast.i()
  EndInterface
  
  Interface Mutex
    free()
    acquire()
    release()
    newConditionVariable.i()
  EndInterface
  
  Declare.i newMutex()
EndDeclareModule

Module Monitor
  Structure MutexS
    *vTable
    mutex.i
    held.i
    acquires.i
  EndStructure
  
  Structure ConditionVariableS
    *vTable
    numWaiters.i
    semaphore.i
    StructureUnion
      *mutex.Mutex
      *mutexAttr.MutexS
    EndStructureUnion
    *internalMutex.Mutex
  EndStructure
  
  Procedure.i newMutex()
    Protected *attr.MutexS = AllocateMemory(SizeOf(MutexS))
    If (Not *attr)
      ProcedureReturn #False
    EndIf
    
    With *attr
      \vTable = ?vTable_Mutex
      \acquires = 0
      
      \mutex = CreateMutex()
      If (Not \mutex) : Goto end1 : EndIf
      
      \held = CreateSemaphore()
      If (Not \held) : Goto end2 : EndIf
      
      ProcedureReturn *attr
      
      end2:
      FreeMutex(\mutex)
      
      end1:
      FreeMemory(*attr)
      
      ProcedureReturn #False
    EndWith
  EndProcedure
  
  Procedure free(*attr.MutexS)
    With *attr
      FreeMutex(\mutex)
      FreeSemaphore(\held)
      FreeMemory(*attr)
    EndWith
  EndProcedure
  
  Procedure acquire(*attr.MutexS)
    With *attr
      LockMutex(\mutex)
      \acquires + 1
      SignalSemaphore(\held)
    EndWith
  EndProcedure
  
  Procedure release(*attr.MutexS)
    With *attr
      WaitSemaphore(\held)
      \acquires - 1
      UnlockMutex(\mutex)
    EndWith
  EndProcedure
  
  Procedure.i newConditionVariable(*mutex.MutexS)
    Protected *attr.ConditionVariableS = AllocateMemory(SizeOf(ConditionVariableS))
    If (Not *attr)
      ProcedureReturn #False
    EndIf
    
    With *attr
      \vTable = ?vTable_ConditionVariable
      \mutex = *mutex
      \numWaiters = 0
      \semaphore = CreateSemaphore(0)
      If (Not \semaphore)
        Goto end1
      EndIf
      \internalMutex = newMutex()
      If (Not \internalMutex)
        Goto end2
      EndIf
      
      ProcedureReturn *attr
      
      end2:
      FreeSemaphore(\semaphore)
      
      end1:
      FreeMemory(*attr)
      
      ProcedureReturn #False
    EndWith
  EndProcedure
  
  DataSection
    vTable_Mutex:
    Data.i @free(), @acquire(), @release(), @newConditionVariable()
  EndDataSection
  
  Procedure free2(*attr.ConditionVariableS)
    With *attr
      FreeMutex(\internalMutex)
      FreeSemaphore(\semaphore)
      FreeMemory(*attr)
    EndWith
  EndProcedure
  
  Procedure wait(*attr.ConditionVariableS)
    With *attr
      If (\mutexAttr\acquires = 0)
        RaiseError(#PB_OnError_IllegalInstruction)
      EndIf
      \internalMutex\acquire()
      
      \numWaiters + 1
      
      \internalMutex\release()
      
      Protected i.i, acquires.i = \mutexAttr\acquires
      For i = 1 To acquires
        \mutex\release()
      Next
      WaitSemaphore(\semaphore)
      For i = 1 To acquires
        \mutex\acquire()
      Next
    EndWith
  EndProcedure
  
  Procedure signal(*attr.ConditionVariableS)
    With *attr
      \internalMutex\acquire()
      If (\numWaiters > 0)
        \numWaiters - 1
        SignalSemaphore(\semaphore)
      EndIf
      \internalMutex\release()
    EndWith
  EndProcedure
  
  Procedure.i broadcast(*attr.ConditionVariableS)
    Protected waiters.i
    With *attr
      \internalMutex\acquire()
      waiters = \numWaiters
      While (\numWaiters > 0)
        \numWaiters - 1
        SignalSemaphore(\semaphore)
      Wend
      \internalMutex\release()
      
      ProcedureReturn waiters
    EndWith
  EndProcedure
  
  DataSection
    vTable_ConditionVariable:
    Data.i @free2(), @wait(), @signal(), @broadcast()
  EndDataSection
EndModule


;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ;Anzahl lesende Threads
  #READER_THREADS = 10
  
  ;Anzahl Werte
  #VALUES = 500000
  #VALUES_PER_LOOP = 50
  
  #DELAY_AFTER_RELEASE = 0
  
  #DEBUG_LEVEL = 2
  
  ;Auf 2 setzen um alle Debugs zu sehen
  DebugLevel #DEBUG_LEVEL
  
  Macro CONSOLE_DEBUG(text, dbgLevel = 0)
    Debug text, dbgLevel
    If (dbgLevel <= #DEBUG_LEVEL)
      PrintN("" + text)
    EndIf
  EndMacro
  
  UseModule Monitor
  
  Global NewList stack.i()
  Global *mutex.Mutex = newMutex()
  Global *newData.ConditionVariable = *mutex\newConditionVariable()
  
  Procedure ReaderThread(id.i)
    ;Simuliere verschachtelte Locks
    *mutex\acquire()
    *mutex\acquire()
    
    Protected i.i = -1, r.i
    Repeat
      r = FirstElement(stack())
      CONSOLE_DEBUG("Reader " + id + ": FirstElement: " + r, 3)
      If (r)
        i = stack()
        ;Wenn der Wert 0 ist, dann breche ab, ohne das Element zu löschen.
        ;Auf die Weise können auch alle anderen Threads sich beenden.
        If (i = 0)
          Break
        EndIf
        DeleteElement(stack())
        CONSOLE_DEBUG("Reader " + id + ": new data: " + i, 1)
      Else
        CONSOLE_DEBUG("Reader " + id + ": waiting for new data.", 2)
        *newData\wait()
        CONSOLE_DEBUG("Reader " + id + ": new data is there.", 2)
        Continue
      EndIf
      
    ForEver
    
    *mutex\release()
    *mutex\release()
  EndProcedure
  
  Define.i time = ElapsedMilliseconds()
  OpenConsole("ConditionVariable Test")
  
  Dim threads.i(#READER_THREADS - 1)
  Define i.i
  For i = 0 To #READER_THREADS - 1
    threads(i) = CreateThread(@ReaderThread(), i)
  Next
  
  ;Lasse die Readerthreads kurz anlaufen, damit sie sich in ihren waits verfangen.
  Delay(100)
  
  *mutex\acquire()
  
  Define i.i
  For i = #VALUES To 0 Step -1
    
    CONSOLE_DEBUG("        ADD acquire", 3)
    LastElement(stack())
    If AddElement(stack())
      CONSOLE_DEBUG("        ADD " + i, 2)
      stack() = i
    EndIf
    
    
    CONSOLE_DEBUG("        ADD release", 3)
    If (i % #VALUES_PER_LOOP = 0)
      ;Signalisiere einen Thread, damit er Daten empfangen kann.
      *newData\signal()
      *mutex\release()
      CompilerIf #DELAY_AFTER_RELEASE
        Delay(#DELAY_AFTER_RELEASE)
      CompilerEndIf
      *mutex\acquire()
    EndIf
    ;Delay(250)
  Next
  *mutex\release()
  
  
  ;Signalisiere alle Threads, die noch warten, damit sie die 0 lesen und sich sauber beenden
  *newData\broadcast()
  
  For i = 0 To #READER_THREADS - 1
    WaitThread(threads(i))
  Next
  
  CONSOLE_DEBUG("ENDE")
  time = ElapsedMilliseconds() - time
  CONSOLE_DEBUG("Zeit: " + time + " ms")
  Input()
  CloseConsole()
CompilerEndIf
