;   Description: Change cursor hovering over HyperLinkGadget
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=425502#p425502
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 Shardik
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

EnableExplicit

Procedure ChangeHoverCursor(HyperLinkID.I, CursorName.S)
  Protected AttributeDictionary.I
  Protected MutableAttributeDictionary.I
  Protected NewCursor.I
  
  AttributeDictionary = CocoaMessage(0, GadgetID(HyperLinkID),
                                     "linkTextAttributes")
  
  If AttributeDictionary
    If CocoaMessage(0, AttributeDictionary, "valueForKey:$", @"NSCursor")
      NewCursor = CocoaMessage(0, 0, "NSCursor " + CursorName)
      
      If NewCursor
        MutableAttributeDictionary = CocoaMessage(0, AttributeDictionary,
                                                  "mutableCopyWithZone:", 0)
        
        If MutableAttributeDictionary
          CocoaMessage(0, MutableAttributeDictionary, "setValue:", NewCursor,
                       "forKey:$", @"NSCursor")
          CocoaMessage(0, GadgetID(HyperLinkID), "setLinkTextAttributes:",
                       MutableAttributeDictionary)
          CocoaMessage(0, MutableAttributeDictionary, "release")
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure


;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  OpenWindow(0, 270, 100, 200, 80, "HyperlinkGadgets")
  HyperLinkGadget(0, 25, 20, 160, 15, "Default HyperLink cursor", $FF0000, #PB_HyperLink_Underline)
  HyperLinkGadget(1, 20, 45, 160, 15, "Modified HyperLink cursor", $FF0000, #PB_HyperLink_Underline)
  
  ChangeHoverCursor(1, "dragLinkCursor")
  
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
CompilerEndIf
