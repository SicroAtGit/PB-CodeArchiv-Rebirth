;   Description: Provides functions to create one-instance only programs
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?p=468905#p468905
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

;======================================================================
; Module:          OnlyOne.pbi
;
; Author:          Thomas (ts-soft) Schulz
; Date:            Aug 13, 2015
; Version:         1.2a
;                  (handling of current directory added by Little John;
;                   tested on Windows 10)
; Target Compiler: PureBasic 5.2+
; Target OS:       All
; License:         Free, unrestricted, no warranty whatsoever
;                  Use at your own risk
; URL:             http://www.purebasic.fr/english/viewtopic.php?p=468905#p468905
;======================================================================


DeclareModule OnlyOne
   EnableExplicit
   
   Declare.i InitOne(wID,                                       ; ID of the main window.
                     OnlyOneName.s,                             ; Unique name for Lockfile.
                     CustomEvent = #PB_Event_FirstCustomValue,  ; User-defined event in which the parameters are processed.
                     TimerID = 1,                               ; TimerID to use.
                     TimeOut = 2000)                            ; Interval in ms, to check the passed parameter queries.
   
   Declare.i ReleaseOne()                                       ; Delete LockFile and removes Timer.
   
   Declare.s GetCurDir()
   
   Declare.s GetParameters()                                    ; The parameter string, separated with #LF$
EndDeclareModule


Module OnlyOne
   Global.i Event, win, timer
   Global.s LockFile, Paras
   
   
   Procedure TimerCB()
      Static oldtime = 0
      If oldtime = 0 : oldtime = Date() : EndIf
      Protected FF, time
     
      If FileSize(LockFile) > 0
         FF = ReadFile(#PB_Any, LockFile)
         If FF
            Paras = ""
            While Not Eof(FF)
               Paras + ReadString(FF) + #LF$
            Wend
            CloseFile(FF)
            FF = CreateFile(#PB_Any, LockFile)
            If FF
               CloseFile(FF)
            EndIf
            PostEvent(Event)
         EndIf
         CompilerSelect #PB_Compiler_OS
            CompilerCase #PB_OS_Windows
            CompilerDefault
            Else
               time = AddDate(oldtime, #PB_Date_Minute, 3)
               If time < Date()
                  oldtime = Date()
                  SetFileDate(LockFile, #PB_Date_Modified, Date())
               EndIf
         CompilerEndSelect
      EndIf
   EndProcedure
   
   
   Procedure.i ReleaseOne()
      RemoveWindowTimer(win, timer)
      UnbindEvent(#PB_Event_Timer, @TimerCB(), win, timer)
      ProcedureReturn DeleteFile(LockFile)
   EndProcedure
   
   
   Procedure.s GetCurDir()
      Protected f.i
     
      f = FindString(Paras, #LF$)
      ProcedureReturn Left(Paras, f-1)
   EndProcedure
   
   
   Procedure.s GetParameters()
      Protected f.i
     
      f = FindString(Paras, #LF$)
      ProcedureReturn Mid(Paras, f+1)
   EndProcedure
   
   
   Procedure InitOne(wID, OnlyOneName.s, CustomEvent = #PB_Event_FirstCustomValue, TimerID = 1, TimeOut = 2000)
      Protected.i FF, i, j, time, result = #False
     
      If Not IsWindow(wID)
         Debug "You have to open a window, before you call this function!"
         ProcedureReturn #False
      EndIf
      win = wID
      timer = TimerID
      Event = CustomEvent
      LockFile = GetTemporaryDirectory() + OnlyOneName
     
      CompilerSelect #PB_Compiler_OS
         CompilerCase #PB_OS_Windows
            Protected Mutex = CreateMutex_(0, 0, OnlyOneName)
            If GetLastError_() = #ERROR_ALREADY_EXISTS
               ReleaseMutex_(Mutex)
               CloseHandle_(Mutex)
            Else
               DeleteFile(LockFile)
            EndIf
         CompilerDefault
            time = AddDate(GetFileDate(LockFile, #PB_Date_Modified), #PB_Date_Minute, 5)
            If time < Date()
               DeleteFile(LockFile)
            EndIf
      CompilerEndSelect
     
      If FileSize(LockFile) = -1
         FF = CreateFile(#PB_Any, LockFile)
         If FF
            CloseFile(FF)
            AddWindowTimer(wID, TimerID, TimeOut)
            BindEvent(#PB_Event_Timer, @TimerCB(), wID, TimerID)
            Paras = ""
            j = CountProgramParameters()
            For i = 0 To j
               Paras + ProgramParameter(i) + #LF$
            Next
            Paras = GetCurrentDirectory() + #LF$ +
                    Left(Paras, Len(Paras) - 1)
            PostEvent(Event)
            HideWindow(wID, #False)
            result = #True
         EndIf
      Else
         FF = OpenFile(#PB_Any, LockFile, #PB_File_Append)
         If FF
            Paras = ""
            j = CountProgramParameters()
            For i = 1 To j
               Paras + ProgramParameter(i-1) + #LF$
            Next
            Paras = GetCurrentDirectory() + #LF$ +
                    Left(Paras, Len(Paras) - 1)
            WriteStringN(FF, Paras)
            CloseFile(FF)
         EndIf
         End
      EndIf
     
      ProcedureReturn result
   EndProcedure
EndModule


CompilerIf #PB_Compiler_IsMainFile
   EnableExplicit
   
   Enumeration #PB_Event_FirstCustomValue
      #Event_NewParams
   EndEnumeration
   
   OpenWindow(0, #PB_Ignore, #PB_Ignore, 640, 480, "Test", #PB_Window_MinimizeGadget|#PB_Window_Invisible)
   ListViewGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 20)
   OnlyOne::InitOne(0, "Example_Application", #Event_NewParams)
   
   Define i, j, paras.s
   
   Repeat
      Select WaitWindowEvent()
         Case #PB_Event_CloseWindow
            OnlyOne::ReleaseOne()
            Break
           
         Case #Event_NewParams
            SetActiveWindow(0)
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
               ShowWindow_(WindowID(0), #SW_RESTORE)
               SetForegroundWindow_(WindowID(0))
            CompilerEndIf
            AddGadgetItem(0, -1, OnlyOne::GetCurDir())
            paras = OnlyOne::GetParameters()
            j = CountString(paras, #LF$)
            For i = 1 To j
               AddGadgetItem(0, -1, StringField(paras, i, #LF$))
            Next
      EndSelect
   ForEver
CompilerEndIf
