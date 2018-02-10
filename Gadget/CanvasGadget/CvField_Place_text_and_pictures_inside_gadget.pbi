;   Description: Place text and pictures in a CanvasGadget
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27854
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Andesdaf
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

; [MODULE] CvField
; Author: Andesdaf
; Version: 1.05 (2014-08-16)
; PureBasic 5.30+

DeclareModule CvField
  Enumeration
    #TYPE_TEXT
    #TYPE_IMAGE
    
    #POS_HRIGHT
    #POS_HMIDDLE
    #POS_HBOTTOM
    #POS_BORDER
    #POS_CENTER
    #POS_NONE
    
    #MODE_BEGIN
    #MODE_DRAW
    #MODE_END
    
    #TEXT_LEFT
    #TEXT_CENTER
    #TEXT_RIGHT
    
    #STACK_TOP
    #STACK_BOTTOM
    #STACK_UP
    #STACK_DOWN
    
    #COLOR_BACK
    #COLOR_SELECT
    #COLOR_BORDER
    #COLOR_HANDLE
    
    #ARRANGE_HORIZONTAL
    #ARRANGE_VERTICAL
    #ARRANGE_LEFT
    #ARRANGE_RIGHT
    #ARRANGE_UPPER
    #ARRANGE_LOWER
  EndEnumeration
  
  UseJPEGImageDecoder()
  UseJPEG2000ImageDecoder()
  UsePNGImageDecoder()
  UseTIFFImageDecoder()
  UseTGAImageDecoder()
  
  Declare.i AddLevel(sName.s, piGadget.i)
  ; add new level to the levelset
  Declare.s CurrentLevel(psName.s = "<!IGNORE>", piGadget.i = 0)
  ; set or return the active level on the given piGadget.
  ; if sName = "", the first level will be selected.
  Declare.i GetLevels(List pllLevels.s(), piGadget.i)
  ; return a list of all levels on the given piGadget.
  Declare.i DeleteLevel()
  ; delete the current level and set the next one active.
  Declare.i LevelGadget(piGadget.i = -1)
  ; set or return the gadget where the current level is on.
  Declare.s LevelBackImage(psValue.s = "<!IGNORE>")
  ; change or return the path of the background image of the current level.
  Declare.i LevelColor(piAttribute.i, piValue.i = -1)
  ; change or return color settings to the current level.
  Declare.i LevelBorderSize(piValue.i = 0)
  ; change or return the border size of all fields of the current level.
  ; if piValue < 0, only the 'selected' border will be shown in the size of Abs(piValue).
  Declare.i LevelWidth(piValue.i = -1)
  ; set or return the current level width.
  Declare.i LevelHeight(piValue.i = -1)
  ; set or return the current level height.
  Declare.i SaveLevelset(psPath.s)
  ; save the current levelset to a xml file.
  Declare.i LoadLevelset(psPath.s)
  ; load a saved levelset to the structures.
  Declare.i AddField(piType.i, piX.i = 0, piY.i = 0, piWidth = 0, piHeight = 0)
  ; add new field to the current level.
  ; piType: #TYPE_TEXT creates text, #TYPE_IMAGE creates image field
  ; piWidth and piHeight support #PB_Ignore.
  Declare.i DeleteField()
  ; delete the current field
  Declare.i SetFieldStack(piPosition.i)
  ; change the position of the current field in the field stack.
  ; #STACK_TOP: field moves to top of the stack
  ; #STACK_BOTTOM: field moves to bottom of the stack
  ; #STACK_UP: field changes the position with the previous field
  ; #STACK_DOWN: field changes the position with the next field
  Declare.i GetMousePosition()
  ; return the position of the mouse in the gadget.
  ; #POS_BORDER: mouse is on border
  ; #POS_CENTER: mouse is on the center of the field
  ; #POS_HBOTTOM: mouse is on the bottom handle
  ; #POS_HRIGHT: mouse is on the right handle
  ; #POS_HMIDDLE: mouse is on the handle in the lower right corner
  ; #POS_NONE: no specific mouse position has been found
  Declare.i MoveField(piMode.i)
  ; change the field position depending on mouse movement.
  ; piMode: #MODE_BEGIN: move has begun
  ;         #MODE_DRAW: move is performed
  ;         #MODE_END: move has ended
  Declare.i ResizeField(piHandle.i, piMode.i)
  ; change the field size depending on mouse movement.
  ; piHandle: #POS_HBOTTOM: bottom handle
  ;           #POS_HRIGHT: right handle
  ;           #POS_HMIDDLE: lower right corner handle
  ; piMode: #MODE_BEGIN: move has begun
  ;         #MODE_DRAW: move is performed
  ;         #MODE_END: move has ended
  Declare.i SelectField(piState.i = 1)
  ; change or return the 'selected' state of the current field.
  ; piState: -1: return the current state
  ;           0: deselect the current field
  ;           1: select the current field
  ;           2: deselect all fields
  Declare.i ArrangeField(piMode.i)
  ; align the current field on the gadget.
  ; #ARRANGE_HORIZONTAL: horizontal centered (x-position)
  ; #ARRANGE_VERTICAL: vertical centered (y-position)
  ; #ARRANGE_LEFT: all selected fields close to the left side
  ; #ARRANGE_RIGHT: all selected fields close to the right side
  ; #ARRANGE_UPPER: all selected fields close to the upper side
  ; #ARRANGE_LOWER: all selected fields close to the lower side
  Declare.i SetSelectedField()
  ; set the first selected field in the stack to the active one.
  Declare.i SelectedFieldCount()
  ; return the number of selected fields.
  Declare.i FieldType()
  ; return the field type (#TYPE_TEXT or #TYPE_IMAGE).
  Declare.s FieldText(psValue.s = "<!IGNORE>")
  ; set or return the text of the current field.
  Declare.i FieldTextAlign(piValue.i = -1)
  ; set or return the alignment of the current text field.
  ; #TEXT_LEFT: left-aligned
  ; #TEXT_RIGHT: right-aligned
  ; #TEXT_CENTER: centered
  Declare.i FieldTextWordwrap(piValue.i = -1)
  ; enable (1) or disable (0) automatic wordwrapping of the text field.
  Declare.s FieldImage(psValue.s = "")
  ; set or return the path of the image in the image field.
  Declare.i FieldImageConstant(piValue.i = -1)
  ; enable (1) or disable (0) a constant aspect ratio for resizing an image field.
  ; if 1, only the handle in the lower right corner will be shown.
  Declare.s FieldFontName(psValue.s = "")
  ; set or return the font name of the current text field.
  Declare.i FieldFontSize(piValue.i = -1)
  ; set or return the font size of the current text field.
  Declare.i FieldFontStyle(piValue.i = -1)
  ; set or return the font style (bold, italic etc.) of the current text field.
  Declare.i FieldFontColor(piValue.i = -1)
  ; set or return the font color of the current text field.
  Declare.i FieldX(piValue.i = -1)
  ; set or return the x position of the current field.
  Declare.i FieldY(piValue.i = -1)
  ; set or return the y position of the current field.
  Declare.i FieldWidth(piValue.i = -1)
  ; set or return the current field's width.
  Declare.i FieldHeight(piValue.i = -1)
  ; set or return the current field's height.
  Declare.i Redraw(piOutput.i = 0)
  ; redraw the whole active level.
  ; if piOutput ist set to ImageOutput(), all things will be drawn to the specified image.
  
EndDeclareModule

Module CvField
  
  EnableExplicit
  
  Structure FIELD
    iType.i
    iX.i
    iY.i
    iWi.i
    iHe.i
    iSelect.i
    
    sText.s
    iTextAlign.i
    iTextWordwrap.i
    sFontName.s
    iFontSize.i
    iFontID.i
    iFontStyle.i
    iFontColor.i
    sImage.s
    iImageID.i
    iImageConstant.i
    
    iMoX.i
    iMoY.i
  EndStructure
  
  Structure LEVEL
    sName.s
    iCanvas.i
    sBackImage.s
    iBackImageID.i
    iBackColor.i
    iBorderSize.i
    iBorderColor.i
    iSelectColor.i
    iHandleColor.i
    iHandleSize.i
    iNoBorder.i
    iWi.i
    iHe.i
    List f.FIELD()
  EndStructure
  
  Global NewList l.LEVEL()
  
  Procedure.i AddLevel(psName.s, piGadget.i)
    
    If AddElement(l()) And psName <> ""
      l()\sName        = psName
      l()\iCanvas      = piGadget
      l()\iWi          = GadgetWidth(piGadget)
      l()\iHe          = GadgetHeight(piGadget)
      l()\iBackColor   = -1
      l()\iBorderColor = $000000
      l()\iSelectColor = $0000FF
      l()\iHandleColor = $FF0000
      l()\iBorderSize  = 5
      l()\iHandleSize  = 7
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure.s CurrentLevel(psName.s = "<!IGNORE>", piGadget.i = 0)
    
    PushListPosition(l())
    If psName = ""
      ForEach l()
        If l()\iCanvas = piGadget : ProcedureReturn "" : EndIf
      Next
    ElseIf psName = "<!IGNORE>"
      ProcedureReturn l()\sName
    Else
      ForEach l()
        If l()\sName = psName : ProcedureReturn "" : EndIf
      Next
    EndIf
    PopListPosition(l())
    
  EndProcedure
  
  Procedure.i GetLevels(List pllLevels.s(), piGadget.i)
    
    PushListPosition(l())
    ForEach l()
      If l()\iCanvas = piGadget
        If AddElement(pllLevels())
          pllLevels() = l()\sName
        Else
          ProcedureReturn 0
        EndIf
      EndIf
    Next
    PopListPosition(l())
    ProcedureReturn 1
    
  EndProcedure
  
  Procedure.i DeleteLevel()
    
    If ListIndex(l()) > -1
      If DeleteElement(l(), 1)
        ProcedureReturn 1
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i LevelGadget(piValue.i = -1)
    
    If piValue <> -1
      l()\iCanvas = piValue
    Else
      ProcedureReturn l()\iCanvas
    EndIf
    
  EndProcedure
  
  Procedure.s LevelBackImage(psValue.s = "<!IGNORE>")
    
    Protected iFoundID.i
    Protected iFoundCount.i
    Protected sOldPath.s
    
    If psValue
      If psValue = "<!IGNORE>"
        ProcedureReturn l()\sBackImage
      Else
        If l()\iBackImageID
          sOldPath = l()\sBackImage
          PushListPosition(l())
          ForEach l()
            If l()\sBackImage = sOldPath
              iFoundCount + 1
            EndIf
          Next
          
          PopListPosition(l())
          
          If iFoundCount <= 1
            FreeImage(l()\iBackImageID)
          EndIf
        EndIf
        
        PushListPosition(l())
        ForEach l()
          If l()\sBackImage = psValue
            iFoundID = l()\iBackImageID
            Break
          EndIf
        Next
        PopListPosition(l())
        
        l()\sBackImage  = psValue
        If iFoundID
          l()\iBackImageID = iFoundID
        Else
          l()\iBackImageID = LoadImage(#PB_Any, psValue)
        EndIf
      EndIf
      
    Else
      sOldPath = l()\sBackImage
      PushListPosition(l())
      ForEach l()
        If l()\sBackImage = sOldPath
          iFoundCount + 1
        EndIf
      Next
      
      PopListPosition(l())
      
      If iFoundCount <= 1 And l()\iBackImageID
        FreeImage(l()\iBackImageID)
      EndIf
      
      l()\iBackImageID = 0
      
    EndIf
    
  EndProcedure
  
  Procedure.i LevelColor(piAttribute.i, piValue.i = -1)
    
    If piValue > -1
      Select piAttribute
        Case #COLOR_BACK
          l()\iBackColor = piValue
        Case #COLOR_SELECT
          l()\iSelectColor = piValue
        Case #COLOR_BORDER
          l()\iBorderColor = piValue
        Case #COLOR_HANDLE
          l()\iHandleColor = piValue
      EndSelect
    Else
      Select piAttribute
        Case #COLOR_BACK
          ProcedureReturn l()\iBackColor
        Case #COLOR_SELECT
          ProcedureReturn l()\iSelectColor
        Case #COLOR_BORDER
          ProcedureReturn l()\iBorderColor
        Case #COLOR_HANDLE
          ProcedureReturn l()\iHandleColor
      EndSelect
    EndIf
    
  EndProcedure
  
  Procedure.i LevelBorderSize(piValue.i = 0)
    
    If piValue > 0
      l()\iBorderSize = piValue
      If piValue > 2
        l()\iHandleSize = piValue + 2
      Else
        l()\iHandleSize = 4
      EndIf
      l()\iNoBorder   = 0
    ElseIf piValue < 0
      l()\iBorderSize = Abs(piValue)
      If Abs(piValue) > 2
        l()\iHandleSize = Abs(piValue) + 2
      Else
        l()\iHandleSize = 4
      EndIf
      l()\iNoBorder   = 1
    Else
      ProcedureReturn l()\iBorderSize
    EndIf
    
  EndProcedure
  
  Procedure LevelWidth(piValue.i = -1)
    
    If piValue > -1
      l()\iWi = piValue
    Else
      ProcedureReturn l()\iWi
    EndIf
    
  EndProcedure
  
  Procedure LevelHeight(piValue.i = -1)
    
    If piValue > -1
      l()\iHe = piValue
    Else
      ProcedureReturn l()\iHe
    EndIf
    
  EndProcedure
  
  Procedure.i SaveLevelset(psPath.s)
    Protected *MainNode, *Node, *Node2
    
    If psPath
      If CreateXML(0)
        *MainNode = CreateXMLNode(RootXMLNode(0), "levelset")
        SetXMLAttribute(*MainNode, "creator", "PureBasic CvField module")
        SetXMLAttribute(*MainNode, "version", "1.02")
        ForEach l()
          *Node = CreateXMLNode(*MainNode, "level", -1)
          SetXMLAttribute(*Node, "name", l()\sName)
          SetXMLAttribute(*Node, "canvas", Str(l()\iCanvas))
          SetXMLAttribute(*Node, "backimage", l()\sBackImage)
          SetXMLAttribute(*Node, "backcolor", Str(l()\iBackColor))
          SetXMLAttribute(*Node, "bordercolor", Str(l()\iBorderColor))
          SetXMLAttribute(*Node, "selectcolor", Str(l()\iSelectColor))
          SetXMLAttribute(*Node, "handlecolor", Str(l()\iHandleColor))
          SetXMLAttribute(*Node, "bordersize", Str(l()\iBorderSize))
          ForEach l()\f()
            *Node2 = CreateXMLNode(*Node, "field", -1)
            SetXMLAttribute(*Node2, "type", Str(l()\f()\iType))
            SetXMLAttribute(*Node2, "x", Str(l()\f()\iX))
            SetXMLAttribute(*Node2, "y", Str(l()\f()\iY))
            SetXMLAttribute(*Node2, "width", Str(l()\f()\iWi))
            SetXMLAttribute(*Node2, "height", Str(l()\f()\iHe))
            SetXMLAttribute(*Node2, "align", Str(l()\f()\iTextAlign))
            SetXMLAttribute(*Node2, "wordwrap", Str(l()\f()\iTextWordwrap))
            SetXMLAttribute(*Node2, "fontname", l()\f()\sFontName)
            SetXMLAttribute(*Node2, "fontsize", Str(l()\f()\iFontSize))
            SetXMLAttribute(*Node2, "fontstyle", Str(l()\f()\iFontStyle))
            SetXMLAttribute(*Node2, "fontcolor", Str(l()\f()\iFontColor))
            SetXMLAttribute(*Node2, "text", l()\f()\sText)
            SetXMLAttribute(*Node2, "image", l()\f()\sImage)
            SetXMLAttribute(*Node2, "constant", Str(l()\f()\iImageConstant))
            SetXMLAttribute(*Node2, "select", Str(l()\f()\iSelect))
          Next
        Next
        SaveXML(0, psPath)
        FreeXML(0)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i LoadLevelset(psPath.s)
    Protected *Node, *Node2
    
    If psPath
      If LoadXML(0, psPath) And XMLStatus(0) = #PB_XML_Success
        ClearList(l())
        *Node = MainXMLNode(0)
        *Node = ChildXMLNode(*Node)
        If *Node
          Repeat
            AddLevel(GetXMLAttribute(*Node, "name"), Val(GetXMLAttribute(*Node, "canvas")))
            LevelBackImage(GetXMLAttribute(*Node, "backimage"))
            LevelBorderSize(Val(GetXMLAttribute(*Node, "bordersize")))
            LevelColor(#COLOR_BACK, Val(GetXMLAttribute(*Node, "backcolor")))
            LevelColor(#COLOR_BORDER, Val(GetXMLAttribute(*Node, "bordercolor")))
            LevelColor(#COLOR_SELECT, Val(GetXMLAttribute(*Node, "selectcolor")))
            LevelColor(#COLOR_HANDLE, Val(GetXMLAttribute(*Node, "handlecolor")))
            
            *Node2 = ChildXMLNode(*Node)
            If *Node2
              Repeat
                AddField(Val(GetXMLAttribute(*Node2, "type")), Val(GetXMLAttribute(*Node2, "x")), Val(GetXMLAttribute(*Node2, "y")), Val(GetXMLAttribute(*Node2, "width")), Val(GetXMLAttribute(*Node2, "height")))
                If FieldType() = #TYPE_TEXT
                  FieldText(GetXMLAttribute(*Node2, "text"))
                  FieldTextAlign(Val(GetXMLAttribute(*Node2, "align")))
                  FieldTextWordwrap(Val(GetXMLAttribute(*Node2, "wordwrap")))
                  FieldFontName(GetXMLAttribute(*Node2, "fontname"))
                  FieldFontSize(Val(GetXMLAttribute(*Node2, "fontsize")))
                  FieldFontStyle(Val(GetXMLAttribute(*Node2, "fontstyle")))
                  FieldFontColor(Val(GetXMLAttribute(*Node2, "fontcolor")))
                ElseIf FieldType() = #TYPE_IMAGE
                  FieldImage(GetXMLAttribute(*Node2, "image"))
                  FieldImageConstant(Val(GetXMLAttribute(*Node2, "constant")))
                EndIf
                If GetXMLAttribute(*Node2, "select") = "1"
                  SelectField()
                EndIf
                *Node2 = NextXMLNode(*Node2)
              Until *Node2 = 0
            EndIf
            
            *Node = NextXMLNode(*Node)
          Until *Node = 0
          ProcedureReturn 1
        Else
          ProcedureReturn 0
        EndIf
      Else
        ProcedureReturn 0
      EndIf
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure.i AddField(piType.i, piX.i = 0, piY.i = 0, piWidth = 0, piHeight = 0)
    
    If ListIndex(l()) > -1
      If AddElement(l()\f())
        With l()\f()
          \iType = piType
          \iX    = piX
          \iY    = piY
          \iWi   = piWidth
          \iHe   = piHeight
          If \iType = #TYPE_TEXT
            \sFontName = "Arial"
            \iFontSize = 14
            \iFontID   = LoadFont(#PB_Any, \sFontName, \iFontSize)
            \iTextAlign = #TEXT_LEFT
          EndIf
        EndWith
        MoveElement(l()\f(), #PB_List_First)
        ProcedureReturn 1
      Else
        ProcedureReturn 0
      EndIf
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure DeleteField()
    
    Protected iFoundCount.i
    Protected sOldPath.s
    
    If ListIndex(l()\f()) > -1
      ResetList(l()\f())
      ForEach l()\f()
        If l()\f()\iSelect = 1
          If l()\f()\iImageID
            sOldPath = l()\f()\sImage
            ForEach l()\f()
              If l()\f()\sImage = sOldPath
                iFoundCount + 1
              EndIf
            Next
            
            If iFoundCount <= 1
              FreeImage(l()\f()\iImageID)
            EndIf
          EndIf
          DeleteElement(l()\f())
        EndIf
      Next
    EndIf
    
  EndProcedure
  
  Procedure SetFieldStack(piPosition.i) 
    Protected *OldElem
    
    *OldElem = @l()\f()
    PushListPosition(l()\f())
    
    Select piPosition
      Case #STACK_TOP
        MoveElement(l()\f(), #PB_List_First)
      Case #STACK_BOTTOM
        MoveElement(l()\f(), #PB_List_Last)
      Case #STACK_UP
        If PreviousElement(l()\f())
          MoveElement(l()\f(), #PB_List_After, *OldElem)
          PopListPosition(l()\f())
        EndIf
      Case #STACK_DOWN
        If NextElement(l()\f())
          MoveElement(l()\f(), #PB_List_Before, *OldElem)
          PopListPosition(l()\f())
        EndIf
    EndSelect
    
  EndProcedure
  
  Procedure.i GetMousePosition()
    Protected iMoX.i
    Protected iMoY.i
    Protected iBrS.i
    Protected iHdS.i, iHdSkh.i, iHdSgh.i
    Protected iBorder.i
    
    iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
    iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
    iBrS = l()\iBorderSize
    iHdS = l()\iHandleSize
    iHdSkh = iHdS / 2
    iHdSgh = iHdS - iHdSkh
    
    ForEach l()\f()
      With l()\f()
        iBorder = l()\iNoBorder - \iSelect
        If ((iMoX >= \iX + (\iWi / 2) - iHdSkh) And (iMoX <= \iX + (\iWi / 2) + iHdSgh)) And ((iMoY >= \iY + \iHe - 1) And (iMoY <= \iY + \iHe + iBrS + 1)) And iBorder <= 0
          ProcedureReturn #POS_HBOTTOM
        ElseIf ((iMoX >= \iX + \iWi - 1) And (iMoX <= \iX + \iWi + iBrS + 1)) And ((iMoY >= \iY + (\iHe / 2) - iHdSkh) And (iMoY <= \iY + (\iHe / 2) + iHdSgh)) And iBorder <= 0
          ProcedureReturn #POS_HRIGHT
        ElseIf ((iMoX >= \iX + \iWi - 1) And (iMoX <= \iX + \iWi + iBrS + 1)) And ((iMoY >= \iY + \iHe + 1) And (iMoY <= \iY + \iHe + iHdS + 1)) And iBorder <= 0
          ProcedureReturn #POS_HMIDDLE
        Else
          If ((iMoX >= \iX) And (iMoX <= \iX + \iWi)) And ((iMoY >= \iY) And (iMoY <= \iY + iBrS)) And iBorder <= 0
            ProcedureReturn #POS_BORDER
          ElseIf ((iMoX >= \iX) And (iMoX <= \iX + iBrS)) And ((iMoY >= \iY) And (iMoY <= \iY + \iHe)) And iBorder <= 0
            ProcedureReturn #POS_BORDER
          ElseIf ((iMoX >= \iX + \iWi) And (iMoX <= \iX + \iWi + iBrS)) And ((iMoY >= \iY) And (iMoY <= \iY + \iHe)) And iBorder <= 0
            ProcedureReturn #POS_BORDER
          ElseIf ((iMoX >= \iX) And (iMoX <= \iX + \iWi)) And ((iMoY >= \iY + \iHe) And (iMoY <= \iY + \iHe + iBrS)) And iBorder <= 0
            ProcedureReturn #POS_BORDER
          Else
            If ((iMoX > \iX + iBrS) And (iMoX < \iX + \iWi)) And ((iMoY > \iY + iBrS) And (iMoY < \iY + \iHe))
              ProcedureReturn #POS_CENTER
            EndIf
          EndIf
        EndIf
      EndWith
    Next
    
    ProcedureReturn #POS_NONE
    
  EndProcedure
  
  Procedure MoveField(piMode.i)
    
    PushListPosition(l()\f())
    
    If piMode = #MODE_BEGIN
      If SelectedFieldCount() > 1
        ForEach l()\f()
          If l()\f()\iSelect = 1
            l()\f()\iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
            l()\f()\iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
          EndIf
        Next
      Else
        l()\f()\iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
        l()\f()\iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
      EndIf
      SetGadgetAttribute(l()\iCanvas, #PB_Canvas_Cursor, #PB_Cursor_Arrows)
    ElseIf piMode = #MODE_DRAW
      If SelectedFieldCount() > 1
        ForEach l()\f()
          With l()\f()
            \iX = \iX + GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX) - \iMoX
            \iY = \iY + GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY) - \iMoY
            
            If \iX < 0 : \iX = 0 : EndIf
            If \iY < 0 : \iY = 0 : EndIf
            
            If \iX + \iWi > l()\iWi  - l()\iBorderSize: \iX = l()\iWi  - \iWi - l()\iBorderSize : EndIf
            If \iY + \iHe > l()\iHe - l()\iBorderSize: \iY = l()\iHe - \iHe - l()\iBorderSize : EndIf
            
            \iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
            \iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
          EndWith
        Next
      Else
        With l()\f()
          \iX = \iX + GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX) - \iMoX
          \iY = \iY + GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY) - \iMoY
          
          If \iX < 0 : \iX = 0 : EndIf
          If \iY < 0 : \iY = 0 : EndIf
          
          If \iX + \iWi > l()\iWi  - l()\iBorderSize: \iX = l()\iWi  - \iWi - l()\iBorderSize : EndIf
          If \iY + \iHe > l()\iHe - l()\iBorderSize: \iY = l()\iHe - \iHe - l()\iBorderSize : EndIf
          
          \iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
          \iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
        EndWith
      EndIf
      Redraw()
    ElseIf piMode = #MODE_END
      SetGadgetAttribute(l()\iCanvas, #PB_Canvas_Cursor, #PB_Cursor_Default)
    EndIf
    
    PopListPosition(l()\f())
    
  EndProcedure
  
  Procedure ResizeField(piHandle.i, piMode.i)
    Protected iDMoX.i
    Protected iDMoY.i
    Protected iConstant.i
    
    With l()\f()
      If piMode = #MODE_BEGIN
        \iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
        \iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
        If piHandle = #POS_HRIGHT
          SetGadgetAttribute(l()\iCanvas, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
        ElseIf piHandle = #POS_HBOTTOM
          SetGadgetAttribute(l()\iCanvas, #PB_Canvas_Cursor, #PB_Cursor_UpDown)
        ElseIf piHandle = #POS_HMIDDLE
          SetGadgetAttribute(l()\iCanvas, #PB_Canvas_Cursor, #PB_Cursor_LeftUpRightDown)
        EndIf
      ElseIf piMode = #MODE_DRAW
        If \iX < 0 : \iX = 0 : EndIf
        If \iY < 0 : \iY = 0 : EndIf
        
        If \iX + \iWi > l()\iWi  - l()\iBorderSize: \iX = l()\iWi  - \iWi - l()\iBorderSize : EndIf
        If \iY + \iHe > l()\iHe - l()\iBorderSize: \iY = l()\iHe - \iHe - l()\iBorderSize : EndIf
        
        iDMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX) - \iMoX
        iDMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY) - \iMoY
        
        If piHandle = #POS_HRIGHT
          \iWi = \iWi + iDMoX
        ElseIf piHandle = #POS_HMIDDLE
          If \iType = #TYPE_IMAGE And \iImageConstant = 1
            iConstant = \iWi / \iHe
            If iDMoX >= iDMoY
              \iWi = \iWi + iDMoX
              \iHe = \iWi / iConstant
            ElseIf iDMoX < iDMoY
              \iHe = \iHe + iDMoY
              \iWi = iConstant * \iHe
            EndIf
          Else
            \iWi = \iWi + iDMoX
            \iHe = \iHe + iDMoY
          EndIf
          
        ElseIf piHandle = #POS_HBOTTOM
          \iHe = \iHe + iDMoY
        EndIf
        
        If \iWi < (2 * l()\iBorderSize) : \iWi = 2 * l()\iBorderSize : EndIf
        If \iHe < (2 * l()\iBorderSize) : \iHe = 2 * l()\iBorderSize : EndIf
        
        \iMoX = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseX)
        \iMoY = GetGadgetAttribute(l()\iCanvas, #PB_Canvas_MouseY)
        
        Redraw()
      ElseIf piMode = #MODE_END
        SetGadgetAttribute(l()\iCanvas, #PB_Canvas_Cursor, #PB_Cursor_Default)
      EndIf
    EndWith
    
  EndProcedure
  
  Procedure SelectField(piState.i = 1)
    
    If piState = 0
      l()\f()\iSelect = 0
    ElseIf piState = 1
      l()\f()\iSelect = 1
    ElseIf piState = 2
      PushListPosition(l()\f())
      ForEach l()\f()
        l()\f()\iSelect = 0
      Next
      PopListPosition(l()\f()) 
    ElseIf piState = -1
      ProcedureReturn l()\f()\iSelect
    EndIf
    
    Redraw()
    
  EndProcedure
  
  Procedure ArrangeField(piMode.i)
    Protected iExX.i
    Protected iExY.i
    Protected iExWi.i
    
    Select piMode
      Case #ARRANGE_HORIZONTAL
        If SelectedFieldCount() < 2
          l()\f()\iX = (l()\iWi / 2) - (l()\f()\iWi / 2)
        Else
          PushListPosition(l()\f())
          ForEach l()\f()
            If l()\f()\iSelect = 1
              l()\f()\iX = (l()\iWi / 2) - (l()\f()\iWi / 2)
            EndIf
          Next
          PopListPosition(l()\f())
        EndIf
        
      Case #ARRANGE_VERTICAL
        If SelectedFieldCount() < 2
          l()\f()\iY = (l()\iHe / 2) - (l()\f()\iHe / 2)
        Else
          PushListPosition(l()\f())
          ForEach l()\f()
            If l()\f()\iSelect = 1
              l()\f()\iY = (l()\iHe / 2) - (l()\f()\iHe / 2)
            EndIf
          Next
          PopListPosition(l()\f())
        EndIf
        
      Case #ARRANGE_LEFT
        If SelectedFieldCount() >= 2
          PushListPosition(l()\f())
          iExX = l()\iWi
          ForEach l()\f()
            If l()\f()\iSelect = 1
              If l()\f()\iX < iExX : iExX = l()\f()\iX : EndIf
            EndIf
          Next
          ForEach l()\f()
            If l()\f()\iSelect = 1
              l()\f()\iX = iExX
            EndIf
          Next
          PopListPosition(l()\f())
        EndIf
        
      Case #ARRANGE_RIGHT
        If SelectedFieldCount() >= 2
          PushListPosition(l()\f())
          iExX = l()\iWi
          ForEach l()\f()
            If l()\f()\iSelect = 1
              If (l()\iWi - (l()\f()\iX + l()\f()\iWi)) < iExX : iExX = l()\iWi - (l()\f()\iX + l()\f()\iWi) : EndIf
            EndIf
          Next
          ForEach l()\f()
            If l()\f()\iSelect = 1
              l()\f()\iX = l()\iWi - iExX - l()\f()\iWi
            EndIf
          Next
          PopListPosition(l()\f())
        EndIf
        
      Case #ARRANGE_UPPER
        If SelectedFieldCount() >= 2
          PushListPosition(l()\f())
          iExY = l()\iHe
          ForEach l()\f()
            If l()\f()\iSelect = 1
              If l()\f()\iY < iExY : iExY = l()\f()\iY : EndIf
            EndIf
          Next
          ForEach l()\f()
            If l()\f()\iSelect = 1
              l()\f()\iY = iExY
            EndIf
          Next
          PopListPosition(l()\f())
        EndIf
        
      Case #ARRANGE_LOWER
        If SelectedFieldCount() >= 2
          PushListPosition(l()\f())
          iExY = l()\iHe
          ForEach l()\f()
            If l()\f()\iSelect = 1
              If (l()\iHe - (l()\f()\iY + l()\f()\iHe)) < iExY : iExY = l()\iHe - (l()\f()\iY + l()\f()\iHe) : EndIf
            EndIf
          Next
          ForEach l()\f()
            If l()\f()\iSelect = 1
              l()\f()\iY = l()\iHe - iExY - l()\f()\iHe
            EndIf
          Next
          PopListPosition(l()\f())
        EndIf
        
    EndSelect
    
    Redraw()
    
  EndProcedure
  
  Procedure.i SelectedFieldCount()
    Protected iCount.i
    
    PushListPosition(l()\f())
    ForEach l()\f()
      If l()\f()\iSelect = 1
        iCount + 1
      EndIf
    Next
    PopListPosition(l()\f())
    
    ProcedureReturn iCount
    
  EndProcedure
  
  Procedure.i SetSelectedField()
    
    ForEach l()\f()
      If l()\f()\iSelect = 1 : ProcedureReturn 1 : EndIf
    Next
    
  EndProcedure
  
  Procedure.i FieldType()
    
    If ListSize(l()\f())
      ProcedureReturn l()\f()\iType
    Else
      ProcedureReturn -1
    EndIf
    
  EndProcedure
  
  Procedure.s FieldText(psValue.s = "<!IGNORE>")
    
    If psValue <> "<!IGNORE>"
      l()\f()\sText = psValue
    Else
      ProcedureReturn l()\f()\sText
    EndIf
    
  EndProcedure
  
  Procedure.i FieldTextAlign(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iTextAlign = piValue
    Else
      ProcedureReturn l()\f()\iTextAlign
    EndIf
    
  EndProcedure
  
  Procedure.i FieldTextWordwrap(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iTextWordwrap = piValue
    Else
      ProcedureReturn l()\f()\iTextWordwrap
    EndIf
    
  EndProcedure
  
  Procedure.s FieldImage(psValue.s = "")
    Protected iFoundID.i
    Protected iFoundCount.i
    Protected sOldPath.s
    
    If psValue
      If l()\f()\iImageID
        sOldPath = l()\f()\sImage
        PushListPosition(l()\f())
        ForEach l()\f()
          If l()\f()\sImage = sOldPath
            iFoundCount + 1
          EndIf
        Next
        
        PopListPosition(l()\f())
        
        If iFoundCount <= 1
          FreeImage(l()\f()\iImageID)
        EndIf
      EndIf
      
      PushListPosition(l()\f())
      ForEach l()\f()
        If l()\f()\sImage = psValue
          iFoundID = l()\f()\iImageID
          Break
        EndIf
      Next
      PopListPosition(l()\f())
      
      l()\f()\sImage   = psValue
      If iFoundID
        l()\f()\iImageID = iFoundID
      Else
        l()\f()\iImageID = LoadImage(#PB_Any, psValue)
      EndIf
      
    Else
      ProcedureReturn l()\f()\sImage
    EndIf
    
  EndProcedure
  
  Procedure.i FieldImageConstant(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iImageConstant = piValue
    Else
      ProcedureReturn l()\f()\iImageConstant
    EndIf
    
  EndProcedure
  
  Procedure.s FieldFontName(psValue.s = "")
    
    If psValue
      If l()\f()\iFontID
        FreeFont(l()\f()\iFontID)
      EndIf
      l()\f()\sFontName = psValue
      l()\f()\iFontID   = LoadFont(#PB_Any, psValue, l()\f()\iFontSize, l()\f()\iFontStyle)
    Else
      ProcedureReturn l()\f()\sFontName
    EndIf
    
  EndProcedure
  
  Procedure.i FieldFontSize(piValue.i = -1)
    
    If piValue > -1
      If l()\f()\iFontID
        FreeFont(l()\f()\iFontID)
      EndIf
      l()\f()\iFontSize = piValue
      l()\f()\iFontID   = LoadFont(#PB_Any, l()\f()\sFontName, piValue, l()\f()\iFontStyle)
    Else
      ProcedureReturn l()\f()\iFontSize
    EndIf
    
  EndProcedure
  
  Procedure.i FieldFontStyle(piValue.i = -1)
    
    If piValue > -1
      If l()\f()\iFontID
        FreeFont(l()\f()\iFontID)
      EndIf
      l()\f()\iFontStyle = piValue
      l()\f()\iFontID    = LoadFont(#PB_Any, l()\f()\sFontName, l()\f()\iFontSize, l()\f()\iFontStyle)
    Else
      ProcedureReturn l()\f()\iFontStyle
    EndIf
    
  EndProcedure
  
  Procedure.i FieldFontColor(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iFontColor = piValue
    Else
      ProcedureReturn l()\f()\iFontColor
    EndIf
    
  EndProcedure
  
  Procedure FieldX(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iX = piValue
    Else
      ProcedureReturn l()\f()\iX
    EndIf
    
  EndProcedure
  
  Procedure FieldY(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iY = piValue
    Else
      ProcedureReturn l()\f()\iY
    EndIf
    
  EndProcedure
  
  Procedure FieldWidth(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iWi = piValue
    Else
      ProcedureReturn l()\f()\iWi
    EndIf
    
  EndProcedure
  
  Procedure FieldHeight(piValue.i = -1)
    
    If piValue > -1
      l()\f()\iHe = piValue
    Else
      ProcedureReturn l()\f()\iHe
    EndIf
    
  EndProcedure
  
  Procedure RedrawBackground()
    
    If l()\iBackColor > -1
      Box(0, 0, l()\iWi, l()\iHe, l()\iBackColor)
    EndIf
    If l()\iBackImageID
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      
      DrawImage(ImageID(l()\iBackImageID), 0, 0, l()\iWi, l()\iHe)
      
      DrawingMode(#PB_2DDrawing_Default)
    EndIf
    
  EndProcedure
  
  Procedure RedrawBoxes()
    Protected iHdS.i
    Protected iHdSkh.i
    
    iHdS   = l()\iHandleSize
    iHdSkh = iHdS / 2
    
    With l()\f()
      If \iSelect
        FrontColor(l()\iSelectColor)
      Else
        FrontColor(l()\iBorderColor)
      EndIf
      If l()\iNoBorder = 0 Or \iSelect
        Box(\iX, \iY, \iWi, l()\iBorderSize)
        Box(\iX, \iY, l()\iBorderSize, \iHe)
        Box(\iX + \iWi, \iY, l()\iBorderSize, \iHe)
        Box(\iX, \iY + \iHe, \iWi, l()\iBorderSize)
        FrontColor(l()\iHandleColor)
        If \iImageConstant = 0
          Box(\iX + (\iWi / 2) - iHdSkh, \iY + \iHe - 1, iHdS, iHdS)
          Box(\iX + \iWi - 1, \iY + (\iHe / 2) - iHdSkh, iHdS, iHdS)
        EndIf
        Box(\iX + \iWi - 1, \iY + \iHe - 1, iHdS, iHdS)
      EndIf
    EndWith
    
  EndProcedure
  
  Procedure RedrawText()
    Protected iTWi.i
    Protected iTHe.i
    Protected i.i, j.i
    Protected iAnz.i
    Protected sRep.s
    Protected Dim asWords.s(0)
    Protected Dim asLines.s(0)
    
    If l()\f()\iFontID And l()\f()\sText
      DrawingFont(FontID(l()\f()\iFontID))
      DrawingMode(#PB_2DDrawing_Transparent)
      
      If l()\f()\iFontColor
        FrontColor(l()\f()\iFontColor)
      Else
        FrontColor($000000)
      EndIf
      
      iTWi = TextWidth(l()\f()\sText)
      iTHe = TextHeight(l()\f()\sText)
      
      If l()\f()\iWi = #PB_Ignore
        l()\f()\iWi = iTWi + 20
      EndIf
      If l()\f()\iHe = #PB_Ignore
        l()\f()\iHe = iTHe + 20
      EndIf
      
      With l()\f()
        If iTWi > \iWi - 20
          If \iTextWordwrap
            sRep = ReplaceString(\sText, " ", "<!WW>")
            sRep = ReplaceString(sRep,   "-", "-<!WW>")
            iAnz = CountString(sRep, "<!WW>")
            ReDim asWords(iAnz)
            If iAnz = 0
              \iWi = iTWi + 20
              asLines(0) = \sText
            Else
              For i = 1 To iAnz + 1
                asWords(i - 1) = StringField(sRep, i, "<!WW>")
              Next i
              
              i = 0
              j = 0
              Repeat
                Repeat
                  If i >= 1 And Right(asWords(i - 1), 1) = "-"
                    sRep = asLines(j) + asWords(i)
                  Else
                    sRep = asLines(j) + " " + asWords(i)
                  EndIf
                  
                  If TextWidth(sRep) > \iWi - 20
                    If CountString(Trim(sRep), " ") + CountString(sRep, "-") = 0
                      \iWi = TextWidth(sRep) + 20
                    EndIf
                    Break
                  Else
                    asLines(j) = sRep
                  EndIf
                  i + 1
                  If i > ArraySize(asWords())
                    Break 2
                  EndIf
                ForEver
                If asLines(j) <> ""
                  j + 1
                EndIf
                ReDim asLines(j)
              ForEver
            EndIf
          Else
            \iWi = iTWi + 20
            asLines(0) = \sText
          EndIf
        Else 
          asLines(0) = \sText
        EndIf
        
        i = ArraySize(asLines()) + 1
        If i * (iTHe + 10) > \iHe - 10
          \iHe = 10 + (i * (iTHe + 10))
        EndIf
        
        If \iTextAlign = #TEXT_LEFT
          For i = 0 To ArraySize(asLines())
            DrawText(\iX + 10, \iY + 10 + (i * (iTHe + 10)), Trim(asLines(i)))
          Next i
        ElseIf \iTextAlign = #TEXT_CENTER
          For i = 0 To ArraySize(asLines())
            iTWi = TextWidth(asLines(i))
            DrawText(\iX + (\iWi / 2) - (iTWi / 2), \iY + 10 + (i * (iTHe + 10)), Trim(asLines(i)))
          Next i
        ElseIf \iTextAlign = #TEXT_RIGHT
          For i = 0 To ArraySize(asLines())
            iTWi = TextWidth(asLines(i))
            DrawText(\iX + \iWi - iTWi - 10, \iY + 10 + (i * (iTHe + 10)), Trim(asLines(i)))
          Next i
        EndIf
      EndWith
      
      DrawingMode(#PB_2DDrawing_Default)
    EndIf
    
  EndProcedure
  
  Procedure RedrawImage()
    
    If l()\f()\iImageID
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      
      If l()\f()\iWi = #PB_Ignore
        l()\f()\iWi = ImageWidth(l()\f()\iImageID)
      EndIf
      If l()\f()\iHe = #PB_Ignore
        l()\f()\iHe = ImageHeight(l()\f()\iImageID)
      EndIf
      
      DrawImage(ImageID(l()\f()\iImageID), l()\f()\iX + l()\iBorderSize, l()\f()\iY + l()\iBorderSize, l()\f()\iWi - l()\iBorderSize, l()\f()\iHe - l()\iBorderSize)
      
      DrawingMode(#PB_2DDrawing_Default)
    EndIf
    
  EndProcedure
  
  Procedure.i Redraw(piOutput.i = 0)
    Protected iPrevious.i
    
    PushListPosition(l()\f())
    
    If piOutput = 0
      piOutput = CanvasOutput(l()\iCanvas)
      If piOutput = 0
        ProcedureReturn 0
      EndIf
    EndIf
    
    If StartDrawing(piOutput)
      RedrawBackground()
      If ListSize(l()\f())
        SelectElement(l()\f(), ListSize(l()\f()) - 1)
        Repeat
          If l()\f()\iType = #TYPE_TEXT
            RedrawText()
          EndIf
          If l()\f()\iType = #TYPE_IMAGE
            RedrawImage()
          EndIf
          RedrawBoxes()
          
          iPrevious = PreviousElement(l()\f())
        Until iPrevious = 0
      EndIf
      StopDrawing()
    EndIf
    
    PopListPosition(l()\f())
    
  EndProcedure
  
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration
    #WIN_MAIN
  EndEnumeration
  
  Enumeration
    #CAN_DRAW
    #PAN_SET
    #TXT_IPATH
    #BUT_IPATH
    #TXT_LCURRENT
    #COM_LCURRENT
    #BUT_LNEW
    #TXT_LIMAGE
    #BUT_LIMAGE
    #TXT_LBCOL
    #BUT_LBCOL
    #TXT_LBCOL1
    #TXT_LBOCOL
    #BUT_LBOCOL
    #TXT_LBOCOL1
    #TXT_LSCOL
    #BUT_LSCOL
    #TXT_LSCOL1
    #TXT_LHCOL
    #BUT_LHCOL
    #TXT_LHCOL1
    #TXT_LBSIZE
    #STR_LBSIZE
    #BUT_LDEL
    #BUT_TNEW
    #BUT_TDEL
    #TXT_TTEXT
    #EDT_TTEXT
    #TXT_TFONT
    #BUT_TFONT
    #TXT_TALIGN
    #OPT_TLEFT
    #OPT_TRIGHT
    #OPT_TCENTER
    #CHE_TWORDWRAP
    #BUT_INEW
    #BUT_IDEL
    #CHE_IFIXED
  EndEnumeration
  
  Enumeration 11
    #MIT_LOAD
    #MIT_SAVE
  EndEnumeration
  
  UseModule CvField
  
  OpenWindow(#WIN_MAIN, 0, 0, 1190, 640, "", #PB_Window_SystemMenu)
  CreateMenu(0, WindowID(#WIN_MAIN))
  MenuTitle("XML Export")
  MenuItem(#MIT_LOAD, "Load file")
  MenuItem(#MIT_SAVE, "Save file")
  CanvasGadget(#CAN_DRAW, 10, 10, 760, 600, #PB_Canvas_ClipMouse)
  PanelGadget(#PAN_SET, 780, 10, 400, 600)
  AddGadgetItem(#PAN_SET, -1, "Level")
  TextGadget(#TXT_LCURRENT, 10, 38, 140, 20, "Current Level:", #PB_Text_Right)
  ComboBoxGadget(#COM_LCURRENT, 210, 38, 180, 20)
  ButtonGadget(#BUT_LNEW, 10, 8, 80, 20, "New Level...")
  TextGadget(#TXT_LIMAGE, 10, 68, 140, 20, "Background image:", #PB_Text_Right)
  ButtonGadget(#BUT_LIMAGE, 210, 68, 180, 20, "Background Image...")
  TextGadget(#TXT_LBCOL, 10, 98, 140, 20, "Background color:", #PB_Text_Right)
  ButtonGadget(#BUT_LBCOL, 210, 98, 180, 20, "Background color...")
  TextGadget(#TXT_LBCOL1, 160, 98, 40, 20, "")
  TextGadget(#TXT_LBOCOL, 10, 128, 140, 20, "Border color:", #PB_Text_Right)
  ButtonGadget(#BUT_LBOCOL, 210, 128, 180, 20, "Border color...")
  TextGadget(#TXT_LBOCOL1, 160, 128, 40, 20, "")
  TextGadget(#TXT_LSCOL, 10, 158, 140, 20, "Selected color:", #PB_Text_Right)
  ButtonGadget(#BUT_LSCOL, 210, 158, 180, 20, "Selected color...")
  TextGadget(#TXT_LSCOL1, 160, 158, 40, 20, "")
  TextGadget(#TXT_LHCOL, 10, 188, 140, 20, "Handle color:", #PB_Text_Right)
  ButtonGadget(#BUT_LHCOL, 210, 188, 180, 20, "Handle color...")
  TextGadget(#TXT_LHCOL1, 160, 188, 40, 20, "")
  TextGadget(#TXT_LBSIZE, 10, 218, 140, 20, "Border size:", #PB_Text_Right)
  StringGadget(#STR_LBSIZE, 210, 218, 180, 20, "")
  ButtonGadget(#BUT_LDEL, 310, 8, 80, 20, "Delete Level")
  AddGadgetItem(#PAN_SET, -1, "Text Field")
  ButtonGadget(#BUT_TNEW, 10, 8, 80, 20, "New Text")
  ButtonGadget(#BUT_TDEL, 310, 8, 80, 20, "Delete Text")
  TextGadget(#TXT_TTEXT, 10, 38, 380, 20, "Text:")
  EditorGadget(#EDT_TTEXT, 10, 58, 380, 80, #PB_Editor_WordWrap)
  TextGadget(#TXT_TFONT, 10, 148, 140, 20, "Font:", #PB_Text_Right)
  ButtonGadget(#BUT_TFONT, 210, 148, 180, 20, "change Font...")
  TextGadget(#TXT_TALIGN, 10, 178, 140, 20, "Alignment:", #PB_Text_Right)
  OptionGadget(#OPT_TLEFT, 210, 178, 60, 20, "left")
  OptionGadget(#OPT_TRIGHT, 270, 178, 60, 20, "right")
  OptionGadget(#OPT_TCENTER, 330, 178, 60, 20, "center")
  CheckBoxGadget(#CHE_TWORDWRAP, 210, 208, 180, 20, "Enable Wordwrap")
  AddGadgetItem(#PAN_SET, -1, "Image Field")
  TextGadget(#TXT_IPATH, 10, 40, 140, 20, "Image Path:", #PB_Text_Right)
  ButtonGadget(#BUT_IPATH, 210, 40, 180, 20, "change Path...")
  ButtonGadget(#BUT_INEW, 10, 8, 80, 20, "New Image...")
  ButtonGadget(#BUT_IDEL, 310, 8, 80, 20, "Delete Image")
  CheckBoxGadget(#CHE_IFIXED, 210, 68, 180, 20, "Fixed aspect ratio")
  CloseGadgetList()
  
  CreatePopupMenu(1)
  MenuItem(0, "Delete")
  MenuBar()
  MenuItem(1, "position up")
  MenuItem(2, "position down")
  MenuItem(3, "move to top")
  MenuItem(4, "move to bottom")
  MenuBar()
  MenuItem(5, "horizontal alignment")
  MenuItem(6, "vertical alignment")
  MenuItem(7, "align left border")
  MenuItem(8, "align right border")
  MenuItem(9, "align upper border")
  MenuItem(10,"align lower border")
  
  Define iEvent.i
  Define iMode.i
  Define NewList Levels.s()
  
  AddLevel("Main", #CAN_DRAW)
  AddGadgetItem(#COM_LCURRENT, -1, "Main")
  SetGadgetState(#COM_LCURRENT, 0)
  LevelColor(#COLOR_BACK, $FFFFFF)
  AddField(#TYPE_TEXT, 0, 0, #PB_Ignore, #PB_Ignore)
  FieldText("InitText")
  Redraw()
  
  Repeat
    iEvent = WaitWindowEvent()
    
    Select iEvent
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #CAN_DRAW
            
            Select EventType()
              Case #PB_EventType_LeftButtonDown
                
                Select GetMousePosition()
                  Case #POS_BORDER
                    MoveField(#MODE_BEGIN)
                    iMode = #POS_BORDER
                  Case #POS_HBOTTOM
                    SelectField(2) : SelectField()
                    ResizeField(#POS_HBOTTOM, #MODE_BEGIN)
                    iMode = #POS_HBOTTOM
                  Case #POS_HMIDDLE
                    SelectField(2) : SelectField()
                    ResizeField(#POS_HMIDDLE, #MODE_BEGIN)
                    iMode = #POS_HMIDDLE
                  Case #POS_HRIGHT
                    SelectField(2) : SelectField()
                    ResizeField(#POS_HRIGHT, #MODE_BEGIN)
                    iMode = #POS_HRIGHT
                    
                  Case #POS_CENTER
                    If GetGadgetAttribute(#CAN_DRAW, #PB_Canvas_Modifiers) & #PB_Canvas_Control
                      If SelectField(-1)
                        SelectField(0)
                        SetGadgetText(#EDT_TTEXT, "")
                      Else
                        SelectField(1)
                        SetGadgetText(#EDT_TTEXT, FieldText())
                      EndIf
                    Else
                      SelectField(2)
                      SelectField(1)
                      SetGadgetText(#EDT_TTEXT, FieldText())
                    EndIf
                    
                    If SelectedFieldCount() = 1
                      SetSelectedField()
                      Select FieldType()
                        Case #TYPE_TEXT
                          SetGadgetText(#EDT_TTEXT, FieldText())
                          SetGadgetState(#CHE_TWORDWRAP, FieldTextWordwrap())
                          Select FieldTextAlign()
                            Case #TEXT_RIGHT  : SetGadgetState(#OPT_TRIGHT, 1)
                            Case #TEXT_CENTER : SetGadgetState(#OPT_TCENTER, 1)
                            Case #TEXT_LEFT   : SetGadgetState(#OPT_TLEFT, 1)
                          EndSelect
                        Case #TYPE_IMAGE
                          SetGadgetState(#CHE_IFIXED, FieldImageConstant())
                      EndSelect
                    EndIf
                    
                  Case #POS_NONE
                    SelectField(2)
                    SetGadgetText(#EDT_TTEXT, "")
                    SetGadgetState(#CHE_TWORDWRAP, 0)
                    SetGadgetState(#OPT_TRIGHT, 0)
                    SetGadgetState(#OPT_TCENTER, 0)
                    SetGadgetState(#OPT_TLEFT, 0)
                    SetGadgetState(#CHE_IFIXED, 0)
                    
                EndSelect
                
              Case #PB_EventType_LeftButtonUp
                If iMode = #POS_BORDER
                  MoveField(#MODE_END)
                  iMode = 0
                ElseIf iMode = #POS_HBOTTOM
                  ResizeField(#POS_HBOTTOM, #MODE_END)
                  iMode = 0
                ElseIf iMode = #POS_HMIDDLE
                  ResizeField(#POS_HMIDDLE, #MODE_END)
                  iMode = 0
                ElseIf iMode = #POS_HRIGHT
                  ResizeField(#POS_HRIGHT, #MODE_END)
                  iMode = 0
                EndIf
                
              Case #PB_EventType_MouseMove
                If iMode = #POS_BORDER
                  MoveField(#MODE_DRAW)
                ElseIf iMode = #POS_HBOTTOM
                  ResizeField(#POS_HBOTTOM, #MODE_DRAW)
                ElseIf iMode = #POS_HMIDDLE
                  ResizeField(#POS_HMIDDLE, #MODE_DRAW)
                ElseIf iMode = #POS_HRIGHT
                  ResizeField(#POS_HRIGHT, #MODE_DRAW)
                EndIf
                
              Case #PB_EventType_RightClick
                If GetMousePosition() = #POS_CENTER
                  If SelectField(-1)
                    DisplayPopupMenu(1, WindowID(#WIN_MAIN))
                  EndIf
                EndIf
                
            EndSelect
            
          Case #EDT_TTEXT
            If FieldType() = #TYPE_TEXT And GetGadgetText(#EDT_TTEXT) And SelectedFieldCount() = 1
              FieldText(GetGadgetText(#EDT_TTEXT))
              Redraw()
            EndIf
            
          Case #BUT_TFONT
            If FieldType() = #TYPE_TEXT And SelectedFieldCount() = 1
              FontRequester(FieldFontName(), FieldFontSize(), #PB_FontRequester_Effects, FieldFontColor(), FieldFontStyle())
              FieldFontColor(SelectedFontColor())
              FieldFontName(SelectedFontName())
              FieldFontSize(SelectedFontSize())
              FieldFontStyle(SelectedFontStyle())
              Redraw()
            EndIf
            
          Case #BUT_IPATH
            If FieldType() = #TYPE_IMAGE And SelectedFieldCount() = 1
              FieldImage(OpenFileRequester("Choose image", GetHomeDirectory(), "*.*", 0))
              Redraw()
            EndIf
            
          Case #BUT_TNEW
            AddField(#TYPE_TEXT, 0, 0, #PB_Ignore, #PB_Ignore)
            SelectField(2) : SelectField()
            FieldText("New Text")
            SetGadgetText(#EDT_TTEXT, FieldText())
            Redraw()
            
          Case #BUT_INEW
            AddField(#TYPE_IMAGE, 0, 0, #PB_Ignore, #PB_Ignore)
            SelectField(2)
            SelectField()
            FieldImage(#PB_Compiler_Home + "Examples/Sources/Data/PureBasicLogo.bmp")
            Redraw()
            
          Case #BUT_LNEW
            AddLevel(InputRequester("New level", "type name:", ""), #CAN_DRAW)
            LevelColor(#COLOR_BACK, $FFFFFF)
            GetLevels(Levels(), #CAN_DRAW)
            ClearGadgetItems(#COM_LCURRENT)
            ForEach Levels()
              AddGadgetItem(#COM_LCURRENT, -1, Levels())
            Next
            SetGadgetState(#COM_LCURRENT, 0)
            Redraw()
            
          Case #BUT_TDEL, #BUT_IDEL
            If SelectedFieldCount() = 1
              DeleteField()
              Redraw()
              SetGadgetText(#EDT_TTEXT, "")
              SetGadgetState(#CHE_TWORDWRAP, 0)
              SetGadgetState(#OPT_TRIGHT, 0)
              SetGadgetState(#OPT_TCENTER, 0)
              SetGadgetState(#OPT_TLEFT, 0)
              SetGadgetState(#CHE_IFIXED, 0)
            EndIf
            
          Case #BUT_LDEL
            DeleteLevel()
            GetLevels(Levels(), #CAN_DRAW)
            ClearGadgetItems(#COM_LCURRENT)
            ForEach Levels()
              AddGadgetItem(#COM_LCURRENT, -1, Levels())
            Next
            SetGadgetState(#COM_LCURRENT, 0)
            If ListSize(Levels()) = 0
              PostEvent(#PB_Event_Gadget, #WIN_MAIN, #BUT_LNEW)
            EndIf
            
          Case #BUT_LIMAGE
            LevelBackImage(OpenFileRequester("Choose image", GetHomeDirectory(), "*.*", 0))
            Redraw()
            
          Case #BUT_LBCOL
            LevelColor(#COLOR_BACK, ColorRequester(LevelColor(#COLOR_BACK)))
            Redraw()
            
          Case #BUT_LBOCOL
            LevelColor(#COLOR_BORDER, ColorRequester(LevelColor(#COLOR_BORDER)))
            Redraw()
            
          Case #BUT_LHCOL
            LevelColor(#COLOR_HANDLE, ColorRequester(LevelColor(#COLOR_HANDLE)))
            Redraw()
            
          Case #BUT_LSCOL
            LevelColor(#COLOR_SELECT, ColorRequester(LevelColor(#COLOR_SELECT)))
            
          Case #STR_LBSIZE
            LevelBorderSize(Val(GetGadgetText(#STR_LBSIZE)))
            Redraw()
            
          Case #OPT_TLEFT
            If FieldType() = #TYPE_TEXT And SelectedFieldCount() = 1
              FieldTextAlign(#TEXT_LEFT)
              Redraw()
            EndIf
            
          Case #OPT_TRIGHT
            If FieldType() = #TYPE_TEXT And SelectedFieldCount() = 1
              FieldTextAlign(#TEXT_RIGHT)
              Redraw()
            EndIf
            
          Case #OPT_TCENTER
            If FieldType() = #TYPE_TEXT And SelectedFieldCount() = 1
              FieldTextAlign(#TEXT_CENTER)
              Redraw()
            EndIf
            
          Case #CHE_IFIXED
            If FieldType() = #TYPE_IMAGE
              FieldImageConstant(GetGadgetState(#CHE_IFIXED))
              Redraw()
            EndIf
            
          Case #CHE_TWORDWRAP
            If FieldType() = #TYPE_TEXT
              FieldTextWordwrap(GetGadgetState(#CHE_TWORDWRAP))
              Redraw()
            EndIf
            
          Case #COM_LCURRENT
            CurrentLevel(GetGadgetText(#COM_LCURRENT), #CAN_DRAW)
            Redraw()
            
        EndSelect
        
      Case #PB_Event_Menu
        Select EventMenu()
            
          Case #MIT_SAVE
            SaveLevelset(SaveFileRequester("save to XML", GetHomeDirectory(), "xml|*.xml", 0))
            
          Case #MIT_LOAD
            LoadLevelset(OpenFileRequester("load from XML", GetHomeDirectory(), "xml|*.xml", 0))
            GetLevels(Levels(), #CAN_DRAW)
            ClearGadgetItems(#COM_LCURRENT)
            ForEach Levels()
              AddGadgetItem(#COM_LCURRENT, -1, Levels())
            Next
            SetGadgetState(#COM_LCURRENT, 0)
            Redraw()
            
          Case 0
            DeleteField()
            Redraw()
            
          Case 1 : SetFieldStack(#STACK_UP)     : Redraw()
          Case 2 : SetFieldStack(#STACK_DOWN)   : Redraw()
          Case 3 : SetFieldStack(#STACK_TOP)    : Redraw()
          Case 4 : SetFieldStack(#STACK_BOTTOM) : Redraw()
          Case 5 : ArrangeField(#ARRANGE_HORIZONTAL)
          Case 6 : ArrangeField(#ARRANGE_VERTICAL)
          Case 7 : ArrangeField(#ARRANGE_LEFT)
          Case 8 : ArrangeField(#ARRANGE_RIGHT)
          Case 9 : ArrangeField(#ARRANGE_UPPER)
          Case 10: ArrangeField(#ARRANGE_LOWER)
            
        EndSelect
        
    EndSelect
    
  Until iEvent = #PB_Event_CloseWindow
  
  UnuseModule CvField
CompilerEndIf
