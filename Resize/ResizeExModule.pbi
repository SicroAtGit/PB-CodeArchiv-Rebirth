;   Description: Saves/restores window size/position/state and automatically adjusts gadgets when window is resized
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72440
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31343
; -----------------------------------------------------------------------------

;/ ============================
;/ =   ResizeExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ [Resize] Automatic size adjustment for gadgets
;/ [Window] Save & restore window size, position and state
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; Last Update: 13/03/2019


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
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
;}


;{ _____ Window-Commands _____

; Window::Free()                - Delete all data
; Window::RestoreData()         - Restore position, size and state of the window
; Window::StoreData()           - Store position, size and state of the window
; Window::Save()                - Save data off all windows
; Window::Load()                - Load data off all windows

;}

DeclareModule Window
  
  ;- ===========================================================================
  ;-   DeclareModule (Window)
  ;- ===========================================================================
  
  EnumerationBinary 
    #IgnoreState
    #IgnorePosition
    #IgnoreSize
  EndEnumeration
  
  Declare Free()
  Declare Remove(WindowNum.i)
  Declare Load(File.s="ResizeData.win")
  Declare RestoreSize(WindowNum.i, WindowState.i=#False)
  Declare Save(File.s="ResizeData.win")
  Declare StoreSize(WindowNum.i)
  
EndDeclareModule

Module Window
  
  EnableExplicit
  
  Structure Window_Structure    ;{ Win()\...
    X.i
    Y.i
    Width.i
    Height.i
    State.i
  EndStructure ;}
  Global NewMap Win.Window_Structure()
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures (Window)
  ;- ==========================================================================
  
  Procedure Free()
    
    ClearMap(Win())
    
  EndProcedure
  
  Procedure Load(File.s="ResizeData.win")
    Define.i JSON
    
    JSON = LoadJSON(#PB_Any, File)
    If JSON
      ExtractJSONMap(JSONValue(JSON), Win())
    EndIf
    
  EndProcedure
  
  Procedure Remove(WindowNum.i)
    
    DeleteMapElement(Win(), Str(WindowNum))
    
  EndProcedure
  
  Procedure RestoreSize(WindowNum.i, Flags.i=#False)
    ; Flags: #IgnoreState / #IgnorePosition
    
    If IsWindow(WindowNum)
      
      If FindMapElement(Win(), Str(WindowNum))
        
        If Win()\State = #PB_Window_Normal Or Flags & #IgnoreState
          If Flags & #IgnorePosition
            ResizeWindow(WindowNum, #PB_Ignore, #PB_Ignore, Win()\Width, Win()\Height)
          ElseIf Flags & #IgnoreSize
            ResizeWindow(WindowNum, Win()\X, Win()\Y, #PB_Ignore, #PB_Ignore)
          Else
            ResizeWindow(WindowNum, Win()\X, Win()\Y, Win()\Width, Win()\Height)
          EndIf
        Else
          SetWindowState(WindowNum, Win()\State)
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure Save(File.s="ResizeData.win")
    Define.i JSON
    
    JSON = CreateJSON(#PB_Any)
    If JSON
      InsertJSONMap(JSONValue(JSON), Win())
      SaveJSON(JSON, File)
      FreeJSON(JSON)
    EndIf
    
  EndProcedure
  
  Procedure StoreSize(WindowNum.i)
    
    If IsWindow(WindowNum)
      
      If AddMapElement(Win(), Str(WindowNum))
        
        Win()\X = WindowX(WindowNum)
        Win()\Y = WindowY(WindowNum)
        Win()\Width  = WindowWidth(WindowNum)
        Win()\Height = WindowHeight(WindowNum)
        Win()\State  = GetWindowState(WindowNum)
        
      EndIf
      
    EndIf
    
  EndProcedure
  
EndModule


;{ _____ Resize-Commands _____

; Resize::AddContainer()        - Add container for automatic size adjustment of the contained gadgets
; Resize::AddWindow()           - Add window for automatic resizing
; Resize::AddGadget()           - Add gadget for automatic resizing
; Resize::Free()                - Delete all data
; Resize::RemoveContainer()     - Remove all resize data for this container
; Resize::RemoveGadget()        - Stop resizing gadget and remove resize data
; Resize::RemoveWindow()        - Remove all resize data for this window (-> CloseWindow)
; Resize::RestoreWindow()       - Restore original window & gadgets size
; Resize::SelectWindow()        - Select a previously added window
; Resize::SetFactor()           - Set the factor for the movement and size adjustment (Default: 100%)
; Resize::SetListColumn()       - Define ListIcon column for automatic resizing
;}

DeclareModule Resize
  
  ;- ===========================================================================
  ;-   DeclareModule (Resize)
  ;- ===========================================================================
  
  ;{ ____ Constants_____
  EnumerationBinary Resize
    #MoveX
    #MoveY
    #Width
    #Height
    #HCenter
    #VCenter
    #HFactor
    #VFactor
    #Column
  EndEnumeration
  ;}
  
  Declare.i AddContainer(GNum.i, WindowNum.i=#PB_Default)
  Declare.i AddWindow(WindowNum.i, minWidth.i=#PB_Default, minHeight.i=#PB_Ignore, maxWidth.i=#PB_Ignore, maxHeight.i=#PB_Ignore)
  Declare.i AddGadget(GNum.i, Flags.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
  Declare.i RemoveContainer(GNum.i, WindowNum.i=#PB_Default)
  Declare.i RemoveGadget(GNum.i, WindowNum.i=#PB_Default)
  Declare.i RemoveWindow(WindowNum.i)
  Declare.i RestoreWindow(WindowNum.i)
  Declare.i SelectWindow(WindowNum.i)
  Declare.i SetFactor(GNum.i, Type.i, Percent.s, WindowNum.i=#PB_Default)
  Declare.i SetListIconColumn(GNum.i, Column.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
  
EndDeclareModule

Module Resize
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module (Resize)
  ;- ===========================================================================
  
  Structure RGEx_Gadgets_Structure   ;{ RGEx()\Gadget(gNum)\...
    X.i
    Y.i
    Width.i
    Height.i
    HFactor.f
    VFactor.f
    Column.i
    ColWidth.i
    Flags.i
  EndStructure ;}
  
  Structure RGEx_Container_Structure ;{ RGEx()\Container(gGum)\...
    X.i
    Y.i
    Width.i
    Height.i
    Map Gadget.RGEx_Gadgets_Structure()
  EndStructure ;}
  
  Structure ResizeEx_Structure       ;{ RGEx(winNum)\...
    X.i
    Y.i
    Width.i
    Height.i
    minWidth.i
    minHeight.i
    maxWidth.i
    maxHeight.i
    Flags.i
    Map Container.RGEx_Container_Structure()
    Map Gadget.RGEx_Gadgets_Structure()
  EndStructure ;}  
  Global NewMap RGEx.ResizeEx_Structure()
  
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  ;- __________ Events __________
  
  Procedure _ResizeHandler()
    Define.i X, Y, Width, Height
    Define.i OffSetX, OffSetY
    Define.i GNum, WinNum
    Define.i ContainerNum = EventGadget()
    
    WinNum = GetGadgetData(ContainerNum)
    If FindMapElement(RGEx(), Str(WinNum))
      
      If FindMapElement(RGEx()\Container(), Str(ContainerNum))
        
        ForEach RGEx()\Container()\Gadget()
          
          GNum = Val(MapKey(RGEx()\Container()\Gadget()))
          If IsGadget(GNum)
            
            OffSetX = GadgetWidth(ContainerNum)  - RGEx()\Container()\Width
            OffsetY = GadgetHeight(ContainerNum) - RGEx()\Container()\Height
            
            If RGEx()\Container()\Gadget()\Flags & #HFactor : OffSetX * RGEx()\Container()\Gadget()\HFactor : EndIf
            If RGEx()\Container()\Gadget()\Flags & #VFactor : OffSetY * RGEx()\Container()\Gadget()\VFactor : EndIf
            
            X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
            
            If RGEx()\Container()\Gadget()\Flags & #MoveX : X = RGEx()\Container()\Gadget()\X + OffSetX : EndIf
            If RGEx()\Container()\Gadget()\Flags & #MoveY : Y = RGEx()\Container()\Gadget()\Y + OffSetY : EndIf
            
            If RGEx()\Container()\Gadget()\Flags & #HCenter : X = (GadgetWidth(ContainerNum) - GadgetWidth(GNum))  / 2 : EndIf
            If RGEx()\Container()\Gadget()\Flags & #VCenter : Y = (GadgetHeight(ContainerNum) - GadgetHeight(GNum)) / 2 : EndIf
            
            If RGEx()\Container()\Gadget()\Flags & #Column
              SetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, RGEx()\Container()\Gadget()\ColWidth + OffSetX, RGEx()\Gadget()\Column)
            EndIf
            
            If RGEx()\Container()\Gadget()\Flags & #Width  : Width  = RGEx()\Container()\Gadget()\Width  + OffSetX : EndIf
            If RGEx()\Container()\Gadget()\Flags & #Height : Height = RGEx()\Container()\Gadget()\Height + OffSetY : EndIf
            
            ResizeGadget(GNum, X, Y, Width, Height)
            
          EndIf
          
        Next
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.i X, Y, Width, Height
    Define.i OffSetX, OffSetY
    Define.i GNum, WinNum = EventWindow()
    
    If FindMapElement(RGEx(), Str(WinNum))
      
      ForEach RGEx()\Gadget()
        
        GNum = Val(MapKey(RGEx()\Gadget()))
        If IsGadget(GNum)
          
          OffSetX = WindowWidth(WinNum)  - RGEx()\Width
          OffsetY = WindowHeight(WinNum) - RGEx()\Height
          
          If RGEx()\Gadget()\Flags & #HFactor : OffSetX * RGEx()\Gadget()\HFactor : EndIf
          If RGEx()\Gadget()\Flags & #VFactor : OffSetY * RGEx()\Gadget()\VFactor : EndIf
          
          X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
          
          
          If RGEx()\Gadget()\Flags & #MoveX : X = RGEx()\Gadget()\X + OffSetX : EndIf
          If RGEx()\Gadget()\Flags & #MoveY : Y = RGEx()\Gadget()\Y + OffSetY : EndIf
          
          If RGEx()\Gadget()\Flags & #HCenter : X = (WindowWidth(WinNum)  - GadgetWidth(GNum))  / 2 : EndIf
          If RGEx()\Gadget()\Flags & #VCenter : Y = (WindowHeight(WinNum) - GadgetHeight(GNum)) / 2 : EndIf
          
          If RGEx()\Gadget()\Flags & #Column And RGEx()\Gadget()\Flags & #Width
            SetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, RGEx()\Gadget()\ColWidth + OffSetX, RGEx()\Gadget()\Column)
          EndIf
          
          If RGEx()\Gadget()\Flags & #Width  : Width  = RGEx()\Gadget()\Width  + OffSetX : EndIf
          If RGEx()\Gadget()\Flags & #Height : Height = RGEx()\Gadget()\Height + OffSetY : EndIf
          
          ResizeGadget(GNum, X, Y, Width, Height)
          
        EndIf
        
      Next
      
    EndIf
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures (Resize)
  ;- ==========================================================================
  
  Procedure.i AddContainer(GNum.i, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
    
    If IsGadget(GNum)
      
      If AddMapElement(RGEx()\Container(), Str(GNum))
        
        RGEx()\Container()\X = GadgetX(GNum)
        RGEx()\Container()\Y = GadgetY(GNum)
        RGEx()\Container()\Width  = GadgetWidth(GNum)
        RGEx()\Container()\Height = GadgetHeight(GNum)
        
        SetGadgetData(GNum, WindowNum)
        BindGadgetEvent(GNum, @_ResizeHandler(), #PB_EventType_Resize)
        
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure.i AddWindow(WindowNum.i, minWidth.i=#PB_Default, minHeight.i=#PB_Ignore, maxWidth.i=#PB_Ignore, maxHeight.i=#PB_Ignore)
    
    If IsWindow(WindowNum)
      
      If AddMapElement(RGEx(), Str(WindowNum))
        
        RGEx()\X = WindowX(WindowNum)
        RGEx()\Y = WindowY(WindowNum)
        RGEx()\Width  = WindowWidth(WindowNum)
        RGEx()\Height = WindowHeight(WindowNum)
        RGEx()\minWidth  = minWidth
        RGEx()\minHeight = minHeight
        RGEx()\maxWidth  = maxWidth
        RGEx()\maxHeight = maxHeight
        RGEx()\Flags  = GetWindowState(WindowNum)
        
        WindowBounds(WindowNum, minWidth, minHeight, maxWidth, maxHeight)
        
        BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
        
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure.i AddGadget(GNum.i, Flags.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
    Define.i X, Y
    
    If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
    
    If IsGadget(GNum)
      
      If ContainerNum = #PB_Ignore ;{ normal gadgets
        
        If AddMapElement(RGEx()\Gadget(), Str(GNum))
          
          RGEx()\Gadget()\X = GadgetX(GNum)
          RGEx()\Gadget()\Y = GadgetY(GNum)
          RGEx()\Gadget()\Width   = GadgetWidth(GNum)
          RGEx()\Gadget()\Height  = GadgetHeight(GNum)
          RGEx()\Gadget()\Flags   = Flags.i
          RGEx()\Gadget()\HFactor = 1
          RGEx()\Gadget()\VFActor = 1
          
          If RGEx()\Gadget()\Flags & #HCenter
            X = (WindowWidth(WindowNum)  - GadgetWidth(GNum))  / 2
            ResizeGadget(GNum, X, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          
          If RGEx()\Gadget()\Flags & #VCenter
            Y = (WindowHeight(WindowNum) - GadgetHeight(GNum)) / 2
            ResizeGadget(GNum, #PB_Ignore, Y, #PB_Ignore, #PB_Ignore)
          EndIf
          
          ProcedureReturn #True
        EndIf
        ;}
      Else                         ;{ container gadget
        
        If IsGadget(ContainerNum)
          
          If FindMapElement(RGEx()\Container(), Str(ContainerNum))
            
            If AddMapElement(RGEx()\Container()\Gadget(), Str(GNum))
              
              RGEx()\Container()\Gadget()\X = GadgetX(GNum)
              RGEx()\Container()\Gadget()\Y = GadgetY(GNum)
              RGEx()\Container()\Gadget()\Width   = GadgetWidth(GNum)
              RGEx()\Container()\Gadget()\Height  = GadgetHeight(GNum)
              RGEx()\Container()\Gadget()\Flags   = Flags
              RGEx()\Container()\Gadget()\HFactor = 1
              RGEx()\Container()\Gadget()\VFActor = 1
              
              If Flags & #HCenter
                X = (GadgetWidth(ContainerNum)  - GadgetWidth(GNum))  / 2
                ResizeGadget(GNum, X, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              EndIf
              
              If Flags & #VCenter
                Y = (GadgetHeight(ContainerNum) - GadgetHeight(GNum)) / 2
                ResizeGadget(GNum, #PB_Ignore, Y, #PB_Ignore, #PB_Ignore)
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          EndIf
          
        EndIf
        ;}  
      EndIf
      
    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure   Free()
    
    ClearMap(RGEx())
    
  EndProcedure
  
  Procedure.i RemoveGadget(GNum.i, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      
      If DeleteMapElement(RGEx()\Gadget(), Str(GNum))
        ProcedureReturn #True
      EndIf
      
    Else
      
      If DeleteMapElement(RGEx(Str(WindowNum))\Gadget(), Str(GNum))
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i RemoveContainer(GNum.i, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      
      If DeleteMapElement(RGEx()\Container(), Str(GNum))
        UnbindGadgetEvent(GNum, @_ResizeHandler(), #PB_EventType_Resize)
        ProcedureReturn #True
      EndIf
      
    Else
      
      If DeleteMapElement(RGEx(Str(WindowNum))\Container(), Str(GNum))
        UnbindGadgetEvent(GNum, @_ResizeHandler(), #PB_EventType_Resize)
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i RemoveWindow(WindowNum.i)
    
    If DeleteMapElement(RGEx(), Str(WindowNum))
      UnbindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
      ProcedureReturn #True
    EndIf 
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i RestoreWindow(WindowNum.i)
    Define.i GNum
    
    If FindMapElement(RGEx(), Str(WindowNum))
      
      If IsWindow(WindowNum)
        ResizeWindow(WindowNum, #PB_Ignore, #PB_Ignore, RGEx()\Width, RGEx()\Height)
        ForEach RGEx()\Container()
          GNum = Val(MapKey(RGEx()\Container()))
          If IsGadget(GNum) : ResizeGadget(GNum, RGEx()\Container()\X, RGEx()\Container()\Y, RGEx()\Container()\Width, RGEx()\Container()\Height) : EndIf
        Next
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i SelectWindow(WindowNum.i)
    
    If FindMapElement(RGEx(), Str(WindowNum))
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetFactor(GNum.i, Type.i, Percent.s, WindowNum.i=#PB_Default)
    
    If WindowNum <> #PB_Default : FindMapElement(RGEx(), Str(WindowNum)) : EndIf
    
    If FindMapElement(RGEx()\Gadget(), Str(GNum))
      
      Percent = Trim(RemoveString(Percent, "%"))
      Select Type
        Case #HFactor
          RGEx()\Gadget()\HFactor = Val(Percent) / 100
          RGEx()\Gadget()\Flags | #HFactor
          ProcedureReturn #True
        Case #VFactor
          RGEx()\Gadget()\VFactor = Val(Percent) / 100
          RGEx()\Gadget()\Flags | #VFactor
          ProcedureReturn #True
      EndSelect
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetListIconColumn(GNum.i, Column.i, ContainerNum.i=#PB_Ignore, WindowNum.i=#PB_Default)
    
    If WindowNum = #PB_Default
      WindowNum = Val(MapKey(RGEx()))
    Else
      FindMapElement(RGEx(), Str(WindowNum))
    EndIf
    
    If IsGadget(GNum)
      
      If ContainerNum = #PB_Ignore ;{ normal list gadgets
        
        If FindMapElement(RGEx()\Gadget(), Str(GNum))
          RGEx()\Gadget()\Column   = Column
          RGEx()\Gadget()\ColWidth = GetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, Column)
          RGEx()\Gadget()\Flags | #Column
        EndIf
        ;}
      Else                         ;{ list in container gadget
        
        If IsGadget(ContainerNum)
          
          If FindMapElement(RGEx()\Container(), Str(ContainerNum))
            
            If FindMapElement(RGEx()\Container()\Gadget(), Str(GNum))
              RGEx()\Container()\Gadget()\Column   = Column
              RGEx()\Container()\Gadget()\ColWidth = GetGadgetItemAttribute(GNum, -1, #PB_ListIcon_ColumnWidth, Column)
              RGEx()\Container()\Gadget()\Flags | #Column
            EndIf
            
          EndIf
          
        EndIf
        ;}
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window = 0
  #StatusBar = 1
  
  Enumeration
    #Button_0
    #Button_1
    #Button_2
    #Button_3
    #Button_4
    #Button_5
    #List
    #Editor1
    #Editor2
    #Container
  EndEnumeration
  
  Window::Load()
  
  If OpenWindow(#Window, 358, 178, 300, 275, " Example", #PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_TitleBar|#PB_Window_ScreenCentered |#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget)
    
    ButtonGadget(#Button_0,   5,   5, 50, 25, "Resize -")
    ButtonGadget(#Button_1, 245,   5, 50, 25, "Resize +")
    ButtonGadget(#Button_2,   5, 240, 50, 25, "Reset")
    ButtonGadget(#Button_3, 250, 125, 45, 20, "Button")
    ListIconGadget(#List, 55, 30, 190, 210, "Column", 56, #PB_ListIcon_GridLines)
    AddGadgetColumn(#List, 1, "Column 1", 130)
    ButtonGadget(#Button_4, 55, 245, 80, 25, "Container")
    EditorGadget(#Editor1, 250,  35, 45, 85)
    EditorGadget(#Editor2, 250, 150, 45, 90)
    If ContainerGadget(#Container, 57, 30, 186, 210, #PB_Container_Single)
      ButtonGadget(#Button_5, 0, 0, 50, 25, "List")
      CloseGadgetList()
      HideGadget(#Container, #True)
    EndIf
    
    If Resize::AddWindow(#Window, 300, 275, 400, 375)
      Resize::AddGadget(#Button_1,  Resize::#MoveX)
      Resize::AddGadget(#Button_2,  Resize::#MoveY)
      Resize::AddGadget(#Button_3,  Resize::#MoveX|Resize::#MoveY)
      Resize::SetFactor(#Button_3,  Resize::#VFactor, "50%", #Window)
      Resize::AddGadget(#Button_4,  Resize::#HCenter|Resize::#MoveY)
      Resize::AddGadget(#Editor1,   Resize::#MoveX|Resize::#Height)
      Resize::SetFactor(#Editor1,   Resize::#VFactor, "50%", #Window)
      Resize::AddGadget(#Editor2,   Resize::#MoveX|Resize::#MoveY|Resize::#Height)
      Resize::SetFactor(#Editor2,   Resize::#VFactor, "50%")
      Resize::AddGadget(#List,      Resize::#Height|Resize::#Width)
      Resize::AddGadget(#Container, Resize::#Height|Resize::#Width)
      If Resize::AddContainer(#Container, #Window)
        Resize::AddGadget(#Button_5, Resize::#HCenter|Resize::#VCenter, #Container)
      EndIf
      Resize::SetListIconColumn(#List, 1)
    EndIf
    
    Window::RestoreSize(#Window)
    
    ExitWindow = #False
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          Window::StoreSize(#Window)
          ExitWindow = #True
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button_0
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 250, 300)
            Case #Button_1
              ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, 350, 400)
            Case #Button_2
              Resize::RestoreWindow(#Window)
            Case #Button_4
              HideGadget(#List, #True)
              HideGadget(#Container, #False)
            Case #Button_5
              HideGadget(#List, #False)
              HideGadget(#Container, #True)
          EndSelect
      EndSelect
    Until ExitWindow
    
    CloseWindow(#Window)
  EndIf
  
  Window::Save()
  
CompilerEndIf
