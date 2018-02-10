EnableExplicit

; ##################################################### Includes ####################################################

XIncludeFile "Includes/AudioIn.pbi"

; ##################################################### Prototypes ##################################################

; ##################################################### Structures ##################################################

; ##################################################### Constants ###################################################

Enumeration #PB_Event_FirstCustomValue
  #CustomEvent_Redraw
EndEnumeration

; ##################################################### Structures ##################################################

Structure Main
  *AudioIn
  
  Quit.i
EndStructure
Global Main.Main

Structure Main_Window
  ID.i
  
  Canvas.i
EndStructure
Global Main_Window.Main_Window

; ##################################################### Variables ###################################################

; ##################################################### Procedures ##################################################

Procedure Main_Window_Open()
  Main_Window\ID = OpenWindow(#PB_Any, 0, 0, 1000, 400, "AudioIn Example", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  
  If Main_Window\ID
    
    Main_Window\Canvas = CanvasGadget(#PB_Any, 0, 0, 1000, 400)
    
    ;AddWindowTimer(Main_Window\ID, 0, 10)
    
  EndIf
EndProcedure

Procedure Main_Window_Redraw()
  Protected Width = GadgetWidth(Main_Window\Canvas)
  Protected Height = GadgetHeight(Main_Window\Canvas)
  
  Protected Need = Width*2
  Protected Available = AudioIn::GetAvailableData(Main\AudioIn)
  
  If Available < Need
    ProcedureReturn
  EndIf
  
  Protected *Temp = AllocateMemory(Need)
  Protected *Pointer.Word
  
  Protected Y.f, Old_Y.f
  
  Protected i
  
  AudioIn::Read_Data(Main\AudioIn, *Temp, Need)
  
  If StartDrawing(CanvasOutput(Main_Window\Canvas))
    
    Box(0, 0, Width, Height, #White)
    
    DrawingMode(#PB_2DDrawing_Transparent)
    
    DrawText(0, 0, "Queue-Size: "+Str(AudioIn::GetAvailableData(Main\AudioIn))+"B", 0)
    
    *Pointer = *Temp
    For i = 0 To Width-1
      Y = Height/2 - *Pointer\w*Height/65536.0
      LineXY(i-1, Old_Y, i, Y, 0)
      Old_Y = Y
      *Pointer + 2
    Next
    
    StopDrawing()
  EndIf
  
  FreeMemory(*Temp)
EndProcedure

Procedure Notifier_CallBack(*AudioIn)
  PostEvent(#CustomEvent_Redraw)
EndProcedure

; ##################################################### Initialisation ##############################################

Main_Window_Open()

AudioIn::GetDevices()

ForEach AudioIn::Device()
  Debug PeekS(AudioIn::@Device()\szPname)
Next

Main\AudioIn = AudioIn::Initialize(#WAVE_MAPPER, 44100, 2, 16, @Notifier_CallBack())

If Not Main\AudioIn
  Debug AudioIn::GetError()
  End
EndIf

AudioIn::Start(Main\AudioIn)

; ##################################################### Main ########################################################

Repeat
  
  Repeat
    Select WaitWindowEvent(100)
      Case #PB_Event_Gadget
        
      Case #CustomEvent_Redraw
        Main_Window_Redraw()
        
      Case #PB_Event_SizeWindow
        ResizeGadget(Main_Window\Canvas, 0, 0, WindowWidth(EventWindow()), WindowHeight(EventWindow()))
        
      Case #PB_Event_CloseWindow
        Main\Quit = #True
        AudioIn::Stop(Main\AudioIn)
        
      Case 0
        Break
    EndSelect
  ForEver
  
Until Main\Quit

; ##################################################### End #########################################################

AudioIn::Deinitialize(Main\AudioIn)
