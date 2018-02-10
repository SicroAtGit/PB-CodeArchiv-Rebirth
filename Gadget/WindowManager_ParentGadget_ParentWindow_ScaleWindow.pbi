;   Description: Manage gadgets to make ParentGadget(), ParentWindow(), ScaleWindow() possible
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27970
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 mk-soft
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

;- Start Include WindowManager.pbi

;-TOP
; Comment       : Window Manager
; Author        : mk-soft
; Second Author :
; File          : WindowManager.pbi
; Version       : 1.04
; Created       :
; Modified      : 01.05.2014
;
; Compilermode  : All
; OS            : All
;
; ***************************************************************************************

; ***************************************************************************************

EnableExplicit

;- *** Window und Gadget Objects ***

Structure GadgetData ; Data Objects
  *parent.GadgetData
  type.i
  handle.i
  id.i
  List Gadgets.GadgetData()
  ; Gadget Initial Data
  x.i
  y.i
  dx.i
  dy.i
  text.s
  param1.i
  param2.i
  param3.i
  flags.i
  ; UserData ScaleWindow
  image.i
  image2.i
  sizeimage.i
  sizeimage2.i
  ; UserData
  ; ...
EndStructure

Global NewList ListWindow.GadgetData()
Define *Glist.GadgetData

; ---------------------------------------------------------------------------------------

; Function Object Manager
Declare ParentGadget(gadget) ; PB-GadgetID
Declare ParentWindow(gadget) ; PB-WindowID
Declare GetGadgetUserData(gadget) ; Pointer to GadgetData Object

; ---------------------------------------------------------------------------------------

; Function Image Manager
Declare GetImageID(handle)

; ---------------------------------------------------------------------------------------

; Function ScaleWindow
Declare UpdateImages()
Declare ScaleWindow(id)
Declare RestoreWindow(id, position = 0)

; ---------------------------------------------------------------------------------------

Procedure MyOpenWindow(Window, x, y, InnerWidth, InnerHeight, Titel.s, Flags = #PB_Window_SystemMenu, ParentWindowID = 0)
  
  Protected result, handle, id
  Shared *Glist.GadgetData
  
  result = OpenWindow(Window, x, y, InnerWidth, InnerHeight, Titel.s, Flags, ParentWindowID)
  
  If result = 0
    ProcedureReturn 0
  EndIf
  
  If Window = #PB_Any
    handle = WindowID(result)
    id = result
  Else
    handle = WindowID(Window)
    id = Window
  EndIf
  
  ForEach ListWindow()
    If ListWindow()\id = Window
      DeleteElement(ListWindow())
      Break
    EndIf
  Next
  
  *Glist = AddElement(ListWindow())
  With ListWindow()
    \type = -1
    \handle = handle
    \id = id
    \x = x
    \y = y
    \dx = InnerWidth
    \dy = InnerHeight
    \text = Titel
  EndWith
  ProcedureReturn result
  
EndProcedure

Macro OpenWindow(Window, x, y, InnerWidth, InnerHeight, Titel, Flags = #PB_Window_SystemMenu, ParentWindowID = 0)
  MyOpenWindow(Window, x, y, InnerWidth, InnerHeight, Titel, Flags, ParentWindowID)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure MyUseGadgetList(WindowID)
  
  Protected result
  Shared *Glist
  
  result = UseGadgetList(WindowID)
  If result
    ForEach ListWindow()
      If ListWindow()\handle = WindowID
        *Glist = ListWindow()
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn result
  
EndProcedure

Macro UseGadgetList(WindowID)
  MyUseGadgetList(WindowID)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure MyCloseWindow(Window)
  
  ForEach ListWindow()
    If ListWindow()\id = Window
      DeleteElement(ListWindow())
      Break
    EndIf
  Next
  
  CloseWindow(Window)
  
EndProcedure

Macro CloseWindow(Window)
  MyCloseWindow(Window)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure CreateGadget(type, gadget, x, y, dx, dy, text.s, param1, param2, param3, flags)
  
  Protected result, handle, id
  Protected *ParentGlist.GadgetData, *NewGlist.GadgetData
  
  Shared *Glist.GadgetData
  
  Select type
    Case #PB_GadgetType_Button : result = ButtonGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_ButtonImage : result = ButtonImageGadget(gadget, x, y, dx, dy, param1, flags)
    Case #PB_GadgetType_Calendar : result = CalendarGadget(gadget, x, y, dx, dy, param1, flags)
    Case #PB_GadgetType_Canvas : result = CanvasGadget(gadget, x, y, dx, dy, flags)
    Case #PB_GadgetType_CheckBox : result = CheckBoxGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_ComboBox : result = ComboBoxGadget(gadget, x, y, dx, dy, flags)
    Case #PB_GadgetType_Container : result = ContainerGadget(gadget, x, y, dx, dy, flags)
    Case #PB_GadgetType_Date : result = DateGadget(gadget, x, y, dx, dy, text, param1, flags)
    Case #PB_GadgetType_Editor : result = EditorGadget(gadget, x, y, dx, dy, flags)
    Case #PB_GadgetType_ExplorerCombo : result = ExplorerComboGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_ExplorerList : result = ExplorerListGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_ExplorerTree : result = ExplorerTreeGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_Frame : result = FrameGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_HyperLink : result = HyperLinkGadget(gadget, x, y, dx, dy, text, param1, flags)
    Case #PB_GadgetType_Image : result = ImageGadget(gadget, x, y, dx, dy, param1, flags)
    Case #PB_GadgetType_IPAddress : result = IPAddressGadget(gadget, x, y, dx, dy)
    Case #PB_GadgetType_ListIcon : result = ListIconGadget(gadget, x, y, dx, dy, text, param1, flags)
    Case #PB_GadgetType_ListView : result = ListViewGadget(gadget, x, y, dx, dy, flags)
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      Case #PB_GadgetType_MDI : result = MDIGadget(gadget, x, y, dx, dy, param1, param2, flags)
      CompilerEndIf
    Case #PB_GadgetType_Option : result = OptionGadget(gadget, x, y, dx, dy, text)
    Case #PB_GadgetType_Panel : result = PanelGadget(gadget, x, y, dx, dy)
    Case #PB_GadgetType_ProgressBar : result = ProgressBarGadget(gadget, x, y, dx, dy, param1, param2, flags)
    Case #PB_GadgetType_Scintilla : result = ScintillaGadget(gadget, x, y, dx, dy, param1)
    Case #PB_GadgetType_ScrollArea : result = ScrollAreaGadget(gadget, x, y, dx, dy, param1, param2, param3, flags)
    Case #PB_GadgetType_ScrollBar : result = ScrollBarGadget(gadget, x, y, dx, dy, param1, param2, param3, flags)
    Case #PB_GadgetType_Shortcut : result = ShortcutGadget(gadget, x, y, dx, dy, param1)
    Case #PB_GadgetType_Spin : result = SpinGadget(gadget, x, y, dx, dy, param1, param2, flags)
    Case #PB_GadgetType_Splitter : result = SplitterGadget(gadget, x, y, dx, dy, param1, param2, flags)
    Case #PB_GadgetType_String : result = StringGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_Text : result = TextGadget(gadget, x, y, dx, dy, text, flags)
    Case #PB_GadgetType_TrackBar : result = TrackBarGadget(gadget, x, y, dx, dy, param1, param2, flags)
    Case #PB_GadgetType_Tree : result = TreeGadget(gadget, x, y, dx, dy, flags)
    Case #PB_GadgetType_Web : result = WebGadget(gadget, x, y, dx, dy, text)
  EndSelect
  
  If result = 0
    ProcedureReturn 0
  EndIf
  
  If gadget = #PB_Any
    handle = GadgetID(gadget)
    id = result
  Else
    handle = result
    id = gadget
  EndIf
  
  *NewGlist = AddElement(*Glist\Gadgets())
  *Glist\Gadgets()\parent = *Glist
  
  With *Glist\Gadgets()
    \type = type
    \handle = handle
    \id = id
    \x = x
    \y = y
    \dx = dx
    \dy = dy
    \text = text
    \param1 = param1
    \param2 = param2
    \param3 = param3
    \flags = flags
    If type = #PB_GadgetType_Container Or type = #PB_GadgetType_Panel Or type = #PB_GadgetType_ScrollArea
      *Glist = *NewGlist
    EndIf
  EndWith
  
  ProcedureReturn result
  
EndProcedure

; Macros
Macro ButtonGadget(Gadget, x, y, dx, dy, text, Flags = 0)
  CreateGadget(#PB_GadgetType_Button, Gadget, x, y, dx, dy, text, 0, 0, 0, Flags)
EndMacro

Macro ButtonImageGadget(Gadget, x, y, dx, dy, ImageID, Flags = 0)
  CreateGadget(#PB_GadgetType_ButtonImage, Gadget, x, y, dx, dy, "", ImageID, 0, 0, Flags)
EndMacro

Macro CalendarGadget(gadget, x, y, dx, dy, Date, Flags = 0)
  CreateGadget(#PB_GadgetType_Calendar, Gadget, x, y, dx, dy, "", Date, 0, 0, Flags)
EndMacro

Macro CanvasGadget(gadget, x, y, dx, dy, Flags = 0)
  CreateGadget(#PB_GadgetType_Canvas, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro CheckBoxGadget(gadget, x, y, dx, dy, text, Flags = 0)
  CreateGadget(#PB_GadgetType_CheckBox, Gadget, x, y, dx, dy, text, 0, 0, 0, Flags)
EndMacro

Macro ComboBoxGadget(gadget, x, y, dx, dy, Flags = 0)
  CreateGadget(#PB_GadgetType_ComboBox, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro ContainerGadget(gadget, x, y, dx, dy, Flags = 0)
  CreateGadget(#PB_GadgetType_Container, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro DateGadget(gadget, x, y, dx, dy, Mask, Date, Flags = 0)
  CreateGadget(#PB_GadgetType_Date, Gadget, x, y, dx, dy, Mask, Date, 0, 0, Flags)
EndMacro

Macro EditorGadget(gadget, x, y, dx, dy, Flags = 0)
  CreateGadget(#PB_GadgetType_Editor, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro ExplorerComboGadget(gadget, x, y, dx, dy, Directory, Flags = 0)
  CreateGadget(#PB_GadgetType_ExplorerCombo, Gadget, x, y, dx, dy, Directory, 0, 0, 0, Flags)
EndMacro

Macro ExplorerListGadget(gadget, x, y, dx, dy, Directory, Flags = 0)
  CreateGadget(#PB_GadgetType_ExplorerList, Gadget, x, y, dx, dy, Directory, 0, 0, 0, Flags)
EndMacro

Macro ExplorerTreeGadget(gadget, x, y, dx, dy, Directory, Flags = 0)
  CreateGadget(#PB_GadgetType_ExplorerTree, Gadget, x, y, dx, dy, Directory, 0, 0, 0, Flags)
EndMacro

Macro FrameGadget(gadget, x, y, dx, dy, text, Flags = 0)
  CreateGadget(#PB_GadgetType_Frame, Gadget, x, y, dx, dy, text, 0, 0, 0, Flags)
EndMacro

Macro HyperLinkGadget(gadget, x, y, dx, dy, text, Color, Flags = 0)
  CreateGadget(#PB_GadgetType_HyperLink, Gadget, x, y, dx, dy, text, Color, 0, 0, Flags)
EndMacro

Macro ImageGadget(gadget, x, y, dx, dy, ImageID, Flags = 0)
  CreateGadget(#PB_GadgetType_Image, Gadget, x, y, dx, dy, "", ImageID, 0, 0, Flags)
EndMacro

Macro IPAddressGadget(gadget, x, y, dx, dy)
  CreateGadget(#PB_GadgetType_IPAddress, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro ListIconGadget(gadget, x, y, dx, dy, Titel, TitelWidth, Flags = 0)
  CreateGadget(#PB_GadgetType_ListIcon, Gadget, x, y, dx, dy, Titel, TitelWidth, 0, 0, Flags)
EndMacro

Macro ListViewGadget(gadget, x, y, dx, dy, Flags = 0)
  CreateGadget(#PB_GadgetType_ListView, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Macro MDIGadget(gadget, x, y, dx, dy, SubMenu, FirstMenuItem, Flags = 0)
    CreateGadget(#PB_GadgetType_MDI, Gadget, x, y, dx, dy, "", SubMenu, FirstMenuItem, 0, Flags)
  EndMacro
CompilerEndIf

Macro OptionGadget(gadget, x, y, dx, dy, text)
  CreateGadget(#PB_GadgetType_Option, Gadget, x, y, dx, dy, text, 0, 0, 0, Flags)
EndMacro

Macro PanelGadget(gadget, x, y, dx, dy)
  CreateGadget(#PB_GadgetType_Panel, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro ProgressBarGadget(gadget, x, y, dx, dy, Minimum, Maximum, Flags = 0)
  CreateGadget(#PB_GadgetType_ProgressBar, Gadget, x, y, dx, dy, "", Minimum, Maximum, 0, Flags)
EndMacro

Macro ScintillaGadget(gadget, x, y, dx, dy, Callback)
  CreateGadget(#PB_GadgetType_Scintilla, Gadget, x, y, dx, dy, "", Callback, 0, 0, Flags)
EndMacro

Macro ScrollAreaGadget(gadget, x, y, dx, dy, param1, param2, param3, Flags = 0)
  CreateGadget(#PB_GadgetType_ScrollArea, Gadget, x, y, dx, dy, "", param1, param2, param3, Flags)
EndMacro

Macro ScrollBarGadget(gadget, x, y, dx, dy, param1, param2, param3, Flags = 0)
  CreateGadget(#PB_GadgetType_ScrollBar, Gadget, x, y, dx, dy, "", param1, parma2, param3, Flags)
EndMacro

Macro ShortcutGadget(gadget, x, y, dx, dy, Shortcut)
  CreateGadget(#PB_GadgetType_Shortcut, Gadget, x, y, dx, dy, "", Shortcut, 0, 0, Flags)
EndMacro

Macro SpinGadget(gadget, x, y, dx, dy, param1, param2, Flags = 0)
  CreateGadget(#PB_GadgetType_Spin, Gadget, x, y, dx, dy, "", param1, param2, 0, Flags)
EndMacro

Macro SplitterGadget(gadget, x, y, dx, dy, param1, param2, Flags = 0)
  CreateGadget(#PB_GadgetType_Splitter, Gadget, x, y, dx, dy, "", param1, param2, 0, Flags)
EndMacro

Macro StringGadget(gadget, x, y, dx, dy, text, Flags = 0)
  CreateGadget(#PB_GadgetType_String, Gadget, x, y, dx, dy, text, 0, 0, 0, Flags)
EndMacro

Macro TextGadget(gadget, x, y, dx, dy, text, Flags = 0)
  CreateGadget(#PB_GadgetType_Text, Gadget, x, y, dx, dy, text, 0, 0, 0, Flags)
EndMacro

Macro TrackBarGadget(gadget, x, y, dx, dy, param1, param2, Flags = 0)
  CreateGadget(#PB_GadgetType_TrackBar, Gadget, x, y, dx, dy, "", param1, param2, 0, Flags)
EndMacro

Macro TreeGadget(gadget, x, y, dx, dy, Flags = 0)
  CreateGadget(#PB_GadgetType_Tree, Gadget, x, y, dx, dy, "", 0, 0, 0, Flags)
EndMacro

Macro WebGadget(gadget, x, y, dx, dy, url)
  CreateGadget(#PB_GadgetType_Web, Gadget, x, y, dx, dy, url, 0, 0, 0, 0)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure DeleteGadgetData(List GList.GadgetData(), gadget)
  
  Protected result
  
  result = #False
  
  ForEach GList()
    If GList()\id = gadget
      DeleteElement(GList())
      LastElement(GList())
      result = #True
      Break
    ElseIf ListSize(GList()\Gadgets())
      result = DeleteGadgetData(Glist()\Gadgets(), gadget)
      If result
        Break
      EndIf
    EndIf
  Next
  
  ProcedureReturn result
  
EndProcedure

; ---------------------------------------------------------------------------------------

Procedure MyFreeGadget(Gadget)
  
  ForEach ListWindow()
    If DeleteGadgetData(ListWindow()\Gadgets(), gadget)
      Break
    EndIf
  Next
  
  FreeGadget(Gadget)
  
EndProcedure

Macro FreeGadget(Gadget)
  MyFreeGadget(Gadget)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure FindGadgetData(List GList.GadgetData(), gadget)
  
  Protected *result
  
  *result = 0
  
  ForEach GList()
    If GList()\id = gadget
      *result = GList()
      Break
    ElseIf ListSize(GList()\Gadgets())
      *result = FindGadgetData(Glist()\Gadgets(), gadget)
      If *result
        Break
      EndIf
    EndIf
  Next
  
  ProcedureReturn *result
  
EndProcedure

; ---------------------------------------------------------------------------------------

Procedure MyOpenGadgetList(gadget, gadgetitem)
  
  Protected *result
  Shared *Glist.GadgetData
  
  ForEach ListWindow()
    *result = FindGadgetData(ListWindow()\Gadgets(), gadget)
    If *result
      *Glist = *result
      Break
    EndIf
  Next
  If gadgetitem >= 0
    OpenGadgetList(gadget, gadgetitem)
  Else
    OpenGadgetList(gadget)
  EndIf
  
EndProcedure

Macro OpenGadgetList(gadget, gadgetitem = -1)
  MyOpenGadgetList(gadget, gadgetitem)
EndMacro


; ---------------------------------------------------------------------------------------

Procedure MyCloseGadgetList()
  
  Shared *Glist.GadgetData
  
  If *Glist\parent
    *Glist = *Glist\parent
  EndIf
  
  CloseGadgetList()
  
EndProcedure

Macro CloseGadgetList()
  MyCloseGadgetList()
EndMacro

; ---------------------------------------------------------------------------------------

Procedure ParentGadget(gadget)
  
  Protected *GList.GadgetData
  
  ForEach ListWindow()
    *GList = FindGadgetData(ListWindow()\Gadgets(), gadget)
    If *Glist
      If *Glist\parent
        If *Glist\parent\type >= 0
          ProcedureReturn *Glist\parent\id
        EndIf
      EndIf
    EndIf
  Next
  
  ProcedureReturn -1
  
EndProcedure

; ---------------------------------------------------------------------------------------

Procedure ParentWindow(gadget)
  
  Protected result, *parent.GadgetData
  
  Shared *Glist
  
  result = -1
  
  ForEach ListWindow()
    *GList = FindGadgetData(ListWindow()\Gadgets(), gadget)
    If *Glist
      *parent = *Glist
      Repeat
        If *parent\type < 0
          result = *parent\id
          Break 2
        EndIf
        *parent = *parent\parent
      Until *parent = 0
    EndIf
  Next
  
  ProcedureReturn result
  
EndProcedure

; ---------------------------------------------------------------------------------------

Procedure GetGadgetUserData(gadget)
  
  Protected *result
  
  *result = 0
  
  ForEach ListWindow()
    *result = FindGadgetData(ListWindow()\Gadgets(), gadget)
    If *result
      Break
    EndIf
  Next
  
  ProcedureReturn *result
  
EndProcedure

; ***************************************************************************************

;- *** Image Objects ***

Structure ImageData
  handle.i
  id.i
  filename.s
EndStructure

Global NewMap ListImages.ImageData()

; ---------------------------------------------------------------------------------------

Procedure MyLoadImage(Image, Filename.s)
  
  Protected result, handle, id, key.s
  
  result = LoadImage(Image, Filename)
  If result = 0
    ProcedureReturn 0
  EndIf
  If Image = #PB_Any
    handle = ImageID(result)
    id = result
  Else
    handle = result
    id = Image
  EndIf
  
  key = Str(handle)
  AddMapElement(ListImages(), key)
  With ListImages()
    \handle = handle
    \id = id
    \filename = Filename
  EndWith
  
  ProcedureReturn result
  
EndProcedure

Macro LoadImage(Image, Filename)
  MyLoadImage(Image, Filename)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure MyCatchImage(Image, *Memory, Size = 0)
  
  Protected result, handle, id, key.s
  
  result = CatchImage(Image, *Memory, Size)
  If result = 0
    ProcedureReturn 0
  EndIf
  If Image = #PB_Any
    handle = ImageID(result)
    id = result
  Else
    handle = result
    id = Image
  EndIf
  key = Str(handle)
  AddMapElement(ListImages(), key)
  With ListImages()
    \handle = handle
    \id = id
    \filename = ":memory:"
  EndWith
  
  ProcedureReturn result
  
EndProcedure

Macro CatchImage(Image, Memory, Size = 0)
  MyCatchImage(Image, Memory, Size)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure MyFreeImage(Image)
  
  Protected key.s
  
  If IsImage(Image)
    key = Str(ImageID(Image))
    DeleteMapElement(ListImages(), key)
    FreeImage(Image)
  EndIf
  
EndProcedure

Macro FreeImage(Image)
  MyFreeImage(Image)
EndMacro

; ---------------------------------------------------------------------------------------

Procedure GetImageID(Handle)
  
  Protected result, key.s
  
  result = -1
  key = Str(Handle)
  If FindMapElement(ListImages(), key)
    result = ListImages()\id
  EndIf
  
  ProcedureReturn result
  
EndProcedure

; ---------------------------------------------------------------------------------------

; ***************************************************************************************

;- *** Scale Windows ***

Procedure HelpUpdateImages(List GList.GadgetData())
  
  ForEach GList()
    With Glist()
      If GadgetType(\id) = #PB_GadgetType_Image
        If \sizeimage = 0
          \param1 = GetGadgetState(\id)
          \image = GetImageID(\param1)
        ElseIf GetGadgetState(\id) <> ImageID(\sizeimage)
          \param1 = GetGadgetState(\id)
          \image = GetImageID(\param1)
        EndIf
      ElseIf GadgetType(\id) = #PB_GadgetType_ButtonImage
        If \sizeimage = 0
          \param1 = GetGadgetAttribute(\id, #PB_Button_Image)
          \image = GetImageID(\param1)
        ElseIf GetGadgetAttribute(\id, #PB_Button_Image) <> ImageID(\sizeimage)
          \param1 = GetGadgetAttribute(\id, #PB_Button_Image)
          \image = GetImageID(\param1)
        EndIf
        If \sizeimage2 = 0
          \param2 = GetGadgetAttribute(\id, #PB_Button_PressedImage)
          \image2 = GetImageID(\param2)
        ElseIf GetGadgetAttribute(\id, #PB_Button_PressedImage) <> ImageID(\sizeimage2)
          \param2 = GetGadgetAttribute(\id, #PB_Button_PressedImage)
          \image2 = GetImageID(\param2)
        EndIf
      EndIf
      ; Client Gadgets
      If ListSize(GList()\Gadgets())
        HelpUpdateImages(GList()\Gadgets())
      EndIf
    EndWith
  Next
  
EndProcedure

; ---------------------------------------------------------------------------------------

Procedure UpdateImages()
  
  ForEach ListWindow()
    HelpUpdateImages(ListWindow()\Gadgets())
  Next
  
EndProcedure

; ***************************************************************************************

Procedure HelpScaleWindow(List GList.GadgetData(), org_dx, org_dy, win_dx, win_dy)
  
  Protected x, y, dx, dy
  
  ForEach GList()
    With Glist()
      x = \x * win_dx / org_dx
      y = \y * win_dy / org_dy
      dx = \dx * win_dx / org_dx
      dy = \dy * win_dy / org_dy
      ResizeGadget(\id, x, y, dx, dy)
      ; Images
      If GadgetType(\id) = #PB_GadgetType_Image
        If \sizeimage
          FreeImage(\sizeimage)
        EndIf
        If \param1
          dx = ImageWidth(\image) * win_dx / org_dx
          dy = ImageHeight(\image) * win_dy / org_dy
          \sizeimage = CopyImage(\image, #PB_Any)
          ResizeImage(\sizeimage, dx, dy)
          If \sizeimage
            SetGadgetState(\id, ImageID(\sizeimage))
          EndIf
        EndIf
      ElseIf GadgetType(\id) = #PB_GadgetType_ButtonImage
        If \sizeimage
          FreeImage(\sizeimage)
        EndIf
        If \param1
          dx = ImageWidth(\image) * win_dx / org_dx
          dy = ImageHeight(\image) * win_dy / org_dy
          \sizeimage = CopyImage(\image, #PB_Any)
          ResizeImage(\sizeimage, dx, dy)
          If \sizeimage
            SetGadgetAttribute(\id, #PB_Button_Image, ImageID(\sizeimage))
          EndIf
        EndIf
        If \sizeimage2
          FreeImage(\sizeimage2)
        EndIf
        If \param2
          dx = ImageWidth(\image2) * win_dx / org_dx
          dy = ImageHeight(\image2) * win_dy / org_dy
          \sizeimage2 = CopyImage(\image2, #PB_Any)
          ResizeImage(\sizeimage2, dx, dy)
          If \sizeimage2
            SetGadgetAttribute(\id, #PB_Button_PressedImage, ImageID(\sizeimage2))
          EndIf
        EndIf
      EndIf
      ; Client Gadgets
      If ListSize(GList()\Gadgets())
        HelpScaleWindow(GList()\Gadgets(), org_dx, org_dy, win_dx, win_dy)
      EndIf
    EndWith
  Next
  
EndProcedure

; -------------------------------------------------------------------------------------

Procedure ScaleWindow(id)
  
  Protected org_dx, org_dy, win_dx, win_dy, x, y, dx, dy
  Protected find
  
  ForEach ListWindow()
    If id = ListWindow()\id
      find = #True
      Break
    EndIf
  Next
  If Not find
    ProcedureReturn 0
  EndIf
  
  win_dx = WindowWidth(id)
  win_dy = WindowHeight(id)
  
  With ListWindow()
    org_dx = \dx
    org_dy = \dy
    HelpScaleWindow(\Gadgets(), org_dx, org_dy, win_dx, win_dy)
  EndWith
  
EndProcedure

Procedure RestoreWindow(id, position = 0)
  
  Protected find
  
  ForEach ListWindow()
    If id = ListWindow()\id
      find = #True
      Break
    EndIf
  Next
  If Not find
    ProcedureReturn 0
  EndIf
  
  With ListWindow()
    If position
      ResizeWindow(id, \x, \y, \dx, \dy)
    Else
      ResizeWindow(id, #PB_Ignore, #PB_Ignore, \dx, \dy)
    EndIf 
  EndWith
  
EndProcedure

;- Ende Include WindowManger.pbi

;- Example

CompilerIf #PB_Compiler_IsMainFile
  
  DisableExplicit
  
  ; ---------------------------------------------------------------------------------
  
  Procedure Main1()
    
    #WindowWidth  = 450
    #WindowHeight = 305
    
    ; Load our images..
    ;
    LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/Drive.bmp")
    LoadImage(1, #PB_Compiler_Home + "examples/sources/Data/File.bmp")
    LoadImage(2, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp")
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ; Only Windows supports .ico file format
      LoadImage(3, #PB_Compiler_Home + "examples/sources/Data/CdPlayer.ico")
    CompilerElse
      LoadImage(3, #PB_Compiler_Home + "examples/sources/Data/Drive.bmp")
    CompilerEndIf
    
    CreatePopupMenu(0)
    MenuItem(0, "Popup !")
    
    style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
    If OpenWindow(1, 0, 0, #WindowWidth, #WindowHeight, "Main 1 - Advanced Gadget Demonstration", style)
      
      ListIconGadget(5, 170, 50, 265, 200, "Column 1", 131)
      AddGadgetColumn(5, 1, "Column 2", 300)
      AddGadgetColumn(5, 2, "Column 3", 80)
      
      TextGadget(4, 10, 16, 180, 24, "Please wait while initializing...")
      
      ProgressBarGadget(3, 10, 260, #WindowWidth-25, 20, 0, 100)
      SetGadgetState(3, 50)
      
      ImageGadget      (0, 200, 5, 0, 0, ImageID(2))
      ButtonImageGadget(1, 384, 5, 50, 36, ImageID(3))
      SetGadgetAttribute(1, #PB_Button_Image, ImageID(0))
      SetGadgetAttribute(1, #PB_Button_PressedImage, ImageID(1))
      
      TreeGadget    (2,  10, 50, 150, 200)
      SetGadgetText(4, "Initialize Ok... Welcome !")
      For k=0 To 10
        AddGadgetItem(2, -1, "General "+Str(k), ImageID(1))
        AddGadgetItem(2, -1, "ScreenMode", ImageID(1))
        AddGadgetItem(2, -1, "640*480", ImageID(1), 1)
        AddGadgetItem(2, -1, "800*600", ImageID(3), 1)
        AddGadgetItem(2, -1, "1024*768", ImageID(1), 1)
        AddGadgetItem(2, -1, "1600*1200", ImageID(1), 1)
        AddGadgetItem(2, -1, "Joystick", ImageID(1))
      Next
      
      For k=0 To 100
        AddGadgetItem(5, -1, "Element "+Str(k)+Chr(10)+"C 2"+Chr(10)+"Comment 3", ImageID(3))
      Next
      
      SetGadgetState(5, 8)
      
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------
  
  Procedure Main2()
    
    style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
    If OpenWindow(2, #PB_Ignore, #PB_Ignore, 322, 220, "Main 2 - PanelGadget", style)
      PanelGadget     (20, 8, 8, 306, 203)
      AddGadgetItem (20, -1, "Panel 1")
      PanelGadget (21, 5, 5, 290, 166)
      AddGadgetItem(21, -1, "Sub-Panel 1")
      ExplorerListGadget(22, 0, 0, 285, 140, "")
      AddGadgetItem(21, -1, "Sub-Panel 2")
      AddGadgetItem(21, -1, "Sub-Panel 3")
      CloseGadgetList()
      AddGadgetItem (20, -1,"Panel 2")
      ButtonGadget(27, 10, 15, 80, 24,"Restore 1")
      ButtonGadget(28, 95, 15, 80, 24,"Restore 2")
      CloseGadgetList()
    EndIf
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------
  
  Procedure.s GadgetTypeName(type)
    
    Protected result.s
    
    Select type
      Case #PB_GadgetType_Button : result = "ButtonGadget"
      Case #PB_GadgetType_ButtonImage : result = "ButtonImageGadget"
      Case #PB_GadgetType_Calendar : result = "CalendarGadget"
      Case #PB_GadgetType_Canvas : result = "CanvasGadget"
      Case #PB_GadgetType_CheckBox : result = "CheckBoxGadget"
      Case #PB_GadgetType_ComboBox : result = "ComboBoxGadget"
      Case #PB_GadgetType_Container : result = "ContainerGadget"
      Case #PB_GadgetType_Date : result = "DateGadget"
      Case #PB_GadgetType_Editor : result = "EditorGadget"
      Case #PB_GadgetType_ExplorerCombo : result = "ExplorerComboGadget"
      Case #PB_GadgetType_ExplorerList : result = "ExplorerListGadget"
      Case #PB_GadgetType_ExplorerTree : result = "ExplorerTreeGadget"
      Case #PB_GadgetType_Frame : result = "FrameGadget"
      Case #PB_GadgetType_HyperLink : result = "HyperLinkGadget"
      Case #PB_GadgetType_Image : result = "ImageGadget"
      Case #PB_GadgetType_IPAddress : result = "IPAddressGadget"
      Case #PB_GadgetType_ListIcon : result = "ListIconGadget"
      Case #PB_GadgetType_ListView : result = "ListViewGadget"
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        Case #PB_GadgetType_MDI : result = "MDIGadget"
        CompilerEndIf
      Case #PB_GadgetType_Option : result = "OptionGadget"
      Case #PB_GadgetType_Panel : result = "PanelGadget"
      Case #PB_GadgetType_ProgressBar : result = "ProgressBarGadget"
      Case #PB_GadgetType_Scintilla : result = "ScintillaGadget"
      Case #PB_GadgetType_ScrollArea : result = "ScrollAreaGadget"
      Case #PB_GadgetType_ScrollBar : result = "ScrollBarGadget"
      Case #PB_GadgetType_Shortcut : result = "ShortcutGadget"
      Case #PB_GadgetType_Spin : result = "SpinGadget"
      Case #PB_GadgetType_Splitter : result = "SplitterGadget"
      Case #PB_GadgetType_String : result = "StringGadget"
      Case #PB_GadgetType_Text : result = "TextGadget"
      Case #PB_GadgetType_TrackBar : result = "TrackBarGadget"
      Case #PB_GadgetType_Tree : result = "TreeGadget"
      Case #PB_GadgetType_Web : result = "WebGadget"
    EndSelect
    
    ProcedureReturn result
    
  EndProcedure
  
  Procedure HelpTreeGadget(gadget, List GList.GadgetData(), a)
    
    ForEach Glist()
      With GList()
        AddGadgetItem(gadget, -1, GadgetTypeName(\type), 0, a)
        a + 1
        AddGadgetItem(gadget, -1, "Gadget ID = " + Str(\id), 0, a)
        AddGadgetItem(gadget, -1, "X = " + Str(\x), 0, a)
        AddGadgetItem(gadget, -1, "Y = " + Str(\y), 0, a)
        AddGadgetItem(gadget, -1, "DX = " + Str(\dx), 0, a)
        AddGadgetItem(gadget, -1, "DY = " + Str(\dy), 0, a)
        AddGadgetItem(gadget, -1, "Text = " + \text, 0, a)
        If ListSize(\Gadgets())
          AddGadgetItem(gadget, -1, "Gadgets", 0, a)
          HelpTreeGadget(gadget, \Gadgets(), a + 1)
        EndIf
        a - 1
      EndWith
    Next
    
  EndProcedure
  
  Procedure ListTreeGadget(gadget)
    
    Protected a
    
    ForEach ListWindow()
      a = 0
      With ListWindow()
        AddGadgetItem(gadget, -1, "Window ID " + Str(\id), 0, 0)
        a + 1
        AddGadgetItem(gadget, -1, "X = " + Str(\x), 0, a)
        AddGadgetItem(gadget, -1, "Y = " + Str(\y), 0, a)
        AddGadgetItem(gadget, -1, "DX = " + Str(\dx), 0, a)
        AddGadgetItem(gadget, -1, "DY = " + Str(\dy), 0, a)
        AddGadgetItem(gadget, -1, "Titel = " + \text, 0, a)
        If ListSize(\Gadgets())
          AddGadgetItem(gadget, -1, "Gadgets", 0, a)
          HelpTreeGadget(gadget, \Gadgets(), a + 1)
        EndIf
        a - 1
      EndWith
    Next
  EndProcedure
  
  Procedure Main3()
    
    style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
    OpenWindow(3, #PB_Ignore, #PB_Ignore, 600, 500, "Main 3 - Gadget Overview", style)
    TreeGadget(30, 0, 0, 600, 500)
    ListTreeGadget(30)
    
  EndProcedure
  
  ; ---------------------------------------------------------------------------------
  
  ;- Init
  ;UseModule ScalingWindow
  
  Main1()
  Main2()
  Main3()
  UpdateImages()
  
  Debug "----------------------------------------------------------------------"
  Debug "ParentWindow from Gadget 0 is Window " + ParentWindow(0)
  Debug "ParentWindow from Gadget 21 is Window " + ParentWindow(21)
  Debug "ParentWindow from Gadget 30 is Window " + ParentWindow(30)
  Debug "----------------------------------------------------------------------"
  Debug "ParendGadget from Gadget 21 is Gadget " + ParentGadget(21)
  Debug "ParendGadget from Gadget 22 is Gadget " + ParentGadget(22)
  Debug "ParendGadget from Gadget 27 is Gadget " + ParentGadget(27)
  Debug "----------------------------------------------------------------------"
  hImage = ImageID(0)
  Debug "Image from hImage " + hImage + " is PB-ID " + GetImageID(hImage)
  hImage = ImageID(2)
  Debug "Image from hImage " + hImage + " is PB-ID " + GetImageID(hImage)
  
  ;- Events
  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Gadget
      
      Select EventGadget()
        Case 27
          RestoreWindow(1, #True)
        Case 28
          RestoreWindow(2)
          
      EndSelect
    ElseIf Event = #PB_Event_SizeWindow
      ScaleWindow(EventWindow())
      
    EndIf
    
  Until Event = #PB_Event_CloseWindow
  
CompilerEndIf
