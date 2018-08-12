;   Description: Logging-Window
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29229
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 mk-soft
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

;-TOP

; ***************************************************************************************

; Comment : Modul Logging
; Author  : mk-soft
; Version : v1.02
; Created : 25.10.2015

; ***************************************************************************************

CompilerIf #PB_Compiler_Thread = 0
  CompilerError "Missing Threadsafe"
CompilerEndIf

DeclareModule Logging
  
  ; Constants
  Enumeration
    #LogEvent_Default
    #LogEvent_Ok
    #LogEvent_Warn
    #LogEvent_Alarm
  EndEnumeration
  
  ; Functions
  Declare InitLogging(GadgetID, MaxList = 1000, MaxBuffer = 2000, EventID = #PB_Event_FirstCustomValue) ; Result : LoggingID
  Declare ReleaseLogging(Logging)
  Declare LogEvent(LoggingID, Type, Text.s)
  Declare SetLogScroll(Logging, State)
  
EndDeclareModule

; ***************************************************************************************

Module Logging
  
  EnableExplicit
  
  ; Flags
  #LogFlagScroll = 1
  
  ; Colors
  #LogColor_Default = $FFF8F8
  #LogColor_Ok = $32CD32
  #LogColor_Warn = $00D7FF
  #LogColor_Alarm = $0045FF
  
  Global LastEventID
  
  Structure udtLogData
    timestamp.i
    type.i
    text.s
    maxlist.i
  EndStructure
  
  Structure udtLogCommon
    gadget.i
    type.i
    maxlist.i
    maxbuffer.i
    event.i
    mutex.i
    index.i
    flags.i
    Array buffer.udtLogData(0)
  EndStructure
  
  ; -----------------------------------------------------------------------------------
  
  Declare EventHandlerListIcon()
  Declare EventHandlerListView()
  
  ; -----------------------------------------------------------------------------------
  
  ; -----------------------------------------------------------------------------------
  
  Procedure InitLogging(GadgetID, MaxList = 1000, MaxBuffer = 2000, EventID = #PB_Event_FirstCustomValue)
    
    Protected type
    Protected *memory.udtLogCommon
    
    If IsGadget(GadgetID) = 0
      ProcedureReturn 0
    EndIf
    
    type = GadgetType(GadgetID)
    If type <> #PB_GadgetType_ListIcon And type <> #PB_GadgetType_ListView
      ProcedureReturn #False
    EndIf
    
    *memory = AllocateStructure(udtLogCommon)
    If *memory = 0
      ProcedureReturn 0
    EndIf
    
    With *memory
      \gadget = GadgetID
      \maxlist = MaxList
      \maxbuffer = MaxBuffer
      If \maxbuffer < \maxlist
        \maxbuffer = \maxlist
      EndIf
      
      Dim \buffer(\maxbuffer)
      If ArraySize(\buffer()) <> \maxbuffer
        FreeStructure(*memory)
        ProcedureReturn 0
      EndIf
      
      \mutex = CreateMutex()
      If \mutex = 0
        FreeStructure(*memory)
        ProcedureReturn 0
      EndIf
      
      If EventID = LastEventID
        \event = EventID + 1
      Else
        \event = EventID
      EndIf
      LastEventID = \event
      
      \type = type
      If \type = #PB_GadgetType_ListIcon
        BindEvent(\event, @EventHandlerListIcon())
      Else
        BindEvent(\event, @EventHandlerListView())
      EndIf
      
      \flags = #LogFlagScroll
      
    EndWith
    
    ProcedureReturn *memory
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------
  
  Procedure ReleaseLogging(LoggingID)
    
    Protected *memory.udtLogCommon = LoggingID
    
    With *memory
      If LoggingID
        If \type = #PB_GadgetType_ListIcon
          UnbindEvent(\event, @EventHandlerListIcon())
        Else
          UnbindEvent(\event, @EventHandlerListView())
        EndIf
      EndIf
    EndWith
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------
  
  Procedure LogEvent(LoggingId, Type, Text.s)
    
    Protected *memory.udtLogCommon = LoggingID
    
    If LoggingID = 0
      ProcedureReturn 0
    EndIf
    
    With *memory
      LockMutex(\mutex)
      
      If \index > \maxbuffer
        \index = 0
      EndIf
      
      \buffer(\index)\timestamp = Date()
      \buffer(\index)\type = type
      \buffer(\index)\text = text
      \buffer(\index)\maxlist = \maxlist
      PostEvent(\event, 0, \gadget, \flags, @\buffer(\index))
      \index + 1
      
      UnlockMutex(\mutex)
    EndWith
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------
  
  Procedure SetLogScroll(LoggingID, State)
    
    Protected *memory.udtLogCommon = LoggingID
    
    If LoggingID = 0
      ProcedureReturn 0
    EndIf
    
    With *memory
      
      If State
        \flags = \flags | #LogFlagScroll
      Else
        \flags = \flags & ~#LogFlagScroll
      EndIf
      
    EndWith
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------
  
  Procedure EventHandlerListIcon()
    
    Protected gadget, flags, *buffer.udtLogData, sTemp.s, c
    
    gadget = EventGadget()
    If Not IsGadget(gadget)
      ProcedureReturn 0
    EndIf
    
    flags = EventType()
    *buffer = EventData()
    If *buffer
      With *buffer
        sTemp = FormatDate("%YYYY/%MM/%DD %HH.%II.%SS", \timestamp)
        Select \type
          Case #LogEvent_Default
            sTemp + #LF$ + "Info"
          Case #LogEvent_Ok
            sTemp + #LF$ + "Ok"
          Case #LogEvent_Warn
            sTemp + #LF$ + "Warn"
          Case #LogEvent_Alarm
            sTemp + #LF$ + "Alarm"
          Default
            sTemp + #LF$ + "Other"
        EndSelect
        sTemp + #LF$ + \text
        AddGadgetItem(gadget, -1, sTemp)
        
        c = CountGadgetItems(gadget)
        If c > \maxlist
          RemoveGadgetItem(gadget, 0)
          c - 1
        EndIf
        c - 1
        
        CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
          Select \type
            Case #LogEvent_Default
              SetGadgetItemColor(gadget, c, #PB_Gadget_BackColor, #LogColor_Default)
            Case #LogEvent_Ok
              SetGadgetItemColor(gadget, c, #PB_Gadget_BackColor, #LogColor_Ok)
            Case #LogEvent_Warn
              SetGadgetItemColor(gadget, c, #PB_Gadget_BackColor, #LogColor_Warn)
            Case #LogEvent_Alarm
              SetGadgetItemColor(gadget, c, #PB_Gadget_BackColor, #LogColor_Alarm)
          EndSelect
        CompilerEndIf
        
        If flags & #LogFlagScroll
          SetGadgetState(gadget, c)
          SetGadgetState(gadget, -1)
        EndIf
        
      EndWith
      
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------
  
  Procedure EventHandlerListView()
    
    Protected gadget, flags, *buffer.udtLogData, sTemp.s, c
    
    gadget = EventGadget()
    If Not IsGadget(gadget)
      ProcedureReturn 0
    EndIf
    
    flags = EventType()
    *buffer = EventData()
    If *buffer
      With *buffer
        sTemp = FormatDate("%YYYY/%MM/%DD %HH.%II.%SS|", \timestamp)
        Select \type
          Case #LogEvent_Default
            sTemp + "Info -> "
          Case #LogEvent_Ok
            sTemp + "Ok -> "
          Case #LogEvent_Warn
            sTemp + "Warn -> "
          Case #LogEvent_Alarm
            sTemp + "Alarm -> "
          Default
            sTemp + "Other -> "
        EndSelect
        sTemp + \text
        AddGadgetItem(gadget, -1, sTemp)
        c = CountGadgetItems(gadget)
        If c > \maxlist
          RemoveGadgetItem(gadget, 0)
          c - 1
        EndIf
        c - 1
        
        If (flags & #LogFlagScroll)
          SetGadgetState(gadget, c)
          SetGadgetState(gadget, -1)
        EndIf
        
      EndWith
      
    EndIf
    
  EndProcedure
  
  ; -----------------------------------------------------------------------------------
  
EndModule

;- END

; ***************************************************************************************
;-Example
CompilerIf #PB_Compiler_IsMainFile
  
    ;XIncludeFile "Modul_Logging.pb"

    UseModule Logging

    ;- Part Declare Main

    Enumeration ;Window
      #Main
    EndEnumeration

    Enumeration ; Menu
      #Menu
    EndEnumeration

    Enumeration ; MenuItems
      #MenuExit
      #MenuStartThread
      #MenuStopThread
      #MenuStartScroll
      #MenuStopScroll
    EndEnumeration

    Enumeration ; Gadgets
      #Splitter
      #List1
      #List2
    EndEnumeration

    Enumeration ; Statusbar
      #Status
    EndEnumeration

    ; Global Variable
    Global exit, stop

    ; ***************************************************************************************

    ; Functions
    Procedure UpdateWindow()
     
      Protected x, y, dx, dy, menu, status
     
      menu = MenuHeight()
      If IsStatusBar(#Status)
        status = StatusBarHeight(#Status)
      Else
        status = 0
      EndIf
      x = 0
      y = 0
      dx = WindowWidth(#Main)
      dy = WindowHeight(#Main) - menu - status
      ResizeGadget(#Splitter, x, y, dx, dy)
     
    EndProcedure

    ; ***************************************************************************************

    ; Thread
    Procedure MyThread1(LogID)
     
      Protected c, result, text.s, time, type
     
      text = "Init Thread 1"
      LogEvent(LogID, 0, text)
     
      c = start
      Repeat
        type = Random(4)
        text = "Thread 1 Counter " + Str(c)
        LogEvent(LogID, type, text)
        c + 1
        time = Random(500, 200)
        Delay(time)
      Until stop
     
      text = "Exit Thread 1"
      LogEvent(LogID, 0, text)
     
    EndProcedure

    Procedure MyThread2(LogID)
     
      Protected c, result, text.s, time, type
     
      text = "Init Thread 2"
      LogEvent(LogID, 0, text)
     
      c = start
      Repeat
        type = Random(4)
        text = "Thread 2 Counter " + Str(c)
        LogEvent(LogID, type, text)
        c + 1
        time = 200
        Delay(time)
      Until stop
     
      text = "Exit Thread 2"
      LogEvent(LogID, 0, text)
     
    EndProcedure

    ; ***************************************************************************************

    ;- Part Main

    Procedure Main()
     
      Protected event, style, dx, dy, LogID1, LogID2
     
      style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
      dx = 800
      dy = 600
     
      If OpenWindow(#Main, #PB_Ignore, #PB_Ignore, dx, dy, "Main", style)
       
        ; Menu
        CreateMenu(#Menu, WindowID(#Main))
        MenuTitle("&File")
        MenuItem(#MenuStartThread, "Start Threads")
        MenuItem(#MenuStopThread, "Stop Threads")
        MenuBar()
        MenuItem(#MenuStartScroll, "Start AutoScroll")
        MenuItem(#MenuStopScroll, "Stop AutoScroll")
        MenuBar()
        MenuItem(#MenuExit, "E&xit")
       
        ; Gadgets
        ListIconGadget(#List1, 0, 0, 0, 0, "Date", 150)
        AddGadgetColumn(#List1, 2, "Type", 50)
        AddGadgetColumn(#List1, 3, "Text", 500)
        ListViewGadget(#List2, 0, 0, 0, 0)
        SplitterGadget(#Splitter, 0, 0, dx ,dy, #List1, #List2)
        SetGadgetState(#Splitter, dy * 2 / 3)
       
        ; Statusbar
        CreateStatusBar(#Status, WindowID(#Main))
        AddStatusBarField(#PB_Ignore)
       
        ; For Mac
        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
          ; Enable Fullscreen
          Protected NewCollectionBehaviour
          NewCollectionBehaviour = CocoaMessage(0, WindowID(#Main), "collectionBehavior") | $80
          CocoaMessage(0, WindowID(#Main), "setCollectionBehavior:", NewCollectionBehaviour)
          ; Mac default menuÂ´s
          If Not IsMenu(#Menu)
            CreateMenu(#Menu, WindowID(#Main))
          EndIf
          MenuItem(#PB_Menu_About, "")
          MenuItem(#PB_Menu_Preferences, "")
        CompilerEndIf
       
        UpdateWindow()
       
        BindEvent(#PB_Event_SizeWindow, @UpdateWindow())
       
        ; Init
        LogID1 = InitLogging(#List1)
        If LogID1
          CreateThread(@MyThread1(), LogID1)
        EndIf
        LogID2 = InitLogging(#List2)
        If LogID2
          CreateThread(@MyThread2(), LogID2)
        EndIf
       
        ; Main Loop
        Repeat
          event = WaitWindowEvent()
          Select event
            Case #PB_Event_Menu
              Select EventMenu()
                CompilerIf #PB_Compiler_OS = #PB_OS_MacOS   
                  Case #PB_Menu_About
                    MessageRequester("Info", "Testing of Modul Logging")
                   
                  Case #PB_Menu_Preferences
                   
                  Case #PB_Menu_Quit
                    exit = #True
                   
                CompilerEndIf
                 
                Case #MenuExit
                  exit = #True
                 
                Case #MenuStartThread
                  If stop
                    CreateThread(@MyThread1(), LogID1)
                    CreateThread(@MyThread2(), LogID2)
                    stop = 0
                  EndIf
                Case #MenuStopThread
                  stop = 1
                 
                Case #MenuStartScroll
                  SetLogScroll(LogID1, #True)
                 
                Case #MenuStopScroll
                  SetLogScroll(LogID1, #False)
               
              EndSelect
             
            Case #PB_Event_CloseWindow
              Select EventWindow()
                Case #Main
                  exit = #True
                 
              EndSelect
             
          EndSelect
         
          If stop = 0 And exit
            MessageRequester("Info", "Stopping first")
            exit = 0
          EndIf
         
        Until exit
       
      EndIf
     
    EndProcedure : Main()

    End

  
CompilerEndIf
