; Description: System wide Mutex, Semaphore, Memory and Memory-Messages 
; Author: Imhotheb
; Date: 11-11-2015
; PB-Version: 5,40
; OS: Windows
; English-Forum: 
; French-Forum: 
; German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29238
;-----------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  CompilerIf #PB_Compiler_Thread = #False   
    CompilerWarning "IPC_Semaphore::BindCallback() - NEED THREADSAFE executable"
    CompilerWarning "IPC_MemMsg - NEED THREADSAFE executable"   
  CompilerEndIf
CompilerElse 
  CompilerError "<IPC.pbi> Windows ONLY"   
CompilerEndIf

DeclareModule IPC_Mutex
  
  #ERR_Abandoned = #WAIT_ABANDONED             ; Mutex was locked by a terminated thread/process ... but is now locked
  #ERR_TimeOut = #WAIT_TIMEOUT                 ; Timeout reached
  #ERR_Failed = #WAIT_FAILED                   ; Lock Failed (OS-Error)
  
  Declare Create(Name$, Security = #False)    ; returns a handle (hMutex), if security is needed use #True
  Declare Free(hMutex)                        ; free resources, close handels and cleanup
  
  Declare Lock(hMutex, TimeOut = #INFINITE)   ; try to lock mutex ... wait until TimeOut ...
                                              ; returns #True (locked) or #False
  Declare TryLock(hMutex)                     ; = Lock(hMutex, 0)
  Declare Unlock(hMutex)                      ; unlock Mutex, returns #True or #False (Error/TimeOut)
  
  Declare GetError(hMutex)                    ; if (Try-)Lock() returns #False ... return value = #ERR_* or #False (no Error)
  Declare.s GetName(hMutex)                   ; returns the name used to create the mutex
  
EndDeclareModule
Module IPC_Mutex
  EnableExplicit
  
  Structure Mutex
    LastError.i
    Name.s
  EndStructure
  
  Global SA.SECURITY_ATTRIBUTES
  Global pSD.SECURITY_DESCRIPTOR
  Global IsInitSecurity
  
  Global Lib
  Global NewMap Mutex.Mutex()
  
  Macro ___LockMutex___(___hMutex___, ___TimeOut___)
    Select WaitForSingleObject_(___hMutex___,       ; Mutex object
                                ___TimeOut___)      ; Wait For x ms       
      Case #WAIT_OBJECT_0
        Mutex(Str(___hMutex___))\LastError = #False
        ProcedureReturn #True       
        
      Case #WAIT_ABANDONED
        Mutex(Str(___hMutex___))\LastError = #ERR_Abandoned
        ProcedureReturn #True                       ; Mutex is still locked
        
      Case #WAIT_FAILED
        Mutex(Str(___hMutex___))\LastError = #ERR_Failed
        
      Case #WAIT_TIMEOUT
        Mutex(Str(___hMutex___))\LastError = #ERR_TimeOut       
    EndSelect       
  EndMacro 
  
  Procedure Create(Name$, Security = #False)
    Protected hMutex, *SA
    
    If Security
      If Not IsInitSecurity
        If Not InitializeSecurityDescriptor_(@pSD, #SECURITY_DESCRIPTOR_REVISION)
          ProcedureReturn 0
        EndIf
        If Not SetSecurityDescriptorDacl_(@pSD, #True, #Null, #False)
          ProcedureReturn 0
        EndIf
        SA\nLength = SizeOf(SA)
        SA\lpSecurityDescriptor = @pSD
        SA\bInheritHandle = #True
        IsInitSecurity = #True
      EndIf
      *SA = @SA
    Else
      *SA = #Null
    EndIf
    
    hMutex = CreateMutex_(*SA,                            ; Security attributes
                          #False,                         ; Mutex owned by creator
                          Name$)                          ; object name
    
    If hMutex
      With Mutex(Str(hMutex))       
        \LastError = #False
        \Name = Name$
      EndWith
    EndIf
    
    ProcedureReturn hMutex   
  EndProcedure
  Procedure Free(hMutex)
    
    DeleteMapElement(Mutex(), Str(hMutex))
    ReleaseMutex_(hMutex) ; try to unlock
    CloseHandle_(hMutex)
    
  EndProcedure
  
  Procedure Lock(hMutex, TimeOut = #INFINITE)
    
    ___LockMutex___(hMutex, TimeOut)
    
    ProcedureReturn #False   
  EndProcedure
  Procedure TryLock(hMutex)
    
    ___LockMutex___(hMutex, 0)
    
    ProcedureReturn #False
  EndProcedure
  Procedure Unlock(hMutex)
    
    Mutex(Str(hMutex))\LastError = #False
    
    ProcedureReturn ReleaseMutex_(hMutex)
  EndProcedure
  
  Procedure GetError(hMutex)
    Protected LastError
    
    LastError = Mutex(Str(hMutex))\LastError
    Mutex(Str(hMutex))\LastError = #False
    
    ProcedureReturn LastError
  EndProcedure 
  Procedure.s GetName(hMutex)
    
    ProcedureReturn Mutex(Str(hMutex))\Name
  EndProcedure
  
EndModule

DeclareModule IPC_Semaphore
  
  #ERR_TimeOut = #WAIT_TIMEOUT                 ; Timeout reached
  #ERR_Failed = #WAIT_FAILED                   ; Failed (OS-Error)
  
  Declare Create(Name$, InitialCount = 0, Security = #False)       ; returns a handle (hSemaphore),  if security is needed use #True
  Declare Free(hSemaphore)                                         ; free resources, close handels and cleanup
  
  Declare Wait(hSemaphore, TimeOut = #INFINITE)                    ; wait for signal until TimeOut reached ...
                                                                   ; returns #True (got signal) or #False (Error/TimeOut)
  Declare Try(hSemaphore)                                          ; = Wait(hSemaphore, 0)
  
  Declare Signal(hSemaphore, Count = 1)                            ; generate signal(s)
  
  Declare BindCallback(hSemaphore, *Callback, Timer = #INFINITE)   ; returns CallbackID or #False
                                                                   ; callback procedure declaration: SemaphoreCallBack(hSemaphore, TimerEvent)
                                                                   ; if TimerEvent = not 0 -> TimeOut reached
                                                                   ; if TimerEvent = 0 -> Signal
  Declare UnbindCallback(hSemaphore)                               ; unbind Callback
  
  
  Declare GetError(hSemaphore)                                     ; if Wait()/Try() returns #False ... return value = #ERR_* or False (no Error=
  Declare.s GetName(hSemaphore)                                    ; returns the name used to create the semaphore
  
EndDeclareModule
Module IPC_Semaphore
  EnableExplicit
  
  #WT_EXECUTEDEFAULT = 0        ; = By default, the callback function is queued to a non-I/O worker thread.
  #WT_EXECUTEONLYONCE = 8       ; = The thread will no longer wait on the handle after the callback function
                                ; has been called once. Otherwise, the timer is reset every time the wait
                                ; operation completes Until the wait operation is canceled.
  #WT_EXECUTELONGFUNCTION = $10 ; = The callback function can perform a long wait.
                                ; This flag helps the system To decide If it should create a new thread.
  
  #BindFlags = #WT_EXECUTEDEFAULT   ; how to execute callback
  #MaxCount = 8192                  ; max. Signals
  
  Structure Semaphore
    CallbackID.i
    LastError.i
    Name.s
  EndStructure
  
  Global SA.SECURITY_ATTRIBUTES
  Global pSD.SECURITY_DESCRIPTOR
  Global IsInitSecurity
  
  Global Lib
  Global NewMap Semaphore.Semaphore()
  
  Macro ___WaitSemaphore___(___hSemaphore___, ___TimeOut___)
    Select WaitForSingleObject_(___hSemaphore___, ___TimeOut___)
      Case #WAIT_OBJECT_0
        Semaphore(Str(___hSemaphore___))\LastError = #False
        ProcedureReturn #True       
        
      Case #WAIT_FAILED
        Semaphore(Str(___hSemaphore___))\LastError = #ERR_Failed
        
      Case #WAIT_TIMEOUT
        Semaphore(Str(___hSemaphore___))\LastError = #ERR_TimeOut       
    EndSelect
  EndMacro
  
  Procedure Create(Name$, InitialCount = 0, Security = #False)
    Protected hSemaphore, *SA
    
    If Security
      If Not IsInitSecurity
        If Not InitializeSecurityDescriptor_(@pSD, #SECURITY_DESCRIPTOR_REVISION)
          ProcedureReturn #False
        EndIf
        If Not SetSecurityDescriptorDacl_(@pSD, #True, #Null, #False)
          ProcedureReturn #False
        EndIf
        SA\nLength = SizeOf(SA)
        SA\lpSecurityDescriptor = @pSD
        SA\bInheritHandle = #True
        IsInitSecurity = #True
      EndIf
      *SA = @SA
    Else
      *SA = #Null
    EndIf
    
    hSemaphore = CreateSemaphore_(*SA,                            ; Security attributes
                                  InitialCount,                   ; Initial Count
                                  #MaxCount,                      ; Maximum Signal Count
                                  Name$)                          ; object name
    
    If hSemaphore
      With Semaphore(Str(hSemaphore))
        \CallbackID = #False
        \LastError = #False
        \Name = Name$
      EndWith
    EndIf
    
    ProcedureReturn hSemaphore   
  EndProcedure
  Procedure Free(hSemaphore)
    
    If Semaphore(Str(hSemaphore))\CallbackID
      UnbindCallback(hSemaphore)
    EndIf   
    CloseHandle_(hSemaphore)
    DeleteMapElement(Semaphore(), Str(hSemaphore))
    
  EndProcedure
  
  Procedure Wait(hSemaphore, TimeOut = #INFINITE)
    
    ___WaitSemaphore___(hSemaphore, TimeOut)
    
    ProcedureReturn #False
  EndProcedure
  Procedure Try(hSemaphore)
    
    ___WaitSemaphore___(hSemaphore, 0)
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure Signal(hSemaphore, Count = 1)
    Protected OldCount
    
    If ReleaseSemaphore_(hSemaphore, Count, @OldCount)    ; Increase Count
      Semaphore(Str(hSemaphore))\LastError = #False
      ProcedureReturn OldCount + Count
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure BindCallback(hSemaphore, *CallbackProc, Timer = #INFINITE)
    
    With Semaphore(Str(hSemaphore))     
      If \CallbackID
        ProcedureReturn \CallbackID
      Else
        
        If Not IsLibrary(Lib)
          Lib = OpenLibrary(#PB_Any, "kernel32.dll")
        EndIf
        
        If IsLibrary(Lib)
          If CallFunction(Lib, "RegisterWaitForSingleObject",
                          @\CallbackID,
                          hSemaphore,
                          *CallbackProc,
                          hSemaphore,
                          Timer,
                          #BindFlags)
            
            ProcedureReturn \CallbackID
          EndIf               
        EndIf
        
      EndIf     
    EndWith
    
    ProcedureReturn #False
  EndProcedure
  Procedure UnbindCallback(hSemaphore)
    Protected Result
    
    With Semaphore(Str(hSemaphore))     
      If \CallbackID
        
        If Not IsLibrary(Lib)
          Lib = OpenLibrary(#PB_Any, "kernel32.dll")
        EndIf
        
        If IsLibrary(Lib)
          Result = CallFunction(Lib, "UnregisterWait",
                                \CallbackID)
          \CallbackID = #False
          CloseLibrary(Lib)
        EndIf
        
      EndIf           
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure GetError(hSemaphore)
    
    ProcedureReturn Semaphore(Str(hSemaphore))\LastError
  EndProcedure 
  Procedure.s GetName(hSemaphore)
    
    ProcedureReturn Semaphore(Str(hSemaphore))\Name
  EndProcedure
  
EndModule


; Code aus dem PureBasic Forum
; ----------------------------
; http://www.purebasic.fr/german/viewtopic.php?f=8&t=16659&sid=26ccf0dc50e3edc9f9985b99351eb52d
; Dank an TS-Soft, MK-Soft und allen anderen Mitwirkenden
; ----------------------------
DeclareModule IPC_Mem
  
  Declare Create(Name.s, Size.i, Security = #False)   ; returns a pointer (*Mem), if security is needed use #True
  Declare Free(*Mem)                                  ; free resources, close handels and cleanup
  
  Declare.s GetName(*Mem)                             ; returns the name used to create the SharedMemory
  
EndDeclareModule
Module IPC_Mem
  EnableExplicit
  
  Global SA.SECURITY_ATTRIBUTES
  Global pSD.SECURITY_DESCRIPTOR
  Global IsInitSecurity
  
  Structure Mem
    handle.i
    Name.s
  EndStructure
  
  Global NewMap Mem.Mem() 
  
  Procedure Create(Name.s, Size.i, Security = #False)
    Protected handle, *Mem, *SA
    
    handle = OpenFileMapping_(#FILE_MAP_ALL_ACCESS, 0, Name)
    
    If handle = #Null     
      If Security
        If Not IsInitSecurity
          If Not InitializeSecurityDescriptor_(@pSD, #SECURITY_DESCRIPTOR_REVISION)
            ProcedureReturn #False
          EndIf
          If Not SetSecurityDescriptorDacl_(@pSD, #True, #Null, #False)
            ProcedureReturn #False
          EndIf
          SA\nLength = SizeOf(SA)
          SA\lpSecurityDescriptor = @pSD
          SA\bInheritHandle = #True
          IsInitSecurity = #True
        EndIf
        *SA = @SA
      Else
        *SA = #Null
      EndIf     
      handle = CreateFileMapping_(#INVALID_HANDLE_VALUE, *SA, #PAGE_READWRITE | #SEC_COMMIT | #SEC_NOCACHE, 0, Size, Name)
    EndIf
    
    If handle
      *Mem = MapViewOfFile_(handle, #FILE_MAP_ALL_ACCESS, 0, 0, 0)
      If *Mem
        With Mem(Str(*Mem))
          \handle = handle
          \Name = Name         
        EndWith     
      EndIf   
    EndIf     
    
    ProcedureReturn *Mem
  EndProcedure
  Procedure Free(*Mem)
    Protected result
    
    UnmapViewOfFile_(*Mem)
    result = CloseHandle_(Mem(Str(*Mem))\handle)
    DeleteMapElement(Mem(), Str(*Mem))
    
    ProcedureReturn result
  EndProcedure
  
  Procedure.s GetName(*Mem)
    
    ProcedureReturn Mem(Str(*Mem))\Name
  EndProcedure
  
EndModule

DeclareModule IPC_MemMsg
  
  Declare Create(Name$, Security = #False)            ; returns a handle (hMsg), if security is needed use #True
  Declare Free(hMsg)                                  ; free resources, close handels and cleanup
  
  Declare Add(hMsg, Msg$)                             ; add a message to queue
  Declare.s Get(hMsg)                                 ; get a message from queue
  
  Declare Wait(hMsg, TimeOut = #False)                ; wait for message until TimeOut reached
  Declare Count(hMsg)                                 ; count messages in queue (for get())
  
EndDeclareModule
Module IPC_MemMsg
  EnableExplicit
  
  Declare Thread(hMsg)
  
  #OnlyNewMsg = #True           ; after create, read only NEW Msg (#True) or ALL in Buffer (#False)
  #MsgBuffer = 100              ; Max. Shared Messages
  #MsgLength = 512              ; Max. Message Length (Chars)
  
  #GlobalDelay = 2              ; Delay for Loops
  #ThreadDelay = 10             ; Delay for Thread
  #MaxWait = 3000               ; max ms to wait for mutex in Add() and Get()
  
  #NamePrefix = "IPC_MemMsg_"
  #MemMutexPostfix = "_MemMutex"
  #MemPostfix = "_Mem"
  
  Structure IPC_Msg   
    ID.i
    Msg.s{#MsgLength}
  EndStructure 
  
  Structure Mem_Buffer
    CountID.i
    LastMsg.i
    Mem_Array.IPC_Msg[#MsgBuffer]
  EndStructure
  
  Structure hMsg   
    *Mem.Mem_Buffer   
    Mem_Size.i
    Mem_Mutex.i
    Thread_ID.i
    Thread_Exit.i
    Name.s
    Send_Semaphore.i
    Send_Mutex.i
    Recv_Mutex.i
    List SendMsg.s()
    List RecvMsg.s()
  EndStructure
  
  Global NewMap Msg.hMsg()
  
  Macro ___ListSize___(___hMsg___)
    ListSize(Msg(Str(___hMsg___))\RecvMsg())
  EndMacro
  
  Procedure Create(Name$, Security = #False)
    Static New_hMsg
    Protected hMsg
    
    ForEach Msg()
      If Msg()\Name = Name$
        hMsg = Val(MapKey(Msg()))
        ProcedureReturn hMsg
      EndIf
    Next
    
    If Not hMsg
      New_hMsg + 1
      hMsg = New_hMsg
    EndIf   
    
    With Msg(Str(hMsg))     
      \Mem_Size = SizeOf(Mem_Buffer)
      \Mem_Mutex = IPC_Mutex::Create(#NamePrefix + Name$ + #MemMutexPostfix, Security)
      If \Mem_Mutex
        \Mem = IPC_Mem::Create(#NamePrefix + Name$ + #MemPostfix, \Mem_Size, Security)
        If \Mem
          \Send_Semaphore = CreateSemaphore(0)
          If \Send_Semaphore
            \Send_Mutex = CreateMutex()
            If \Send_Mutex
              \Recv_Mutex = CreateMutex()
              If \Recv_Mutex
                \Thread_ID = CreateThread(@Thread(), hMsg)
                If \Thread_ID                 
                  ProcedureReturn hMsg
                EndIf             
                FreeMutex(\Recv_Mutex)
              EndIf             
              FreeMutex(\Send_Mutex)
            EndIf
            FreeSemaphore(\Send_Semaphore)
          EndIf
          IPC_Mem::Free(\Mem)
        EndIf
        IPC_Mutex::Free(\Mem_Mutex)
      EndIf     
    EndWith
    
    DeleteMapElement(Msg(), Str(hMsg))
    ProcedureReturn #False
  EndProcedure
  Procedure Free(hMsg)
    Protected startTime
    With Msg(Str(hMsg))
      
      startTime = ElapsedMilliseconds()
      \Thread_Exit = #True
      
      Repeat
        If TryLockMutex(\Send_Mutex) Or ElapsedMilliseconds() - startTime > #MaxWait
          If IsThread(\Thread_ID)
            If WaitThread(\Thread_ID, #MaxWait) = #False
              KillThread(\Thread_ID)
            EndIf
          EndIf         
          FreeMutex(\Recv_Mutex)
          FreeMutex(\Send_Mutex)
          FreeSemaphore(\Send_Semaphore)
          IPC_Mem::Free(\Mem)
          IPC_Mutex::Free(\Mem_Mutex)
          Break
        Else
          Delay(#GlobalDelay)
        EndIf
      ForEver
      
    EndWith   
    DeleteMapElement(Msg(), Str(hMsg))       
  EndProcedure
  
  Procedure Add(hMsg, Msg$)
    Protected startTime   
    With Msg(Str(hMsg))
      
      startTime = ElapsedMilliseconds()
      Repeat
        If TryLockMutex(\Send_Mutex)
          LastElement(\SendMsg())
          AddElement(\SendMsg())
          \SendMsg() = Msg$
          UnlockMutex(\Send_Mutex)
          SignalSemaphore(\Send_Semaphore)
          ProcedureReturn #True
        Else         
          Delay(#GlobalDelay)
        EndIf   
      Until ElapsedMilliseconds() - startTime > #MaxWait
      
    EndWith
    ProcedureReturn #False
  EndProcedure
  Procedure.s Get(hMsg)
    Protected startTime, Ret$ = ""
    With Msg(Str(hMsg))
      
      startTime = ElapsedMilliseconds()
      If ___ListSize___(hMsg)
        Repeat
          If TryLockMutex(\Recv_Mutex)       
            FirstElement(\RecvMsg())
            Ret$ = \RecvMsg()
            DeleteElement(\RecvMsg())
            UnlockMutex(\Recv_Mutex)
            Break
          Else
            Delay(#GlobalDelay)
          EndIf       
        Until ElapsedMilliseconds() - startTime > #MaxWait
      EndIf
      
    EndWith
    ProcedureReturn Ret$
  EndProcedure
  
  Procedure Wait(hMsg, TimeOut = #False)
    Protected startTime, Size
    
    startTime = ElapsedMilliseconds()
    Repeat
      Size = ___ListSize___(hMsg)
      If Size
        ProcedureReturn Size
      ElseIf TimeOut
        If ElapsedMilliseconds() - startTime > TimeOut
          Break
        EndIf
      Else
        Delay(#GlobalDelay)
      EndIf
    ForEver
    
    ProcedureReturn #False
  EndProcedure
  Procedure Count(hMsg)
    
    ProcedureReturn ___ListSize___(hMsg)
  EndProcedure
  
  Procedure Thread(hMsg)
    Protected LastRead, LastWrite, LastCount, ReadCount, i
    With Msg(Str(hMsg))
      
      CompilerIf #OnlyNewMsg
        LastRead = \Mem\LastMsg
        If LastRead
          LastCount = \Mem\CountID
        EndIf
      CompilerEndIf 
      
      Repeat
        
        
        ; read messages
        ; -------------
        If LastRead < \Mem\LastMsg
          ReadCount = LastCount + 1
          If ReadCount >= #MsgBuffer
            ReadCount = 0
          EndIf         
          ;If ReadCount <= \Mem\CountID
          
          If \Mem\Mem_Array[ReadCount]\ID = LastWrite
            LastRead = \Mem\Mem_Array[ReadCount]\ID
            LastCount = ReadCount
          Else               
            If \Mem\Mem_Array[ReadCount]\ID > LastRead
              Repeat
                If TryLockMutex(\Recv_Mutex)
                  LastElement(\RecvMsg())
                  AddElement(\RecvMsg())
                  \RecvMsg() = \Mem\Mem_Array[ReadCount]\Msg
                  LastRead = \Mem\Mem_Array[ReadCount]\ID                 
                  LastCount = ReadCount
                  UnlockMutex(\Recv_Mutex)
                  Break
                ElseIf \Thread_Exit
                  Break 2
                Else
                  Delay(#GlobalDelay)
                EndIf
              ForEver
            EndIf
          EndIf
          ;EndIf
          
          
          ; send message
          ; ------------
        ElseIf TrySemaphore(\Send_Semaphore)
          Repeat
            If TryLockMutex(\Send_Mutex)
              FirstElement(\SendMsg())
              IPC_Mutex::Lock(\Mem_Mutex)               
              CompilerIf #PB_Compiler_Debugger
                If IPC_Mutex::GetError(\Mem_Mutex) = IPC_Mutex::#ERR_Abandoned
                  Debug "IPC_MemMsg::Thread() ... Mutex Abandoned"
                EndIf 
              CompilerEndIf
              \Mem\CountID + 1
              If \Mem\CountID >= #MsgBuffer
                \Mem\CountID = 0
              EndIf                     
              \Mem\LastMsg + 1
              \Mem\Mem_Array[\Mem\CountID]\ID = \Mem\LastMsg             
              \Mem\Mem_Array[\Mem\CountID]\Msg = Right(\SendMsg(), #MsgLength)
              DeleteElement(\SendMsg())
              LastWrite = \Mem\LastMsg
              IPC_Mutex::Unlock(\Mem_Mutex)
              UnlockMutex(\Send_Mutex)
              Break
            ElseIf \Thread_Exit
              Break 2
            Else
              Delay(#GlobalDelay)
            EndIf
          ForEver
          
          
          ; free resources
          ; -------------- 
        Else
          Delay(#ThreadDelay)
        EndIf
        
      Until \Thread_Exit
      
      UnlockMutex(\Recv_Mutex)
      IPC_Mutex::Unlock(\Send_Mutex)     
    EndWith
  EndProcedure
  
EndModule








;-Example
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; !!!!!!!!!!!!! zum testen mehrmals starten !!!!!!!!!!!!!
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  #Test_Mutex     = #True
  #Test_Semaphore = #True
  #Test_Mem       = #True
  #Test_MemMsg    = #True
  #OnlyRead = #False    ; for Test_MemMsg
  
  CompilerIf #Test_Mutex
    OpenConsole("<IPC_Mutex> TEST")
    EnableGraphicalConsole(#True)
    ClearConsole()
    EnableGraphicalConsole(#False)
    
    #MutexName = "TestMutex"
    
    Define hMutex
    Define ms, starttime
    
    hMutex = IPC_Mutex::Create(#MutexName) ; Mutex erstellen oder öffnen
    
    If hMutex     
      Repeat
        Print("Checking Mutex ... ")
        If IPC_Mutex::Lock(hMutex, 500)   ; versuche Mutex zu sperren         
          PrintN("LOCKED")
          ms = Random(10000, 3000)      ; zufällige Wartezeit ... 3 bis 10 Sek.
          startTime = ElapsedMilliseconds()
          PrintN("waiting " + Str(ms) + " ms")
          Repeat
            If Inkey()
              Break 2
            EndIf             
          Until ElapsedMilliseconds() - startTime > ms           
          IPC_Mutex::Unlock(hMutex)
          PrintN("Mutex UNLOCKED")
        Else
          Select IPC_Mutex::GetError(hMutex)
            Case IPC_Mutex::#ERR_TimeOut       ; Zeit abgelaufen
              PrintN("TIMEOUT")
            Case IPC_Mutex::#ERR_Abandoned     ; verwaist
              IPC_Mutex::Unlock(hMutex)        ; um weitere Prozesse nicht zu blockieren ...
                                               ; alternativ Free(hMutex) um den Mutex zu zerstören
              PrintN("ABANDONED")
              PrintN("WAITING 10 sec.")
              Delay(10000)
            Case IPC_Mutex::#ERR_Failed
              PrintN("Function FAILED")
            Case #False
              ;PrintN("no error")
          EndSelect                       
        EndIf
      Until Inkey()
      IPC_Mutex::Unlock(hMutex)
      IPC_Mutex::Free(hMutex)   ; Mutex freigeben
    Else
      PrintN("Cannot create/open mutex object")
      PrintN("waiting 5 sec.")
      Delay(5000)
    EndIf
    
    PrintN(#CRLF$ +
           "------------------------------------------")
    PrintN("... Press any Key to close / next Test ...")
    PrintN("------------------------------------------" + #CRLF$)
    Repeat
      Delay(100)
    Until Inkey() 
    
  CompilerEndIf
  CompilerIf #Test_Semaphore
    OpenConsole("<IPC_Semaphore> TEST")
    
    Procedure SemaphoreCallBack(hSemaphore, TimerEvent)
      Static i
      Protected Str.s, ms
      
      i + 1  ; internal callback counter   
      Str = "CallBack Nr. " + Str(i) + " ... Name: " + IPC_Semaphore::GetName(hSemaphore)
      If TimerEvent
        PrintN(Str + " ... Event: TIMER")
      Else
        ms = Random(5000, 1000)    ; random waittime
        PrintN(Str + " ... Event: SIGNAL ... Waiting " + Str(ms) + " ms")
        Delay(ms)
        PrintN(Str + " ... DONE")
      EndIf
      
    EndProcedure
    
    
    Define hSemaphore
    Define i, AddSignals, startTime, queue    ; Example Vars
    
    
    hSemaphore = IPC_Semaphore::Create("TestSemaphore")
    
    If hSemaphore   
      
      PrintN("Generating 3x Signal")
      PrintN("--------------------")
      IPC_Semaphore::Signal(hSemaphore)     ; generate one signal
      IPC_Semaphore::Signal(hSemaphore, 2)  ; generate two signals
      
      
      PrintN("Testing 5x")
      PrintN("----------")       
      For i = 1 To 5
        Print("Waiting 500 ms for signal ... ")
        If IPC_Semaphore::Wait(hSemaphore, 500)
          PrintN("SIGNAL")
        ElseIf IPC_Semaphore::GetError(hSemaphore) = IPC_Semaphore::#ERR_TimeOut
          PrintN("TIMEOUT")
        ElseIf IPC_Semaphore::GetError(hSemaphore) = IPC_Semaphore::#ERR_Failed
          PrintN("FAILED")
        EndIf     
      Next
      
      
      PrintN(#CRLF$ +
             "Generate some signals")
      PrintN("---------------------")   
      For i = 1 To 5                  ; Add Some Signals     
        Delay(100)
        AddSignals = Random(10, 2)    ; random number of signals
        queue = IPC_Semaphore::Signal(hSemaphore, AddSignals)
        PrintN("Add signal(s) " + Str(AddSignals) +
               " ... in queue: " + Str(queue))
      Next
      
      
      PrintN(#CRLF$ + "Waiting 10 sec." + #CRLF$)
      Delay(10000)
      
      PrintN("Register callback")
      PrintN("-----------------")
      IPC_Semaphore::BindCallback(hSemaphore,             ; hSemaphore
                                  @SemaphoreCallBack(),   ; pointer to callback-procedure
                                  #INFINITE)              ; timer ... call callback-procedure after timeout
      
      
      ; Add Signal(s) each 10 sec.
      startTime = ElapsedMilliseconds()
      Repeat
        Delay(100)
        If ElapsedMilliseconds() - startTime > 10000
          AddSignals = Random(10, 2)    ; random number of signals
          queue = IPC_Semaphore::Signal(hSemaphore, AddSignals)
          PrintN("Add signal(s) " + Str(AddSignals) +
                 " ... in queue: " + Str(queue))
          startTime = ElapsedMilliseconds()
        EndIf     
      Until Inkey()
    EndIf
    
    
    
    PrintN(#CRLF$ + "unregister callback")
    IPC_Semaphore::UnbindCallback(hSemaphore)
    PrintN("free semaphore")
    IPC_Semaphore::Free(hSemaphore)
    
    
    PrintN(#CRLF$ +
           "------------------------------------------")
    PrintN("... Press any Key to close / next Test ...")
    PrintN("------------------------------------------" + #CRLF$)
    Repeat
      Delay(100)
    Until Inkey() 
    
  CompilerEndIf
  CompilerIf #Test_Mem
    OpenConsole("<IPC_Mem> TEST")
    EnableGraphicalConsole(#True)
    ClearConsole()
    
    
    #MemName = "TestMem"
    #MemSize = 1
    
    #MemMutexName = "MemMutex"
    
    
    Define bVar.b
    Define *IPC_Mem, hMutex
    
    *IPC_Mem = IPC_Mem::Create(#MemName, #MemSize)
    If *IPC_Mem
      PrintN("Shared Memory created")
      hMutex = IPC_Mutex::Create(#MemMutexName)
      If hMutex
        PrintN("Shared Mutex created")
        PrintN("---------------------------------------------------------")
        Repeat
          ConsoleLocate(0, 0)
          bVar = PeekB(*IPC_Mem)
          Print(" Read SharedMem ... %" +
                RSet(Bin(bVar, #PB_Byte), 8, "0") +
                Space(20))
          If IPC_Mutex::Lock(hMutex, 10)   ; versuche Mutex zu sperren         
            ConsoleLocate(0, 0)
            RandomData(@bVar, #MemSize)
            PrintN("Write SharedMem ... %" +
                   RSet(Bin(bVar, #PB_Byte), 8, "0") +
                   Space(20))
            PokeB(*IPC_Mem, bVar)
            PrintN("waiting" + Space(20))
            Delay(5000)           
            ConsoleLocate(0, 1)
            Print(Space(40))
            IPC_Mutex::Unlock(hMutex)
          EndIf
          Delay(100)
        Until Inkey()
        IPC_Mutex::Unlock(hMutex)
        IPC_Mutex::Free(hMutex)   ; Mutex freigeben         
      EndIf
      IPC_Mem::Free(*IPC_Mem)
    EndIf
    
    ConsoleLocate(0, 10)   
    PrintN("------------------------------------------")
    PrintN("... Press any Key to close / next Test ...")
    PrintN("------------------------------------------")
    Repeat
      Delay(100)
    Until Inkey() 
    
    EnableGraphicalConsole(#False)
    
  CompilerEndIf 
  CompilerIf #Test_MemMsg
    OpenConsole("<IPC_MemMsg> TEST")
    
    #MsgName = "TestMsg"
    
    Define Msg$
    Define hMsg, i, MsgCount, Wait, Counter
    
    hMsg = IPC_MemMsg::Create(#MsgName)
    If hMsg
      Repeat
        
        Counter + 1
        Msg$ = Str(Counter)
        
        If Not #OnlyRead
          PrintN("Write Message: " + Msg$ + " ... Ret: " +
                 Str(IPC_MemMsg::Add(hMsg, Msg$)))
          
        EndIf
        
        MsgCount = IPC_MemMsg::Count(hMsg)       
        
        If Not #OnlyRead
          PrintN("Messages Received: " + Str(MsgCount))
        EndIf
        
        If MsgCount
          For i = 1 To MsgCount
            PrintN("Read Message Nr. " + Str(i) + " ... " +
                   IPC_MemMsg::Get(hMsg))
          Next
        EndIf
        
        Wait = 10       
        If Not #OnlyRead
          Wait = Random(5000, 1000)
          PrintN("Waiting " + Str(Wait) + " ms")
        EndIf
        
        Delay(Wait)
      Until Inkey()
    EndIf
    
    IPC_MemMsg::Free(hMsg)
    
    PrintN(#CRLF$ +
           "------------------------------")
    PrintN("... Press any Key to close ...")
    PrintN("------------------------------" + #CRLF$)
    Repeat
      Delay(100)
    Until Inkey() 
    
    
  CompilerEndIf 
CompilerEndIf

; IDE Options = PureBasic 5.40 LTS (Windows - x64)
; CursorPosition = 4
; Folding = ---------
; EnableUnicode
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant