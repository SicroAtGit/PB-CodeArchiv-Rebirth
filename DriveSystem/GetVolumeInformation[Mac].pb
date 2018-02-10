;   Description: Get Volume Information
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=415435#p415435
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

Structure VolumeEntry
  KeyName.S
  Format.S
  ColumnTitle.S
  ColumnWidth.I
EndStructure

If OSVersion() <= #PB_OS_MacOSX_10_5
  MessageRequester("Info", "Sorry, but this program needs at least OS X 10.6 (Snow Leopard) !")
  End
ElseIf OSVersion() = #PB_OS_MacOSX_10_6
  MessageRequester("Info", "Sorry, but OS X 10.6 (Snow Leopard) is only able to obtain the data for the first 5 columns!")
EndIf

NewList Volume.VolumeEntry()

Procedure DisplayVolumeInfos()
  Shared Volume.VolumeEntry()
  
  Protected CellContent.S
  Protected Error.I
  Protected FileManager.I
  Protected Format.S
  Protected i.I
  Protected j.I
  Protected KeyArray.I
  Protected NumColumns.I = ListSize(Volume())
  Protected NumVolumes.I
  Protected RowContent.S
  Protected Size.Q
  Protected URL.I
  Protected URLArray.I
  Protected Value.I
  
  FirstElement(Volume())
  KeyArray = CocoaMessage(0, 0, "NSArray arrayWithObject:$", @Volume()\KeyName)
  NextElement(Volume())
  
  If KeyArray
    For i = 1 To ListSize(Volume()) - 1
      KeyArray = CocoaMessage(0, KeyArray, "arrayByAddingObject:$", @Volume()\KeyName)
      NextElement(Volume())
    Next
    
    FileManager = CocoaMessage(0, 0, "NSFileManager defaultManager")
    
    If FileManager
      URLArray = CocoaMessage(0, FileManager, "mountedVolumeURLsIncludingResourceValuesForKeys:", KeyArray, "options:", 0)
      
      If URLArray
        NumVolumes = CocoaMessage(0, URLArray, "count")
        
        If NumVolumes > 0
          For j = 0 To NumVolumes - 1
            URL = CocoaMessage(0, URLArray, "objectAtIndex:", j)
            
            If URL
              FirstElement(Volume())
              
              For i = 0 To NumColumns - 1
                CellContent = ""
                
                Select Volume()\Format
                  Case "B" ; Boolean NSNumber
                    If CocoaMessage(0, URL, "getResourceValue:", @Value, "forKey:$", @Volume()\KeyName, "error:", @Error) = #YES
                      If Value
                        If CocoaMessage(0, Value, "boolValue")
                          CellContent = "Yes"
                        Else
                          CellContent = "No"
                        EndIf
                      EndIf
                    EndIf
                  Case "D" ; NSDate
                    If CocoaMessage(0, URL, "getResourceValue:", @Value, "forKey:$", @Volume()\KeyName, "error:", @Error) = #YES
                      If Value <> 0
                        CellContent = Left(PeekS(CocoaMessage(0, CocoaMessage(0, Value, "description"), "UTF8String"), -1, #PB_UTF8), 10)
                      EndIf
                    EndIf
                  Case "Q" ; NSNumber (Quad)
                    If CocoaMessage(0, URL, "getResourceValue:", @Value, "forKey:$", @Volume()\KeyName, "error:", @Error) = #YES
                      If Value
                        CocoaMessage(@Size, Value, "unsignedLongLongValue")
                        
                        If Volume()\KeyName = "NSURLVolumeMaximumFileSizeKey"
                          If Size >> 30 < 1024
                            CellContent = Str(Size >> 30 + 1) + " GB"
                          Else
                            CellContent = Str((Size >> 60) & $FFFFFFFFFFFFFFFF + 1) + " EB"
                          EndIf
                        Else
                          CellContent = StrF(Size / 1024 / 1024 / 1024, 2)
                        EndIf
                      EndIf
                    EndIf
                  Case "S" ; NSString
                    If CocoaMessage(0, URL, "getResourceValue:", @Value, "forKey:$", @Volume()\KeyName, "error:", @Error) = #YES
                      If Value <> 0
                        CellContent = UCase(PeekS(CocoaMessage(0, Value, "UTF8String"), -1, #PB_UTF8))
                      EndIf
                    EndIf
                  Case "U" ; NSURL
                    CellContent = PeekS(CocoaMessage(0, CocoaMessage(0, URL, "path"), "UTF8String"), -1, #PB_UTF8)
                    CellContent = StringField(CellContent, CountString(CellContent, "/") + 1, "/")
                    
                    If CellContent = ""
                      CellContent = "/"
                    EndIf
                EndSelect
                
                If i = 0
                  RowContent = CellContent
                Else
                  RowContent + #LF$ + CellContent
                EndIf
                
                NextElement(Volume())
              Next i
            EndIf
            
            AddGadgetItem(0, -1, RowContent)
          Next j
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure

Define ColumnWidth.S
Define ColumnWidthTotal.I
Define i.I
Define KeyName.S

Read.S KeyName

While KeyName <> ""
  AddElement(Volume())
  Volume()\KeyName = KeyName
  Read.S Volume()\ColumnTitle
  Read.S Volume()\Format 
  Read.S ColumnWidth
  Volume()\ColumnWidth = Val(ColumnWidth)
  ColumnWidthTotal + Volume()\ColumnWidth + 3
  Read.S KeyName
Wend


OpenWindow(0, 0, 0, ColumnWidthTotal + 22, 247, "Volume infos", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
FirstElement(Volume())
ListIconGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 20, Volume()\ColumnTitle, Volume()\ColumnWidth, #PB_ListIcon_GridLines)
NextElement(Volume())

For i = 1 To ListSize(Volume()) - 1
  AddGadgetColumn(0, i, Volume()\ColumnTitle, Volume()\ColumnWidth)
  NextElement(Volume())
Next

DisplayVolumeInfos()

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow

End

DataSection
  Data.S "NSURLVolumeNameKey", "Volume name", "U", "150"
  Data.S "NSURLVolumeLocalizedNameKey", "Localized name", "U", "150"
  Data.S "NSURLVolumeLocalizedFormatDescriptionKey", "Partition format", "S", "215"
  Data.S "NSURLVolumeTotalCapacityKey", "Total [GB]", "Q", "55"
  Data.S "NSURLVolumeAvailableCapacityKey", "Free [GB]", "Q", "50"
  Data.S "NSURLVolumeSupportsRenamingKey", "Renamable", "B", "62"
  Data.S "NSURLVolumeIsBrowsableKey", "Icon visible", "B", "63"
  Data.S "NSURLVolumeMaximumFileSizeKey", "File size limit", "Q", "72"
  Data.S "NSURLVolumeIsEjectableKey", "Ejectable", "B", "50"
  Data.S "NSURLVolumeIsRemovableKey", "Removable", "B", "60"
  Data.S "NSURLVolumeIsInternalKey", "Internal", "B", "45"
  Data.S "NSURLVolumeIsAutomountedKey", "Automounted", "B", "74"
  Data.S "NSURLVolumeIsLocalKey", "Local", "B", "30"
  Data.S "NSURLVolumeIsReadOnlyKey", "Read only", "B", "55"
  Data.S "NSURLVolumeCreationDateKey", "Creation date", "D", "90"
  Data.S "NSURLVolumeUUIDStringKey", "UUID", "S", "300"
  Data.S ""
EndDataSection
