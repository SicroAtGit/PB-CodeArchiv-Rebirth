;   Description: Named GadgetData (Under windows and linux objects are automatic released)
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=63937
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29255
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

;-Begin

; Comment: Named GadgetData
; Author : mk-soft
; Version: v1.05
; Created: 08.11.2015
; Updated: 26.11.2015
; Link   : http://www.purebasic.fr/english/viewtopic.php?f=12&t=63937

; ***************************************************************************************

DeclareModule MyGadgetData
  
  Declare   InitGadgetData(event = #PB_Event_FirstCustomValue + 10001)
  Declare   SetGadgetDataValue(gadget, *value, property.s = "Default")
  Declare   GetGadgetDataValue(gadget, property.s = "Default")
  Declare   SetGadgetDataString(gadget, text.s, property.s = "Default")
  Declare.s GetGadgetDataString(gadget, property.s = "Default")
  Declare   FreeGadgetData(gadget)
  Declare   DebugGadgetData(gadget)
  Declare   RemoveGadgetItemEx(gadget, position)
  Declare   FreeGadgetEx(gadget)
  Declare   CloseWindowEx(window)
  
EndDeclareModule

Module MyGadgetData
  
  EnableExplicit
  
  Structure udtMyGadgetData
    value.i
    text.s
  EndStructure
  
  Structure udtMyGadgetDataSet
    gadget.i
    Map ds.udtMyGadgetData()
  EndStructure
  
  Global NewList GadgetData.udtMyGadgetDataSet()
  Global event_update
  
  Declare UpdateGadgetData()
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure InitGadgetData(event = #PB_Event_FirstCustomValue + 10001)
    
    BindEvent(event, @UpdateGadgetData())
    event_update = event
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure SetGadgetDataValue(gadget, *value, property.s = "Default")
    
    Protected *map.udtMyGadgetDataSet
    
    *map = GetGadgetData(gadget)
    If *map = 0
      *map = AddElement(GadgetData())
      If *map
        *map\gadget = gadget
        *map\ds(property)\value = *value
        SetGadgetData(gadget, *map)
      EndIf
    Else
      *map\ds(property)\value = *value
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure GetGadgetDataValue(gadget, property.s = "Default")
    
    Protected *map.udtMyGadgetDataSet
    
    *map = GetGadgetData(gadget)
    If *map
      ProcedureReturn *map\ds(property)\value
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure SetGadgetDataString(gadget, text.s, property.s = "Default")
    
    Protected *map.udtMyGadgetDataSet
    
    *map = GetGadgetData(gadget)
    If *map = 0
      *map = AddElement(GadgetData())
      If *map
        *map\gadget = gadget
        *map\ds(property)\text = text
        SetGadgetData(gadget, *map)
      EndIf
    Else
      *map\ds(property)\text = text
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure.s GetGadgetDataString(gadget, property.s = "Default")
    
    Protected *map.udtMyGadgetDataSet
    
    *map = GetGadgetData(gadget)
    If *map
      ProcedureReturn *map\ds(property)\text
    Else
      ProcedureReturn ""
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure FreeGadgetData(gadget)
    
    Protected *map.udtMyGadgetDataSet
    
    ForEach GadgetData()
      If GadgetData()\gadget = gadget
        DeleteElement(GadgetData(), 1)
      EndIf
    Next
    SetGadgetData(gadget, 0)
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure DebugGadgetData(gadget)
    
    Protected *map.udtMyGadgetDataSet
    
    *map = GetGadgetData(gadget)
    If *map
      ForEach *map\ds()
        Debug "Property('" + MapKey(*map\ds()) + "') = " + *map\ds()\value + " : " + *map\ds()\text
      Next
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure UpdateGadgetData()
    
    ForEach GadgetData()
      If Not IsGadget(GadgetData()\gadget)
        DeleteElement(GadgetData(), 1)
      EndIf
    Next
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure RemoveGadgetItemEx(gadget, position)
    
    RemoveGadgetItem(gadget, position)
    If GadgetType(gadget) = #PB_GadgetType_Panel
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        PostEvent(event_update)
      CompilerElse
        UpdateGadgetData()
      CompilerEndIf
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure FreeGadgetEx(gadget)
    
    If gadget = #PB_All
      FreeGadget(#PB_All)
      ClearList(GadgetData())
    Else
      FreeGadget(gadget)
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        PostEvent(event_update)
      CompilerElse
        UpdateGadgetData()
      CompilerEndIf
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure CloseWindowEx(window)
    
    If window = #PB_All
      CloseWindow(#PB_All)
      ClearList(GadgetData())
    Else
      CloseWindow(window)
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        PostEvent(event_update)
      CompilerElse
        UpdateGadgetData()
      CompilerEndIf
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  
EndModule

; ***************************************************************************************

;-Init

UseModule MyGadgetData

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  InitGadgetData()
CompilerEndIf

Macro SetGadgetData(gadget, value, property = "Default")
  SetGadgetDataValue(gadget, value, property)
EndMacro

Macro GetGadgetData(gadget, property = "Default")
  GetGadgetDataValue(gadget, property)
EndMacro

Macro RemoveGadgetItem(gadget, position)
  RemoveGadgetItemEx(gadget, position)
EndMacro

Macro FreeGadget(gadget)
  FreeGadgetEx(gadget)
EndMacro

Macro CloseWindow(window)
  CloseWindowEx(window)
EndMacro

;-End Named GadgetData

; ***************************************************************************************

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  ; CalendarGadget Events
  
  Procedure EventHandler_Calendar()
    
    Protected gadget, datetime, date, lastdate
    
    gadget = EventGadget()
    
    If EventType() <> #PB_EventType_Change
      datetime = GetGadgetState(gadget)
      date = datetime / 86400
      lastdate = GetGadgetData(gadget, "EventData")
      If date <> lastdate
        lastdate = date
        SetGadgetData(gadget, lastdate, "EventData")
        PostEvent(#PB_Event_Gadget, EventWindow(), gadget, #PB_EventType_Change, datetime)
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure Init_Calendar(gadget, first = #False)
    
    SetGadgetData(Gadget, Date() / 86400, "EventData")
    If first
      PostEvent(#PB_Event_Gadget, EventWindow(), gadget, #PB_EventType_Change, Date())
    EndIf
    BindGadgetEvent(Gadget, @EventHandler_Calendar())
    
  EndProcedure
  
  Procedure Main()
    
    Protected event
    
    If OpenWindow(0, #PB_Ignore, #PB_Ignore, 600, 400, "Hello")
      CalendarGadget(0, 10, 10, 200, 200) 
      CalendarGadget(1, 220, 10, 200, 200) 
    EndIf
    Init_Calendar(0, #True)
    Init_Calendar(1, #True)
    
    Repeat
      event = WaitWindowEvent()
      Select event
        Case #PB_Event_CloseWindow
          Break
        Case #PB_Event_Gadget
          Select EventGadget()
            Case 0
              Select EventType()
                Case #PB_EventType_Change
                  Debug "New date 0: " + FormatDate("%dd.%mm.%yyyy", EventData())
                  cnt = GetGadgetData(0) + 1
                  SetGadgetData(0, cnt)
                  SetGadgetDataString(0, FormatDate("%dd.%mm.%yyyy", EventData()), "Date")
                  DebugGadgetData(0)
                  
              EndSelect
              
            Case 1
              Select EventType()
                Case #PB_EventType_Change
                  Debug "New date 1: " + FormatDate("%dd.%mm.%yyyy", EventData())
                  cnt = GetGadgetData(1) + 1
                  SetGadgetData(1, cnt)
                  SetGadgetDataString(1, FormatDate("%dd.%mm.%yyyy", EventData()), "Date")
                  DebugGadgetData(1)
                  
              EndSelect
              
          EndSelect
      EndSelect
      
    ForEver
    
  EndProcedure : Main()
  
CompilerEndIf
