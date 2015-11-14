; Description: Read PC-Sensor-data with the Aida64-Api
; Author: Bisonte
; Date: 03-11-2015
; PB-Version: 5,40
; OS: Windows
; English-Forum: 
; French-Forum: 
; German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29241
;-----------------------------------------------------------------------------


;: ############################################################################
;: #
;: # Module     : Aida64
;: #
;: # Author     : Bisonte
;: # Date       : 02. November 2015
;: # COpt.      : THREAD
;: # PB Version : 5.40 LTS Final
;: #
;: ############################################################################
;:
;: To get the SharedMemory SensorData of Aida64
;: Req. CompilerOption Threadsafe
;: and, of course, Aida64 with Shared Memory enabled
;: (and some sensors marked)
;:
;: Tested with Aida64 Extrem on Win10 Pro x64
;: The Demo shows CPU Package Temperature and CPU Utilization if marked
;: in Aida64

DeclareModule Aida64
  
  EnableExplicit
  
  #AIDA64_SensorValues = "AIDA64_SensorValues"
  
  Structure aida_sensordata
    category.s
    id.s
    label.s
    value.s
  EndStructure
  
  Global NewList Aida64Sensor.aida_sensordata()
  
  Declare.i StartAida64(Delay = 1000, CustomEvent = #PB_Event_FirstCustomValue)
  Declare.i StopAida64()
  Declare.s GetSensorValueOverID(ID.s)
  Declare.s GetSensorValueOverLabel(Label.s)
  
EndDeclareModule
Module        Aida64
  
  CompilerIf Not #PB_Compiler_Thread
    CompilerError "Module : 'Aida64' requires ThreadSafe Compileroption!"
  CompilerEndIf 
  
  Global Mutex = CreateMutex()
  Global Thread = #False
  Global Halt   = #False
  Global CEvent = #PB_Event_FirstCustomValue
  
  Procedure.s _GetString(String.s, Before.s, After.s)
    
    Protected Result.s
    Protected Start, Stop
    
    Start = FindString(String, Before)
    Stop  = FindString(String, After)
    
    If Start > 0 And Stop > Start
      Result = Mid(String, Start + Len(Before), (Stop-Len(After)) - Start + 1) 
    EndIf
    
    ProcedureReturn Result
    
  EndProcedure 
  Procedure GetAidaSensorList(Delay)
    
    Protected handle, *Mem, Size, Result.s, String.s
    
    While Halt <> #True
      
      LockMutex(mutex)
      
      ClearList(Aida64Sensor())
      
      handle = OpenFileMapping_(#FILE_MAP_ALL_ACCESS, 0, "AIDA64_SensorValues")
      If handle
        *Mem = MapViewOfFile_(handle, #FILE_MAP_ALL_ACCESS, 0, 0, 0)
        If *Mem
          Size = MemoryStringLength(*Mem, #PB_Ascii)
          Result = PeekS(*Mem, Size, #PB_Ascii)
          While Result <> ""
            String = Left(Result, FindString(Result, ">"))
            String + _GetString(Result, Left(Result, FindString(Result, ">")), "</" + Mid(Left(Result, FindString(Result, ">")), 2))
            String + "</" + Mid(Left(Result, FindString(Result, ">")), 2)
            AddElement(Aida64Sensor())
            Aida64Sensor()\category = Left(String, FindString(String, ">"))
            Aida64Sensor()\id  = _GetString(String, "<id>", "</id>")
            Aida64Sensor()\label = _GetString(String, "<label>", "</label>")
            Aida64Sensor()\value = _GetString(String, "<value>", "</value>")
            Result = Mid(Result, Len(String) + 1)
          Wend
          UnmapViewOfFile_(*Mem)
        EndIf
        CloseHandle_(handle)
      EndIf
      
      UnlockMutex(mutex)
      
      PostEvent(CEvent)
      
      Delay(Delay)
      
    Wend
    
  EndProcedure
  Procedure StartAida64(Delay = 1000, CustomEvent = #PB_Event_FirstCustomValue)
    
    Protected Result
    
    If IsThread(Thread) : Halt = #True : EndIf
    
    CEvent = CustomEvent
    Thread = CreateThread(@GetAidaSensorList(), Delay)
    If Thread
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
    
  EndProcedure
  Procedure StopAida64()
    If IsThread(Thread) : Halt = #True : EndIf
  EndProcedure
  
  Procedure.s GetSensorValueOverID(ID.s)
    Protected Result.s
    ForEach Aida64Sensor()
      If Aida64Sensor()\id = ID
        Result = Aida64Sensor()\value
        Break
      EndIf
    Next
    ProcedureReturn Result
  EndProcedure
  Procedure.s GetSensorValueOverLabel(Label.s)
    Protected Result.s
    ForEach Aida64Sensor()
      If Aida64Sensor()\label = Label
        Result = Aida64Sensor()\value
        Break
      EndIf
    Next
    ProcedureReturn Result
  EndProcedure 
  
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  #AIDA64_DataReady = #PB_Event_FirstCustomValue
  
  Define Event, CPUTEMP, CPUUTIL
  
  OpenWindow(0, 0, 0, 100, 150, "Aida64", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  CanvasGadget(1, 10, 10, 50, 100)
  TextGadget(2, 10, 110, 20, 25, "", #PB_Text_Center)
  TextGadget(3, 40, 110, 20, 25, "", #PB_Text_Center)
  
  Aida64::StartAida64(500, #AIDA64_DataReady)
  
  Repeat
    Event = WaitWindowEvent()
    
    Select Event
      Case #PB_Event_CloseWindow
        Aida64::StopAida64()
        Break
      Case #AIDA64_DataReady
        If StartDrawing(CanvasOutput(1))
          CPUTEMP = Val(Aida64::GetSensorValueOverID("TCPUPKG"))
          CPUUTIL = Val(Aida64::GetSensorValueOverID("SCPUUTI"))
          Box(0, 0, OutputWidth(), OutputHeight(), GetSysColor_(#COLOR_BTNFACE))
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(#Red) : FrontColor(#Green)
          LinearGradient(0, 0, 20, 100)
          Box(0, 100, 20, -CPUTEMP, 0)
          Box(30, 100, 20, -CPUUTIL, 0)
          StopDrawing()
        EndIf
        SetGadgetText(2, Str(CPUTEMP))
        SetGadgetText(3, Str(CPUUTIL) + "%")
        
    EndSelect
    
  ForEver
  
CompilerEndIf

; IDE Options = PureBasic 5.40 LTS (Windows - x64)
; CursorPosition = 7
; Folding = --
; EnableUnicode
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant