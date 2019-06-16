;   Description: Distribute tasks across multiple workers
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=72247
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2019 Michael R. King (Env)
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

; ====================================================================================================
; Title:        Load-Balanced Worker Threads Module
; Description:  Distribute tasks across multiple workers.
; Author:       Michael R. King (Env)
; License:      MIT
; Revision:     5

; If you like it, feel free to use it, if you really like it then you can buy me coffee :)
; https://ko-fi.com/mikerking
; ====================================================================================================

; Changelog
; Revision 2: Corrected TaskData to *TaskData in task creation.  Compiler ThreadSafe checking
; Revision 3: Added task cost to balance tasks more effectively
; Revision 4: Task handling events added
; Revision 5: Clearing pending tasks & Terminate all added

CompilerIf #PB_Compiler_Thread = #False
  CompilerError "Please compile with ThreadSafe enabled."
CompilerEndIf

DeclareModule WorkerThreads
 
  #MaximumEvents = 1000
 
  Structure sTaskInfo ; The structure of data to be passed to the worker procedure
    WorkerID.i
    ID.i
    Type.i
    *UserData
  EndStructure
 
  Enumeration BalanceMethod
    #BalanceMethod_QueueSize
    #BalanceMethod_QueueCost
  EndEnumeration
 
  Enumeration TaskCost
    #TaskCost_Minimal
    #TaskCost_Medium
    #TaskCost_High
    #TaskCost_Heavy
  EndEnumeration
 
  Enumeration WorkerEvent
    #Event_None
    #Event_TaskStarted
    #Event_TaskEnded
  EndEnumeration
 
  Prototype pTaskHandler(*TaskData.sTaskInfo)
 
  Declare SetBalanceMethod(Method = #BalanceMethod_QueueSize)                                   ;- Set how the tasks should be distributed.
  Declare SetMaximumThreads(Maximum)                                                            ;- Set the Maximum number of concurrent worker threads.
  Declare AddTask(ID, Type, *TaskData, *TaskHandler.pTaskHandler, TaskCost = #TaskCost_Medium)  ;- Create a task and add it to the queue.
  Declare Update()                                                                              ;- Process the queue.
  Declare TasksRemaining()                                                                      ;- Return how many tasks remain in the queue.
 
  Declare TrackEvents(State = #True)                                                            ;- Turn on/off tracking of worker events.
  Declare GetEvent()                                                                            ;- Get the next event in the events queue.
  Declare.i EventTaskID()                                                                       ;- Get the corresponding task ID of the currently pulled event.
  Declare ClearPending()                                                                        ;- Clear Pending Tasks
  Declare TerminateAll()                                                                        ;- Terminate any running tasks and clear the queue.
 
EndDeclareModule

Module WorkerThreads
 
  Structure sTask
    taskInfo.sTaskInfo
    cost.a
    *thread
    *handler
    pending.a
  EndStructure
 
  Structure sWorker
    workerIndex.i
    List tasks.sTask()
  EndStructure
 
  Structure sWorkerEvent
    eventType.i
    taskID.i
  EndStructure
 
  Structure sWorkerThreads
    *mutex
    maxThreads.i
    balanceMethod.a
    List worker.sWorker()
    currentEvent.sWorkerEvent
    trackEvents.a
    List eventQueue.sWorkerEvent()
  EndStructure
 
  Global gWorkerThreads.sWorkerThreads
  With gWorkerThreads
    \balanceMethod = #BalanceMethod_QueueSize
    \mutex = CreateMutex()
    \maxThreads = 1
  EndWith
 
  Procedure SetBalanceMethod(Method = #BalanceMethod_QueueSize)
    With gWorkerThreads
      \balanceMethod = Method
    EndWith
  EndProcedure
 
  Procedure SetMaximumThreads(Maximum)
    If Maximum > 0
      gWorkerThreads\maxThreads = Maximum
    EndIf
  EndProcedure
 
  Procedure GetWorkerTotalCost()
    Protected.i cost
    With gWorkerThreads\worker()
      ForEach \tasks()
        cost = cost + \tasks()\cost
      Next
    EndWith
    ProcedureReturn cost
  EndProcedure
 
  Procedure AddEvent(evtType, evtTaskID)
    With gWorkerThreads
      If \trackEvents = #True
        If ListSize(\eventQueue()) < #MaximumEvents
          LastElement(\eventQueue())
          AddElement(\eventQueue())
          \eventQueue()\eventType = evtType
          \eventQueue()\taskID = evtTaskID
        EndIf
      EndIf
    EndWith     
  EndProcedure
 
  Procedure TrackEvents(State = #True)
    If State
      gWorkerThreads\trackEvents = #True
    Else
      gWorkerThreads\trackEvents = #False
    EndIf
  EndProcedure
 
  Procedure GetEvent()
    With gWorkerThreads
      LockMutex(\mutex)
      If ListSize(\eventQueue()) > 0
        FirstElement(\eventQueue())
        \currentEvent\eventType = \eventQueue()\eventType
        \currentEvent\taskID = \eventQueue()\taskID
        DeleteElement(\eventQueue())
      Else
        \currentEvent\eventType = #Event_None
        \currentEvent\taskID = 0
      EndIf
      UnlockMutex(\mutex)
      ProcedureReturn \currentEvent\eventType
    EndWith
  EndProcedure
 
  Procedure EventTaskID()
    With gWorkerThreads
      ProcedureReturn \currentEvent\taskID
    EndWith
  EndProcedure
 
  Procedure AddTask(ID, Type, *TaskData, *TaskHandler.pTaskHandler, TaskCost = #TaskCost_Medium)
    With gWorkerThreads
      LockMutex(\mutex)
      If ListSize(\worker()) < \maxThreads
        AddElement(\worker())
        \worker()\workerIndex = ListIndex(\worker())
        LastElement(\worker()\tasks())
        AddElement(\worker()\tasks())
        \worker()\tasks()\taskInfo\WorkerID = \worker()\workerIndex
        \worker()\tasks()\taskInfo\ID = ID
        \worker()\tasks()\taskInfo\Type = Type
        \worker()\tasks()\taskInfo\UserData = *TaskData
        \worker()\tasks()\cost = TaskCost
        \worker()\tasks()\pending = #True
        \worker()\tasks()\handler = *TaskHandler
      Else
        Define ix.i, minCount.i = 1000000, bestWorker.i, cost.i, workers.i
        If \maxThreads < ListSize(\worker())
          workers = \maxThreads
        Else
          workers = ListSize(\worker())
        EndIf       
        For ix = 0 To workers - 1
          SelectElement(\worker(), ix)
          Select \balanceMethod
            Case #BalanceMethod_QueueSize
              If ListSize(\worker()\tasks()) < minCount
                minCount = ListSize(\worker()\tasks())
                bestWorker = ix
              EndIf
            Case #BalanceMethod_QueueCost
              cost = GetWorkerTotalCost()
              If cost < minCount
                minCount = cost
                bestWorker = ix
              EndIf
          EndSelect
        Next
        SelectElement(\worker(), bestWorker)
        LastElement(\worker()\tasks())
        AddElement(\worker()\tasks())
        \worker()\tasks()\taskInfo\WorkerID = \worker()\workerIndex
        \worker()\tasks()\taskInfo\ID = ID
        \worker()\tasks()\taskInfo\Type = Type
        \worker()\tasks()\taskInfo\UserData = *TaskData
        \worker()\tasks()\cost = TaskCost
        \worker()\tasks()\pending = #True
        \worker()\tasks()\handler = *TaskHandler       
      EndIf
      UnlockMutex(\mutex)
    EndWith
  EndProcedure
 
  Procedure Update()
    With gWorkerThreads
      LockMutex(\mutex)
      ForEach \worker()
        If ListSize(\worker()\tasks()) > 0
          FirstElement(\worker()\tasks())
          If \worker()\tasks()\pending
            \worker()\tasks()\pending = #False
            AddEvent(#Event_TaskStarted, \worker()\tasks()\taskInfo\ID)
            \worker()\tasks()\thread = CreateThread(\worker()\tasks()\handler, @\worker()\tasks()\taskInfo)
          Else
            If IsThread(\worker()\tasks()\thread) = 0
              AddEvent(#Event_TaskEnded, \worker()\tasks()\taskInfo\ID)
              DeleteElement(\worker()\tasks())
            EndIf
          EndIf
        EndIf
      Next
      UnlockMutex(\mutex)
    EndWith
  EndProcedure
 
  Procedure TasksRemaining()
    Protected.i count
    With gWorkerThreads
      LockMutex(\mutex)
      ForEach \worker()
        count = count + ListSize(\worker()\tasks())
      Next
      UnlockMutex(\mutex)
    EndWith
    ProcedureReturn count
  EndProcedure
 
  Procedure ClearPending()
    With gWorkerThreads
      LockMutex(\mutex)
      ForEach \worker()
        ForEach \worker()\tasks()
          If \worker()\tasks()\pending
            DeleteElement(\worker()\tasks())
          EndIf
        Next
      Next
      UnlockMutex(\mutex)
    EndWith
  EndProcedure
 
  Procedure TerminateAll()
    With gWorkerThreads
      LockMutex(\mutex)
      ForEach \worker()
        ForEach \worker()\tasks()
          If \worker()\tasks()\pending = #False
            If IsThread(\worker()\tasks()\thread)
              KillThread(\worker()\tasks()\thread)
            EndIf
          EndIf
        Next
        ClearList(\worker()\tasks())
      Next
      UnlockMutex(\mutex)
    EndWith
  EndProcedure
 
EndModule

CompilerIf #PB_Compiler_IsMainFile
 
  ; ========= EXAMPLE =========
 
  ; Make sure only 10 threads run at the same time (It will be 1 by default)
  WorkerThreads::SetMaximumThreads(10)
 
  ; Define a Worker procedure
  Procedure TestWorker(*Worker.WorkerThreads::sTaskInfo)
    With *Worker
      Debug "Task " + Str(\ID) + " started on worker " + Str(\WorkerID)
     
      Select *Worker\Type
        Case WorkerThreads::#TaskCost_Minimal
          Delay(Random(500))
        Case WorkerThreads::#TaskCost_Medium
          Delay(Random(1000))
        Case WorkerThreads::#TaskCost_High
          Delay(Random(2000))
        Case WorkerThreads::#TaskCost_Heavy
          Delay(Random(3000))
      EndSelect
     
      Debug "Task " + Str(\ID) + " finished on worker " + Str(\WorkerID) + ". Total tasks remaining: " + Str(WorkerThreads::TasksRemaining() - 1)
    EndWith
  EndProcedure
 
  ; Distribute tasks across workers depending on cost, not worker queue size
  WorkerThreads::SetBalanceMethod(WorkerThreads::#BalanceMethod_QueueCost)
 
  ; Create some tasks to queue, setting a random task cost.
  Define.i W, Cost
  For W = 1 To 40
    Cost = Random(WorkerThreads::#TaskCost_Heavy)
    WorkerThreads::AddTask(W, Cost, #Null, @TestWorker(), Cost)
  Next
 
  ; Enable Event Tracking
  WorkerThreads::TrackEvents(#True)
 
  ; Main loop - Handle until no tasks remain
  While WorkerThreads::TasksRemaining() > 0
    WorkerThreads::Update()
   
    ; Event Handling
    Select WorkerThreads::GetEvent()
      Case WorkerThreads::#Event_TaskStarted
        Debug "[Event] Task " + Str(WorkerThreads::EventTaskID()) + " has started."
      Case WorkerThreads::#Event_TaskEnded
        Debug "[Event] Task " + Str(WorkerThreads::EventTaskID()) + " has ended."
    EndSelect
   
    Delay(1)
  Wend
 
CompilerEndIf
