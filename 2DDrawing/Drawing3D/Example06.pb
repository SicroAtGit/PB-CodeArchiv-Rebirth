; Disk and Cylinder
;----------------------------
; Disable the debugger !


XIncludeFile "Drawing3D.pbi" : UseModule Drawing3D

Enumeration
	#Window
	#Gadget
EndEnumeration

OpenWindow(#Window, 0, 0, 500, 500, "Drawing3D", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 0, 0, WindowWidth(#Window), WindowHeight(#Window))

If StartDrawing3D(CanvasOutput(#Gadget), 60)
	Drawing3DLight(1, 1, 1, $FFFFFFFF)
	DrawDisk3D(0, 0, 0, 200, 30, -30, 0, $80808080)
	DrawCylinder3D(0, 0, 0, 50, 600, 90, 30, 40, $FF0000FF, $8000FFFF)
	StopDrawing3D()
EndIf

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
	EndSelect
	
ForEver
