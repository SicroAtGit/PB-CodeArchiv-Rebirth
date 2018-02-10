;   Description: Example how to enumerate PB_Event_CustomValue and PB_EventType_FirstCustomValue
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28379
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 hjbremer
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

CompilerIf Defined(Common_Event_CustomValue, #PB_Module) = #False
  
  DeclareModule Common_Event_CustomValue
    
    Enumeration PB_Event_CustomValue  #PB_Event_FirstCustomValue
    EndEnumeration
    
    Enumeration PB_EventType_CustomValue #PB_EventType_FirstCustomValue
    EndEnumeration
    
  EndDeclareModule
  
  Module Common_Event_CustomValue
  EndModule
  
CompilerEndIf

DeclareModule test1   
  UseModule Common_Event_CustomValue
  
  Enumeration PB_Event_CustomValue
    #my_test1_Event_1
    #my_test1_Event_2
  EndEnumeration
  
  Enumeration PB_EventType_CustomValue
    #my_test1_Eventtype_1
    #my_test1_Eventtype_2
  EndEnumeration 
  
EndDeclareModule

Module test1
EndModule


DeclareModule test11
  UseModule Common_Event_CustomValue
  
  Enumeration PB_Event_CustomValue
    #my_test11_Event_1
    #my_test11_Event_2
  EndEnumeration
  
  Enumeration PB_EventType_CustomValue
    #my_test11_Eventtype_1
    #my_test11_Eventtype_2
  EndEnumeration
  
EndDeclareModule

Module test11   
EndModule

UseModule test1
UseModule test11

Debug #my_test1_Event_1
Debug #my_test1_Event_2
Debug #my_test11_Event_1
Debug #my_test11_Event_2

Debug #my_test1_Eventtype_1
Debug #my_test1_Eventtype_2
Debug #my_test11_Eventtype_1
Debug #my_test11_Eventtype_2
