;   Description: GKRandomDistribution - Random numbers example (OS X 10.11+)
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=474084#p474084
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 wilbert
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

CompilerIf #PB_Compiler_Processor=#PB_Processor_x86
  CompilerError "X86 only!"
CompilerEndIf


; Requirements to run this source : PB 5.40+
; Requirements to use GameplayKit framework : PB x64, OSX 10.11+


; Show foundation version number using dlsym

; #NSFoundationVersionNumber10_0  = 397.40
; #NSFoundationVersionNumber10_1  = 425.00
; #NSFoundationVersionNumber10_2  = 462.00
; #NSFoundationVersionNumber10_3  = 500.00
; #NSFoundationVersionNumber10_4  = 567.00
; #NSFoundationVersionNumber10_5  = 677.00
; #NSFoundationVersionNumber10_6  = 751.00
; #NSFoundationVersionNumber10_7  = 833.10
; #NSFoundationVersionNumber10_8  = 945.00
; #NSFoundationVersionNumber10_9  = 1056.00
; #NSFoundationVersionNumber10_10 = 1151.16
; #NSFoundationVersionNumber10_11 = 1252.00
; #NSFoundationVersionNumber10_11_1 = 1255.10
; #NSFoundationVersionNumber10_11_2 = 1256.10

*FoundationVersion.Double = dlsym_(#RTLD_DEFAULT, "NSFoundationVersionNumber")
Debug "Foundation version : " + StrD(*FoundationVersion\d, 2)
Debug "-------------------------------------------"


; Use sel_registerName and sel_getName without ImportC statement
Sel = sel_registerName_("nextInt")
Debug PeekS(sel_getName_(Sel), -1, #PB_UTF8)


; Load GameplayKit framework if possible

If Not dlopen_("/Library/Frameworks/GameplayKit.framework/GameplayKit", #RTLD_LAZY)
  MessageRequester("Error", PeekS(dlerror_(), -1, #PB_UTF8))
Else
  
  ; Show twenty ARC4 random values between 1 and 5
  
  RandomDistribution = CocoaMessage(0, 0, "GKRandomDistribution distributionWithLowestValue:", 1, "highestValue:", 5)
  For i = 1 To 20
    Debug CocoaMessage(0, RandomDistribution, "nextInt")
  Next
  
EndIf
