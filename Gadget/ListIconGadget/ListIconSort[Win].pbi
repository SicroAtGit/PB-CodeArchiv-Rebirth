;   Description: ListIcon sort
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27260
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 hjbremer
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

; by HJBremer Purebasic 5.20 - Windows x86 - September 2013

; Basis dieses Moduls sind Codes von nalor und bisonte aus dem englischen Forum
; Beide Vorbilder gefallen mir aber nicht. Sie basieren auf einem Beispielcode
; von http://msdn.microsoft.com/de-de/library/bb979183.aspx
; Positiv an den Beispielen sind Idee und die Verwendung von #LVM_SORTITEMSEX.

; Ganz besonders die verwendete Autodetect Funktion ist mir nicht flexibel genug.
; Ich habe darum Autodetect durch ein globales Feld und ListIconSetColumnTyp() ersetzt.
; Vorteil: einfach, sicher und flexibel bzw. erweiterbar.
; Nachteil: Wer verschieben von Spalten erlaubt, muß den Code erweitern und ev. den lParam
; Wert von #HDM_GETITEM/#HDM_SETITEM benutzen um TypDaten (falls vorhanden) einer Spalte mit
; zuverschieben und diesen Wert vorm Sortieren dann auswerten. Meistens wohl nicht der Fall.


DeclareModule ListIconSort
  
  Enumeration Sorttyp
    #ListIconSort_Char
    #ListIconSort_Date
    #ListIconSort_Float
    #ListIconSort_Numeric
  EndEnumeration
  
  Structure LvSortInfo
    lvnr.i         ; PB Gadgednr
    lvid.i         ; GadgedId
    column.i       ; Spalte
    sorttyp.i      ; Datentyp
    direction.i    ; Sortierrichtung
    datemask.s     ; Mask für ParseDate()
  EndStructure
  
  Declare ListIconSortcolumn(lvnr, column, direction)
  Declare ListIconSetColumnTyp(lvnr, column, typ, datemask.s = "")
  
EndDeclareModule

Module ListIconSort
  
  EnableExplicit
  
  Global sortinfoidx
  Global Dim sortinfo.LvSortInfo(0)
  
  Global cursor_original = GetClassLong_(GetDesktopWindow_(), #GCL_HCURSOR)
  Global cursor_sanduhr  = LoadCursor_(0, #IDC_WAIT)
  
  Procedure.i ListIconSetColumnTyp(lvnr, column, sorttyp, datemask.s = "")
    
    ;Procedure dient dazu, der SortierVergleichsfunktion Zugriff auf Eigenschaften
    ; einer Spalte zu ermöglichen. z.B. Datentyp wie Zahlen oder Datum etc.
    ; Die Structur kann fast beliebig erweitert werden.
    
    ;column ab null gezählt !
    ;sortinfoidx = 0 wird für Spalten genutzt, welche keinen Typ haben
    
    sortinfoidx + 1               ;Global in diesem Modul
    ReDim sortinfo(sortinfoidx)   ;Global in diesem Modul
    
    sortinfo(sortinfoidx)\lvnr = lvnr
    sortinfo(sortinfoidx)\lvid = GadgetID(lvnr)
    
    sortinfo(sortinfoidx)\column = column
    sortinfo(sortinfoidx)\sorttyp = sorttyp
    sortinfo(sortinfoidx)\datemask = datemask
    
  EndProcedure
  
  Procedure.i ListIconCompareFunc(lParam1, lParam2, lParamSort)
    ; dies ist die Vergleichsfunktion von #LVM_SORTITEMSEX
    
    ; lParam1 und lParam2 sind die Itemnummern welche verglichen werden
    ; der Rückgabewert des Vergleichs ist -1, +1 oder 0
    
    ; lParamSort ist der Pointer der bei Aufruf von #LVM_SORTITEMSEX übergeben wurde
    
    Static subitem1.s    ;Static beschleunigt das Vergleichen minimal
    Static subitem2.s   
    Static result
    
    Protected *lvs.LvSortInfo = lParamSort
    
    With *lvs
      
      subitem1 = GetGadgetItemText(\lvnr, lParam1, \column)
      subitem2 = GetGadgetItemText(\lvnr, lParam2, \column)
      
      ;beide Subitems gleich
      If subitem1 = subitem2
        result = 0
        ProcedureReturn result
      EndIf
      
      Select \sorttyp
          
        Case #ListIconSort_Numeric
          result = 1
          If \direction = #PB_Sort_Ascending
            If Val(subitem1) < Val(subitem2)
              result = -1
            EndIf
          Else
            If Val(subitem2) < Val(subitem1)
              result = -1
            EndIf
          EndIf
          
        Case #ListIconSort_Float
          ReplaceString(subitem1, ",", ".", #PB_String_InPlace) ;Zeitverlust durch Replace
          ReplaceString(subitem2, ",", ".", #PB_String_InPlace) ;beträgt ca 3-5%
          result = 1
          If \direction = #PB_Sort_Ascending
            If ValF(subitem1) < ValF(subitem2)
              result = -1
            EndIf
          Else
            If ValF(subitem2) < ValF(subitem1)
              result = -1
            EndIf
          EndIf                 
          
        Case #ListIconSort_Date
          result = 1
          If \direction = #PB_Sort_Ascending
            If ParseDate(\datemask, subitem1) < ParseDate(\datemask, subitem2)
              result = -1
            EndIf
          Else
            If ParseDate(\datemask, subitem2) < ParseDate(\datemask, subitem1)
              result = -1
            EndIf
          EndIf
          
        Default  ;Character
                 ;result ist 1 oder -1
          If \direction = #PB_Sort_Ascending  ;Aufsteigende Sortierung
            result = CompareMemoryString(@subitem1, @subitem2, #PB_String_CaseSensitive)
          Else
            result = CompareMemoryString(@subitem2, @subitem1, #PB_String_CaseSensitive)
          EndIf             
          
      EndSelect
      
    EndWith
    
    ProcedureReturn result
  EndProcedure
  
  Procedure.i ListIconSortcolumn(lvnr, column, direction)
    
    Protected j, sortinfopointer = 0
    
    ;durchsucht das globale Sortinfofeld nach lvnr und column
    ;um die zugehörige DatenStructur dem InfoPointer zuzuweisen.
    ;diese Daten wurden mit ListIconSetColumnTyp() definiert.
    For j = 1 To sortinfoidx
      If sortinfo(j)\lvnr = lvnr
        If sortinfo(j)\column = column
          sortinfo(j)\direction = direction
          sortinfopointer = @sortinfo(j)
          Break
        EndIf
      EndIf
    Next
    
    If sortinfopointer = 0         
      ;Spalte nicht definiert mit ListIconSetColumnTyp()
      sortinfo(0)\lvnr = lvnr
      sortinfo(0)\lvid = GadgetID(lvnr)
      sortinfo(0)\direction = direction
      sortinfo(0)\column = column
      sortinfo(0)\sorttyp = #ListIconSort_Char
      sortinfo(0)\datemask = ""
      sortinfopointer = @sortinfo(0)
    EndIf
    
    DisableGadget(lvnr, 1)
    SetCursor_(cursor_sanduhr): ShowCursor_(#True)   
    
    SendMessage_(GadgetID(lvnr), #LVM_SORTITEMSEX, sortinfopointer, @ListIconCompareFunc())
    
    DisableGadget(lvnr, 0)     
    SetCursor_(cursor_original): ShowCursor_(#True)
    
    SetGadgetState(lvnr, GetGadgetState(lvnr))
    
  EndProcedure
  
EndModule

UseModule ListIconSort



;--- Example

CompilerIf #PB_Compiler_IsMainFile
  
  Enumeration
    #window
    #liste
    #info
  EndEnumeration
  
  Procedure.i WindowCallback(hWnd, uMsg, wParam, lParam)
    
    ;dient hier im Beispiel nur dazu den Click auf den Header abzufangen
    
    Protected *nml.NM_LISTVIEW
    
    If uMsg = #WM_NOTIFY
      *nml = lParam
      If *nml\hdr\code = #LVN_COLUMNCLICK
        
        Protected timeend, timestart = ElapsedMilliseconds()
        
        Protected lvnr = *nml\hdr\idFrom    ;PB Gadgetnr
        Protected column = *nml\iSubItem
        Protected header = SendMessage_(*nml\hdr\hwndFrom, #LVM_GETHEADER, 0, 0)
        Protected colscount = SendMessage_(header, #HDM_GETITEMCOUNT, 0, 0) - 1
        
        Protected hditem.HD_ITEM
        Protected j, sortdirection
        
        ;alle Pfeile löschen, außer gewählte Spalte
        hditem\mask = #HDI_FORMAT
        For j = 0 To colscount
          If j <> column   
            SendMessage_(header, #HDM_GETITEM, j, hditem)
            hditem\fmt & ~ (#HDF_SORTDOWN | #HDF_SORTUP)
            SendMessage_(header, #HDM_SETITEM, j, hditem)
          EndIf
        Next
        ;gewählte Spalte Pfeil setzen
        SendMessage_(header, #HDM_GETITEM, column, hditem)
        If hditem\fmt & #HDF_SORTDOWN                             
          hditem\fmt & ~ #HDF_SORTDOWN        ;löschen
          hditem\fmt | #HDF_SORTUP            ;setzen
          sortdirection = #PB_Sort_Ascending
        Else
          hditem\fmt & ~ #HDF_SORTUP
          hditem\fmt | #HDF_SORTDOWN
          sortdirection = #PB_Sort_Descending
        EndIf
        SendMessage_(header, #HDM_SETITEM, column, hditem)
        ;Sortieren
        ListIconSortcolumn(lvnr, column, sortdirection)
        
        timeend = ElapsedMilliseconds()
        SetGadgetText(#info, "Sorttime: " + StrF(timeend - timestart, 2))
        
      EndIf
    EndIf
    
    ProcedureReturn #PB_ProcessPureBasicEvents
    
  EndProcedure
  
  OpenWindow(#window, 0, 0, 850, 550, "ListIconGadget Sortieren", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget(#info, 10, 525, 100, 25, "")
  
  ListIconGadget(#liste, 10, 10, 830, 490, "COL 0", 150, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect)
  AddGadgetColumn(#liste, 1, "COL 1", 100)
  AddGadgetColumn(#liste, 2, "COL 2", 100)
  AddGadgetColumn(#liste, 3, "COL 3 (NUM)", 100)
  AddGadgetColumn(#liste, 4, "COL 4 (FLOAT)", 100)
  AddGadgetColumn(#liste, 5, "COL 5 (DATE)", 100)
  AddGadgetColumn(#liste, 6, "COL 6 (DATETIME)", 150)
  
  ListIconSetColumnTyp(#liste, 3, #ListIconSort_Numeric)
  ListIconSetColumnTyp(#liste, 4, #ListIconSort_Float)
  ListIconSetColumnTyp(#liste, 5, #ListIconSort_Date, "%dd.%mm.%yyyy")
  ListIconSetColumnTyp(#liste, 6, #ListIconSort_Date, "%mm-%dd-%yyyy %hh:%mm:%ss")
  
  SetWindowCallback(@WindowCallback())   ;für Headerclick
  
  
  ;Test Values:
  
  Define event
  Define j, A$, B$, C$, D$, E$, F$, G$
  
  HideGadget(#liste,1)
  
  For j = 0 To 10000
    
    A$ = "Row "+RSet(Str(j),6,"0") + #LF$     
    B$ = Str(Random(9999)) + #LF$     
    C$ = "$"+RSet(Hex(Random($7FFFFFFF)),8,"0") + #LF$     
    D$ = Str(Random(99999)) + #LF$
    E$ = Str(Random(99999))+"."+Str(Random(99)) + #LF$
    F$ = FormatDate("%dd.%mm.%yyyy", Random(Date(), 0))+Chr(10)
    G$ = FormatDate("%mm-%dd-%yyyy %hh:%mm:%ss", Random(Date(), 0))
    
    AddGadgetItem(#liste, j, A$+B$+C$+D$+E$+F$+G$)
    
  Next
  
  HideGadget(#liste,0)
  
  Repeat     
    event = WaitWindowEvent()     
  Until event = #PB_Event_CloseWindow
  
CompilerEndIf
