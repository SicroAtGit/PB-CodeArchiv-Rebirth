;   Description: Helps to add simply a window 'about' to the program
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29444
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 ts-soft
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

DeclareModule About
  Declare Set(what.s, text.s, image.i = 0)
  Declare Show(parent.i = 0)
EndDeclareModule

Module About
  EnableExplicit

  UsePNGImageDecoder()
  UseJPEGImageDecoder()

  CompilerIf #PB_Compiler_Unicode
    #XmlEncoding = #PB_UTF8
  CompilerElse
    #XmlEncoding = #PB_Ascii
  CompilerEndIf

  Structure AboutDialog
    title.s
    program.s
    version.s
    comment.s
    website.s
    copyright.s
    credits_file.s
    license_file.s
    logo.i
  EndStructure

  Global about.AboutDialog\title = "About ..."
  Global Dialog, XML

  Procedure eventClose()
    FreeDialog(Dialog)
    FreeXML(XML)
  EndProcedure

  Procedure eventLnkwebsiteClick()
    Protected website.s
    website = about\website
    If FindString(LCase(website), "://") = 0
      website = "http://" + website
    EndIf
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        RunProgram(website)
      CompilerCase #PB_OS_Linux
        RunProgram("xdg-open", website, "")
      CompilerCase #PB_OS_MacOS
        RunProgram("open", website, "")
    CompilerEndSelect
  EndProcedure

  Procedure eventCreditsClick()
    HideGadget(DialogGadget(Dialog, "conGeneral"), #True)
    HideGadget(DialogGadget(Dialog, "conLicense"), #True)
    HideGadget(DialogGadget(Dialog, "conCredits"), #True)
    SetGadgetState(DialogGadget(Dialog, "license"), #False)
    If GetGadgetState(DialogGadget(Dialog, "credit"))
      HideGadget(DialogGadget(Dialog, "conCredits"), #False)
    Else
      HideGadget(DialogGadget(Dialog, "conGeneral"), #False)
    EndIf
  EndProcedure

  Procedure eventLicenseClick()
    HideGadget(DialogGadget(Dialog, "conGeneral"), #True)
    HideGadget(DialogGadget(Dialog, "conLicense"), #True)
    HideGadget(DialogGadget(Dialog, "conCredits"), #True)
    SetGadgetState(DialogGadget(Dialog, "credit"), #False)
    If GetGadgetState(DialogGadget(Dialog, "license"))
      HideGadget(DialogGadget(Dialog, "conLicense"), #False)
    Else
      HideGadget(DialogGadget(Dialog, "conGeneral"), #False)
    EndIf
  EndProcedure

  Procedure Set(what.s, text.s, image.i = 0)
    With about
      Select LCase(what)
        Case "title"
          \title = text
        Case "program"
          \program = text
        Case "version"
          \version = text
        Case "comment"
          \comment = text
        Case "website"
          \website = text
        Case "copyright"
          \copyright = text
        Case "credits_file"
          \credits_file = text
        Case "license_file"
          \license_file = text
        Case "logo"
          \logo = image
      EndSelect
    EndWith
  EndProcedure

  Procedure Show(parent.i = 0)
    Protected aboutXML.s
    Protected hWnd, file, mem

    With about
      If parent = 0
        aboutXML =  "<window name='About' text='" + \title + "' flags='#PB_Window_ScreenCentered' >"
      Else
        aboutXML =  "<window name='About' text='" + \title + "' flags='#PB_Window_WindowCentered' >"
      EndIf
      aboutXML +  " <vbox>" +
                  "   <multibox>" +
                  "     <container name='conGeneral' height='150' >" +
                  "       <vbox>"
      If \logo <> 0 : aboutXML + "<image name='imgLogo' />" : EndIf
      If \program <> "" : aboutXML + "<text name='txtProgram' text='" + \program + "' flags='#PB_Text_Center' />" : EndIf
      If \version <> "" : aboutXML + "<text name='txtVersion' text='" + \version + "' flags='#PB_Text_Center' />" : EndIf
      If \comment <> "" : aboutXML + "<text name='txtComment' text='" + \comment + "' flags='#PB_Text_Center' />" : EndIf
      If \copyright <> "" : aboutXML + "<text name='txtCopyright' text='" + \copyright + "' flags='#PB_Text_Center' />" : EndIf
      If \website <> "" : aboutXML + "<hyperlink name='lnkwebsite' text='" + \website + "' flags='#PB_Hyperlink_Underline' />" : EndIf
      aboutXML +  "       </vbox>" +
                  "     </container>" +
                  "     <container name='conCredits' invisible='yes' >" +
                  "       <editor name='editCredits' flags='#PB_Editor_ReadOnly|#PB_Editor_WordWrap' />" +
                  "     </container>" +
                  "     <container name='conLicense' invisible='yes' >" +
                  "       <editor name='editLicense' flags='#PB_Editor_ReadOnly|#PB_Editor_WordWrap' />" +
                  "     </container>" +
                  "   </multibox>" +
                  "   <hbox>" +
                  "     <button name='credit' text='Credits' flags='#PB_Button_Toggle' />" +
                  "     <button name='license' text='License' flags='#PB_Button_Toggle' />" +
                  "     <button name='okay' text='Okay' flags='#PB_Button_Default' />" +
                  "   </hbox>" +
                  " </vbox>" +
                  "</window>"
      XML = CatchXML(#PB_Any, @aboutXML, StringByteLength(aboutXML), 0, #XmlEncoding)
      If XML And XMLStatus(XML) = #PB_XML_Success
        If IsDialog(Dialog) = #False
          Dialog = CreateDialog(#PB_Any)
          If Dialog And OpenXMLDialog(Dialog, XML, "About", 0, 0, 300, 100, parent)
            hWnd = DialogWindow(Dialog)
            If \logo : SetGadgetState(DialogGadget(Dialog, "imgLogo"), \logo) : EndIf
            If \credits_file = ""
              HideGadget(DialogGadget(Dialog, "credit"), #True)
            Else
              file = ReadFile(#PB_Any, \credits_file)
              If file
                mem = AllocateMemory(Lof(file))
                If mem
                  ReadData(file, mem, Lof(file))
                  SetGadgetText(DialogGadget(Dialog, "editCredits"), PeekS(mem, Lof(file), #PB_UTF8))
                  FreeMemory(mem)
                EndIf
                CloseFile(file)
              EndIf
            EndIf
            If \license_file = ""
              HideGadget(DialogGadget(Dialog, "license"), #True)
            Else
              file = ReadFile(#PB_Any, \license_file)
              If file
                mem = AllocateMemory(Lof(file))
                If mem
                  ReadData(file, mem, Lof(file))
                  SetGadgetText(DialogGadget(Dialog, "editLicense"), PeekS(mem, Lof(file), #PB_UTF8))
                  FreeMemory(mem)
                EndIf
                CloseFile(file)
              EndIf
            EndIf

            BindEvent(#PB_Event_CloseWindow, @eventClose(), hWnd)
            BindGadgetEvent(DialogGadget(Dialog, "okay"), @eventClose())
            If IsGadget(DialogGadget(Dialog, "lnkwebsite"))
              BindGadgetEvent(DialogGadget(Dialog, "lnkwebsite"), @eventLnkwebsiteClick())
            EndIf
            BindGadgetEvent(DialogGadget(Dialog, "credit"), @eventCreditsClick())
            BindGadgetEvent(DialogGadget(Dialog, "license"), @eventLicenseClick())
            RefreshDialog(Dialog)
          EndIf
        Else
          SetActiveWindow(hWnd)
        EndIf
      Else
        Debug "XML error: " + XMLError(XML) + " (Line: " + XMLErrorLine(XML) + ")"
      EndIf
    EndWith
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
    InitNetwork()
    OpenWindow(0, 100, 100, 150, 50, "")
    Define logo = LoadImage(#PB_Any, #PB_Compiler_Home + "examples/sources/Data/PureBasicLogo.bmp")
    If FileSize(GetTemporaryDirectory() + "license.txt") <= 0
      ReceiveHTTPFile("https://dl.dropboxusercontent.com/u/3086026/license.txt", GetTemporaryDirectory() + "license.txt")
    EndIf
    About::Set("license_file", GetTemporaryDirectory() + "license.txt")
    About::Set("title", "Über ...")
    About::Set("logo", "", ImageID(logo))
    About::Set("program", "PureBasic")
    About::Set("version", "5.42 beta 1")
    ;About::Set("comment", "Development")
    About::Set("comment", "Entwicklungsumgebung")
    About::Set("website", "www.purebasic.com")
    About::Set("copyright", "©2001-2016 by Fantaisie Software")
    ;About::Set("credits_file", "credits.txt")
    ButtonGadget(0, 10, 10, 130, 30, "Show About")
  
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow : Break
        Case #PB_Event_Gadget
          Select EventGadget()
            Case 0 : About::Show(WindowID(0))
          EndSelect
      EndSelect
    ForEver
CompilerEndIf
