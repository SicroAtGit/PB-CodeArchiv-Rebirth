XIncludeFile "Includes/AudioIn.pbi"

OpenConsole()

PrintN("Devices:")
AudioIn::GetDevices()
ForEach AudioIn::Device()
 PrintN(PeekS(AudioIn::@Device()\szPname))
Next
PrintN("")

*AudioIn = AudioIn::Initialize(#WAVE_MAPPER, 44100, 1, 8)

If Not *AudioIn
  PrintN("Error: " + AudioIn::GetError())
  Input()
  End
EndIf

PrintN("Press enter to start recording")
Input()
AudioIn::Start(*AudioIn)

*Temp = AllocateMemory(10)

Repeat
  If AudioIn::GetAvailableData(*AudioIn) >= 10
    
    If AudioIn::Read_Data(*AudioIn, *Temp, 10) >= 0
      PrintN(LSet("", PeekA(*Temp)/2, " ")+"#") ; #### Only draw the first byte of the 10 byte buffer
    Else
      PrintN(AudioIn::GetError())
    EndIf
    
  EndIf
Until Inkey()

FreeMemory(*Temp)

AudioIn::Deinitialize(*AudioIn)
