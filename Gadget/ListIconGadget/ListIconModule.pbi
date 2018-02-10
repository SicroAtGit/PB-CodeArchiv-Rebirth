;   Description: ListIcon Handling (Sort, Add Column, Editable ...)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27694
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014, 2015 Thorsten1867
; Copyright (c) 2014 RSBasic -- Code for sort on header click
; Copyright (c) 2014 hjbremer -- Code for editable ListIconGadget
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

;/ === ListIconModule.pbi ===  [ PureBasic V5.2x ]
;/
;/ February 2014 by Thorsten1867
;/ Sort on header click - based on the code of RSBasic
;/ Edit ListIcon items  - based on LvEditMini of hjbremer

; ===== Replaced Commands ==================
; AddGadgetItem()      -> AddListItem()
; RemoveGadgetItem()   -> RemoveListItem()
; ClearGadgetItems()   -> ClearListItems()
; SetGadgetItemData()  -> SetListItemData()
; SetGadgetItemImage() -> SetListItemImage()
; SetGadgetItemText()  -> SetListItemText()
; AddGadgetColumn()    -> AddListColumn()
; RemoveGadgetColumn() -> RemoveListColumn()
; ==========================================


DeclareModule ListIcon
  Enumeration 1
    #Left
    #Right
    #Center
    #Namen    = 0
    #Lexikon  = 1   
    #Standard = 2
  EndEnumeration
  Enumeration 1
    #Default         = -1
    #UserSort        = 1
    #CaseSensitive   = 1 << 1
    #CaseInSensitive = 1 << 2
    #Ascending       = 1 << 3
    #Descending      = 1 << 4
    #NoSort          = 1 << 5
    #NoEdit          = 1 << 6
    #String          = 1 << 7
    #Integer         = 1 << 8
    #Float           = 1 << 9
    #Edit            = 1 << 10
    #NoResize        = 1 << 11
    #Hide            = 1 << 12
  EndEnumeration
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Declare CountColumns(GadgetID.i)
      Declare DefineListCallback(GadgetID.i, Flags.l=#False) ; Sort after HeaderClick / Edit Cells
      Declare ResetHeaderSort(GadgetID.i)                    ; Remove sort arrows from header
      Declare JustifyColumn(GadgetID.i, Column.i, Flag.l=#Center)
      Declare AutoWidthColumns(GadgetID.i)
      Declare SetFont(GadgetID.i, HeaderFont.i, ListFont.i=#False)
    CompilerCase #PB_OS_Linux
      Declare JustifyColumn(GadgetID.i, Column.i, Flag.l=#Center)
    CompilerCase #PB_OS_MacOS
      ; ???
  CompilerEndSelect
  Declare DefineSort(GadgetID.i, Norm.l) ; Define German Sort Norm
  Declare SetColumnFlag(GadgetID.i, Column.i, Flags.l)
  Declare.i AddListItem(GadgetID.i, Position.i, Text.s, UserSort.s="", ImageID.i=#False) ; UserSort.s <- #Default
  Declare SetListItemData(GadgetID.i, Position.i, Value.i)
  Declare.i GetListItemData(GadgetID.i, Position.i)
  Declare SetListItemImage(GadgetID.i, Position.i, ImageID.i)
  Declare AddUserSort(GadgetID.i, Column.i, UserSort.s)                ; Use only after AddListItem() !
  Declare ChangeUserSortColumn(GadgetID.i, Position.i, Column.i, UserSort.s)
  Declare ChangeUserSortDefault(GadgetID.i, Position.i, UserSort.s="")
  Declare SetListItemText(GadgetID.i, Position.i, Text.s , Column.i)
  Declare RemoveListItem(GadgetID.i, Position.i)                     
  Declare ClearListItems(GadgetID.i)                                   ; Don't use ClearGadgetItems() !
  Declare AddListColumn(GadgetID.i, Column.i, Titel.s, Width.i, ReFill.l=#True)
  Declare RemoveListColumn(GadgetID.i, Column.i)
  Declare SortListItems(GadgetID.i, SortCol.i, Flags.l=#False)
  Declare MultiSortListItems(GadgetID.i, SortCol1.i, SortCol2.i, SortCol3.i=#PB_Ignore, Flags.l=#False)
  Declare RemoveSortData(GadgetID.i)
EndDeclareModule


Module ListIcon
  
  EnableExplicit
  
  Structure ListItemStructure
    Position.i
    ImageID.i
    ItemData.i
    Checked.l
    Text.s
    Sort.s
    SortInteger.i
    SortFloat.f
    Map UserSort.s()
  EndStructure
  
  Structure ListIconStructure
    Flags.l
    SortNorm.i
    UserSort.i
    Map Column.l()
    List Item.ListItemStructure()
  EndStructure
  Global NewMap ListIcon.ListIconStructure()
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      
      Structure ListEditStructure
        *CallBack      ; ListIcon Callback
        *StrgCallBack  ; String Callback
        GadgetID.i     ; ListIconGadget ID
        StrgID.i       ; Stringgadget ID
        HeaderHnd.i    ; Header Id
        Row.i          ; List Row (Position)
        Column.i       ; List Column
        CellText.s
        SortDirection.i
        EditFlag.i     ; EditMode = 1
        StructureUnion
          lParam.i       ; lParam from Callback
          points.points  ; lParam => x + y
        EndStructureUnion
      EndStructure
      
      Procedure ResetHeaderSort(GadgetID.i)
        Protected *ListEdit.ListEditStructure = GetWindowLongPtr_(GadgetID(GadgetID), #GWL_USERDATA)
        Protected i.i, HDItem.HD_ITEM, ColsCount.i = SendMessage_(*ListEdit\HeaderHnd, #HDM_GETITEMCOUNT, 0, 0)
        HDItem\mask = #HDI_FORMAT
        For i = 0 To ColsCount - 1
          SendMessage_(*ListEdit\HeaderHnd, #HDM_GETITEM, i, HDItem)
          HDItem\fmt & ~ (#HDF_SORTDOWN | #HDF_SORTUP)
          SendMessage_(*ListEdit\HeaderHnd, #HDM_SETITEM, i, HDItem)
        Next
      EndProcedure
      
      Procedure StopListEdit(*ListEdit.ListEditStructure)
        If IsGadget(*ListEdit\StrgID)
          If *ListEdit\EditFlag
            *ListEdit\EditFlag = #False
            *ListEdit\CellText = GetGadgetText(*ListEdit\StrgID)
            SetListItemText(*ListEdit\GadgetID, *ListEdit\Row, *ListEdit\CellText, *ListEdit\Column)
            HideGadget(*ListEdit\StrgID, #True)   
          EndIf
        EndIf
      EndProcedure
      
      Procedure.i ListIcon_CallBack(hWnd, Message, wParam, lParam)
        Protected.i Column, x, y, width, height, i
        Protected *ListEdit.ListEditStructure = GetWindowLongPtr_(hWnd, #GWL_USERDATA)
        Protected *Header.HD_NOTIFY, *nm.NMHDR, *nmhdr.NMHEADER, MouseClick.LVHITTESTINFO, rect.rect
        Protected HDItem.HD_ITEM, ColsCount.i = SendMessage_(*ListEdit\HeaderHnd, #HDM_GETITEMCOUNT, 0, 0)
        Protected GID.s=Str(*ListEdit\GadgetID), SortDirection.l, Flags.l = ListIcon(GID)\Flags
        Protected Result.i = CallWindowProc_(*ListEdit\CallBack, hWnd, Message, wParam, lParam)
        Select Message
          Case #WM_NOTIFY            ;{ ListIcon
            If Flags & #Edit         ;{ Edit
              *nm = lParam
              If *nm\hWndFrom = *ListEdit\HeaderHnd
                StopListEdit(*ListEdit)
              EndIf
            EndIf ;}
            *nmhdr = lParam          ;{ Column NoResize/Hide
            If *nmhdr\hdr\code = #HDN_ITEMCHANGING
              Column = *nmhdr\iItem
              If ListIcon(GID)\Column(Str(Column)) & #NoResize Or Flags & #NoResize Or ListIcon(GID)\Column(Str(Column)) & #Hide
                Result=#True
              EndIf 
            EndIf ;}
            *Header = lParam         ;{ Header Click
            If *Header\hdr\code=#HDN_ITEMCLICK
              Column = *Header\iItem
              If Not ListIcon(GID)\Column(Str(Column)) & #NoSort
                HDItem\mask = #HDI_FORMAT
                For i = 0 To ColsCount - 1
                  If i <> column   
                    SendMessage_(*ListEdit\HeaderHnd, #HDM_GETITEM, i, HDItem)
                    HDItem\fmt & ~ (#HDF_SORTDOWN | #HDF_SORTUP)
                    SendMessage_(*ListEdit\HeaderHnd, #HDM_SETITEM, i, HDItem)
                  EndIf
                Next
                SendMessage_(*ListEdit\HeaderHnd, #HDM_GETITEM, Column, HDItem)
                If HDItem\fmt & #HDF_SORTDOWN                             
                  HDItem\fmt & ~ #HDF_SORTDOWN
                  HDItem\fmt | #HDF_SORTUP
                  SortDirection = #Descending
                Else
                  HDItem\fmt & ~ #HDF_SORTUP
                  HDItem\fmt | #HDF_SORTDOWN
                  SortDirection = #Ascending
                EndIf
                Flags & ~ (#Ascending|#Descending)
                SendMessage_(*ListEdit\HeaderHnd, #HDM_SETITEM, Column, HDItem)
                SortListItems(*ListEdit\GadgetID, Column, Flags|SortDirection)
              EndIf
            EndIf ;}
                  ;}
          Case #WM_MOUSEMOVE         ;{ Mouse position
            If *ListEdit\EditFlag = #False
              *ListEdit\lParam = lParam
            EndIf ;}
          Case #WM_VSCROLL, #WM_HSCROLL, #WM_RBUTTONDOWN, #WM_LBUTTONDOWN ;{
            StopListEdit(*ListEdit)
            ;}
          Case #WM_LBUTTONDBLCLK     ;{ Left mouse button   
            If Flags & #Edit
              StopListEdit(*ListEdit)
              MouseClick\pt\x = *ListEdit\points\x  ; \points <- #WM_MOUSEMOVE
              MouseClick\pt\y = *ListEdit\points\y
              SendMessage_(hWnd, #LVM_SUBITEMHITTEST, 0, MouseClick)           
              *ListEdit\Row    = MouseClick\iitem
              *ListEdit\Column = MouseClick\iSubItem
              If Not ListIcon(GID)\Column(Str(MouseClick\iSubItem)) & #NoEdit 
                rect\top    = *ListEdit\Column         
                rect\left   = #LVIR_LABEL
                SendMessage_(hWnd, #LVM_GETSUBITEMRECT, *ListEdit\Row, rect)               
                *ListEdit\CellText = GetGadgetItemText(*ListEdit\GadgetID, *ListEdit\Row, *ListEdit\Column)               
                x = rect\left + 1
                y = rect\top  + 0
                width  = rect\right  - rect\left - 1
                height = rect\bottom - rect\top  - 0
                If width > 32767 : width = 32767 : EndIf
                ResizeGadget(*ListEdit\StrgID, x, y, width, height)
                SetGadgetText(*ListEdit\StrgID, *ListEdit\CellText)
                HideGadget(*ListEdit\StrgID, 0)
                SetActiveGadget(*ListEdit\StrgID)
                *ListEdit\EditFlag = #True
              EndIf
            EndIf
            ;}
        EndSelect
        ProcedureReturn Result
      EndProcedure
      
      Procedure.i ListEdit_CallBack(hWnd, Message, wParam, lParam)
        Protected *ListEdit.ListEditStructure = GetWindowLongPtr_(hWnd, #GWL_USERDATA)
        Select Message
          Case #WM_CHAR
            Select wParam
              Case #VK_RETURN
                StopListEdit(*ListEdit)
              Case #VK_ESCAPE
                If *ListEdit\EditFlag
                  *ListEdit\EditFlag = #False
                  HideGadget(*ListEdit\StrgID, #True)   
                EndIf
            EndSelect
          Case #WM_KILLFOCUS
            StopListEdit(*ListEdit)
        EndSelect
        ProcedureReturn CallWindowProc_(*ListEdit\StrgCallBack, hWnd, Message, wParam, lParam)
      EndProcedure
      
      Procedure DefineListCallback(GadgetID.i, Flags.l=#False)
        Protected StrgID.i, GID.s = Str(GadgetID)
        Protected *ListEdit.ListEditStructure = AllocateMemory(SizeOf(ListEditStructure))
        ListIcon(GID)\Flags = Flags
        SetWindowLongPtr_(GadgetID(GadgetID), #GWL_USERDATA, *ListEdit)
        *ListEdit\CallBack = SetWindowLongPtr_(GadgetID(GadgetID), #GWL_WNDPROC, @ListIcon_CallBack())
        *ListEdit\GadgetID  = GadgetID
        *ListEdit\HeaderHnd = SendMessage_(GadgetID(GadgetID), #LVM_GETHEADER, 0, 0)   
        If Flags & #Edit
          StrgID = StringGadget(#PB_Any, 0, 0, 0, 0, "")
          *ListEdit\StrgID = StrgID
          SetGadgetFont(StrgID, GetGadgetFont(GadgetID))
          HideGadget(StrgID, 1)
          SetParent_(GadgetID(StrgID), GadgetID(GadgetID)) ; important !!!
          SetWindowLongPtr_(GadgetID(StrgID), #GWL_USERDATA, *ListEdit)
          *ListEdit\StrgCallBack = SetWindowLongPtr_(GadgetID(StrgID), #GWL_WNDPROC, @ListEdit_CallBack())
        EndIf
      EndProcedure
      
      Procedure.i CountColumns(GadgetID.i)
        ProcedureReturn SendMessage_(SendMessage_(GadgetID(GadgetID),#LVM_GETHEADER,0,0), #HDM_GETITEMCOUNT,0,0)
      EndProcedure
      
      Procedure AutoWidthColumns(GadgetID.i)
        Protected col.i, W1.i, W2.i, ColWidth.i, hHnd.i = GadgetID(GadgetID) 
        Protected ColsCount.i = SendMessage_(SendMessage_(hHnd,#LVM_GETHEADER,0,0),#HDM_GETITEMCOUNT,0,0)
        For col = 0 To ColsCount-1
          SendMessage_(hHnd, #LVM_SETCOLUMNWIDTH, col, #LVSCW_AUTOSIZE)
          W1 = SendMessage_(hHnd, #LVM_GETCOLUMNWIDTH, col, 0)
          SendMessage_(hHnd, #LVM_SETCOLUMNWIDTH, col, #LVSCW_AUTOSIZE_USEHEADER)
          W2 = SendMessage_(hHnd, #LVM_GETCOLUMNWIDTH, col, 0)
          If W1 > W2
            ColWidth = W1
          Else
            ColWidth = W2
          EndIf
          SendMessage_(hHnd, #LVM_SETCOLUMNWIDTH, col, ColWidth)
        Next
      EndProcedure
      
      Procedure JustifyColumn(GadgetID.i, Column.i, Flag.l=#Center)
        Protected ListIcon.LV_COLUMN
        ListIcon\mask = #LVCF_FMT
        Select Flag
          Case #Center
            ListIcon\fmt = #LVCFMT_CENTER
          Case #Right
            ListIcon\fmt = #LVCFMT_RIGHT
          Default
            ListIcon\fmt = #LVCFMT_LEFT
        EndSelect
        SendMessage_(GadgetID(GadgetID), #LVM_SETCOLUMN, Column, @ListIcon)
      EndProcedure
      
      Procedure SetFont(GadgetID.i, HeaderFont.i, ListFont.i=#False)
        If IsFont(ListFont)
          SendMessage_(GadgetID(GadgetID), #WM_SETFONT, ListFont, 1)
        EndIf
        If IsFont(HeaderFont)
          SendMessage_(SendMessage_(GadgetID(GadgetID), #LVM_GETHEADER,0,0), #WM_SETFONT, HeaderFont, 1)
        EndIf
      EndProcedure
      
    CompilerCase #PB_OS_Linux
      
      ;{ used for justify ListIcon columns
      ImportC ""
        g_object_set_double(*Object, Property.P-ASCII, Value.D, Null) As "g_object_set"
      EndImport
      ;}
      
      Procedure JustifyColumn(GadgetID.i, Column.i, Flag.l=#Center)
        ; based on code from Shardik
        Protected *CellRenderers, *Column
        Protected.d AlignmentFactor
        Protected.i Count, i
        
        Select Flag
          Case #Left
            AlignmentFactor = 0.0
          Case #Center
            AlignmentFactor = 0.5
          Case #Right
            AlignmentFactor = 1.0
        EndSelect
        
        *Column = gtk_tree_view_get_column_(GadgetID(GadgetID), Column)
        If *Column
          gtk_tree_view_column_set_alignment_(*Column, AlignmentFactor)
          *CellRenderers = gtk_tree_view_column_get_cell_renderers_(*Column)
          If *CellRenderers
            Count = g_list_length_(*CellRenderers)
            For i = 0 To Count - 1
              g_object_set_double(g_list_nth_data_(*CellRenderers, i), "xalign", AlignmentFactor, #Null)
            Next i         
            g_list_free_(*CellRenderers)
          EndIf
        EndIf
        
      EndProcedure
      
    CompilerCase #PB_OS_MacOS
      
      
  CompilerEndSelect
  
  ; ===================================================================
  
  Procedure DefineSort(GadgetID.i, Norm.l) ; Set german DIN norm for sort
    Protected.s GID = Str(GadgetID)
    ListIcon(GID)\SortNorm = Norm
  EndProcedure
  
  ; --- Replaced ListIcon Commands ---
  
  Procedure.i AddListItem(GadgetID.i, Position.i, Text.s, UserSort.s="", ImageID.i=#False)
    Protected *ptr, GID.s = Str(GadgetID)
    AddGadgetItem(GadgetID, Position, Text, ImageID)
    If Position = -1
      *ptr = AddElement(ListIcon(GID)\Item())
      ListIcon(GID)\Item()\Text = Text
      ListIcon(GID)\Item()\Position = CountGadgetItems(GadgetID)-1     
    Else
      ForEach ListIcon(GID)\Item()
        If ListIcon(GID)\Item()\Position >= Position
          ListIcon(GID)\Item()\Position + 1
        EndIf
      Next
      *ptr = AddElement(ListIcon(GID)\Item())
      ListIcon(GID)\Item()\Text = Text
      ListIcon(GID)\Item()\Position = Position
    EndIf
    ListIcon(GID)\Item()\ImageID = ImageID
    If UserSort : ListIcon(GID)\Item()\UserSort("D") = UserSort : EndIf ; Default UserSort (No Column)
    ProcedureReturn *ptr
  EndProcedure
  
  Procedure RemoveListItem(GadgetID.i, Position.i)
    Protected GID.s = Str(GadgetID)
    RemoveGadgetItem(GadgetID, Position)
    SelectElement(ListIcon(GID)\Item(), Position)
    DeleteElement(ListIcon(GID)\Item())
  EndProcedure
  
  Procedure ClearListItems(GadgetID.i)
    Protected GID.s = Str(GadgetID)
    ClearGadgetItems(GadgetID)
    ClearList(ListIcon(GID)\Item())
  EndProcedure
  
  Procedure SetListItemData(GadgetID.i, Position.i, Value.i)
    Protected GID.s = Str(GadgetID)
    SetGadgetItemData(GadgetID, Position, Value)
    SelectElement(ListIcon(GID)\Item(), Position)
    ListIcon(GID)\Item()\ItemData = Value
  EndProcedure
  
  Procedure.i GetListItemData(GadgetID.i, Position.i)
    Protected GID.s = Str(GadgetID)
    SelectElement(ListIcon(GID)\Item(), Position)
    ProcedureReturn ListIcon(GID)\Item()\ItemData
  EndProcedure
  
  Procedure SetListItemImage(GadgetID.i, Position.i, ImageID.i)
    Protected GID.s = Str(GadgetID)
    SetGadgetItemImage(GadgetID, Position, ImageID)
    SelectElement(ListIcon(GID)\Item(), Position)
    ListIcon(GID)\Item()\ImageID = ImageID
  EndProcedure 
  
  Procedure SetListItemText(GadgetID.i, Position.i, Text.s, Column.i)
    Protected GID.s = Str(GadgetID), Row.i, col.i, StartPos.i, EndPos.i
    SetGadgetItemText(GadgetID, Position, Text, Column)
    ForEach ListIcon(GID)\Item()
      If Row = Position
        If Column > 0 ;{
          For col=1 To Column
            StartPos = FindString(ListIcon(GID)\Item()\Text, #LF$, StartPos+1)
          Next
        EndIf ;}
        EndPos = FindString(ListIcon(GID)\Item()\Text, #LF$, StartPos+1)
        If Column = 0
          ListIcon(GID)\Item()\Text = Text + Mid(ListIcon(GID)\Item()\Text, EndPos)
        ElseIf EndPos
          ListIcon(GID)\Item()\Text = Left(ListIcon(GID)\Item()\Text, StartPos) + Text + Mid(ListIcon(GID)\Item()\Text, EndPos)
        Else ; Last Column
          ListIcon(GID)\Item()\Text = Left(ListIcon(GID)\Item()\Text, StartPos) + Text
        EndIf
        Break
      EndIf
      Row + 1
    Next
  EndProcedure
  
  Procedure AddListColumn(GadgetID.i, Column.i, Titel.s, Width.i, ReFill.l=#True)
    Protected GID.s = Str(GadgetID), c.i, col.i, ColPos.i = 0
    AddGadgetColumn(GadgetID, Column, Titel, Width)
    If Refill : ClearGadgetItems(GadgetID) : EndIf
    ForEach ListIcon(GID)\Item()
      ColPos = 0
      If Column > 0 ;{ 
        For col=1 To Column
          ColPos = FindString(ListIcon(GID)\Item()\Text, #LF$, ColPos+1)
        Next
      EndIf ;}
      If Column = 0
        ListIcon(GID)\Item()\Text = #LF$ + ListIcon(GID)\Item()\Text
      ElseIf ColPos
        ListIcon(GID)\Item()\Text = InsertString(ListIcon(GID)\Item()\Text, #LF$, ColPos)
      Else ; last column
        ListIcon(GID)\Item()\Text + #LF$
      EndIf
      If ReFill : AddGadgetItem(GadgetID, -1, ListIcon(GID)\Item()\Text, ListIcon(GID)\Item()\ImageID) : EndIf
    Next
    For c = CountGadgetItems(GadgetID)-1 To Column+1 Step -1
      If ListIcon(GID)\Column(Str(c-1))
        ListIcon(GID)\Column(Str(c)) = ListIcon(GID)\Column(Str(c-1))
      EndIf
    Next
    ListIcon(GID)\Column(Str(Column)) = #False
  EndProcedure
  
  Procedure RemoveListColumn(GadgetID.i, Column.i)
    Protected GID.s = Str(GadgetID), col.i, StartPos.i, EndPos.i
    RemoveGadgetColumn(GadgetID, Column)
    ForEach ListIcon(GID)\Item()
      StartPos = 0
      If Column > 0 ;{ Column 1 - Last
        For col=1 To Column
          StartPos = FindString(ListIcon(GID)\Item()\Text, #LF$, StartPos+1)
        Next
      EndIf ;}
      EndPos = FindString(ListIcon(GID)\Item()\Text, #LF$, StartPos+1)
      If Column = 0
        ListIcon(GID)\Item()\Text = Mid(ListIcon(GID)\Item()\Text, EndPos+1)
      ElseIf EndPos
        ListIcon(GID)\Item()\Text = Left(ListIcon(GID)\Item()\Text, StartPos-1) + Mid(ListIcon(GID)\Item()\Text, EndPos)
      Else ; Last Column
        ListIcon(GID)\Item()\Text = Left(ListIcon(GID)\Item()\Text, StartPos-1)
      EndIf
    Next
    ListIcon(GID)\Column(Str(Column)) = #False
    For col = Column+1 To CountGadgetItems(GadgetID)
      If ListIcon(GID)\Column(Str(col))
        ListIcon(GID)\Column(Str(col-1)) = ListIcon(GID)\Column(Str(col))
      EndIf
    Next
    ListIcon(GID)\Column(Str(CountGadgetItems(GadgetID))) = #False
  EndProcedure
  
  ; --- Sort List Commands ---
  Procedure SetColumnFlag(GadgetID.i, Column.i, Flags.l)
    ; Flags: #String / #Float / #Integer / #NoSort  / #NoEdit / #UserSort / #NoResize / #Hide
    Protected GID.s = Str(GadgetID)
    ListIcon(GID)\Column(Str(Column)) = Flags
    If Flags & #Hide
      SetGadgetItemAttribute(GadgetID, #Null, #PB_ListIcon_ColumnWidth, 0, Column)
    EndIf
  EndProcedure
  
  Procedure AddUserSort(GadgetID.i, Column.i, UserSort.s)
    Protected GID.s = Str(GadgetID)
    If ListIndex(ListIcon(GID)\Item()) <> -1
      ListIcon(GID)\Item()\UserSort(Str(Column)) = UserSort
    EndIf
  EndProcedure
  
  Procedure ChangeUserSortDefault(GadgetID.i, Position.i, UserSort.s="")
    Protected GID.s = Str(GadgetID)
    ForEach ListIcon(GID)\Item()
      If ListIcon(GID)\Item()\Position = Position
        ListIcon(GID)\Item()\UserSort("D") = UserSort
        Break
      EndIf
    Next
  EndProcedure
  
  Procedure ChangeUserSortColumn(GadgetID.i, Position.i, Column.i, UserSort.s)
    Protected GID.s = Str(GadgetID)
    ForEach ListIcon(GID)\Item()
      If ListIcon(GID)\Item()\Position = Position
        ListIcon(GID)\Item()\UserSort(Str(Column)) = UserSort
        Break
      EndIf
    Next
  EndProcedure
  
  Procedure.s SortDEU(Text.s, SortNorm.l=#Namen) ; german charakters (DIN 5007)
    Select SortNorm
      Case #Lexikon
        Text = ReplaceString(Text, "Ä", "A")
        Text = ReplaceString(Text, "Ö", "O")
        Text = ReplaceString(Text, "Ü", "U")
        Text = ReplaceString(Text, "ä", "a")
        Text = ReplaceString(Text, "ö", "o")
        Text = ReplaceString(Text, "ü", "u")
        Text = ReplaceString(Text, "ß", "ss")
      Case #Namen
        Text = ReplaceString(Text, "Ä", "Ae")
        Text = ReplaceString(Text, "Ö", "Oe")
        Text = ReplaceString(Text, "Ü", "Ue")
        Text = ReplaceString(Text, "ä", "ae")
        Text = ReplaceString(Text, "ö", "oe")
        Text = ReplaceString(Text, "ü", "ue")
        Text = ReplaceString(Text, "ß", "ss")
    EndSelect
    ProcedureReturn Text
  EndProcedure
  
  Procedure.s GetSortString(Text.s, Flags.i, SortNorm.l=#Namen)
    Text = SortDEU(Text, SortNorm)
    If Flags & #CaseSensitive
      ProcedureReturn Left(Text, 4)
    Else
      ProcedureReturn Left(LCase(Text), 4)
    EndIf
  EndProcedure
  
  
  Procedure SetSortOrder(GadgetID.i, Flags.l, SortCol1.i, SortCol2.i=#PB_Ignore, SortCol3.i=#PB_Ignore)
    Protected.s GID = Str(GadgetID)
    ForEach ListIcon(GID)\Item()
      If Flags & #NoSort
        ListIcon(GID)\Item()\Sort = RSet(Str(ListIcon(GID)\Item()\Position), 4, "0")
      Else
        ListIcon(GID)\Item()\Sort = GetSortString(StringField(ListIcon(GID)\Item()\Text, SortCol1+1, #LF$), Flags, ListIcon(GID)\SortNorm)
        If SortCol2 <> #PB_Ignore
          ListIcon(GID)\Item()\Sort + GetSortString(StringField(ListIcon(GID)\Item()\Text, SortCol2+1, #LF$), Flags, ListIcon(GID)\SortNorm)
        ElseIf SortCol3 <> #PB_Ignore
          ListIcon(GID)\Item()\Sort + GetSortString(StringField(ListIcon(GID)\Item()\Text, SortCol3+1, #LF$), Flags, ListIcon(GID)\SortNorm)
        EndIf
      EndIf
    Next
  EndProcedure
  
  Procedure SetSortOrderInteger(GadgetID.i, Flags.l, SortCol.i)
    Protected.s GID = Str(GadgetID)
    ForEach ListIcon(GID)\Item()
      If Flags & #NoSort
        ListIcon(GID)\Item()\SortInteger = ListIcon(GID)\Item()\Position
      Else
        ListIcon(GID)\Item()\SortInteger = Val(StringField(ListIcon(GID)\Item()\Text, SortCol+1, #LF$))
      EndIf
    Next
  EndProcedure
  
  Procedure SetSortOrderFloat(GadgetID.i, Flags.l, SortCol.i)
    Protected.s GID = Str(GadgetID)
    ForEach ListIcon(GID)\Item()
      If Flags & #NoSort
        ListIcon(GID)\Item()\SortFloat = ListIcon(GID)\Item()\Position
      Else
        ListIcon(GID)\Item()\SortFloat = ValF(ReplaceString(StringField(ListIcon(GID)\Item()\Text, SortCol+1, #LF$), ",", "."))
      EndIf
    Next
  EndProcedure
  
  Procedure SetSortUserOrder(GadgetID.i, Flags.l, SortCol.i=#Default)
    Protected.s GID = Str(GadgetID), COL$ = Str(SortCol)
    If SortCol=#Default : COL$="D" : EndIf
    ForEach ListIcon(GID)\Item()
      If Flags & #NoSort
        ListIcon(GID)\Item()\Sort = RSet(Str(ListIcon(GID)\Item()\Position), 4, "0")
      Else
        If Flags & #CaseSensitive
          ListIcon(GID)\Item()\Sort = ListIcon(GID)\Item()\UserSort(COL$)
        Else
          ListIcon(GID)\Item()\Sort = LCase(ListIcon(GID)\Item()\UserSort(COL$))
        EndIf
      EndIf
    Next
  EndProcedure
  
  Procedure SortListItems(GadgetID.i, SortCol.i, Flags.l=#False)
    ; Flags: #UserSort / #Descending / #Ascending / #CaseSensitive / #CaseInSensitive
    ; SortCol: #Default (if #UserSort)
    Protected i.i, Row.i, GID.s = Str(GadgetID), ColumnFlag = ListIcon(GID)\Column(Str(SortCol))
    If ListSize(ListIcon(GID)\Item())
      ; --- Read Checked / GadgetItemData ---
      For i = 0 To CountGadgetItems(GadgetID)-1
        ListIcon(GID)\Item()\Checked = GetGadgetItemState(GadgetID, i)
        ListIcon(GID)\Item()\ItemData = GetListItemData(GadgetID, i)
      Next
      ; -------------------------------------
      If ColumnFlag & #Integer   ;{ Sort Integer
        SetSortOrderInteger(GadgetID, Flags, SortCol)
        If Flags & #Descending
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Descending, OffsetOf(ListItemStructure\SortInteger), TypeOf(ListItemStructure\SortInteger))
        Else
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Ascending, OffsetOf(ListItemStructure\SortInteger), TypeOf(ListItemStructure\SortInteger))
        EndIf ;}
      ElseIf ColumnFlag & #Float ;{ Sort Float
        SetSortOrderFloat(GadgetID, Flags, SortCol)
        If Flags & #Descending
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Descending, OffsetOf(ListItemStructure\SortFloat), TypeOf(ListItemStructure\SortFloat))
        Else
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Ascending, OffsetOf(ListItemStructure\SortFloat), TypeOf(ListItemStructure\SortFloat))
        EndIf ;}
      ElseIf ColumnFlag & #UserSort ;{ Sort User
        SetSortUserOrder(GadgetID, Flags, SortCol)
        If Flags & #Descending
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Descending, OffsetOf(ListItemStructure\Sort), TypeOf(ListItemStructure\Sort))
        Else
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Ascending, OffsetOf(ListItemStructure\Sort), TypeOf(ListItemStructure\Sort))
        EndIf ;}
      Else    ;{ Sort String
        If Flags & #UserSort
          SetSortUserOrder(GadgetID, Flags, SortCol)
        Else
          SetSortOrder(GadgetID, Flags, SortCol)
        EndIf
        If Flags & #Descending
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Descending, OffsetOf(ListItemStructure\Sort), TypeOf(ListItemStructure\Sort))
        Else
          SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Ascending, OffsetOf(ListItemStructure\Sort), TypeOf(ListItemStructure\Sort))
        EndIf ;}
      EndIf
      ClearGadgetItems(GadgetID)
      ForEach ListIcon(GID)\Item()
        AddGadgetItem(GadgetID, Row, ListIcon(GID)\Item()\Text, ListIcon(GID)\Item()\ImageID)
        SetGadgetItemState(GadgetID, Row, ListIcon(GID)\Item()\Checked)
        SetGadgetItemData(GadgetID, Row, ListIcon(GID)\Item()\ItemData)
        Row + 1
      Next
    EndIf
  EndProcedure
  
  Procedure MultiSortListItems(GadgetID.i, SortCol1.i, SortCol2.i, SortCol3.i=#PB_Ignore, Flags.l=#False)
    ; Flags: #UserSort / #Descending / #Ascending / #CaseSensitive / #CaseInSensitive
    Protected.s Row.i, GID = Str(GadgetID)
    ; Ignore SortCol3 with #PB_Ignore
    If ListSize(ListIcon(GID)\Item())
      If Flags & #UserSort
        SetSortUserOrder(GadgetID, Flags, SortCol1)
      Else
        SetSortOrder(GadgetID, Flags, SortCol1, SortCol2, SortCol3)
      EndIf
      If Flags & #Descending
        SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Descending, OffsetOf(ListItemStructure\Sort), TypeOf(ListItemStructure\Sort))
      Else
        SortStructuredList(ListIcon(GID)\Item(), #PB_Sort_Ascending, OffsetOf(ListItemStructure\Sort), TypeOf(ListItemStructure\Sort))
      EndIf
      ClearGadgetItems(GadgetID)
      ForEach ListIcon(GID)\Item()
        AddGadgetItem(GadgetID, Row, ListIcon(GID)\Item()\Text, ListIcon(GID)\Item()\ImageID)
        SetGadgetItemData(GadgetID, Row, ListIcon(GID)\Item()\ItemData)
        Row + 1
      Next
    EndIf
  EndProcedure
  
  Procedure RemoveSortData(GadgetID.i)
    DeleteMapElement(ListIcon(), Str(GadgetID))
  EndProcedure
  
EndModule

;-Example

CompilerIf #PB_Compiler_IsMainFile
  #Window = 0
  #List   = 1
  #Font_Arial10B = 2
  #Font_Arial9I  = 3
  
  LoadFont(#Font_Arial10B,"Arial",10,#PB_Font_Bold)
  LoadFont(#Font_Arial9I,"Arial",9,#PB_Font_Italic)
  
  If OpenWindow(#Window,0,0,320,250,"Window",#PB_Window_SystemMenu|#PB_Window_ScreenCentered)
    ListIconGadget(#List,10,10,300,230,"Column 0",80,#PB_ListIcon_GridLines)
    AddGadgetColumn(#List,1,"Column 1",80)
    AddGadgetColumn(#List,2,"Column 2",80)
    AddGadgetColumn(#List,3,"Number",54)
    AddGadgetColumn(#List,4,"Hide",40)
    UseModule ListIcon
    AddListItem(#List, -1, "Left"  +#LF$+ "Center"+#LF$+"Right"+#LF$+"2.66")
    AddListItem(#List, -1, "Alpha" +#LF$+ "Gamma" +#LF$+"Beta" +#LF$+"1.33")
    AddListItem(#List, -1, "Ärmel" +#LF$+ "Esel"  +#LF$+"Öfen" +#LF$+"2.33")
    AddListItem(#List, -1, "Besen" +#LF$+ "Gans"  +#LF$+"Quark" +#LF$+"10.33")
    AddListItem(#List, -1, "Faden" +#LF$+ "Affe"  +#LF$+"Zebra" +#LF$+"2.33")
    SetColumnFlag(#List, 1, #NoSort|#NoResize)
    SetColumnFlag(#List, 2, #NoEdit)
    SetColumnFlag(#List, 3, #Float)
    SetColumnFlag(#List, 4, #Hide) ; Hide Column 4
                                   ;If AddListItem(#List, -1, "Ärmel"+#LF$+"Esel"+#LF$+"Öfen")
                                   ;  AddUserSort(#List, 0, "A")
                                   ;  AddUserSort(#List, 1, "E")
                                   ;  AddUserSort(#List, 2, "O")
                                   ;EndIf
    UnuseModule ListIcon
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      UseModule ListIcon
      DefineListCallback(#List, #Edit|#NoResize)
      SetFont(#List, FontID(#Font_Arial10B), FontID(#Font_Arial9I))
      UnuseModule ListIcon
      Debug ListIcon::CountColumns(#List)
      ListIcon::JustifyColumn(#List, 1, ListIcon::#Center)
      ListIcon::JustifyColumn(#List, 3, ListIcon::#Right)
    CompilerEndIf
    
    MessageRequester("ListIcon Test","Sort ListIcon Items")
    ListIcon::SortListItems(#List, 0, ListIcon::#Descending)
    ;ListIcon::AutoWidthColumns(#List)
    ;ListIcon::SortListItems(#List, #Default, #UserSort) ; Default User Sort
    ;ListIcon::MultiSortListItems(#List, 0, 1, #PB_Ignore)
    ;ListIcon::SetListItemText(#List, 1, "New Text", 2)
    MessageRequester("ListIcon Test","Add ListIcon Column")
    ListIcon::AddListColumn(#List, 1, "New", 40)
    ;MessageRequester("ListIcon Test","Remove ListIcon Items")
    ;ListIcon::RemoveListItem(#List, 3)
    Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndIf
  
CompilerEndIf
