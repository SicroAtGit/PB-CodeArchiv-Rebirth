;   Description: Add support for iCal files
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=73180
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31579
; -----------------------------------------------------------------------------

;/ ===========================
;/ =    iCalModule.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ iCal-Files (ICS)
;/
;/ © 2019 by Thorsten Hoeppner (07/2019)
;/

; Last Update:


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
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
;}


;{ _____ iCal - Commands _____

; iCal::AddEvent()    - adds an event to iCal
; iCal::ClearEvents() - clear all events
; iCal::Create()      - create an iCal entry
; iCal::ExportFile()  - export as iCal file (*.ics)
; iCal::GetEvents()   - get events as linked list (iCal::Event_Structure)
; iCal::ImportFile()  - import an iCal file (*.ics)
; iCal::Remove(ID.i)  - remove the iCal entry
  
;}


DeclareModule iCal
  
  ;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  Enumeration 1 ;{ Method / Class
    #Publish
    #Request
    #Public
    #Private
  EndEnumeration ;}
  
  ;- ===========================================================================
	;-   DeclareModule - Structure
  ;- ===========================================================================
  
  Structure Event_Structure ;{ GetEvents()
    Location.s
    Summary.s
    Description.s
    StartDate.i
    EndDate.i
    Class.i
  EndStructure ;}
  
  ;- ===========================================================================
	;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddEvent(ID.i, StartDate.i, Summary.s, Description.s="", Location.s="", EndDate.i=#PB_Default, Class.i=#Public)
  Declare   ClearEvents(ID.i)
  Declare.i Create(ID.i, Producer.s="PureBasic", Method.i=#Publish)
  Declare.i ExportFile(ID.i, File.s="iCal_Export.ics")
  Declare.i GetEvents(ID.i, List Events.Event_Structure()) 
  Declare.i ImportFile(ID.i, File.s="iCal_Import.ics")
  Declare.i Remove(ID.i)
  
EndDeclareModule  

Module iCal
  
  EnableExplicit
  
  ;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
  
  ; Date parameter: [year:4][month:2][day:2]T[hour:2][minute:2][second:2]Z
  ; Example date (18/07/2019 20:15:00): 20190718T201500Z  
  
  #iCal_BeginCalendar = "BEGIN:VCALENDAR" ; Begin iCalendar file
  #iCal_Version       = "VERSION:2.0"     ; Version of the format
  #iCal_ProID         = "PRODID:"         ; Instance that created the document.
  #iCal_Publish       = "METHOD:PUBLISH"  ; Makes the entry appear immediately
  #iCal_Request       = "METHOD:REQUEST"  ; Packs the entry into a request to the user
  #iCal_BeginEvent    = "BEGIN:VEVENT"    ; Begin of the area in which the appointment data is contained.
  #iCal_UID           = "UID:"            ; Unique ID of an ICS file
  #iCal_Location      = "LOCATION:"       ; Event location
  #iCal_Summary       = "SUMMARY:"        ; Summary 
  #iCal_Description   = "DESCRIPTION:"    ; Description
  #iCal_Public        = "CLASS:PUBLIC"    ; Save appointment publicly 
  #iCal_Private       = "CLASS:PRIVATE"   ; Save appointment privately 
  #iCal_DateStart     = "DTSTART:"        ; Start of the calendar entry
  #iCal_DateEnd       = "DTEND:"          ; End of the calendar entry
  #iCal_DateStamp     = "DTSTAMP:"        ; Time at which the entry was created
  #iCal_EndEvent      = "END:VEVENT"      ; End of the area in which the appointment data is contained.
  #iCal_EndCalendar   = "END:VCALENDAR"   ; End iCalendar file

  ;- ============================================================================
	;-   Module - Structures
	;- ============================================================================
  
  Structure UUID_Structure      ;{ UID
    Byte.b[16]
  EndStructure ;}
  
  Structure iCal_Event_Structure ;{ iCal()\Event()\...
    UID.s
    Location.s
    Summary.s
    Description.s
    StartDate.q
    EndDate.q
    DateStamp.q
    Class.i
  EndStructure ;} 
  
  Structure iCal_Structure       ;{ iCal('id')\...
    ProducerID.s
    List Event.iCal_Event_Structure()
    Method.i
  EndStructure ;}
  Global NewMap iCal.iCal_Structure()
  
  
  ;- ============================================================================
	;-   Module - Internal
  ;- ============================================================================
  
  Procedure.s UniqueID(*UUID.UUID_Structure)
    Define i.i, UUID$
    
    If Not *UUID : ProcedureReturn "" : EndIf
    
    For i=0 To 15
      *UUID\Byte[i]=Random(255)
    Next
    
    *UUID\Byte[9] = 128 + Random(63)
    *UUID\Byte[7] =  64 + Random(15)
    
    For i=0 To 16-1
      UUID$ + RSet(Hex(*UUID\Byte[i]&$FF), 2, "0")
    Next
    
    ProcedureReturn UUID$
  EndProcedure
  
  Procedure.s DateICal(Date.q)
    ProcedureReturn FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Date)
  EndProcedure
  
  
  ;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  Procedure.i AddEvent(ID.i, StartDate.i, Summary.s, Description.s="", Location.s="", EndDate.i=#PB_Default, Class.i=#Public)
    Define UUID.UUID_Structure
    
    If FindMapElement(iCal(), Str(ID))
      
      If AddElement(iCal()\Event())
        
        iCal()\Event()\UID         = UniqueID(@UUID)
        iCal()\Event()\StartDate   = StartDate
        If EndDate = #PB_Default
          iCal()\Event()\EndDate   = StartDate
        Else
          iCal()\Event()\EndDate   = EndDate
        EndIf
        iCal()\Event()\Summary     = Summary
        iCal()\Event()\Description = Description
        iCal()\Event()\DateStamp   = Date()
        iCal()\Event()\Location    = Location
        iCal()\Event()\Class       = Class
        
        ProcedureReturn #True
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.i Create(ID.i, Producer.s="PureBasic", Method.i=#Publish)
    
    If ID = #PB_Any : ID = MapSize(iCal()) : EndIf
    If ID : While FindMapElement(iCal(), Str(ID)) : ID + 1 : Wend : EndIf
    
    If AddMapElement(iCal(), Str(ID))
      
      iCal()\ProducerID = Producer
      iCal()\Method     = Method
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure   ClearEvents(ID.i)
    
    If FindMapElement(iCal(), Str(ID))
      ClearList(iCal()\Event())
    EndIf  
   
  EndProcedure
  
  Procedure.i GetEvents(ID.i, List Events.Event_Structure()) 
    Define.i Count
    
    If FindMapElement(iCal(), Str(ID))
      
      ClearList(Events())
      
      ForEach iCal()\Event()
        
        If AddElement(Events())
          Events()\StartDate   = iCal()\Event()\StartDate
          Events()\EndDate     = iCal()\Event()\EndDate
          Events()\Summary     = iCal()\Event()\Summary
          Events()\Description = iCal()\Event()\Description
          Events()\Location    = iCal()\Event()\Location
          Events()\Class       = iCal()\Event()\Class
          Count + 1
        EndIf
        
      Next  
      
    EndIf
    
    ProcedureReturn Count
  EndProcedure
  
  
  Procedure.i ExportFile(ID.i, File.s="iCal_Export.ics")
    Define.i FileID, Result = #False
    
    If FindMapElement(iCal(), Str(ID))
      
      FileID = CreateFile(#PB_Any, File, #PB_UTF8)
      If FileID
        
        WriteStringN(FileID, #iCal_BeginCalendar, #PB_UTF8)
        WriteStringN(FileID, #iCal_Version,       #PB_UTF8)
        WriteStringN(FileID, #iCal_ProID + iCal()\ProducerID, #PB_UTF8)
        
        If iCal()\Method = #Request
          WriteStringN(FileID, #iCal_Request, #PB_UTF8)
        Else
          WriteStringN(FileID, #iCal_Publish, #PB_UTF8)
        EndIf
        
        ForEach iCal()\Event()
          
          WriteStringN(FileID, #iCal_BeginEvent, #PB_UTF8)
          WriteStringN(FileID, #iCal_UID         + iCal()\Event()\UID,         #PB_UTF8)
          WriteStringN(FileID, #iCal_Location    + iCal()\Event()\Location,    #PB_UTF8)
          WriteStringN(FileID, #iCal_Summary     + iCal()\Event()\Summary,     #PB_UTF8)
          WriteStringN(FileID, #iCal_Description + iCal()\Event()\Description, #PB_UTF8)
          
          If iCal()\Event()\Class = #Private
            WriteStringN(FileID, #iCal_Private, #PB_UTF8)
          Else
            WriteStringN(FileID, #iCal_Public,  #PB_UTF8)
          EndIf
        
          WriteStringN(FileID, #iCal_DateStart + DateICal(iCal()\Event()\StartDate), #PB_UTF8)
          WriteStringN(FileID, #iCal_DateEnd   + DateICal(iCal()\Event()\EndDate),   #PB_UTF8)
          WriteStringN(FileID, #iCal_DateStamp + DateICal(iCal()\Event()\DateStamp), #PB_UTF8)
          
          WriteStringN(FileID, #iCal_EndEvent,  #PB_UTF8)
          
        Next
        
        WriteStringN(FileID, #iCal_EndCalendar, #PB_UTF8)

        Result = #True
        
        CloseFile(FileID)
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i ImportFile(ID.i, File.s="iCal_Import.ics")
    Define.i FileID, Result = #False
    Define.s String, Param
    
    If FindMapElement(iCal(), Str(ID))
      
      FileID = ReadFile(#PB_Any, File, #PB_UTF8)
      If FileID

        While Eof(FileID) = #False
          
          String = ReadString(FileID)
          
          Select StringField(String, 1, ":")
            Case "PRODID" ;{ PRODID:
              iCal()\ProducerID = StringField(String, 2, ":")
              ;}
            Case "METHOD" ;{ METHOD:
              If StringField(String, 2, ":") = "REQUEST"
                iCal()\Method = #Request
              Else
                iCal()\Method = #Publish
              EndIf ;}
            Case "END"    ;{ END:VCALENDAR
              If StringField(String, 2, ":") = "VCALENDAR"
                Result = #True
                Break
              EndIf ;}  
            Case "BEGIN"  ;{ BEGIN:VEVENT
              
              If StringField(String, 2, ":") = "VEVENT" 
                
                If AddElement(iCal()\Event())
                  
                  Repeat
                    String = ReadString(FileID)
                    Select StringField(String, 1, ":")
                      Case "UID"
                        iCal()\Event()\UID         = StringField(String, 2, ":")
                      Case "LOCATION"
                        iCal()\Event()\Location    = StringField(String, 2, ":")
                      Case "SUMMARY"
                        iCal()\Event()\Summary     = StringField(String, 2, ":")
                      Case "DESCRIPTION"
                        iCal()\Event()\Description = StringField(String, 2, ":")
                      Case "CLASS"
                        If StringField(String, 2, ":") = "PRIVATE"
                          iCal()\Event()\Class = #Private
                        Else
                          iCal()\Event()\Class = #Public
                        EndIf
                      Case "DTSTART"
                        iCal()\Event()\StartDate = ParseDate("%yyyy%mm%ddT%hh%ii%ssZ", StringField(String, 2, ":")) 
                      Case "DTEND"
                        iCal()\Event()\EndDate   = ParseDate("%yyyy%mm%ddT%hh%ii%ssZ", StringField(String, 2, ":")) 
                      Case "DTSTAMP"
                        iCal()\Event()\DateStamp = ParseDate("%yyyy%mm%ddT%hh%ii%ssZ", StringField(String, 2, ":"))  
                    EndSelect
                  Until String = "END:VEVENT" Or Eof(FileID)
                  
                EndIf
                
              EndIf
              ;}
          EndSelect

        Wend
        
        Result = #True
        CloseFile(FileID)
      EndIf

    EndIf 
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i Remove(ID.i)
    
    If FindMapElement(iCal(), Str(ID))
      
      DeleteMapElement(iCal())
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  NewList Events.iCal::Event_Structure()
  
  #Date = 1
  
  Date = Date(2019, 7, 18, 20, 15, 0)
  
  If iCal::Create(#Date)
    iCal::AddEvent(#Date, Date, "Geburtstag")
    
    iCal::GetEvents(#Date, Events())
    ForEach Events()
      Debug "Event: " + Events()\Summary + " " + FormatDate("%dd/%mm/%yyyy", Events()\StartDate)
    Next
    
    ;iCal::ImportFile(#Date, "iCal_Import.ics")
    iCal::ExportFile(#Date, "iCal_Export.ics")
  EndIf
  
CompilerEndIf
