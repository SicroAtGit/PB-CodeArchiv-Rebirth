; Description: Named GadgetData
;              Under windows and linux objects are released.
; Author : mk-soft
; Date: 13.11.2015
; PB-Version: 5.40
; OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=24&t=63979
; French-Forum:
; German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29255
;-----------------------------------------------------------------------------

;-Begin

; Comment: Named GadgetData
; Author : mk-soft
; Version: v1.04
; Created: 08.11.2015
; Updated: 13.11.2015
; Link   :

; ***************************************************************************************


DeclareModule MyGadgetData
  
  Declare   SetGadgetDataValue(gadget, *value, property.s = "Default")
  Declare   GetGadgetDataValue(gadget, property.s = "Default")
  Declare   SetGadgetDataString(gadget, text.s, property.s = "Default")
  Declare.s GetGadgetDataString(gadget, property.s = "Default")
  Declare   FreeGadgetData(gadget)
  Declare   DebugGadgetData(gadget)
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
  
  Procedure FreeGadgetEx(gadget)
    
    If gadget = #PB_All
      ClearList(GadgetData())
      FreeGadget(#PB_All)
    Else
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        FreeGadgetData(gadget)
      CompilerEndIf
      FreeGadget(gadget)
      UpdateGadgetData()
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  Procedure CloseWindowEx(window)
    
    If window = #PB_All
      ClearList(GadgetData())
      CloseWindow(#PB_All)
    Else
      CloseWindow(window)
      UpdateGadgetData()
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------------
  
  
EndModule

; ***************************************************************************************

;-Init

UseModule MyGadgetData

Macro SetGadgetData(gadget, value, property = "Default")
  SetGadgetDataValue(gadget, value, property)
EndMacro

Macro GetGadgetData(gadget, property = "Default")
  GetGadgetDataValue(gadget, property)
EndMacro

Macro FreeGadget(gadget)
  FreeGadgetEx(gadget)
EndMacro

Macro CloseWindow(window)
  CloseWindowEx(window)
EndMacro

;-End Named GadgetData

; ***************************************************************************************

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

; IDE Options = PureBasic 5.40 LTS (Windows - x64)
; CursorPosition = 4
; Folding = ----
; EnableUnicode
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant