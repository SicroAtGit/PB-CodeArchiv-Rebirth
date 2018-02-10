; Two transparent cubes
;-----------------------
; Disable the debugger !


XIncludeFile "Drawing3D.pbi" : UseModule Drawing3D

Enumeration
	#Window
	#Gadget
EndEnumeration

OpenWindow(#Window, 0, 0, 500, 500, "Two transparent cubes", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 0, 0, WindowWidth(#Window), WindowHeight(#Window))

If StartDrawing3D(CanvasOutput(#Gadget))
	Drawing3DMode(#Drawing3D_Default)
	Drawing3DLight(1, 1, 1, $40FFFFFF)
	DrawBox3D(-70, 0, 0, 200, 200, 200, 30, 30, 0, $C0C04000)
	DrawBox3D(70, 0, 0, 200, 200, 200, -20, 30, 0, $C0400080)
	StopDrawing3D()
EndIf

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
	EndSelect
	
ForEver
