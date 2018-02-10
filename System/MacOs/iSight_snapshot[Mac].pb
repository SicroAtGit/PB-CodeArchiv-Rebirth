;   Description: iSight snapshot
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=422589#p422589
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


CompilerIf #True ;- example 1 Open a window with snapshot
  
  
  ImportC "/System/Library/Frameworks/QTKit.framework/QTKit" : EndImport
  
  ImportC ""
    sel_registerName(MethodName.P-ASCII)
    class_addMethod(Class.I, Selector.I, Implementation.I, Types.P-ASCII)
  EndImport
  
  Define Delegate.I
  Define DelegateClass.I
  Define Device.I
  Define DeviceInput.I
  Define NSError.I
  Define Session.I
  Define TakeSnapshotNow.I
  Define View.I
  
  ProcedureC SnapshotCallback(Object.I, Selector.I, View.I, CIImage.I)
    Shared TakeSnapshotNow.I
    
    Protected CGImage.I
    Protected NSCIImageRep.I
    Protected NSImage.I
    Protected ImageSize.NSSize
    
    If TakeSnapshotNow
      TakeSnapshotNow = #False
      
      NSCIImageRep = CocoaMessage(0, CocoaMessage(0, 0,
                                                  "NSBitmapImageRep alloc"), "initWithCIImage:", CIImage)
      
      If NSCIImageRep
        CGImage = CocoaMessage(0, NSCIImageRep, "CGImage")
        
        If CGImage
          NSImage = CocoaMessage(0, 0, "NSImage alloc")
          
          If NSImage
            ImageSize\width = WindowWidth(1) + 4
            ImageSize\height = WindowHeight(1) + 4
            CocoaMessage(0, NSImage, "initWithCGImage:", CGImage,
                         "size:@", @ImageSize)
            SetGadgetState(0, NSImage)
            CocoaMessage(0, NSImage, "release")
          EndIf
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Delegate = CocoaMessage(0, CocoaMessage(0, 0,
                                          "NSApplication sharedApplication"), "delegate")
  DelegateClass = CocoaMessage(0, Delegate, "class")
  class_addMethod(DelegateClass, sel_registerName("view:willDisplayImage:"),
                  @SnapshotCallback(), "v@:@@")
  
  OpenWindow(0, 270, 100, 376, 300, "Press toolbar button for snapshot")
  
  CreateImage(0, 16, 16)
  
  StartDrawing(ImageOutput(0))
  Box(0, 0, 16, 16, $FFFFFF)
  Box(4, 4, 8, 8, $FF)
  StopDrawing()
  
  If CreateToolBar(0, WindowID(0))
    ToolBarImageButton(0, ImageID(0))
  EndIf
  
  OpenWindow(1, WindowX(0) + WindowWidth(0) + 10, 132, WindowWidth(0),
             WindowHeight(0), "Captured image",
             #PB_Window_SystemMenu | #PB_Window_Invisible)
  ImageGadget(0, 0, 0, WindowWidth(1), WindowHeight(1), 0)
  CocoaMessage(0, GadgetID(0), "setImageScaling:", 0)
  
  Session = CocoaMessage(0, CocoaMessage(0, 0, "QTCaptureSession alloc"), "init")
  
  If Session
    View = CocoaMessage(0, CocoaMessage(0, 0, "QTCaptureView alloc"), "init")
    
    If View
      CocoaMessage(0, View, "setDelegate:", Delegate)
      CocoaMessage(0, WindowID(0), "setContentView:", View)
      Device = CocoaMessage(0, 0,
                            "QTCaptureDevice defaultInputDeviceWithMediaType:$", @"vide")
      
      If Device
        If CocoaMessage(0, Device, "open:", @NSError) = #YES
          DeviceInput = CocoaMessage(0, CocoaMessage(0, 0,
                                                     "QTCaptureDeviceInput alloc"), "initWithDevice:", Device)
          
          If DeviceInput
            If CocoaMessage(0, Session, "addInput:", DeviceInput, "error:",
                            @NSError) = #YES
              CocoaMessage(0, View, "setCaptureSession:", Session)
              CocoaMessage(0, Session, "startRunning")
              
              Repeat
                Select WaitWindowEvent()
                  Case #PB_Event_CloseWindow
                    Break
                  Case #PB_Event_Menu
                    If EventMenu() = 0
                      TakeSnapshotNow = #True
                      HideWindow(1, #False)
                    EndIf
                EndSelect
              ForEver
              
              CocoaMessage(0, Session, "stopRunning")
              CocoaMessage(0, Device, "close")
              CocoaMessage(0, DeviceInput, "release")
              CocoaMessage(0, Session, "release")
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
CompilerElse;-example 2 Save an Image 
  EnableExplicit
  
  ImportC "/System/Library/Frameworks/QTKit.framework/QTKit" : EndImport
  
  ImportC ""
    sel_registerName(MethodName.P-ASCII)
    class_addMethod(Class.I, Selector.I, Implementation.I, Types.P-ASCII)
  EndImport
  
  Define Delegate.I
  Define DelegateClass.I
  Define Device.I
  Define DeviceInput.I
  Define NSError.I
  Define Session.I
  Define SnapshotFile.S = GetTemporaryDirectory() + "Snapshot.jpg"
  Define TakeSnapshotNow.I
  Define View.I
  
  ProcedureC SnapshotCallback(Object.I, Selector.I, View.I, CIImage.I)
    Shared SnapshotFile.S
    Shared TakeSnapshotNow.I
    
    Protected NSCIImageRep.I
    Protected NSData.I
    
    If TakeSnapshotNow
      NSCIImageRep = CocoaMessage(0, CocoaMessage(0, 0, "NSBitmapImageRep alloc"), "initWithCIImage:", CIImage)
      NSData = CocoaMessage(0, NSCIImageRep, "representationUsingType:", #NSJPEGFileType, "properties:", 0)
      
      If CocoaMessage(0, NSData, "writeToFile:$", @SnapshotFile,
                      "atomically:", #NO) = #YES
      EndIf
      
      PostEvent(#PB_Event_CloseWindow)
    EndIf
  EndProcedure
  
  Delegate = CocoaMessage(0, CocoaMessage(0, 0, "NSApplication sharedApplication"), "delegate")
  DelegateClass = CocoaMessage(0, Delegate, "class")
  class_addMethod(DelegateClass, sel_registerName("view:willDisplayImage:"), @SnapshotCallback(), "v@:@@")
  
  OpenWindow(0, 270, 100, 376, 300, "Press toolbar button for snapshot")
  
  CreateImage(0, 16, 16)
  
  StartDrawing(ImageOutput(0))
  Box(0, 0, 16, 16, $FFFFFF)
  Box(4, 4, 8, 8, $FF)
  StopDrawing()
  
  If CreateToolBar(0, WindowID(0))
    ToolBarImageButton(0, ImageID(0))
  EndIf
  
  Session = CocoaMessage(0, CocoaMessage(0, 0, "QTCaptureSession alloc"), "init")
  
  If Session
    View = CocoaMessage(0, CocoaMessage(0, 0, "QTCaptureView alloc"), "init")
    
    If View
      CocoaMessage(0, View, "setDelegate:", Delegate)
      CocoaMessage(0, WindowID(0), "setContentView:", View)
      Device = CocoaMessage(0, 0, "QTCaptureDevice defaultInputDeviceWithMediaType:$", @"vide")
      
      If Device
        If CocoaMessage(0, Device, "open:", @NSError) = #YES
          DeviceInput = CocoaMessage(0, CocoaMessage(0, 0,
                                                     "QTCaptureDeviceInput alloc"), "initWithDevice:", Device)
          
          If DeviceInput
            If CocoaMessage(0, Session, "addInput:", DeviceInput, "error:", @NSError) = #YES
              CocoaMessage(0, View, "setCaptureSession:", Session)
              CocoaMessage(0, Session, "startRunning")
              
              Repeat
                Select WaitWindowEvent()
                  Case #PB_Event_CloseWindow
                    If TakeSnapshotNow
                      CloseWindow(0)
                      MessageRequester("Info", "Snapshot was saved to " + SnapshotFile)
                    EndIf
                    
                    Break
                  Case #PB_Event_Menu
                    If EventMenu() = 0
                      TakeSnapshotNow = #True
                    EndIf
                EndSelect
              ForEver
              
              CocoaMessage(0, Session, "stopRunning")
              CocoaMessage(0, Device, "close")
              CocoaMessage(0, DeviceInput, "release")
              CocoaMessage(0, Session, "release")
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
CompilerEndIf
