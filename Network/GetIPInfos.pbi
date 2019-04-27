;   Description: Gets some information about an IP address
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2019 Sicro
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

Procedure GetIPInfos(Map infos$(), ip$="")
  
  Protected httpRequest, json, httpStatusCode, *jsonValuePointer, *jsonMemberValuePointer
  Protected url$, httpResponse$, value$
  
  InitNetwork()
  
  ; API Documentation: https://ipapi.co/api/
  url$ = "https://ipapi.co"
  If ip$ <> ""
    url$ + "/" + ip$
  EndIf
  url$ + "/json/"
  
  ; Send the HTTP request
  httpRequest = HTTPRequest(#PB_HTTP_Get, url$)
  If httpRequest = 0
    ProcedureReturn #False
  EndIf
  
  ; Check if the request was successful
  httpStatusCode = Val(HTTPInfo(httpRequest, #PB_HTTP_StatusCode))
  If httpStatusCode <> 200
    FinishHTTP(httpRequest)
    ProcedureReturn #False
  EndIf
  
  ; Read in the response as JSON
  httpResponse$ = HTTPInfo(httpRequest, #PB_HTTP_Response)
  json = ParseJSON(#PB_Any, httpResponse$)
  If json = 0
    ProcedureReturn #False
  EndIf
  
  ; Convert the JSON to a MAP
  ; ExtractJSONMap() does not convert member values to strings if they have a different type
  *jsonValuePointer = JSONValue(json)
  If Not ExamineJSONMembers(*jsonValuePointer)
    FreeJSON(json)
    ProcedureReturn #False
  EndIf
  While NextJSONMember(*jsonValuePointer)
    *jsonMemberValuePointer = JSONMemberValue(*jsonValuePointer)
    Select JSONType(*jsonMemberValuePointer)
      Case #PB_JSON_String:  value$ = GetJSONString(*jsonMemberValuePointer)
      Case #PB_JSON_Number:  value$ = StrD(GetJSONDouble(*jsonMemberValuePointer))    
      Case #PB_JSON_Boolean: value$ = Str(GetJSONBoolean(*jsonMemberValuePointer))
    EndSelect
    infos$(JSONMemberKey(*jsonValuePointer)) = value$
  Wend
  
  FreeJSON(json)
  ProcedureReturn #True
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  NewMap infos$()
  
  If Not GetIPInfos(infos$())
    Debug "Error"
    End
  EndIf
  
  ForEach infos$()
    Debug MapKey(infos$()) + " = " + infos$()
  Next
  
CompilerEndIf
