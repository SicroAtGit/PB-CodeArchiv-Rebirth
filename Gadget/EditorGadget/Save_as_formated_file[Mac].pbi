;   Description: Save to a file in a specific file format like RTF or HTML
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=448103#p448103
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 wilbert
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

CompilerIf #PB_Compiler_OS<>#PB_OS_MacOS
  CompilerError "MacOs only!"
CompilerEndIf

Procedure SaveFormattedText(EditorGadget, FileName.s, Type.s = "NSRTF")
  
  ; Type can be "NSPlainText", "NSRTF", "NSHTML", "NSDocFormat", "NSWordML", "NSOfficeOpenXML", "NSOpenDocument"
  
  Protected.i range.NSRange, attributes, dataObj, textStorage = CocoaMessage(0, GadgetID(EditorGadget), "textStorage")
  CocoaMessage(@range\length, textStorage, "length")
  CocoaMessage(@attributes, 0, "NSDictionary dictionaryWithObject:$", @Type, "forKey:$", @"DocumentType")
  CocoaMessage(@dataObj, textStorage, "dataFromRange:@", @range, "documentAttributes:", attributes, "error:", #Null)
  ProcedureReturn CocoaMessage(0, dataObj, "writeToFile:$", @FileName, "atomically:", #NO)
  
EndProcedure

;-Example
CompilerIf #False
  SaveFormattedText(0, "MyFile.rtf", "NSRTF"); save as rtf file
CompilerEndIf
