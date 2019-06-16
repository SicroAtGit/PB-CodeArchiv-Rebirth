;   Description: Supports the thread-safe manipulation of windows and gadgets
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=66180
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29728
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016-2018 mk-soft
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

; Comment: Thread To GUI
; Author : mk-soft
; Version: v1.19
; Created: 16.07.2016
; Updated: 21.05.2018
; Link En: http://www.purebasic.fr/english/viewtopic.php?f=12&t=66180
; Link De: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29728

; ***************************************************************************************

;- Begin Declare Module

CompilerIf #PB_Compiler_Thread = 0
  CompilerError "Use Compileroption Threadsafe!"
CompilerEndIf

DeclareModule ThreadToGUI
 
  ;-Public
 
  ;- Init
  Declare   BindEventGUI(EventCustomValue = #PB_Event_FirstCustomValue)
  Declare   UnBindEventGUI()
  ; Main
  Declare   DoWait()
  ; Windows
  Declare   DoDisableWindow(Window, State)
  Declare   DoHideWindow(Window, State, Flags)
  Declare   DoSetActiveWindow(Window)
  Declare   DoSetWindowColor(Window, Color)
  Declare   DoSetWindowData(Window, Value)
  Declare   DoSetWindowState(Window, State)
  Declare   DoSetWindowTitle(Window, Text.s)
  ; Menus
  Declare   DoDisableMenuItem(Menu, MenuItem, State)
  Declare   DoSetMenuItemState(Menu, MenuItem, State)
  Declare   DoSetMenuItemText(Menu, MenuItem, Text.s)
  Declare   DoSetMenuTitleText(Menu, Index, Text.s)
  Declare   DoDisplayPopupMenu(Menu, WindowID, x = #PB_Ignore, y = #PB_Ignore)
 
  ; Gadgets
  Declare   DoAddGadgetColumn(Gadget, Position, Text.s, Width)
  Declare   DoAddGadgetItem(Gadget, Position, Text.s, ImageID = 0, Flags = #PB_Ignore)
  Declare   DoClearGadgetItems(Gadget)
  Declare   DoClearGadgetColumns(Gadget) ; Owner Gadget Function
  Declare   DoDisableGadget(Gadget, State)
  Declare   DoHideGadget(Gadget, State)
  Declare   DoSetActiveGadget(Gadget)
  Declare   DoSetGadgetAttribute(Gadget, Attribute, Value)
  Declare   DoSetGadgetColor(Gadget, ColorType, Color)
  Declare   DoSetGadgetData(Gadget, Value)
  Declare   DoSetGadgetFont(Gadget, FontID)
  Declare   DoSetGadgetItemAttribute(Gadget, Item, Attribute, Value, Column = 0)
  Declare   DoSetGadgetItemColor(Gadget, Item, ColorType, Color, Column = 0)
  Declare   DoSetGadgetItemData(Gadget, Item, Value)
  Declare   DoSetGadgetItemImage(Gadget, Item, ImageID)
  Declare   DoSetGadgetItemState(Gadget, Position, State)
  Declare   DoSetGadgetItemText(Gadget, Position, Text.s, Column = 0)
  Declare   DoSetGadgetState(Gadget, State)
  Declare   DoSetGadgetText(Gadget, Text.s)
  Declare   DoResizeGadget(Gadget, x, y, Width, Height)
  Declare   DoRemoveGadgetColumn(Gadget, Column)
  Declare   DoRemoveGadgetItem(Gadget, Position)
  Declare   DoGadgetToolTip(Gadget, Text.s)
  ; Statusbar
  Declare   DoStatusBarImage(StatusBar, Field, ImageID, Appearance = 0)
  Declare   DoStatusBarProgress(StatusBar, Field, Value, Appearance = 0, Min = #PB_Ignore, Max = #PB_Ignore)
  Declare   DoStatusBarText(StatusBar, Field, Text.s, Appearance = 0)
  ; Toolbar
  Declare   DoDisableToolBarButton(ToolBar, ButtonID, State)
  Declare   DoSetToolBarButtonState(ToolBar, ButtonID, State)
  ; Systray
  Declare   DoChangeSysTrayIcon(SysTrayIcon, ImageID)
  Declare   DoSysTrayIconToolTip(SysTrayIcon, Text.s)
  ; Clipboard
  Declare   DoGetClipboardImage(Image, Depth=24)
  Declare.s DoGetClipboardText()
  Declare   DoSetClipboardImage(Image)
  Declare   DoSetClipboardText(Text.s)
  Declare   DoClearClipboard()
  ; Requester
  Declare   DoMessageRequester(Title.s, Text.s, Flags=0)
 
  Declare.s DoOpenFileRequester(Title.s, DefaultFile.s, Pattern.s, PatterPosition, Flags=0)
  Declare.s DoNextSelectedFileName()
  Declare   DoSelectedFilePattern()
         
  Declare.s DoSaveFileRequester(Title.s, DefaultFile.s, Pattern.s, PatterPosition)
  Declare.s DoPathRequester(Title.s, InitialPath.s)
  Declare.s DoInputRequester(Title.s, Message.s, DefaultString.s, Flags=0)
  Declare   DoColorRequester(Color = $FFFFFF)
 
  Declare   DoFontRequester(FontName.s, FontSize, Flags, Color = 0, Style = 0)
  Declare.s DoSelectedFontName()
  Declare   DoSelectedFontSize()
  Declare   DoSelectedFontColor()
  Declare   DoSelectedFontStyle()
 
  ; SendEvent
  Declare   SendEvent(Event, Window = 0, Object = 0, EventType = 0, pData = 0, Semaphore = 0)
  Declare   SendEventData(*MyEvent)
  Declare   DispatchEvent(*MyEvent, result)
 
EndDeclareModule

;- Begin Module

Module ThreadToGUI
 
  EnableExplicit
 
  ;-- Const
  Enumeration Command ; Main
    #BeginOfMain
    #WaitOnSignal
    #EndOfMain
  EndEnumeration
 
  Enumeration Command ; Windows
    #BeginOfWindows
    #DisableWindow
    #HideWindow
    #SetActiveWindow
    #SetWindowColor
    #SetWindowData
    #SetWindowState
    #SetWindowTitle
    #EndOfWindows
  EndEnumeration
 
  Enumeration Command ; Menus
    #BeginOfMenu
    #DisableMenuItem
    #SetMenuItemState
    #SetMenuItemText
    #SetMenuTitleText
    #DisplayPopupMenu
    #EndOfMenu
  EndEnumeration
 
  Enumeration Command ; Gadgets
    #BeginOfGadgets
    #AddGadgetColumn
    #AddGadgetItem
    #ClearGadgetItems
    #ClearGadgetColumns ; Owner Gadget Function
    #DisableGadget
    #HideGadget
    #SetActiveGadget
    #SetGadgetAttribute
    #SetGadgetColor
    #SetGadgetData
    #SetGadgetFont
    #SetGadgetItemAttribute
    #SetGadgetItemColor
    #SetGadgetItemData
    #SetGadgetItemImage
    #SetGadgetItemState
    #SetGadgetItemText
    #SetGadgetState
    #SetGadgetText
    #ResizeGadget
    #RemoveGadgetColumn
    #RemoveGadgetItem
    #GadgetToolTip
    #EndOfGadgets
  EndEnumeration
 
  Enumeration Command ; Statusbar
    #BeginOfStatusbar
    #StatusBarImage
    #StatusBarProgress
    #StatusBarText
    #EndOfStatusbar
  EndEnumeration
 
  Enumeration Command ; ToolBar
    #BeginOfToolbar
    #DisableToolBarButton
    #SetToolBarButtonState
    #EndOfToolbar
  EndEnumeration
 
  Enumeration Command ; Systray
    #BeginOfSystray
    #ChangeSysTrayIcon
    #SysTrayIconToolTip
    #EndOfSystray
  EndEnumeration
 
  Enumeration Command ; Clipboard
    #BeginOfClipboard
    #GetClipboardImage
    #GetClipboardText
    #SetClipboardImage
    #SetClipboardText
    #ClearClipboard
    #EndOfClipboard
  EndEnumeration
 
  Enumeration Command ; Requester
    #BeginOfRequester
    #MessageRequester
    #OpenFileRequester
    #SaveFileRequester
    #PathRequester
    #InputRequester
    #ColorRequester
    #FontRequester
    #EndOfRequester
  EndEnumeration
 
  ;-- Structure DoCommand
  Structure udtParam
    Command.i
    Signal.i
    Result.i
    Object.i
    Param1.i
    Param2.i
    Param3.i
    Param4.i
    Param5.i
  EndStructure
 
  Structure udtParamText
    Command.i
    Signal.i
    Result.i
    Object.i
    Param1.i
    Param2.i
    Param3.i
    Param4.i
    Param5.i
    Text.s
  EndStructure
 
  Structure udtParamText2
    Command.i
    Signal.i
    Result.i
    Object.i
    Param1.i
    Param2.i
    Param3.i
    Param4.i
    Param5.i
    Text.s
    Text2.s
  EndStructure
 
  Structure udtParamText3
    Command.i
    Signal.i
    Result.i
    Object.i
    Param1.i
    Param2.i
    Param3.i
    Param4.i
    Param5.i
    Text.s
    Text2.s
    Text3.s
  EndStructure
 
  Structure udtParamAll Extends udtParamText3
  EndStructure
 
  ;-- Structure SendEvent
  Structure udtSendEvent
    Signal.i
    Result.i
    *pData
  EndStructure
 
  ;-- Global
  Global DoEvent
  Global LockMessageRequester = CreateMutex()
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Functions
 
  Procedure PostEventCB()
   
    Protected *data.udtParamAll
   
    *data = EventData()
    With *data
      Select \Command
        Case #WaitOnSignal
          ; Do nothing
         
        Case #BeginOfWindows To #EndOfWindows
          If IsWindow(\Object)
            Select \Command
              Case #DisableGadget
                DisableWindow(\Object, \Param1)
              Case #HideGadget
                HideWindow(\Object, \Param1, \Param2)
              Case #SetActiveGadget
                SetActiveWindow(\Object)
              Case #SetWindowColor
                SetWindowColor(\Object, \Param1)
              Case #SetWindowData
                SetWindowData(\Object, \Param1)
              Case #SetWindowState
                SetWindowState(\Object, \Param1)
              Case #SetWindowTitle
                SetWindowTitle(\Object, \Text)
            EndSelect
          EndIf
         
        Case #BeginOfMenu To #EndOfMenu
          If IsMenu(\Object)
            Select \Command
              Case #DisableMenuItem
                DisableMenuItem(\Object, \Param1, \Param2)
              Case #SetMenuItemState
                SetMenuItemState(\Object, \Param1, \Param2)
              Case #SetMenuItemText
                SetMenuItemText(\Object, \Param1, \Text)
              Case #SetMenuTitleText
                SetMenuTitleText(\Object, \Param1, \Text)
              Case #DisplayPopupMenu
                If \Param2 = #PB_Ignore
                  Debug "Popup"
                  DisplayPopupMenu(\Object, \Param1)
                Else
                  DisplayPopupMenu(\Object, \Param1, \Param2, \Param3)
                EndIf 
            EndSelect
          EndIf
         
        Case #BeginOfGadgets To #EndOfGadgets
          If IsGadget(\Object)
            Select \Command
              Case #AddGadgetColumn
                AddGadgetColumn(\Object, \Param1, \Text.s, \Param3)
              Case #AddGadgetItem
                If \Param4 = #PB_Ignore
                  AddGadgetItem(\Object, \Param1, \Text.s, \Param3)
                Else
                  AddGadgetItem(\Object, \Param1, \Text.s, \Param3, \Param4)
                EndIf
              Case #ClearGadgetItems
                ClearGadgetItems(\Object)
              Case #ClearGadgetColumns ; Owner gadget function
                CompilerIf #PB_Compiler_Version <= 551
                  ClearGadgetItems(\Object)
                  While GetGadgetItemText(\Object, -1, 0)
                    RemoveGadgetColumn(\Object, 0)
                  Wend
                CompilerElse
                  RemoveGadgetColumn(\Object, #PB_All)
                CompilerEndIf
              Case #DisableGadget
                DisableGadget(\Object, \Param1)
              Case #HideGadget
                HideGadget(\Object, \Param1)
              Case #SetActiveGadget
                SetActiveGadget(\Object)
              Case #SetGadgetAttribute
                SetGadgetAttribute(\Object, \Param1, \Param2)
              Case #SetGadgetColor
                SetGadgetColor(\Object, \Param1, \Param2)
              Case #SetGadgetData
                SetGadgetData(\Object, \Param1)
              Case #SetGadgetFont
                SetGadgetFont(\Object, \Param1)
              Case #SetGadgetItemAttribute
                SetGadgetItemAttribute(\Object, \Param1, \Param2, \Param3, \Param4)
              Case #SetGadgetItemColor
                SetGadgetItemColor(\Object, \Param1, \Param2, \Param3, \Param4)
              Case #SetGadgetItemData
                SetGadgetItemData(\Object, \Param1, \Param2)
              Case #SetGadgetItemImage
                SetGadgetItemImage(\Object, \Param1, \Param2)
              Case #SetGadgetItemState
                SetGadgetItemState(\Object, \Param1, \Param2)
              Case #SetGadgetItemText
                SetGadgetItemText(\Object, \Param1, \Text.s, \Param3)
              Case #SetGadgetState
                SetGadgetState(\Object, \Param1)
              Case #SetGadgetText
                SetGadgetText(\Object, \Text.s)
              Case #ResizeGadget
                ResizeGadget(\Object, \Param1, \Param2, \Param3, \Param4)
              Case #RemoveGadgetColumn
                RemoveGadgetColumn(\Object, \Param1)
              Case #RemoveGadgetItem
                RemoveGadgetItem(\Object, \Param1)
              Case #GadgetToolTip
                GadgetToolTip(\Object, \Text)
            EndSelect
          EndIf
         
        Case #BeginOfStatusbar To #EndOfStatusbar
          If IsStatusBar(\Object)
            Select \Command
              Case #StatusBarImage
                StatusBarImage(\Object, \Param1, \Param2, \Param3)
              Case #StatusBarProgress
                StatusBarProgress(\Object, \Param1, \Param2, \Param3, \Param4, \Param5)
              Case #StatusBarText
                StatusBarText(\Object, \Param1, \Text, \Param3)
            EndSelect
          EndIf
         
        Case #BeginOfToolbar To #EndOfToolbar
          If IsToolBar(\Object)
            Select \Command
              Case #DisableToolBarButton
                DisableToolBarButton(\Object, \Param1, \Param2)
              Case #SetToolBarButtonState
                SetToolBarButtonState(\Object, \Param1, \Param2)
            EndSelect
          EndIf
         
        Case #BeginOfSystray To #EndOfSystray
          If IsSysTrayIcon(\Object)
            Select \Command
              Case #ChangeSysTrayIcon
                ChangeSysTrayIcon(\Object, \Param1)
              Case #SysTrayIconToolTip
                SysTrayIconToolTip(\Object, \Text)
            EndSelect
          EndIf
         
        Case #BeginOfClipboard To #EndOfClipboard
          Select \Command
            Case #GetClipboardImage
              \Result = GetClipboardImage(\Param1, \Param2)
            Case #GetClipboardText
              \Text = GetClipboardText()
            Case #SetClipboardImage
              SetClipboardImage(\Param1)
            Case #SetClipboardText
              SetClipboardText(\Text)
            Case #ClearClipboard
              ClearClipboard()
          EndSelect
         
        Case #BeginOfRequester To #EndOfRequester
          Select \Command
            Case #MessageRequester
              \Result = MessageRequester(\Text, \Text2, \Param3)
            Case #OpenFileRequester
              \Text = OpenFileRequester(\Text, \Text2, \Text3, \Param4, \Param5)
              If \Text
                \Param4 = SelectedFilePattern()
                If \Param5 = #PB_Requester_MultiSelection
                  Repeat
                    \Text2 = NextSelectedFileName()
                    If \Text2
                      \Text + #TAB$ + \Text2
                    Else
                      Break
                    EndIf
                  ForEver
                EndIf
              EndIf
            Case #SaveFileRequester
              \Text = SaveFileRequester(\Text, \Text2, \Text3, \Param4)
            Case #PathRequester
              \Text = PathRequester(\Text, \Text2)
            Case #InputRequester
              \Text = InputRequester(\Text, \Text2, \Text3, \Param4)
            Case #ColorRequester
              \Result = ColorRequester(\Param1)
            Case #FontRequester
              \Result = FontRequester(\Text, \Param2, \Param3, \Param4,  \Param5)
              If \Result
                \Text = SelectedFontName()
                \Param2 = SelectedFontSize()
                \Param4 = SelectedFontColor()
                \Param5 = SelectedFontStyle()
              EndIf
          EndSelect
         
      EndSelect
     
      If \Signal
        SignalSemaphore(\Signal)
      Else
        FreeStructure(*data)
      EndIf
     
    EndWith
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;- Public
 
  Procedure BindEventGUI(EventCustomValue = #PB_Event_FirstCustomValue)
    If Not DoEvent
      BindEvent(EventCustomValue, @PostEventCB())
      DoEvent = EventCustomValue
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure UnbindEventGUI()
    If DoEvent
      UnbindEvent(DoEvent, @PostEventCB())
      DoEvent = 0
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Speziale main command
 
  Procedure DoWait()
    Protected *data.udtParam, signal, result
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #WaitOnSignal
          \Signal = signal
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(\Signal)
          FreeSemaphore(signal)
          Result = 1
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Windows commands
 
  Procedure DoDisableWindow(Window, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #DisableWindow
        \Object = Window
        \Param1 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoHideWindow(Window, State, Flags)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #HideWindow
        \Object = Window
        \Param1 = State
        \Param2 = Flags
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetActiveWindow(Window)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetActiveWindow
        \Object = Window
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetWindowColor(Window, Color)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetWindowColor
        \Object = Window
        \Param1 = Color
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetWindowData(Window, Value)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetWindowData
        \Object = Window
        \Param1 = Value
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetWindowState(Window, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetWindowState
        \Object = Window
        \Param1 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetWindowTitle(Window, Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SetWindowTitle
        \Object = Window
        \Text = Text
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Menu commands
 
  Procedure DoDisableMenuItem(Menu, MenuItem, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #DisableMenuItem
        \Object = Menu
        \Param1 = MenuItem
        \Param2 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetMenuItemState(Menu, MenuItem, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetMenuItemState
        \Object = Menu
        \Param1 = MenuItem
        \Param2 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetMenuItemText(Menu, MenuItem, Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SetMenuItemText
        \Object = Menu
        \Param1 = MenuItem
        \Text = Text
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetMenuTitleText(Menu, Index, Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SetMenuTitleText
        \Object = Menu
        \Param1 = Index
        \Text = Text
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoDisplayPopupMenu(Menu, WindowID, x = #PB_Ignore, y = #PB_Ignore)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #DisplayPopupMenu
        \Object = Menu
        \Param1 = WindowID
        \Param2 = x
        \Param3 = y
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Gadget commands
 
  Procedure DoAddGadgetColumn(Gadget, Position, Text.s, Width)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #AddGadgetColumn
        \Object = Gadget
        \Param1 = Position
        \Text = Text
        \Param3 = Width
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoAddGadgetItem(Gadget, Position, Text.s, ImageID = 0, Flags = #PB_Ignore)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #AddGadgetItem
        \Object = Gadget
        \Param1 = Position
        \Text = Text
        \Param3 = ImageID
        \Param4 = Flags
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoClearGadgetItems(Gadget)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #ClearGadgetItems
        \Object = Gadget
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoClearGadgetColumns(Gadget)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #ClearGadgetColumns
        \Object = Gadget
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoDisableGadget(Gadget, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #DisableGadget
        \Object = Gadget
        \Param1 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoHideGadget(Gadget, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #HideGadget
        \Object = Gadget
        \Param1 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetActiveGadget(Gadget)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetActiveGadget
        \Object = Gadget
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetAttribute(Gadget, Attribute, Value)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetAttribute
        \Object = Gadget
        \Param1 = Attribute
        \Param2 = Value
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetColor(Gadget, ColorType, Color)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetColor
        \Object = Gadget
        \Param1 = ColorType
        \Param2 = Color
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetData(Gadget, Value)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetData
        \Object = Gadget
        \Param1 = Value
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetFont(Gadget, FontID)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetFont
        \Object = Gadget
        \Param1 = FontID
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetItemAttribute(Gadget, Item, Attribute, Value, Column = 0)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetItemAttribute
        \Object = Gadget
        \Param1 = Item
        \Param2 = Attribute
        \Param3 = Value
        \Param4 = Column
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetItemColor(Gadget, Item, ColorType, Color, Column = 0)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetItemColor
        \Object = Gadget
        \Param1 = Item
        \Param2 = ColorType
        \Param3 = Color
        \Param4 = Column
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetItemData(Gadget, Item, Value)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetItemData
        \Object = Gadget
        \Param1 = Item
        \Param2 = Value
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetItemImage(Gadget, Item, ImageID)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetItemImage
        \Object = Gadget
        \Param1 = Item
        \Param2 = ImageID
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetItemState(Gadget, Position, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetItemState
        \Object = Gadget
        \Param1 = Position
        \Param2 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetItemText(Gadget, Position, Text.s, Column = 0)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SetGadgetItemText
        \Object = Gadget
        \Param1 = Position
        \Text = Text
        \Param3 = Column
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetState(Gadget, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetGadgetState
        \Object = Gadget
        \Param1 = State
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetGadgetText(Gadget, Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SetGadgetText
        \Object = Gadget
        \Text = text
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoResizeGadget(Gadget, x, y, Width, Height)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #ResizeGadget
        \Object = Gadget
        \Param1 = x
        \Param2 = y
        \Param3 = Width
        \Param4 = Height
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoRemoveGadgetColumn(Gadget, Column)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #RemoveGadgetColumn
        \Object = Gadget
        \Param1 = Column
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoRemoveGadgetItem(Gadget, Position)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #RemoveGadgetItem
        \Object = Gadget
        \Param1 = Position
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoGadgetToolTip(Gadget, Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
   
    *data = AllocateStructure(udtParamText)
    With *data
      \Command = #GadgetToolTip
      \Object = Gadget
      \Text = Text
      PostEvent(DoEvent, 0, 0, 0, *data)
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Statusbar commands
 
  Procedure DoStatusBarImage(StatusBar, Field, ImageID, Appearance = 0)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
   
    *data = AllocateStructure(udtParam)
    With *data
      \Command = #StatusBarImage
      \Object = StatusBar
      \Param1 = Field
      \Param2 = ImageID
      \Param3 = Appearance
      PostEvent(DoEvent, 0, 0, 0, *data)
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoStatusBarProgress(StatusBar, Field, Value, Appearance = 0, Min = #PB_Ignore, Max = #PB_Ignore)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
   
    *data = AllocateStructure(udtParam)
    With *data
      \Command = #StatusBarProgress
      \Object = StatusBar
      \Param1 = Field
      \Param2 = Value
      \Param3 = Appearance
      \Param4 = Min
      \Param5 = Max
      PostEvent(DoEvent, 0, 0, 0, *data)
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoStatusBarText(StatusBar, Field, Text.s, Appearance = 0)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
   
    *data = AllocateStructure(udtParamText)
    With *data
      \Command = #StatusBarText
      \Object = StatusBar
      \Param1 = Field
      \Text = Text
      \Param3 = Appearance
      PostEvent(DoEvent, 0, 0, 0, *data)
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Toolbar commands
 
  Procedure DoDisableToolBarButton(ToolBar, ButtonID, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
   
    *data = AllocateStructure(udtParam)
    With *data
      \Command = #DisableToolBarButton
      \Object = ToolBar
      \Param1 = ButtonID
      \Param2 = State
      PostEvent(DoEvent, 0, 0, 0, *data)
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetToolBarButtonState(ToolBar, ButtonID, State)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
   
    *data = AllocateStructure(udtParam)
    With *data
      \Command = #SetToolBarButtonState
      \Object = ToolBar
      \Param1 = ButtonID
      \Param2 = State
      PostEvent(DoEvent, 0, 0, 0, *data)
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Systray commands
 
  Procedure DoChangeSysTrayIcon(SysTrayIcon, ImageID)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #ChangeSysTrayIcon
        \Object = SysTrayIcon
        \Param1 = ImageID
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSysTrayIconToolTip(SysTrayIcon, Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SysTrayIconToolTip
        \Object = SysTrayIcon
        \Text = Text
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Clipboard command
 
  Procedure DoGetClipboardImage(Image, Depth=24)
    Protected *data.udtParam, signal, result
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        signal = CreateSemaphore()
        \Command = #GetClipboardImage
        \Signal = signal
        \Param1 = Image
        \Param2 = Depth
        PostEvent(DoEvent, 0, 0, 0, *data)
        WaitSemaphore(signal)
        FreeSemaphore(signal)
        result = \Result
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure.s DoGetClipboardText()
    Protected *data.udtParamText, signal, result.s
   
    If Not DoEvent : ProcedureReturn "" : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        signal = CreateSemaphore()
        \Command = #GetClipboardText
        \Signal = signal
        PostEvent(DoEvent, 0, 0, 0, *data)
        WaitSemaphore(signal)
        FreeSemaphore(signal)
        result = \Text
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetClipboardImage(Image)
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        \Command = #SetClipboardImage
        \Param1 = Image
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoSetClipboardText(Text.s)
    Protected *data.udtParamText
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        \Command = #SetClipboardText
        \Text = Text
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoClearClipboard()
    Protected *data.udtParam
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      If *data
        *data = AllocateStructure(udtParam)
        \Command = #ClearClipboard
        PostEvent(DoEvent, 0, 0, 0, *data)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ;-- Requester
 
  Procedure DoMessageRequester(Title.s, Text.s, Flags=0)
    Protected *data.udtParamText2, signal, result
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText2)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #MessageRequester
          \Signal = signal
          \Text = Title
          \Text2 = Text
          \Param3 = Flags
          LockMutex(LockMessageRequester)
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          UnlockMutex(LockMessageRequester)
          result = \Result
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Threaded NewList SelectedFileName.s()
  Threaded __SelectedFilePattern.i
 
  Procedure.s DoOpenFileRequester(Title.s, DefaultFile.s, Pattern.s, PatterPosition, Flags=0)
    Protected *data.udtParamText3, signal, result.s, cnt, index, filename.s
   
    If Not DoEvent : ProcedureReturn "" : EndIf
    With *data
      *data = AllocateStructure(udtParamText3)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #OpenFileRequester
          \Signal = signal
          \Text = Title
          \Text2 = DefaultFile
          \Text3 = Pattern
          \Param4 = PatterPosition
          \Param5 = Flags
          ClearList(SelectedFileName())
          __SelectedFilePattern = 0
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          If Flags & #PB_Requester_MultiSelection
            cnt = CountString(\Text, #TAB$) + 1
            For index = 1 To cnt
              AddElement(SelectedFileName())
              SelectedFileName() = StringField(\Text, index, #TAB$)
            Next
            FirstElement(SelectedFileName())
            result = SelectedFileName()
          Else
            result = \Text
          EndIf
          __SelectedFilePattern = \Param4
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
  Procedure.s DoNextSelectedFileName()
    Protected result.s
    If NextElement(SelectedFileName())
      result = SelectedFileName()
    Else
      ClearList(SelectedFileName())
      result = ""
    EndIf
    ProcedureReturn result
  EndProcedure
 
  Procedure DoSelectedFilePattern()
    ProcedureReturn __SelectedFilePattern
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure.s DoSaveFileRequester(Title.s, DefaultFile.s, Pattern.s, PatterPosition)
    Protected *data.udtParamText3, signal, result.s
   
    If Not DoEvent : ProcedureReturn "" : EndIf
    With *data
      *data = AllocateStructure(udtParamText3)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #SaveFileRequester
          \Signal = signal
          \Text = Title
          \Text2 = DefaultFile
          \Text3 = Pattern
          \Param4 = PatterPosition
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          result = \Text
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure.s DoPathRequester(Title.s, InitialPath.s)
    Protected *data.udtParamText2, signal, result.s
   
    If Not DoEvent : ProcedureReturn "" : EndIf
    With *data
      *data = AllocateStructure(udtParamText2)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #PathRequester
          \Signal = signal
          \Text = Title
          \Text2 = InitialPath
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          result = \Text
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure.s DoInputRequester(Title.s, Message.s, DefaultString.s, Flags=0)
    Protected *data.udtParamText3, signal, result.s
   
    If Not DoEvent : ProcedureReturn "" : EndIf
    With *data
      *data = AllocateStructure(udtParamText3)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #InputRequester
          \Signal = signal
          \Text = Title
          \Text2 = Message
          \Text3 = DefaultString
          \Param4 = Flags
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          result = \Text
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DoColorRequester(Color = $FFFFFF)
    Protected *data.udtParam, signal, result
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParam)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #ColorRequester
          \Signal = signal
          \Param1 = Color
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          result = \Result
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Structure udtSelectedFont
    Name.s
    Size.i
    Color.i
    Style.i
  EndStructure
 
  Threaded SelectedFont.udtSelectedFont
 
  Procedure DoFontRequester(FontName.s, FontSize, Flags, Color = 0, Style = 0)
    Protected *data.udtParamText, signal, result
   
    If Not DoEvent : ProcedureReturn 0 : EndIf
    With *data
      *data = AllocateStructure(udtParamText)
      If *data
        signal = CreateSemaphore()
        If signal
          \Command = #FontRequester
          \Signal = signal
          \Text = FontName
          \Param2 = FontSize
          \Param3 = Flags
          \Param4 = Color
          \Param5 = Style
          PostEvent(DoEvent, 0, 0, 0, *data)
          WaitSemaphore(signal)
          FreeSemaphore(signal)
          result = \Result
          If result
            SelectedFont\Name = \Text
            SelectedFont\Size = \Param2
            SelectedFont\Color = \Param4
            SelectedFont\Style = \Param5
          EndIf
        EndIf
        FreeStructure(*data)
      EndIf
      ProcedureReturn result
    EndWith
  EndProcedure
 
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 
  Procedure.s DoSelectedFontName()
    ProcedureReturn SelectedFont\Name
  EndProcedure
 
  Procedure DoSelectedFontSize()
    ProcedureReturn SelectedFont\Size
  EndProcedure
 
  Procedure DoSelectedFontColor()
    ProcedureReturn SelectedFont\Color
  EndProcedure
 
  Procedure DoSelectedFontStyle()
    ProcedureReturn SelectedFont\Style
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ; *************************************************************************************
 
  ;-- SendEvent commands
 
  Procedure SendEvent(Event, Window = 0, Object = 0, EventType = 0, pData = 0, Semaphore = 0)
    Protected MyEvent.udtSendEvent, result
   
    With MyEvent
      If Semaphore
        \Signal = Semaphore
      Else
        \Signal = CreateSemaphore()
      EndIf
      \pData = pData
      PostEvent(Event, Window, Object, EventType, @MyEvent)
      WaitSemaphore(\Signal)
      result = \Result
      If Semaphore = 0
        FreeSemaphore(\Signal)
      EndIf
    EndWith
   
    ProcedureReturn result
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendEventData(*MyEvent.udtSendEvent)
    ProcedureReturn *MyEvent\pData
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure DispatchEvent(*MyEvent.udtSendEvent, result)
    *MyEvent\Result = result
    SignalSemaphore(*MyEvent\Signal)
  EndProcedure
 
  ; *************************************************************************************
 
EndModule

;- End Module

; ***************************************************************************************
