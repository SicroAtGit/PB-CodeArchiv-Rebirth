EnableExplicit

; ##################################################### Includes ####################################################

XIncludeFile "Includes/AudioIn.pbi"
XIncludeFile "Includes/AudioOut.pbi"

; ##################################################### Prototypes ##################################################

; ##################################################### Structures ##################################################

; ##################################################### Constants ###################################################

#Samplerate = 44100

; ##################################################### Structures ##################################################

Structure Main
  *AudioIn
  *AudioOut
  
  Quit.i
EndStructure
Global Main.Main

Structure Main_Window
  ID.i
  
  Button.i [10]
EndStructure
Global Main_Window.Main_Window

; ##################################################### Variables ###################################################

; ##################################################### Procedures ##################################################

Procedure Main_Window_Open()
  Main_Window\ID = OpenWindow(#PB_Any, 0, 0, 200, 100, "AudioIn/Out Example", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
  
  If Main_Window\ID
    
    Main_Window\Button[0] = ButtonGadget(#PB_Any, 10, 10, 90, 30, "Stop")
    Main_Window\Button[1] = ButtonGadget(#PB_Any, 10, 40, 90, 30, "Start")
    
  EndIf
EndProcedure

Procedure Notifier_CallBack(*AudioIn)
  Protected *Temp
  Protected Temp_Size = AudioIn::GetAvailableData(*AudioIn)
  
  If Temp_Size > 0
    *Temp = AllocateMemory(Temp_Size)
    
    AudioIn::Read_Data(*AudioIn, *Temp, Temp_Size)
    AudioOut::Write_Data(Main\AudioOut, *Temp, Temp_Size)
    
    FreeMemory(*Temp)
  EndIf
EndProcedure

; ##################################################### Initialisation ##############################################

Main_Window_Open()

AudioIn::GetDevices()
Debug "Input-Devices:"
ForEach AudioIn::Device()
  Debug PeekS(AudioIn::@Device()\szPname)
Next

AudioOut::GetDevices()
Debug "Output-Devices:"
ForEach AudioOut::Device()
  Debug PeekS(AudioOut::@Device()\szPname)
Next

Main\AudioIn = AudioIn::Initialize(#WAVE_MAPPER, #Samplerate, 2, 16, @Notifier_CallBack())
Main\AudioOut = AudioOut::Initialize(#WAVE_MAPPER, #Samplerate, 2, 16)

If Not Main\AudioOut
  Debug AudioOut::GetError()
  End
EndIf
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
        Select EventGadget()
          Case Main_Window\Button[0]
            AudioIn::Stop(Main\AudioIn)
            
          Case Main_Window\Button[1]
            AudioIn::Start(Main\AudioIn)
            
        EndSelect
        
      Case #PB_Event_CloseWindow
        Main\Quit = #True
        
      Case 0
        Break
    EndSelect
  ForEver
  
Until Main\Quit

; ##################################################### End #########################################################

AudioIn::Deinitialize(Main\AudioIn)
AudioOut::Deinitialize(Main\AudioOut)
