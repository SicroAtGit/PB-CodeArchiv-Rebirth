;   Description: Base for service program - IMPORTANT READ THE THREAD!
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=25667
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 mk-soft
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

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf

;- TOP

; Comment: MySerive Base Program
; Author1: ?
; Author2: mk-soft
; Version: v1.05

; Install Service 'Servicename.exe install or /i'
; Uninstall Service 'Servicename.exe uninstall or /u'

;- Konstanten

EnableExplicit

#SERVICE_WIN32_OWN_PROCESS = $10
#SERVICE_WIN32_SHARE_PROCESS = $20
#SERVICE_WIN32 = #SERVICE_WIN32_OWN_PROCESS + #SERVICE_WIN32_SHARE_PROCESS
#SERVICE_ACCEPT_STOP = $1
#SERVICE_ACCEPT_PAUSE_CONTINUE = $2
#SERVICE_ACCEPT_SHUTDOWN = $4
#SC_MANAGER_CONNECT = $1
#SC_MANAGER_CREATE_SERVICE = $2
#SC_MANAGER_ENUMERATE_SERVICE = $4
#SC_MANAGER_LOCK = $8
#SC_MANAGER_QUERY_LOCK_STATUS = $10
#SC_MANAGER_MODIFY_BOOT_CONFIG = $20

#STANDARD_RIGHTS_REQUIRED = $F0000
#SERVICE_QUERY_CONFIG = $1
#SERVICE_CHANGE_CONFIG = $2
#SERVICE_QUERY_STATUS = $4
#SERVICE_ENUMERATE_DEPENDENTS = $8
#SERVICE_START = $10
#SERVICE_STOP = $20
#SERVICE_PAUSE_CONTINUE = $40
#SERVICE_INTERROGATE = $80
#SERVICE_USER_DEFINED_CONTROL = $100
#SERVICE_ALL_ACCESS2 = #STANDARD_RIGHTS_REQUIRED | #SERVICE_QUERY_CONFIG | #SERVICE_CHANGE_CONFIG | #SERVICE_QUERY_STATUS | #SERVICE_ENUMERATE_DEPENDENTS | #SERVICE_START | #SERVICE_STOP | #SERVICE_PAUSE_CONTINUE | #SERVICE_INTERROGATE |#SERVICE_USER_DEFINED_CONTROL
#SERVICE_INTERACTIVE_PROCESS = $100

#SERVICE_AUTO_START = $2
#SERVICE_DEMAND_START = $3

#SERVICE_ERROR_NORMAL = $1

; SERVICE_CONTROL
#SERVICE_CONTROL_STOP = $1
#SERVICE_CONTROL_PAUSE = $2
#SERVICE_CONTROL_CONTINUE = $3
#SERVICE_CONTROL_INTERROGATE = $4
#SERVICE_CONTROL_SHUTDOWN = $5


; SERVICE_STATE
#SERVICE_STOPPED = $1
#SERVICE_START_PENDING = $2
#SERVICE_STOP_PENDING = $3
#SERVICE_RUNNING = $4
#SERVICE_CONTINUE_PENDING = $5
#SERVICE_PAUSE_PENDING = $6
#SERVICE_PAUSED = $7

#SERVICE_USERDATA_128 = 128
#SERVICE_USERDATA_129 = 129
#SERVICE_USERDATA_130 = 130
#SERVICE_USERDATA_131 = 131

;- Structuren

;- IncludeFile´s

;- Global Variables
Global ServiceStatus.SERVICE_STATUS
Global hServiceStatus.i
Global AppPath.s
Global AppPathName.s
Global AppPathLog.s
Global Finish.i
Global *UserData
Global SERVICE_NAME.s
Global SERVICE_DESCRIPTION.s
Global SERVICE_STARTNAME.s
Global SERVICE_PASSWORD.s

Global MutexLog
Global thCommand
Global hThread

;- Declare Function´s
Declare svHandler(fdwControl.i)
Declare svServiceMain(dwArgc.i, lpszArgv.i)

Declare svInit()
Declare svPause()
Declare svContinue()
Declare svInterrogate()
Declare svStop()
Declare svShutdown()
Declare svUserdata128()
Declare svUserdata129()
Declare svUserdata130()
Declare svUserdata131()
Declare WriteLog(Text.s)
Declare thMain(id)

; *************************************************************************************************

Procedure.s FormatMessage(Errorcode)
  
  Protected *Buffer, len, result.s
  
  len = FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER|#FORMAT_MESSAGE_FROM_SYSTEM,0,Errorcode,0,@*Buffer,0,0)
  If len
    result = PeekS(*Buffer, len)
    LocalFree_(*Buffer)
    ProcedureReturn result
  Else
    ProcedureReturn "Errorcode: " + Hex(Errorcode)
  EndIf
  
EndProcedure

; *************************************************************************************************

Procedure.s GetSpecialFolder(iCSIDL)
  Protected sPath.s = Space(#MAX_PATH)
  If SHGetSpecialFolderPath_(#Null, @sPath, iCSIDL, 0) = #True
    ProcedureReturn sPath
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

; *************************************************************************************************

Procedure.s CreateLogFolder(name.s)
  
  Protected path.s
  
  path = GetSpecialFolder(#CSIDL_COMMON_APPDATA)
  If Right(path, 1) <> "\"
    path + "\"
  EndIf
  path + name + "\"
  
  CreateDirectory(path)
  ;MakeSureDirectoryPathExists_(path)
  
  ProcedureReturn path
  
EndProcedure

; *************************************************************************************************

Procedure MyWriteLog(Text.s)
  
  If OpenFile(0, AppPathLog)
    FileSeek(0, Lof(0))
    WriteStringN(0, FormatDate("%YYYY-%MM-%DD %HH:%II:%SS : ",Date()) + Text)
    CloseFile(0)
  EndIf
EndProcedure

Macro WriteLog(text)
  LockMutex(MutexLog) : MyWriteLog(text) : UnlockMutex(MutexLog)
EndMacro

; *************************************************************************************************

Procedure svMain()
  
  Protected hSCManager.i
  Protected hService.i
  Protected ServiceTableEntry.SERVICE_TABLE_ENTRY
  Protected lpServiceStatus.SERVICE_STATUS
  Protected lpInfo
  Protected b.i
  Protected cmd.s
  Protected result
  
  ;Change SERVICE_NAME and app name as needed
  ;-- Service name
  SERVICE_NAME = "MyService"
  ;-- Service description
  SERVICE_DESCRIPTION = "MyService Test"
  
  ;-- Service startname
  ;--- LocalSystem account (Default)
  SERVICE_STARTNAME = "" ; NULL
  SERVICE_PASSWORD = ""  ; Null
  
  ;--- LocalService account
  ;   SERVICE_STARTNAME = "NT AUTHORITY\LocalService"
  ;   SERVICE_PASSWORD = ""
  
  ;--- NetworkService account
  ;   SERVICE_STARTNAME = "NT AUTHORITY\NetworkService"
  ;   SERVICE_PASSWORD = ""
  
  ;--- DomainName\UserName or .\Username account
  ;   SERVICE_STARTNAME = ".\username"
  ;   SERVICE_PASSWORD = "password"
  
  AppPathName.s = Space(1023)
  GetModuleFileName_(0, AppPathName, 1023)
  
  cmd = Trim(LCase(ProgramParameter()))
  
  Select cmd
      
    Case "install", "/i" ;Install service on machine
      
      Repeat
        result = 0
        hSCManager = OpenSCManager_(0, 0, #SC_MANAGER_CREATE_SERVICE)
        If hSCManager = #Null
          result = GetLastError_()
          Break
        EndIf
        If SERVICE_STARTNAME
          hService = CreateService_(hSCManager, SERVICE_NAME, SERVICE_NAME, #SERVICE_ALL_ACCESS2, #SERVICE_WIN32_OWN_PROCESS, #SERVICE_AUTO_START, #SERVICE_ERROR_NORMAL, AppPathName, 0, 0, 0, SERVICE_STARTNAME, SERVICE_PASSWORD)
        Else ; Local service
          hService = CreateService_(hSCManager, SERVICE_NAME, SERVICE_NAME, #SERVICE_ALL_ACCESS2, #SERVICE_INTERACTIVE_PROCESS | #SERVICE_WIN32_OWN_PROCESS, #SERVICE_AUTO_START, #SERVICE_ERROR_NORMAL, AppPathName, 0, 0, 0, 0, 0)
        EndIf
        
        If hService = #Null
          result = GetLastError_()
          Break
        EndIf
        lpInfo = @SERVICE_DESCRIPTION
        ChangeServiceConfig2_(hService, #SERVICE_CONFIG_DESCRIPTION, @lpInfo)
      Until #True
      
      If hService
        CloseServiceHandle_(hService)
      EndIf
      If hSCManager
        CloseServiceHandle_(hSCManager)
      EndIf
      
      If result
        MessageRequester("Fehler", "Service nicht installiert! " + FormatMessage(result), #MB_ICONSTOP)
      EndIf
      
      finish = 1
      
    Case "uninstall", "/u" ;Remove service from machine
      
      Repeat
        result = 0
        hSCManager = OpenSCManager_(0, 0, #SC_MANAGER_CREATE_SERVICE)
        If hSCManager = #Null
          result = GetLastError_()
          Break
        EndIf
        hService = OpenService_(hSCManager, SERVICE_NAME, #SERVICE_ALL_ACCESS)
        If hService = #Null
          result = GetLastError_()
          Break
        EndIf
        If QueryServiceStatus_(hService, lpServiceStatus) = #Null
          result = GetLastError_()
          Break
        EndIf
        If lpServiceStatus\dwCurrentState <> #SERVICE_STOPPED
          result = #ERROR_SERVICE_ALREADY_RUNNING
          Break
        EndIf
        If DeleteService_(hService) = #Null
          result = GetLastError_()
          Break
        EndIf
        
      Until #True
      
      If hService
        CloseServiceHandle_(hService)
      EndIf
      If hSCManager
        CloseServiceHandle_(hSCManager)
      EndIf
      
      If result
        MessageRequester("Fehler", "Service nicht deinstalliert! " + FormatMessage(result), #MB_ICONSTOP)
      EndIf
      
      finish = 1
      
    Default
      ;Start the service
      ServiceTableEntry\lpServiceName = @SERVICE_NAME
      ServiceTableEntry\lpServiceProc = @svServiceMain()
      b = StartServiceCtrlDispatcher_(@ServiceTableEntry)
      
      If b = 0
        Finish = 1
      EndIf
  EndSelect
  
  Repeat
    Delay(100)
  Until Finish = 1
  
  End
  
EndProcedure

; *************************************************************************************************

Procedure svHandler(fdwControl.i)
  
  Protected b.i
  
  Select fdwControl
    Case #SERVICE_CONTROL_PAUSE
      
      ;** Do whatever it takes To pause here.
      If svPause()
        ServiceStatus\dwCurrentState = #SERVICE_PAUSED
      EndIf
      
    Case #SERVICE_CONTROL_CONTINUE
      
      ;** Do whatever it takes To continue here.
      If svContinue()
        ServiceStatus\dwCurrentState = #SERVICE_RUNNING
      EndIf
      
    Case #SERVICE_CONTROL_STOP
      ServiceStatus\dwWin32ExitCode = 0
      ServiceStatus\dwCurrentState = #SERVICE_STOP_PENDING
      ServiceStatus\dwCheckPoint = 0
      ServiceStatus\dwWaitHint = 0 ;Might want a time estimate
      b = SetServiceStatus_(hServiceStatus, ServiceStatus)
      
      ;** Do whatever it takes to stop here.
      If svStop()
        Finish = 1
        ServiceStatus\dwCurrentState = #SERVICE_STOPPED
      EndIf
      
    Case #SERVICE_CONTROL_INTERROGATE
      
      ;Fall through To send current status.
      svInterrogate()
      
      
    Case #SERVICE_CONTROL_SHUTDOWN
      ServiceStatus\dwWin32ExitCode = 0
      ServiceStatus\dwCurrentState = #SERVICE_STOP_PENDING
      ServiceStatus\dwCheckPoint = 0
      ServiceStatus\dwWaitHint = 0 ;Might want a time estimate
      b = SetServiceStatus_(hServiceStatus, ServiceStatus)
      
      ;** Do whatever it takes to stop here.
      If svShutdown()
        Finish = 1
        ServiceStatus\dwCurrentState = #SERVICE_STOPPED
      EndIf
      
    Case #SERVICE_USERDATA_128
      svUserdata128()
      
    Case #SERVICE_USERDATA_129
      svUserdata129()
      
    Case #SERVICE_USERDATA_130
      svUserdata130()
      
    Case #SERVICE_USERDATA_131
      svUserdata131()
      
  EndSelect
  
  ;Send current status.
  b = SetServiceStatus_(hServiceStatus, ServiceStatus)
EndProcedure

; *************************************************************************************************

Procedure svServiceMain(dwArgc.i, lpszArgv.i)
  
  Protected b.i
  
  ;Set initial state
  ServiceStatus\dwServiceType = #SERVICE_WIN32_OWN_PROCESS
  ServiceStatus\dwCurrentState = #SERVICE_START_PENDING
  ServiceStatus\dwControlsAccepted = #SERVICE_ACCEPT_STOP | #SERVICE_ACCEPT_PAUSE_CONTINUE | #SERVICE_ACCEPT_SHUTDOWN
  ServiceStatus\dwWin32ExitCode = 0
  ServiceStatus\dwServiceSpecificExitCode = 0
  ServiceStatus\dwCheckPoint = 0
  ServiceStatus\dwWaitHint = 0
  
  hServiceStatus = RegisterServiceCtrlHandler_(SERVICE_NAME, @svHandler())
  ServiceStatus\dwCurrentState = #SERVICE_START_PENDING
  b = SetServiceStatus_(hServiceStatus, ServiceStatus)
  
  ;** Do Initialization Here
  If svInit()
    ServiceStatus\dwCurrentState = #SERVICE_RUNNING
    b = SetServiceStatus_(hServiceStatus, ServiceStatus)
  Else
    ServiceStatus\dwCurrentState = #SERVICE_STOP_PENDING
    b = SetServiceStatus_(hServiceStatus, ServiceStatus)
    ServiceStatus\dwCurrentState = #SERVICE_STOPPED
    b = SetServiceStatus_(hServiceStatus, ServiceStatus)
    Finish = 1
  EndIf
  
  ;** Perform tasks -- If none exit
  
  ;** If an error occurs the following should be used for shutting
  ;** down:
  ; SetServerStatus SERVICE_STOP_PENDING
  ; Clean up
  ; SetServerStatus SERVICE_STOPPED
  
EndProcedure

; *************************************************************************************************

Procedure svInit()
  
  Protected path.s
  
  ; Create folder for logs
  AppPathLog = CreateLogFolder(SERVICE_NAME)
  AppPathLog + "MyLogs.log"
  
  ; Create mutex for logs
  MutexLog = CreateMutex()
  
  WriteLog("Service Start")
  
  thCommand = #SERVICE_START
  hThread = CreateThread(@thMain(), 0)
  
  If hThread
    ProcedureReturn 1
  Else
    WriteLog("Service Start - Error: Start Thread")
    thCommand = 0
    ProcedureReturn 0
  EndIf
  
EndProcedure

; *************************************************************************************************

Procedure svPause()
  
  Protected ctime
  
  WriteLog("Service Pause")
  
  thCommand = #SERVICE_CONTROL_PAUSE
  Repeat
    If Not IsThread(hThread)
      Break
    EndIf
    ctime + 1
    If ctime > 10
      WriteLog("Service Pause - Error: Killed Thread")
      KillThread(hThread)
      Break
    EndIf
    Delay(1000)
  ForEver
  
  thCommand = 0
  hThread = 0
  
  ProcedureReturn 1
  
EndProcedure

; *************************************************************************************************

Procedure svContinue()
  
  WriteLog("Service Continue")
  
  thCommand = #SERVICE_CONTROL_CONTINUE
  hThread = CreateThread(@thMain(), 0)
  
  If hThread
    ProcedureReturn 1
  Else
    WriteLog("Service Continue - Error: Start Thread")
    thCommand = 0
    ProcedureReturn 0
  EndIf
  
EndProcedure

; *************************************************************************************************

Procedure svStop()
  
  Protected ctime
  
  WriteLog("Service Stop")
  
  thCommand = #SERVICE_CONTROL_STOP
  Repeat
    If Not IsThread(hThread)
      Break
    EndIf
    ctime + 1
    If ctime > 10
      WriteLog("Service Stop - Error: Killed Thread")
      KillThread(hThread)
      Break
    EndIf
    Delay(1000)
  ForEver
  
  thCommand = 0
  hThread = 0
  
  ProcedureReturn 1
  
EndProcedure

; *************************************************************************************************

Procedure svInterrogate()
  
  WriteLog("Service Interrogate")
  
  ProcedureReturn 1
  
EndProcedure

; *************************************************************************************************

Procedure svShutdown()
  
  Protected ctime
  
  WriteLog("Service Shutdown")
  
  thCommand = #SERVICE_CONTROL_SHUTDOWN
  Repeat
    If Not IsThread(hThread)
      Break
    EndIf
    ctime + 1
    If ctime > 10
      WriteLog("Service Shutdown - Error: Killed Thread")
      KillThread(hThread)
      Break
    EndIf
    Delay(1000)
  ForEver
  
  thCommand = 0
  hThread = 0
  
  ProcedureReturn 1
  
EndProcedure

; *************************************************************************************************

Procedure svUserdata128()
  
EndProcedure

; *************************************************************************************************

Procedure svUserdata129()
  
EndProcedure

; *************************************************************************************************

Procedure svUserdata130()
  
EndProcedure

; *************************************************************************************************

Procedure svUserdata131()
  
EndProcedure

; *************************************************************************************************

;- Thread main

Procedure thMain(id)
  
  ; Global code for init
  WriteLog("Thread - Init")
  
  Repeat
    Select thCommand
      Case #SERVICE_START
        thCommand = 0
        ; Code for start
        WriteLog("Thread - Start")
        
      Case #SERVICE_CONTROL_CONTINUE
        thCommand = 0
        ; Code for contine
        WriteLog("Thread - Continue")
        
      Case #SERVICE_CONTROL_PAUSE
        thCommand = 0
        ; Code for pause before exit
        WriteLog("Thread - Pause")
        
        Break
        
      Case #SERVICE_CONTROL_STOP
        thCommand = 0
        ; Code for stop before exit
        WriteLog("Thread - Stop")
        
        Break
        
      Case #SERVICE_CONTROL_SHUTDOWN
        thCommand = 0
        ; Code for shutdown before exit
        WriteLog("Thread - Shutdown")
        
        Break
        
      Default
        ; Any cycle code
        Delay(100)
        
    EndSelect
    
  ForEver
  
  ; Global code for exit
  WriteLog("Thread - Exit")
  
EndProcedure

; *************************************************************************************************

svMain()
