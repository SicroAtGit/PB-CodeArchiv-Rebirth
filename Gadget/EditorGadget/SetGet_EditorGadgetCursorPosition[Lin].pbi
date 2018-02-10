;   Description: Adds support to get or set cursor position on editor gadgets
;            OS: Linux
; English-Forum: 
;  French-Forum: Not in the forum
;  German-Forum: Not in the forum
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 Sicro
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

CompilerIf #PB_Compiler_OS <> #PB_OS_Linux
  CompilerError "Supported OS are only: Linux"
CompilerEndIf

Procedure.i SetEditorGadgetCursorPos(Gadget.i, NewPos.i)

  Protected.GtkTextBuffer *Buffer
  Protected.GtkTextIter   Pos

  If Not IsGadget(Gadget)
    ProcedureReturn #False
  EndIf

  *Buffer = gtk_text_view_get_buffer_(GadgetID(Gadget))
  If Not *Buffer
    ProcedureReturn #False
  EndIf

  ; Iterator der Position ermitteln
  gtk_text_buffer_get_iter_at_offset_(*Buffer, @Pos, NewPos)

  ; Cursor entsprechend dem Iterator setzen
  gtk_text_buffer_place_cursor_(*Buffer, @Pos)

  ProcedureReturn #True

EndProcedure

Procedure.i GetEditorGadgetCursorPos(Gadget)

  Protected.GtkTextBuffer *Buffer
  Protected.GtkTextMark   *Cursor
  Protected.GtkTextIter   Pos

  If Not IsGadget(Gadget)
    ProcedureReturn #False
  EndIf

  *Buffer = gtk_text_view_get_buffer_(GadgetID(Gadget))
  If Not *Buffer
    ProcedureReturn -1
  EndIf

  *Cursor = gtk_text_buffer_get_insert_(*Buffer)
  gtk_text_buffer_get_iter_at_mark_(*Buffer, @Pos, *Cursor)

  ProcedureReturn gtk_text_iter_get_offset_(@Pos)

EndProcedure

; SetEditorGadgetCursorPos(0, 10)
; Pos = GetEditorGadgetCursorPos(0)
