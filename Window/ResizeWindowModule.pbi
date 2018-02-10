;   Description: Resize window and gadgets (based on RS_ResizeGadget by USCode)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27664
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014, 2017 Thorsten1867
; Copyright (c) 2017 ts-soft -- Code optimizations
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

;/ === ResizeWindowModule.pbi ===  [ PureBasic V5.6x ]
;/ Resize window and gadgets (based on RS_ResizeGadget by USCode)
;/ Restore last window position and size 
;/
;/ October 2017 by Thorsten1867 (optimized by TS-Soft)

DeclareModule ResizeWindow
  Enumeration 1
    #LEFT    = 1
    #TOP     = 1 << 1
    #RIGHT   = 1 << 2
    #BOTTOM  = 1 << 3
    #HCENTER = 1 << 4
    #VCENTER = 1 << 5
    #HFLOAT  = 1 << 6
    #VFLOAT  = 1 << 7
  EndEnumeration
  Declare AddGadget(WindowID.i, GadgetID.i, Flags.l)
  Declare SetResizeColumn(GadgetID.i, Column.i)
  Declare SetProportionalResize(GadgetID.i, HFactor.i, VFactor.i, Flags.l=#False)
  Declare RemoveGadget(GadgetID.i)
  Declare RemoveWindow(WindowID.i)
  Declare LoadResizeData(AppName.s, File.s="ResizeWindow.reg", Publisher.s="")
  Declare FreeResizeData()
  Declare SaveWindow(WindowsID.i)
  Declare SaveListColums(WindowsID.i, GadgetID.i, Columns.i)
  Declare RestoreWindow(WindowsID.i, IgnorePosition.i=#False, State.i=#False)
  Declare DeleteWindow(WindowsID.i, ListsOnly.i=#False)
EndDeclareModule

Module ResizeWindow
  
  EnableExplicit
  
  Structure WindowResizeStructure
    ID.i
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure
  Global NewMap Window.WindowResizeStructure()
  
  Structure GadgetResizeStructure
    ID.i
    HND.i
    WinID.i
    Left.i
    Top.i
    Right.i
    Bottom.i
    X.i
    Y.i
    Width.i
    Height.i
    Lock_Left.i
    Lock_Top.i
    Lock_Right.i
    Lock_Bottom.i
    HCenter.i
    VCenter.i
    Typ.i
    Column.i
    HFactor.i
    VFactor.i
    Flags.i
  EndStructure
  Global NewMap Gadget.GadgetResizeStructure()
  
  Structure XMLStructure
    ID.i
    File.s
  EndStructure
  Global XML.XMLStructure
  
  ;- Event-Handler
  
  Procedure ResizeWindowHandler() ; === #PB_Event_SizeWindow ===
    Protected WindowID = EventWindow() ; WindowID of the current window
    Protected.s WinID = Str(WindowID)  ; WindowID as string for MapKey
    Protected.i X, Y, Width, Height, ColWidth, WinWidth, WinHeight, VOffSet, HOffSet
    WinWidth  = WindowWidth(WindowID)
    WinHeight = WindowHeight(WindowID)
    If GetWindowState(WindowID) = #PB_Window_Normal
      Window(WinID)\Width  = WinWidth
      Window(WinID)\Height = WinHeight
    EndIf
    If MapSize(Gadget())
      ForEach Gadget()
        If Gadget()\WinID = WindowID   ; only Gadget from the current window
          If IsGadget(Gadget()\ID)
            X = GadgetX(Gadget()\ID)
            Y = GadgetY(Gadget()\ID)
            Width  = #PB_Ignore
            Height = #PB_Ignore
            If Gadget()\Lock_Left   = #False : X = WinWidth  - Gadget()\Left : EndIf
            If Gadget()\Lock_Top    = #False : Y = WinHeight - Gadget()\Top  : EndIf       
            If Gadget()\Lock_Right  = #True  : Width  = WinWidth  - X - Gadget()\Right  : EndIf
            If Gadget()\Lock_Bottom = #True  : Height = WinHeight - Y - Gadget()\Bottom : EndIf
            If Gadget()\HCenter : X = (WinWidth   - GadgetWidth(Gadget()\ID))  / 2 : EndIf
            If Gadget()\VCenter : Y = (WinHeight  - GadgetHeight(Gadget()\ID)) / 2 : EndIf
            If Gadget()\VFactor ;{ Vertical resize/move by factor
              If Gadget()\Lock_Top And Gadget()\Lock_Bottom  ; Resize Height by Factor
                Height = Gadget()\Height + ((Height - Gadget()\Height) / Gadget()\VFactor)
              ElseIf Gadget()\Lock_Bottom ; Move and/or Resize by Factor
                VOffSet = (Y - Gadget()\Y) / Gadget()\VFactor
                If Gadget()\Flags & #VFLOAT             
                  Height = Gadget()\Height + VOffSet
                EndIf
                Y = Gadget()\Y + VOffSet
              EndIf
            EndIf ;}
            If Gadget()\HFactor ;{ horizontal resize/move by factor
              If Gadget()\Lock_Left And Gadget()\Lock_Right ; Resize Width by Factor
                Width = Gadget()\Width + ((Width - Gadget()\Width) / Gadget()\HFactor)
              ElseIf Gadget()\Lock_Right
                HOffSet = (X - Gadget()\X) / Gadget()\HFactor
                If Gadget()\Flags & #HFLOAT ; Move and/or Resize by Factor
                  Width = Gadget()\Width + HOffSet
                EndIf
                X = Gadget()\X + HOffSet
              EndIf
            EndIf ;}
            Select Gadget()\Typ
              Case #PB_GadgetType_ListIcon     ;{ ListIconGadget
                If Width <> #PB_Ignore
                  ColWidth = GetGadgetItemAttribute(Gadget()\ID, #Null, #PB_ListIcon_ColumnWidth, Gadget()\Column) + (Width - GadgetWidth(Gadget()\ID))
                  SetGadgetItemAttribute(Gadget()\ID, #Null, #PB_ListIcon_ColumnWidth, ColWidth, Gadget()\Column)
                EndIf ;}
              Case #PB_GadgetType_ExplorerList ;{ ExplorerListGadget
                If Width <> #PB_Ignore
                  ColWidth = GetGadgetItemAttribute(Gadget()\ID, #Null, #PB_Explorer_ColumnWidth, Gadget()\Column) + (Width - GadgetWidth(Gadget()\ID))
                  SetGadgetItemAttribute(Gadget()\ID, #Null, #PB_Explorer_ColumnWidth, ColWidth, Gadget()\Column)
                EndIf ;}
            EndSelect
            ResizeGadget(Gadget()\ID, X, Y, Width, Height)
          EndIf
        EndIf
      Next
    EndIf
  EndProcedure
  
  Procedure MoveWindowHandler()   ; === #PB_Event_MoveWindow ===
    Protected WindowID = EventWindow() ; WindowID of the current window
    Protected.s WinID = Str(WindowID)  ; WindowID as string for MapKey
    If GetWindowState(WindowID) = #PB_Window_Normal
      Window(WinID)\X = WindowX(WindowID)
      Window(WinID)\Y = WindowY(WindowID)
    EndIf
  EndProcedure
  
  ;- Resize Gadgets
  
  Procedure AddGadget(WindowID.i, GadgetID.i, Flags.l) ; Add gadget to resize
    Protected.i WinWidth, WinHeight, X, Y
    Protected.s GID = Str(GadgetID)
    If IsWindow(WindowID)
      WinWidth  = WindowWidth(WindowID)
      WinHeight = WindowHeight(WindowID)
      If IsGadget(GadgetID)
        Gadget(GID)\WinID = WindowID
        Gadget(GID)\ID    = GadgetID
        If Flags & #LEFT   : Gadget(GID)\Lock_Left    = #True : EndIf
        If Flags & #TOP    : Gadget(GID)\Lock_Top     = #True : EndIf
        If Flags & #RIGHT  : Gadget(GID)\Lock_Right   = #True : EndIf
        If Flags & #BOTTOM : Gadget(GID)\Lock_Bottom  = #True : EndIf
        Gadget(GID)\X = GadgetX(GadgetID)
        Gadget(GID)\Y = GadgetY(GadgetID)
        Gadget(GID)\Width  = GadgetWidth(GadgetID)
        Gadget(GID)\Height = GadgetHeight(GadgetID)
        If Flags & #HCENTER ;{ Center
          X = (WinWidth - Gadget(GID)\Width) / 2
          Gadget(GID)\HCenter = #True
        Else
          X = Gadget(GID)\X
        EndIf
        If Flags & #VCENTER
          Y = (WinHeight - Gadget(GID)\Height) / 2
          Gadget(GID)\VCenter = #True
        Else
          Y = Gadget(GID)\Y
        EndIf ;}
        If Gadget(GID)\Lock_Left   = #False : Gadget(GID)\Left   = WinWidth  - X : EndIf
        If Gadget(GID)\Lock_Top    = #False : Gadget(GID)\Top    = WinHeight - Y : EndIf
        If Gadget(GID)\Lock_Right  = #True  : Gadget(GID)\Right  = WinWidth  - (X + Gadget(GID)\Width)  : EndIf
        If Gadget(GID)\Lock_Bottom = #True  : Gadget(GID)\Bottom = WinHeight - (Y + Gadget(GID)\Height) : EndIf
        If Flags & #HCENTER Or Flags & #VCENTER
          ResizeGadget(GadgetID, X, Y, #PB_Ignore, #PB_Ignore)
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure SetResizeColumn(GadgetID.i, Column.i)      ; Set column to resize (ListIcon/ExplorerList)
    Protected.s GID  = Str(GadgetID)
    If IsGadget(GadgetID)
      Gadget(GID)\Typ = GadgetType(GadgetID)
      Gadget(GID)\Column = Column
    EndIf
  EndProcedure
  
  Procedure SetProportionalResize(GadgetID.i, HFactor.i, VFactor.i, Flags.l=#False)
    Protected.s GID  = Str(GadgetID)
    Gadget(GID)\HFactor = HFactor
    Gadget(GID)\VFactor = VFactor
    Gadget(GID)\Flags   = Flags
  EndProcedure
  
  Procedure RemoveGadget(GadgetID.i)                   ; Stop resizing gadget
    DeleteMapElement(Gadget(), Str(GadgetID))
  EndProcedure
  
  Procedure RemoveWindow(WindowID.i)                   ; Remove all resize data for this window (-> CloseWindow)
    DeleteMapElement(Window(), Str(WindowID))
    ForEach Gadget()
      If Gadget()\WinID = WindowID
        DeleteMapElement(Gadget(), MapKey(Gadget()))
      EndIf
    Next
  EndProcedure
  
  ;- Restore Window
  
  Procedure.i GetGadgetNode(*Window, GadgetID.i)
    Protected *Gadget
    If *Window
      *Gadget = XMLNodeFromPath(*Window, "Gadget")
      While *Gadget
        If GetXMLAttribute(*Gadget, "GID") = Str(GadgetID)
          ProcedureReturn *Gadget
        EndIf
        *Gadget = NextXMLNode(*Gadget)
      Wend
    EndIf
  EndProcedure
  
  Procedure.s GetDefaultPath(AppName.s, Publisher.s="")
    Protected Path.s, Slash.s
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Slash = "\"
        Path = GetEnvironmentVariable("APPDATA") + "\"
      CompilerCase #PB_OS_MacOS
        Slash = "/"
        Path = GetHomeDirectory() + "Library/Application Support/"
      CompilerCase #PB_OS_Linux
        Slash = "/"
        Path = GetHomeDirectory() + "."   
    CompilerEndSelect
    If Publisher
      Path + Publisher + Slash
      If Not FileSize(Path) = - 2
        CreateDirectory(Path)
      EndIf
    EndIf
    Path + AppName + Slash
    If Not FileSize(Path) = - 2
      CreateDirectory(Path)
    EndIf
    If FileSize(Path) = -2
      ProcedureReturn Path
    EndIf
  EndProcedure
  
  Procedure LoadResizeData(AppName.s, File.s="ResizeWindow.reg", Publisher.s="")  ; Open or create registry
    Protected *MainNode, *Node
    If GetPathPart(File) = ""
      File = GetDefaultPath(AppName, Publisher) + File
    EndIf
    ;{ Load XML-File
    XML\ID = LoadXML(#PB_Any, File, #PB_UTF8)
    If XML\ID And XMLStatus(XML\ID) = #PB_XML_Success
      XML\File = File
      ProcedureReturn #True
    EndIf ;}
          ;{ Create new XML
    XML\ID = CreateXML(#PB_Any, #PB_UTF8)
    If XML\ID
      *MainNode = CreateXMLNode(RootXMLNode(XML\ID), "Registry")
      If *MainNode
        XML\File = File
        ProcedureReturn #True
      EndIf
    EndIf ;}
    XML\File = ""
    ProcedureReturn #False
  EndProcedure
  
  Procedure FreeResizeData()
    If IsXML(XML\ID)
      FreeXML(XML\ID)
    EndIf
  EndProcedure
  
  
  Procedure SaveWindow(WindowsID.i)                    ; save position and size of window
    Protected *WinID, *MainNode
    Protected.i WinX, WinY, WinWidth, WinHeight, WinState
    If IsWindow(WindowsID)
      WinState = GetWindowState(WindowsID)
      If WinState = #PB_Window_Normal ;{ Get position and size
        WinX      = WindowX(WindowsID)
        WinY      = WindowY(WindowsID)
        WinWidth  = WindowWidth(WindowsID)
        WinHeight = WindowHeight(WindowsID)
      Else
        If FindMapElement(Window(), Str(WindowsID))
          WinX      = Window()\X
          WinY      = Window()\Y
          WinWidth  = Window()\Width
          WinHeight = Window()\Height
        Else
          ProcedureReturn #False
        EndIf
      EndIf ;}
      If IsXML(XML\ID)
        *WinID = XMLNodeFromID(XML\ID, Str(WindowsID))
        If *WinID
          SetXMLAttribute(*WinID, "X", Str(WinX))
          SetXMLAttribute(*WinID, "Y", Str(WinY))
          SetXMLAttribute(*WinID, "Width", Str(WinWidth))
          SetXMLAttribute(*WinID, "Hight", Str(WinHeight))
          SetXMLAttribute(*WinID, "State", Str(WinState))
        Else
          *MainNode = MainXMLNode(XML\ID)
          If *MainNode
            *WinID = CreateXMLNode(*MainNode, "Window", -1)
            If *WinID
              SetXMLAttribute(*WinID, "ID", Str(WindowsID))
              SetXMLAttribute(*WinID, "X",  Str(WinX))
              SetXMLAttribute(*WinID, "Y",  Str(WinY))
              SetXMLAttribute(*WinID, "Width", Str(WinWidth))
              SetXMLAttribute(*WinID, "Hight", Str(WinHeight))
              SetXMLAttribute(*WinID, "State", Str(WinState))
            EndIf
          EndIf
        EndIf
        SaveXML(XML\ID, XML\File)
      EndIf
    EndIf
  EndProcedure
  
  Procedure SaveListColums(WindowsID.i, GadgetID.i, Columns.i)
    Protected *WinID, *Gadget, *Column, col.i
    If IsGadget(GadgetID)
      If IsXML(XML\ID)
        *WinID = XMLNodeFromID(XML\ID, Str(WindowsID))
        If *WinID
          *Gadget = GetGadgetNode(*WinID, GadgetID)
          If *Gadget ;{ Update GadgetNode
            For col = 0 To Columns-1
              *Column = ChildXMLNode(*Gadget, col+1)
              If *Column
                Select GadgetType(GadgetID)
                  Case #PB_GadgetType_ListIcon
                    SetXMLAttribute(*Column, "pos", Str(col))
                    SetXMLAttribute(*Column, "width", Str(GetGadgetItemAttribute(GadgetID, #Null, #PB_ListIcon_ColumnWidth, col)))
                  Case #PB_GadgetType_ExplorerList
                    SetXMLAttribute(*Column, "pos", Str(col))
                    SetXMLAttribute(*Column, "width", Str(GetGadgetItemAttribute(GadgetID, #Null, #PB_Explorer_ColumnWidth, col)))
                EndSelect 
              EndIf
            Next ;}
          Else   ;{ Create new GadgetNode
            *Gadget = CreateXMLNode(*WinID, "Gadget", -1)
            If *Gadget
              SetXMLAttribute(*Gadget, "GID", Str(GadgetID))
              For col = 0 To Columns-1
                Select GadgetType(GadgetID)
                  Case #PB_GadgetType_ListIcon
                    *Column = CreateXMLNode(*Gadget, "Column", -1)
                    If *Column
                      SetXMLAttribute(*Column, "pos", Str(col))
                      SetXMLAttribute(*Column, "width", Str(GetGadgetItemAttribute(GadgetID, #Null, #PB_ListIcon_ColumnWidth, col)))
                    EndIf
                  Case #PB_GadgetType_ExplorerList
                    *Column = CreateXMLNode(*Gadget, "Column", -1)
                    If *Column
                      SetXMLAttribute(*Column, "pos", Str(col))
                      SetXMLAttribute(*Column, "width", Str(GetGadgetItemAttribute(GadgetID, #Null, #PB_Explorer_ColumnWidth, col)))
                    EndIf
                EndSelect 
              Next
            EndIf ;}
          EndIf
        EndIf
        SaveXML(XML\ID, XML\File)
      EndIf
    EndIf
  EndProcedure
  
  
  Procedure RestoreWindow(WindowsID.i, IgnorePosition.i=#False, State.i=#False) ; restore position and size of window
    Protected *WinID, *Gadget, *ChildNode
    Protected.i WinX, WinY, WinWidth, WinHeight, WinState, GadgetID
    If IsXML(XML\ID)
      *WinID = XMLNodeFromID(XML\ID, Str(WindowsID))
      If *WinID
        WinX      = Val(GetXMLAttribute(*WinID, "X"))
        WinY      = Val(GetXMLAttribute(*WinID, "Y"))
        WinWidth  = Val(GetXMLAttribute(*WinID, "Width"))
        WinHeight = Val(GetXMLAttribute(*WinID, "Hight"))
        WinState  = Val(GetXMLAttribute(*WinID, "State"))
        If IsWindow(WindowsID)
          If IgnorePosition
            ResizeWindow(WindowsID, #PB_Ignore, #PB_Ignore, WinWidth, WinHeight)
          Else
            ResizeWindow(WindowsID, WinX, WinY, WinWidth, WinHeight)
          EndIf
          If State : SetWindowState(WindowsID, WinState) : EndIf
          If XMLChildCount(*WinID) ;{ Restore Columns
            *Gadget = XMLNodeFromPath(*WinID, "Gadget")
            While *Gadget
              GadgetID = Val(GetXMLAttribute(*Gadget, "GID"))
              If IsGadget(GadgetID)
                *ChildNode = ChildXMLNode(*Gadget)
                While *ChildNode
                  Select GadgetType(GadgetID)
                    Case #PB_GadgetType_ListIcon
                      SetGadgetItemAttribute(GadgetID, #Null, #PB_ListIcon_ColumnWidth, Val(GetXMLAttribute(*ChildNode, "width")), Val(GetXMLAttribute(*ChildNode, "pos")))
                    Case #PB_GadgetType_ExplorerList
                      SetGadgetItemAttribute(GadgetID, #Null, #PB_Explorer_ColumnWidth, Val(GetXMLAttribute(*ChildNode, "width")), Val(GetXMLAttribute(*ChildNode, "pos")))
                  EndSelect 
                  *ChildNode = NextXMLNode(*ChildNode)
                Wend
              EndIf
              *Gadget = NextXMLNode(*Gadget)
            Wend
          EndIf ;}
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  
  Procedure DeleteWindow(WindowsID.i, ListsOnly.i=#False)
    Protected *WinID, *Gadget
    If IsXML(XML\ID)
      *WinID = XMLNodeFromID(XML\ID, Str(WindowsID))
      If *WinID
        If ListsOnly
          *Gadget = XMLNodeFromPath(*WinID, "Gadget")
          While *Gadget
            DeleteXMLNode(*Gadget)
            *Gadget = NextXMLNode(*Gadget)
          Wend
        Else
          DeleteXMLNode(*WinID)
        EndIf
      EndIf
      SaveXML(XML\ID, XML\File)
    EndIf
  EndProcedure
  
  
  ;- Bind Events to Event Handler
  
  BindEvent(#PB_Event_SizeWindow, @ResizeWindowHandler())
  BindEvent(#PB_Event_MoveWindow, @MoveWindowHandler())
  
EndModule


CompilerIf #PB_Compiler_IsMainFile
  
  #Window = 0
  #StatusBar = 1
  Enumeration
    #Button_0
    #Button_1
    #Button_2
    #Button_3
    #Button_4
    #List
    #Editor1
    #Editor2
  EndEnumeration
  
  ResizeWindow::LoadResizeData("MyProg") ; Load at program start
  
  If OpenWindow(#Window, 358, 178, 300, 275, " Test ResizeWindow (Module)",  #PB_Window_SizeGadget | #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
    
    WindowBounds(#Window, 250, 200, #PB_Ignore, #PB_Ignore)
    
    ButtonGadget(#Button_0, 5, 5, 50, 25, "Resize -")
    ButtonGadget(#Button_1, 245, 5, 50, 25, "Resize +")
    ButtonGadget(#Button_2, 5, 240, 50, 25, "Reset")
    ButtonGadget(#Button_3, 250, 125, 45, 20, "Button")
    ListIconGadget(#List, 55, 30, 190, 210, "Column 0", 56, #PB_ListIcon_GridLines)
    AddGadgetColumn(#List, 1, "Column 1", 130)
    ButtonGadget(#Button_4, 5, 245, 80, 25, "Center")
    EditorGadget(#Editor1, 250, 35, 45, 85)
    EditorGadget(#Editor2, 250, 150, 45, 90)
    
    ResizeWindow::AddGadget(#Window, #Button_0, ResizeWindow::#LEFT | ResizeWindow::#TOP)
    ResizeWindow::AddGadget(#Window, #Button_1, ResizeWindow::#TOP  | ResizeWindow::#RIGHT)
    
    UseModule ResizeWindow
    AddGadget(#Window, #Button_2, #LEFT|#BOTTOM)
    AddGadget(#Window, #Button_3, #RIGHT|#BOTTOM)
    AddGadget(#Window, #List, #LEFT|#TOP|#RIGHT|#BOTTOM)
    SetResizeColumn(#List, 1)
    AddGadget(#Window, #Editor1, #RIGHT|#TOP|#BOTTOM)
    AddGadget(#Window, #Editor2, #RIGHT|#BOTTOM)
    SetProportionalResize(#Editor1, #False, 2)             ; Factor: Resize / 2
    SetProportionalResize(#Button_3, #False, 2)            ; Factor: Move / 2
    SetProportionalResize(#Editor2, #False, 2, #VFLOAT)    ; Factor: Resize & Move / 2
    AddGadget(#Window, #Button_4, #HCENTER)
    UnuseModule ResizeWindow
    
    ExitWindow = #False
    
    ResizeWindow::RestoreWindow(#Window) ; Restore last size and position
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          ExitWindow = #True
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button_0
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 250, 300)
            Case #Button_1
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 350, 400)
            Case #Button_2
              ResizeWindow::DeleteWindow(#Window) ; Delete Position and Size
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 300, 300)
          EndSelect
      EndSelect
    Until ExitWindow
    
    ResizeWindow::SaveWindow(#Window)
    ResizeWindow::SaveListColums(#Window, #List, 2)
    
    ResizeWindow::RemoveWindow(#Window)
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
