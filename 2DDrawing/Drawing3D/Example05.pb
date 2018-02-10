; Triangle with vertex color
;----------------------------
; Disable the debugger !


XIncludeFile "Drawing3D.pbi" : UseModule Drawing3D

Enumeration
	#Window
	#Gadget
	#Image
	#Image3D
EndEnumeration

OpenWindow(#Window, 0, 0, 500, 500, "Image3D", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 0, 0, WindowWidth(#Window), WindowHeight(#Window))

If StartDrawing3D(CanvasOutput(#Gadget))
	Drawing3DMode(#Drawing3D_Default)
	Drawing3DBackground($FFFFFFFF)
	DrawTriangle3D(-200, 200, -100, 200, 250, -100, 0, -150, 100, $FFFF0000, $FF00FF00, $FF0000FF)
	DrawTriangle3D(150, -150, 100, 100, 150, 100, -200, 0, -100, $FFFFFF00, $FF00FFFF, $FFFF00FF)
	StopDrawing3D()
EndIf

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
	EndSelect
	
ForEver
