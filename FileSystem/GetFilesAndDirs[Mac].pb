;   Description: Get all file names from a directory including all files in all of its subdirectories.
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=410298#p410298
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 wilbert
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

Dir.s = #PB_Compiler_Home + "purelibraries"

FileManager = CocoaMessage(0, 0, "NSFileManager defaultManager")
DirEnum = CocoaMessage(0, FileManager, "enumeratorAtPath:$", @Dir)

File = CocoaMessage(0, DirEnum, "nextObject")
While File
  
  FileName.s = PeekS(CocoaMessage(0, File, "UTF8String"), -1, #PB_UTF8)
  Debug FileName
  
  File = CocoaMessage(0, DirEnum, "nextObject")
Wend
