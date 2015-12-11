#Persistent
#SingleInstance force
#NoEnv 
SetBatchLines, -1
SendMode Input
FileEncoding, UTF-8
SetWorkingDir, %A_ScriptDir%
Item := Object()
Menu, Tray, NoStandard
Scan("Tray", A_ScriptDir)
Menu, Tray, Add, Scan
Menu, Tray, Add, Exit
return

^+x::
Exit:
exitapp

^+z::
Scan::
Reload

; Look for folders to create submenus
Scan(parent, path) {
	Loop, Files, %path%\*, D 
	{
		if A_LoopFileAttrib contains H,R,S
			continue
		Random, MenuId
		Scan(MenuId, A_LoopFileFullPath)
		if (Populate(MenuId, A_LoopFileFullPath))
			Menu, % parent, add, % A_LoopFileName, :%MenuId%	
	}	
}

; Populate menus with folder contents
Populate(parent, path) {
	global item
	Loop, Files, %path%\*, F 
	{
		Menu, % parent, add, % A_LoopFileName, Handler
		Item[(parent), (A_LoopFileName)] := A_LoopFileFullPath
	}
	if (Item[(parent)])
		return true
}

; Start menu item
Handler(ItemName, ItemPos, MenuName) {
	Global Item
	target := Item[(MenuName), (ItemName)]
	ControlDown := GetKeyState("ctrl" , "P")
	if (ControlDown)
		Run *RunAs "cmd.exe" /C "START %target%" ; Avoids issues with file association 
	else
		Run, % target
	RunAs
}