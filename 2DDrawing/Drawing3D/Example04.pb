; Image3D
;---------
; Disable the debugger !


XIncludeFile "Drawing3D.pbi" : UseModule Drawing3d

Enumeration
	#Window
	#Gadget
	#Image
	#Image3D
EndEnumeration

UsePNGImageDecoder()

LoadImage(#Image, "Image.png")
CreateImage3D(#Image3D, #Image)

OpenWindow(#Window, 0, 0, 500, 500, "Image3D", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 0, 0, WindowWidth(#Window), WindowHeight(#Window))

If StartDrawing3D(CanvasOutput(#Gadget))
	Drawing3DMode(#Drawing3D_Default)
	DrawImage3D(#Image3D, 0, 0, 0, 256, 256, -15, 30, 10)
	StopDrawing3D()
EndIf

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
	EndSelect
	
ForEver
