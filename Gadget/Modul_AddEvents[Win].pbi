;   Description: Add more Events to Gadgets (MouseEnter, MouseLeave, etc.)
;            OS: Windows (min. XP/2000)
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27701
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014-2015 Bisonte
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

;     07.02.2014
;     EventType Variable einstellbar (Danke TS-Soft)
;     AE_SetEventType_FreeGadget(EventTypeValue) & AE_GetEventType_FreeGadget() hinzugefügt und Beispielcode angepasst.
;     04.02.2014
;     #PB_EventType_FreeGadget hinzugefügt.
DeclareModule AddEvents
 
  Declare AE_AddEvents(Window, Gadget) ; Add #PB_EventTypes to a gadget
  Declare AE_GadgetMouseX(Gadget)      ; Get MouseX in a gadget (like WindowMouseX()) if AE_AddEvents() registered this gadget
  Declare AE_GadgetMouseY(Gadget)      ; Get MouseY in a gadget (like WindowMouseY()) if AE_AddEvents() registered this gadget
  Declare AE_SetEventType_FreeGadget(EventTypeValue) ; Set the EventType Value to your Custom Value
  Declare AE_GetEventType_FreeGadget()               ; Get the actual EventType Value for #EventType_FreeGadget
 
EndDeclareModule
Module        AddEvents
  EnableExplicit
 
  Structure struct_addeventdata
    Window.i
    Gadget.i
    mTrack.i
    mx.i
    my.i
    OldProc.i
  EndStructure
 
  Global NewMap AE_Data.struct_addeventdata()
  Global EventType_FreeGadget = #PB_EventType_FirstCustomValue
 
  Procedure AE_SetEventType_FreeGadget(EventTypeValue)
    EventType_FreeGadget = EventTypeValue
  EndProcedure
  Procedure AE_GetEventType_FreeGadget()
    ProcedureReturn EventType_FreeGadget
  EndProcedure
  Procedure AE_SendEvent(hWnd, EType)               ; All OS
   
    Protected mPosX, mPosY, gPosLeft, gPosTop, gPosRight, gPosBottom
   
    With AE_Data(Str(hWnd))
     
      gPosLeft    = GadgetX(\Gadget, #PB_Gadget_ScreenCoordinate)
      gPosTop     = GadgetY(\Gadget, #PB_Gadget_ScreenCoordinate)
      gPosRight   = gPosLeft + GadgetWidth(\Gadget)
      gPosBottom  = gPosTop  + GadgetHeight(\Gadget)
     
      mPosX = DesktopMouseX()
      mPosY = DesktopMouseY()
     
      \mx = mPosX - gPosLeft : \my = mPosY - gPosTop
     
      PostEvent(#PB_Event_Gadget, \Window, \Gadget, EType)
     
    EndWith
   
  EndProcedure
  Procedure AE_CallBack(hWnd, uMsg, wParam, lParam) ; TRACKMOUSEEVENT, #WM_ Messages, CallWindowProc_(OldProc, hWnd, uMsg, wParam, lParam)
   
    Protected OldProc, tm.TRACKMOUSEEVENT
   
    If Not FindMapElement(AE_Data(), Str(hWnd))
      ProcedureReturn #Null
    EndIf
   
    With AE_Data(Str(hWnd))
     
      OldProc = \OldProc
     
      Select uMsg
        Case #WM_DESTROY
          AE_SendEvent(hWnd, EventType_FreeGadget)
          DeleteMapElement(AE_Data(), Str(hWnd))
         
        Case #WM_LBUTTONDOWN
          AE_SendEvent(hWnd, #PB_EventType_LeftButtonDown)
         
        Case #WM_RBUTTONDOWN
          AE_SendEvent(hWnd, #PB_EventType_RightButtonDown)
         
        Case #WM_MBUTTONDOWN
          AE_SendEvent(hWnd, #PB_EventType_MiddleButtonDown)
         
        Case #WM_LBUTTONUP
          AE_SendEvent(hWnd, #PB_EventType_LeftButtonUp)
         
        Case #WM_RBUTTONUP
          AE_SendEvent(hWnd, #PB_EventType_RightButtonUp)
         
        Case #WM_MBUTTONUP
          AE_SendEvent(hWnd, #PB_EventType_MiddleButtonUp)
         
        Case #WM_MOUSEMOVE
          If Not \mTrack
            \mTrack = #True
            tm\cbSize     = SizeOf(TRACKMOUSEEVENT)
            tm\dwFlags    = #TME_LEAVE
            tm\hwndTrack  = hWnd
            TrackMouseEvent_(@tm)
            AE_SendEvent(hWnd, #PB_EventType_MouseEnter)
            If OldProc : CallWindowProc_(OldProc, hWnd, uMsg, wParam, lParam) : EndIf
            ProcedureReturn #Null
          Else ; MouseMove
            AE_SendEvent(hWnd, #PB_EventType_MouseMove)
          EndIf
         
        Case #WM_MOUSELEAVE
          AE_SendEvent(hWnd, #PB_EventType_MouseLeave)
          \mTrack = #False : \mx = -1 : \my = -1
          ProcedureReturn #Null
         
      EndSelect
     
    EndWith
   
    If OldProc
      ProcedureReturn CallWindowProc_(OldProc, hWnd, uMsg, wParam, lParam)
    Else
      ProcedureReturn #False
    EndIf
   
  EndProcedure
  Procedure AE_AddEvents(Window, Gadget)            ; SetWindowLongPtr_(GadgetID(Gadget), #GWLP_WNDPROC, @AE_CallBack())
   
    If IsGadget(Gadget) And IsWindow(Window)
      AE_Data(Str(GadgetID(Gadget)))\Gadget  = Gadget
      AE_Data(Str(GadgetID(Gadget)))\Window  = Window
      AE_Data(Str(GadgetID(Gadget)))\mTrack  = #False
      AE_Data(Str(GadgetID(Gadget)))\mx      = -1
      AE_Data(Str(GadgetID(Gadget)))\my      = -1
      AE_Data(Str(GadgetID(Gadget)))\OldProc = SetWindowLongPtr_(GadgetID(Gadget), #GWLP_WNDPROC, @AE_CallBack())
    EndIf
   
  EndProcedure
  Procedure AE_GadgetMouseX(Gadget)                 ; All OS
    Protected Result = -1
    If IsGadget(Gadget)
      If FindMapElement(AE_Data(), Str(GadgetID(Gadget)))
        Result = AE_Data(Str(GadgetID(Gadget)))\mx
      EndIf
    EndIf
    ProcedureReturn Result
  EndProcedure
  Procedure AE_GadgetMouseY(Gadget)                 ; All OS
    Protected Result = -1
    If IsGadget(Gadget)
      If FindMapElement(AE_Data(), Str(GadgetID(Gadget)))
        Result = AE_Data(Str(GadgetID(Gadget)))\my
      EndIf
    EndIf
    ProcedureReturn Result
  EndProcedure
 
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile ; Test
 
  EnableExplicit
 
  UseModule AddEvents
 
  Enumeration #PB_EventType_FirstCustomValue; customevents
    #custom1
    #custom2
  EndEnumeration
 
  AE_SetEventType_FreeGadget(#PB_Compiler_EnumerationValue) ; <- thx ts soft
 
  Define Event, Quit
 
  Procedure MouseEnterProc()
    Debug "Enter"
  EndProcedure
 
  LoadImage(1, #PB_Compiler_Home + "Examples\Sources\Data\GeeBee2.bmp") ; Change to your Image
 
  OpenWindow(0, 0, 0, 248, 148, "Test", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  ImageGadget(1, 10, 10, 0, 0, ImageID(1))
 
  ; Add Extra Eventtypes
  AE_AddEvents(0, 1)
 
  ; This works also now with BindGadgetEvent...
  BindGadgetEvent(1, @MouseEnterProc(), #PB_EventType_MouseEnter)
 
  Repeat
    Event = WaitWindowEvent()
   
    Select Event
      Case #WM_LBUTTONDOWN
        If AE_GadgetMouseX(1) = -1
          Debug "Not in Gadget"
        EndIf
      Case #PB_Event_CloseWindow
        Quit = 1
      Case #PB_Event_Gadget
        If EventGadget() = 1
          Select EventType()
            Case #PB_EventType_LeftButtonDown
              Debug "LeftButtonDown on x : " + Str(AE_GadgetMouseX(EventGadget())) + " y : " + Str(AE_GadgetMouseY(EventGadget()))
            Case #PB_EventType_RightButtonDown
              Debug "RightButtonDown on x : " + Str(AE_GadgetMouseX(EventGadget())) + " y : " + Str(AE_GadgetMouseY(EventGadget()))
              FreeGadget(1)
            Case #PB_EventType_MiddleButtonDown
              Debug "MiddleButtonDown on x : " + Str(AE_GadgetMouseX(EventGadget())) + " y : " + Str(AE_GadgetMouseY(EventGadget()))
            Case #PB_EventType_MouseLeave
              Debug "Leave"   
            Case AE_GetEventType_FreeGadget() ; <- thx ts soft
              Debug "FreeGadget : " + Str(EventGadget())
          EndSelect
        EndIf
    EndSelect
   
  Until Quit > 0
 
CompilerEndIf 
