; * Cube with lines *
;---------------------
; Disable the debugger !


XIncludeFile "Drawing3D.pbi" : UseModule Drawing3D

Enumeration
	#Window
	#Gadget
EndEnumeration

OpenWindow(#Window, 0, 0, 500, 500, "Cube with lines", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 0, 0, WindowWidth(#Window), WindowHeight(#Window))

If StartDrawing3D(CanvasOutput(#Gadget))
	Drawing3DMode(#Drawing3D_Outline)
	DrawBox3D(0, 0, 0, 200, 200, 200, 30, 30, 0, $FF000000)
	StopDrawing3D()
EndIf

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
	EndSelect
	
ForEver
