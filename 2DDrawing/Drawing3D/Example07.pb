; Rotated Text
;----------------------------
; Disable the debugger !


XIncludeFile "Drawing3D.pbi" : UseModule Drawing3D

Enumeration
	#Window
	#Gadget
	#Font
EndEnumeration

OpenWindow(#Window, 0, 0, 500, 500, "Drawing3D", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 0, 0, WindowWidth(#Window), WindowHeight(#Window))
LoadFont(#Font, "Arial", 36)

If StartDrawing3D(CanvasOutput(#Gadget), 60)
	DrawingFont(FontID(#Font))
	DrawText3D(50, 0, 200, 30, 40, 0, "Pure Basic!", $FFFF0000)
	DrawText3D(0, 0, 200, 30, 0, 0, "Pure Basic!", $FF00FF00)
	DrawText3D(-50, 0, 200, 30, -40, 0, "Pure Basic!", $FF0000FF)
	StopDrawing3D()
EndIf

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
	EndSelect
	
ForEver
