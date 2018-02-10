;   Description: List all predefined NSImageName icons and their minimum OS X version
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=441501#p441501
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Shardik
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

DataSection
  Data.S "NSQuickLook", "10.5"
  Data.S "NSBluetooth", "10.5"
  Data.S "NSIChatTheater", "10.5"
  Data.S "NSSlideshow", "10.5"
  
  ; This image is appropriate on an 'action' button. An action button is a popup
  ; that has the same contents as the contextual menu for a related control.
  Data.S "NSAction", "10.5"
  
  ; This image can be used as a badge for a 'smart' item. In 10.5, this and the
  ; 'action' image are both gears. Please avoid using a gear for other
  ; situations, and If you do, use custom art.
  Data.S "NSSmartBadge", "10.5"
  
  ; These images are intended for use in a segmented control for switching view
  ; interfaces for another part of the window.
  Data.S "NSIconView", "10.5"
  Data.S "NSListView", "10.5"
  Data.S "NSColumnView", "10.5"
  Data.S "NSFlowView", "10.5"
  Data.S "NSPath", "10.5"
  
  ; Place this image to the right of invalid data. For example, use it if the
  ; user tries to commit a form when it's missing a required name field.
  Data.S "NSInvalidData", "10.5"
  Data.S "NSLockLocked", "10.5"
  Data.S "NSLockUnlocked", "10.5"
  
  ; Use these images for "go forward" or "go back" functions, as seen in
  ; Safari's toolbar. See also the right and left facing triangle images.
  Data.S "NSGoRight", "10.5"
  Data.S "NSGoLeft", "10.5"
  
  ; Prefer the "GoLeft" and "GoRight" images for situations where they apply.
  ; These generic triangles aren't endorsed for any particular use, but you can
  ; use them if you don't have any better art.
  Data.S "NSRightFacingTriangle", "10.5"
  Data.S "NSLeftFacingTriangle", "10.5"
  Data.S "NSAdd", "10.5"
  Data.S "NSRemove", "10.5"
  Data.S "NSRevealFreestanding", "10.5"
  Data.S "NSFollowLinkFreestanding", "10.5"
  Data.S "NSEnterFullScreen", "10.5"
  Data.S "NSExitFullScreen", "10.5"
  Data.S "NSStopProgress", "10.5"
  Data.S "NSStopProgressFreestanding", "10.5"
  Data.S "NSRefresh", "10.5"
  Data.S "NSRefreshFreestanding", "10.5"
  Data.S "NSBonjour", "10.5"
  Data.S "NSComputer", "10.5"
  Data.S "NSFolderBurnable", "10.5"
  Data.S "NSFolderSmart", "10.5"
  Data.S "NSFolder", "10.6"
  Data.S "NSNetwork", "10.5"
  
  ; NSImageNameDotMac will continue to work for the forseeable future, and will
  ; return the same image as NSMobileMe.
  Data.S "NSDotMac", "10.5"
  Data.S "NSMobileMe", "10.6"
  
  ; This image is appropriate as a drag image for multiple items.
  Data.S "NSMultipleDocuments", "10.5"
  
  ; These images are intended for use in toolbars in preference windows.
  Data.S "NSUserAccounts", "10.5"
  Data.S "NSPreferencesGeneral", "10.5"
  Data.S "NSAdvanced", "10.5"
  
  ; These images are intended for use in other toolbars.
  Data.S "NSInfo", "10.5"
  Data.S "NSFontPanel", "10.5"
  Data.S "NSColorPanel", "10.5"
  
  ; These images are appropriate for use in sharing or permissions interfaces.
  Data.S "NSUser", "10.5"
  Data.S "NSUserGroup", "10.5"
  Data.S "NSEveryone", "10.5"
  Data.S "NSUserGuest", "10.6"
  
  ; These images are the default state images used by NSMenuItem. Drawing these
  ; outside of menus is discouraged.
  Data.S "NSMenuOnState", "10.6"
  Data.S "NSMenuMixedState", "10.6"
  
  ; The name @"NSApplicationIcon" has been available since Mac OS X 10.0. The
  ; symbol NSApplicationIcon is new in 10.6.
  Data.S "NSApplicationIcon", "10.6"
  Data.S "NSTrashEmpty", "10.6"
  Data.S "NSTrashFull", "10.6"
  Data.S "NSHome", "10.6"
  Data.S "NSBookmarks", "10.6"
  Data.S "NSCaution", "10.6"
  Data.S "NSStatusAvailable", "10.6"
  Data.S "NSStatusPartiallyAvailable", "10.6"
  Data.S "NSStatusUnavailable", "10.6"
  Data.S "NSStatusNone", "10.6"
  Data.S "NSShare", "10.8"
  Data.S ""
EndDataSection

Structure IconEntry
  Name.S
  Version.S
EndStructure

If OSVersion() < #PB_OS_MacOSX_10_5
  MessageRequester("Info", "Sorry, but your MacOS X version doesn't support NSImageNames!")
  End
EndIf

Define Icon.I
Define Name.S
Define Version.S

NewList Icon.IconEntry()

Repeat
  Read.S Name
  
  If Name <> ""
    Read.S Version
    
    If Val(Left(Version, 2)) * 1000 + Val(Right(Version, 1)) * 100 <= OSVersion()
      AddElement(Icon())
      Icon()\Name = Name
      Icon()\Version = Version
    EndIf
  EndIf
Until Name = ""

OpenWindow(0, 270, 100, 290, 398, "Predefined system icons")
ListIconGadget(0, 10, 10, 270, 378, "Icon name", 180, #PB_ListIcon_GridLines)
AddGadgetColumn(0, 1, "OS X", 40)

ForEach Icon()
  Icon = CocoaMessage(0, 0, "NSImage imageNamed:$", @Icon()\Name)
  AddGadgetItem(0, -1, Icon()\Name + #LF$ + Icon()\Version, Icon)
Next

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow
