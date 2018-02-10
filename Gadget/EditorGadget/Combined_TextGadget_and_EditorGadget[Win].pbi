;   Description: A combined Text- and EditorGadget
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28668
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 hjbremer
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

;Mini-EditGadget, HJBremer 18.01.2015 Ver.1.28

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf

DeclareModule EditGadget
  Declare.i EditGadget(nr, x, y, b, h, text$, flag = 0, decimals = 0)
  Declare.i EditGadget_GetLfdnr(nr)
  Declare.s EditGadget_GetText(nr, ablfdnr = 1)
  Declare.i EditGadget_SetTextFont(nr, fontid, ablfdnr = 1)
  Declare.i EditGadget_SetTextCheck(nr, pointer)
  Declare.i EditGadget_SetInfoLeft(nr, text$, width = -1, fontid = 0)
  Declare.i EditGadget_SetInfoRight(nr, text$, width = -1, fontid = 0)   
  Declare.s EditGadget_TextSave(file$)
  Declare.s EditGadget_TextLoad(file$)
  
  #EG_Right  = #PB_Text_Right            ;2   
  #EG_Select = 4
  #EG_Numeric = #PB_String_Numeric       ;8192
  #EG_ReadOnly = #PB_Editor_ReadOnly     ;2048
  
  Structure EditGadget
    nr.i
    id.i
    wprc.i
    left.i
    right.i
    flag.i
    deci.i
    check.i
    lfdnr.i
  EndStructure   
EndDeclareModule

Module EditGadget     
  EnableExplicit     
  #space = 2                                            ;für Abstand im EditorGadget
  #trenn = #LF$                                         ;für GetGadgetText
  #infotextcolor = $AAAA00                              ;für InfoTextGadget                 
  Global backColorBrush = GetStockObject_(#NULL_BRUSH)  ;für InfoTextGadget   
  Global NewList editlist()                             ;Liste verwaltet Gadgetdaten
  Prototype EditCheck(eventtyp, wparam, *eg.EditGadget) ;für externe Eingabekontrolle
  
  Procedure.i EditGadget_GetTextWidth(t$, fontid)
    Protected size.size, dc = GetDC_(0)     
    SelectObject_(dc, fontid)
    GetTextExtentPoint32_(dc, @t$, Len(t$), size)     
    ReleaseDC_(0, dc)
    ProcedureReturn size\cx       
  EndProcedure   
  Procedure.i EditGadget_GetTextHeight(t$, fontid)
    Protected size.size, dc = GetDC_(0)
    t$ + "Test" ;falls t$ leer
    SelectObject_(dc, fontid)
    GetTextExtentPoint32_(dc, @t$, Len(t$), size)     
    ReleaseDC_(0, dc)
    ProcedureReturn size\cy       
  EndProcedure
  
  Procedure.s EditGadget_GetText(nr, ablfdnr = 1)
    Protected *edit.editgadget   
    Static text$: text$ = ""     
    ForEach editlist()
      *edit = editlist()
      If nr = *edit\nr Or nr = #PB_All
        If ablfdnr = 1 Or *edit\lfdnr >= ablfdnr           
          text$ + GetGadgetText(*edit\nr)
          If nr = #PB_All: text$ + #trenn: EndIf
        EndIf   
      EndIf       
    Next
    ProcedureReturn text$   
  EndProcedure
  
  Procedure.i EditGadget_GetLfdnr(nr)     
    Protected *edit.editgadget, lfdnr = 0
    ForEach editlist()
      *edit = editlist()
      If nr = *edit\nr: lfdnr = *edit\lfdnr: EndIf 
    Next
    ProcedureReturn lfdnr
  EndProcedure
  
  Procedure.i EditGadget_SetTextCheck(nr, pointer)     
    Protected *edit.editgadget
    ForEach editlist()
      *edit = editlist()
      If nr = *edit\nr Or nr = #PB_All
        *edit\check = pointer
      EndIf 
    Next
  EndProcedure     
  Procedure.i EditGadget_SetTextFont(nr, fontid, ablfdnr = 1)
    Protected *edit.editgadget, r.rect, height
    ForEach editlist()
      *edit = editlist()
      If nr = *edit\nr Or nr = #PB_All
        If ablfdnr = 1 Or *edit\lfdnr >= ablfdnr
          SetGadgetFont(*edit\nr, fontid)
          height = EditGadget_GetTextHeight("Uups", fontid)
          SendMessage_(*edit\id, #EM_GETRECT, 0, r)    ;EditorGadget Drawbereich holen 
          r\top = ((r\bottom - height) / 2)            ;Texthöhe abziehen, Rest / 2
          SendMessage_(*edit\id, #EM_SETRECT, 0, r)    ;Drawbereich verschieben           
        EndIf
      EndIf 
    Next
  EndProcedure   
  Procedure.i EditGadget_SetTextRight(id)
    Protected pf.PARAFORMAT
    pf\cbSize = SizeOf(PARAFORMAT)
    pf\dwMask = #PFM_ALIGNMENT
    pf\wAlignment = #PFA_RIGHT
    SendMessage_(id, #EM_SETPARAFORMAT, 0, pf)       
  EndProcedure
  
  Procedure.i EditGadget_SetInfoLeft(nr, text$, width = -1, fontid = 0)
    ;in linkes InfoTextgadget Text einsetzen und alles Resizen
    Protected *edit.EditGadget, r.rect
    ForEach editlist()
      *edit = editlist()
      If nr = *edit\nr Or nr = #PB_All
        If fontid = 0: fontid = GetGadgetFont(nr): EndIf     
        SetGadgetText(*edit\left, text$)
        SetGadgetFont(*edit\left, fontid)     
        If width = -1: width = EditGadget_GetTextWidth(text$, fontid): EndIf 
        ResizeGadget(*edit\left, #PB_Ignore, #PB_Ignore, width, #PB_Ignore)
        SendMessage_(*edit\id, #EM_GETRECT, 0, r)    ;aktuelles EditRect holen
        r\left = #space + width                      ; ändern
        SendMessage_(*edit\id, #EM_SETRECT, 0, r)    ; setzen
      EndIf
    Next     
    ProcedureReturn width
  EndProcedure   
  Procedure.i EditGadget_SetInfoRight(nr, text$, width = -1, fontid = 0)
    ;in dem rechten InfoTextgadget Text einsetzen und alles Resizen
    Protected *edit.EditGadget, r.rect, rr.rect
    ForEach editlist()
      *edit = editlist()
      If nr = *edit\nr Or nr = #PB_All
        If fontid = 0: fontid = GetGadgetFont(nr): EndIf
        SetGadgetText(*edit\right, text$)
        SetGadgetFont(*edit\right, fontid)     
        If width = -1: width = EditGadget_GetTextWidth(text$, fontid): EndIf   
        ResizeGadget(*edit\right, #PB_Ignore, #PB_Ignore, width, #PB_Ignore)
        GetClientRect_(*edit\id, rr)                 ;Original EditRect holen
        SendMessage_(*edit\id, #EM_GETRECT, 0, r)    ;aktuelles EditRect holen
        r\right = rr\right - width - #space - #space ; ändern
        SendMessage_(*edit\id, #EM_SETRECT, 0, r)    ; setzen
        ResizeGadget(*edit\right, r\right + #space, #PB_Ignore, width, #PB_Ignore)
      EndIf
    Next     
    ProcedureReturn width
  EndProcedure 
  
  Procedure.s EditGadget_TextLoad(file$)
    Protected *edit.editgadget, text$, t$, j
    Protected dnr = ReadFile(#PB_Any, file$)
    If dnr
      text$ = Space(Lof(dnr))
      ReadData(dnr, @text$, Lof(dnr)) 
      CloseFile(dnr)
      ForEach editlist()
        *edit = editlist()
        If *edit\nr
          j + 1: t$ = StringField(text$, j, #trenn)
          SendMessage_(*edit\id, #WM_SETTEXT, 0, @t$)
          SendMessage_(*edit\id, #EM_SETSEL, -1, -1)
          If *edit\flag & #EG_Right: EditGadget_SetTextRight(*edit\id): EndIf
        EndIf       
      Next
    EndIf
    ProcedureReturn text$
  EndProcedure   
  
  Procedure.s EditGadget_TextSave(file$)
    Protected text$     
    Protected dnr = CreateFile(#PB_Any, file$)
    If dnr
      text$ = EditGadget_GetText(#PB_All)         
      WriteData(dnr, @text$, StringByteLength(text$))
      CloseFile(dnr)
    EndIf
    ProcedureReturn text$
  EndProcedure
  
  Procedure.i EditGadget_CB(hwnd, msg, wParam, lParam)   
    ;hwnd ist gleich *edit\id
    Protected *edit.EditGadget = GetWindowLongPtr_(hwnd, #GWL_USERDATA)
    Protected oldwndproc = *edit\wprc     
    Protected EditCheck.EditCheck = *edit\check
    Protected hwndnext
    Static text$
    
    Select msg         
      Case #WM_DESTROY     ;Gadget wird mit FreeGadget(nr) gelöscht
        FreeMemory(*edit)
        FreeGadget(*edit\left): FreeGadget(*edit\right)
        ForEach editlist()
          If *edit = editlist(): DeleteElement(editlist()): EndIf
        Next
        
      Case #WM_CTLCOLORSTATIC                   ;vom TextGadget für Farbe
        SetTextColor_(wparam, #infotextcolor)   ;wParam ist das DC vom TextGadget
        SetBkMode_(wParam, #TRANSPARENT)        ;Farbe läßt sich nur hier ändern     
        ProcedureReturn backColorBrush
        
      Case #WM_SETFOCUS
        If *edit\flag & #EG_Select: SendMessage_(hwnd, #EM_SETSEL, 0, -1): EndIf
        ;es folgt ein Workaround für Drop + Strg V Probleme
        text$ = GetGadgetText(*edit\nr)
        If FindString(text$, #CRLF$)
          text$ = ReplaceString(text$, #CRLF$, " ")
          While FindString(text$, "  ")                 
            text$ = ReplaceString(text$, "  ", " ")
          Wend
          SetGadgetText(*edit\nr, text$)
          If *edit\flag & #EG_Right: EditGadget_SetTextRight(hwnd): EndIf
        EndIf
        
      Case #WM_KILLFOCUS
        If *edit\flag & #EG_Numeric
          text$ = GetGadgetText(*edit\nr)
          text$ = StrF(ValF(text$), *edit\deci)
          SetGadgetText(*edit\nr, text$)
        EndIf
        If *edit\check
          EditCheck(#PB_EventType_LostFocus, wparam, *edit)
        EndIf
        If *edit\flag & #EG_Right: EditGadget_SetTextRight(hwnd): EndIf
        If *edit\flag & #EG_Select: SendMessage_(hwnd, #EM_SETSEL, -1, -1): EndIf
        
      Case #WM_CHAR
        If wparam = #VK_TAB: wparam = 0: EndIf ;#VK_TAB muß hier gelöscht werden !!!
        If *edit\flag & #EG_Numeric
          Select wparam
            Case '-', #VK_0 To #VK_9
            Case ',': wparam = '.'
            Default: wparam = 0
          EndSelect
        EndIf
        If *edit\check
          wparam = EditCheck(#PB_EventType_Change, wparam, *edit)
        EndIf
        
      Case #WM_KEYDOWN
        Select wparam
          Case #VK_TAB:  ;zum nächsten Gadget
            hwndnext = GetWindow_(hwnd, #GW_HWNDNEXT)
            If hwndnext: SetFocus_(hwndnext)
            Else:        SetFocus_(GetWindow_(hwnd, #GW_HWNDFIRST))
            EndIf
            
          Case #VK_UP, #VK_DOWN, #VK_RETURN   ;innerhalb der Gadgets
            ForEach editlist()
              *edit = editlist()
              If hwnd = *edit\id     
                If wparam = #VK_UP
                  If PreviousElement(editlist())
                    Else: LastElement(editlist()): EndIf
                Else
                  If NextElement(editlist())
                    Else: FirstElement(editlist()): EndIf
                EndIf
                *edit = editlist(): SetActiveGadget(*edit\nr)
                Break                       
              EndIf       
            Next   
            wparam = 0  ;#VK_RETURN etc muß hier gelöscht werden !!!
        EndSelect
        
    EndSelect   
    ProcedureReturn CallWindowProc_(oldwndproc, hwnd, msg, wParam, lParam)
  EndProcedure
  
  Procedure.i EditGadget(pbnr, x, y, b, h, text$, flags = 0, decimals = 0)     
    Protected flag, nr, id, fontid
    Protected r.rect, pf.PARAFORMAT
    Protected *edit.EditGadget = AllocateMemory(SizeOf(EditGadget))
    Static lfdnr
    
    lfdnr + 1     
    If flags & #EG_ReadOnly: flag = #PB_Editor_ReadOnly: EndIf     
    If pbnr = #PB_Any
      nr = EditorGadget(#PB_Any, x, y, b, h, flag): id = GadgetID(nr)
    Else
      nr = pbnr: id = EditorGadget(pbnr, x, y, b, h, flag)
    EndIf     
    SetGadgetText(nr, text$)
    
    *edit\nr = nr
    *edit\id = id
    *edit\wprc = SetWindowLongPtr_(id, #GWL_WNDPROC, @EditGadget_CB())           
    *edit\flag = flags
    *edit\deci = decimals
    *edit\left = TextGadget(#PB_Any, 0, 0, 0, h-4, "", #PB_Text_Right|#SS_CENTERIMAGE)
    *edit\right = TextGadget(#PB_Any, 0, 0, 0, h-4, "", #SS_CENTERIMAGE) 
    *edit\lfdnr = lfdnr
    
    SetParent_(GadgetID(*edit\left), id)
    SetParent_(GadgetID(*edit\right), id)     
    SetWindowLongPtr_(id, #GWL_USERDATA, *edit)              ;in Userdata speichern     
    SendMessage_(id, #EM_SHOWSCROLLBAR, #SB_VERT, #False)    ;Scrollbars weg
    SendMessage_(id, #EM_SHOWSCROLLBAR, #SB_HORZ, #False)
    SendMessage_(id, #EM_SETSEL, -1, -1)                     ;Cursor bei Start rechts
    SendMessage_(id, #EM_GETRECT, 0, r): r\left = #space: r\right - #space  ;Abstand
    SendMessage_(id, #EM_SETRECT, 0, r)
    
    If flags & #EG_ReadOnly: SetGadgetColor(nr, #PB_Gadget_FrontColor, #Gray): EndIf   
    
    AddElement(editlist()): editlist() = *edit                  ;muß vor SetFont stehen     
    If flags & #EG_Right: EditGadget_SetTextRight(id): EndIf    ;Text nach rechts
    fontid = GetGadgetFont(nr): EditGadget_SetTextFont(nr, fontid) ;Font + Text mittig       
    
    If pbnr = #PB_Any
      ProcedureReturn nr
    Else
      ProcedureReturn id
    EndIf
  EndProcedure   
EndModule


;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  UseModule EditGadget
  
  LoadFont(0, "Times", 10)
  LoadFont(1, "Arial", 8)
  
  CompilerIf #PB_Compiler_Unicode
    #euro = Chr(8364)
  CompilerElse
    #euro = Chr(0128)
  CompilerEndIf
  
  Enumeration 10
    #window
    #butt1
    #butt2   
    #edit1: #edit2: #edit3: #edit4
  EndEnumeration
  
  Procedure.i Editcheck(eventtyp, wparam, *eg.EditGadget)
    ;ein Beispiel
    Static text$
    
    ;    Debug Str(eventtyp) + " " + *eg\nr
    ;    Debug "--"
    
    If eventtyp = #PB_EventType_Change
      ;Debug wparam
    ElseIf eventtyp = #PB_EventType_LostFocus
      ;If editflags & #EG_Numeric
      ;Debug GetGadgetText(nr)
      ;EndIf
    EndIf
    
    ProcedureReturn wparam
  EndProcedure
  
  OpenWindow(#window, 0, 0, 500, 150, "EditorGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  EditGadget(#edit1, 8, 10, 200, 22, "HJ")
  EditGadget(#edit2, 8, 33, 200, 22, "Bremer")
  EditGadget(#edit3, 8, 56, 200, 22, "Mühlenhof")
  EditGadget(#edit4, 8, 79, 200, 22, "24534 Neumünster", #EG_ReadOnly)
  
  ;alle bisher erstellten EditGadgets erhalten den Font 0
  EditGadget_SetTextFont(#PB_All, FontID(0))   
  
  EditGadget_SetInfoLeft(#edit1, "Vorname:", 60, FontID(1))
  EditGadget_SetInfoLeft(#edit2, "Nachname:", 60, FontID(1))
  EditGadget_SetInfoLeft(#edit3, "Strasse:", 60, FontID(1))
  EditGadget_SetInfoLeft(#edit4, "Plz + Ort:", 60, FontID(1))
  
  edit1 = EditGadget(#PB_Any, 220, 10, 200, 22, "0", #EG_Right|#EG_Select|#EG_Numeric, 2)
  edit2 = EditGadget(#PB_Any, 220, 33, 200, 22, "2", #EG_Right|#EG_Select|#EG_Numeric, 2)
  edit3 = EditGadget(#PB_Any, 220, 56, 200, 22, "3", #EG_Right|#EG_Select|#EG_Numeric, 2)
  edit4 = EditGadget(#PB_Any, 220, 79, 200, 22, "4", #EG_Right|#EG_Select|#EG_Numeric, 2)
  
  ;alle EditGadgets ab edit1 erhalten den Font 1,
  lfdnr = EditGadget_GetLfdnr(edit1)
  EditGadget_SetTextFont(#PB_All, FontID(1), lfdnr) 
  
  EditGadget_SetInfoRight(edit1, #euro, -1, FontID(1))
  EditGadget_SetInfoRight(edit2, #euro, -1, FontID(1))
  EditGadget_SetInfoRight(edit3, #euro, -1, FontID(1))
  EditGadget_SetInfoRight(edit4, #euro, -1, FontID(1))
  
  ;alle EditGadgets erhalten die gleiche Editcheck Prozedur
  EditGadget_SetTextCheck(#PB_All, @Editcheck())
  
  SetActiveGadget(#edit1)
  
  ButtonGadget(#butt1, 8, 110, 88, 22, "load")
  ButtonGadget(#butt2, 108, 110, 88, 22, "save")
  
  ; Debug EditGadget_GetText(#edit4)
  ; Debug EditGadget_GetText(#PB_All)
  ;
  ; lfdnr = EditGadget_GetLfdnr(edit1)
  ; Debug EditGadget_GetText(#PB_All, lfdnr)
  
  Repeat
    event = WaitWindowEvent()
    Select event
      Case #PB_Event_Gadget     
        Select EventGadget()
          Case #butt1: EditGadget_TextLoad("edit.txt")
          Case #butt2: EditGadget_TextSave("edit.txt")
        EndSelect
    EndSelect
    
  Until event = #PB_Event_CloseWindow
  
  
  
  
CompilerEndIf
