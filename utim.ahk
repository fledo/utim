#Persistent
#SingleInstance force
#NoEnv 
SetBatchLines, -1
SendMode Input
FileEncoding, UTF-8
SetWorkingDir, %A_ScriptDir%

; Contains menus as sub-arrays with file paths.
Item := Object()

; Build menu, start from Tray level
Menu, Tray, NoStandard
Scan("Tray", A_ScriptDir)
Menu, Tray, Add, Scan
Menu, Tray, Add, Exit
return

Exit:
exitapp

Scan::
Reload

/*	Scan(parent, path)
		Description:
			Scan path for folders, attach them as submenus
			to the parent menu and populate them.
		
		Paramaters:
			(parent) ID of parent menu.
			(path) Location of folder to scan.
*/
Scan(parent, path) {
	Loop, Files, %path%\*, D 
	{
		if A_LoopFileAttrib contains H,R,S
			continue
		Random, MenuId
		Scan(MenuId, A_LoopFileFullPath)
		Populate(MenuId, A_LoopFileFullPath)
		Menu, % parent, add, % A_LoopFileName, :%MenuId%
	}	
}

/*	Populate(submenu, path)
		Description:
			Scan path for files and attach them to submenu.
			Save file path in array.
		
		Paramaters:
			(submenu) ID of submenu for files.
			(path) Location of folder to scan.
*/
Populate(submenu, path) {
	global Item
	Loop, Files, %path%\*, F 
	{
		Menu, % submenu, add, % A_LoopFileName, Handler
		Item[(submenu), (A_LoopFileName)] := A_LoopFileFullPath
	}
	if !(Item[(parent)])	; Filler for folders only containing folders
		Menu, % submenu, add
}

/*	Handler(ItemName, ItemPos, MenuName)
		Description:
			Handles menu call. Run clicked item by looking it
			up in the Item array. Hold ctrl to run as administrator.
		
		Paramaters:
			(ItemName) Name of clicked item.
			(ItemPos) Item position in menu.
			(MenuName) Name of menu containing item.
*/
Handler(ItemName, ItemPos, MenuName) {
	Global Item
	target := Item[(MenuName), (ItemName)]
	ControlDown := GetKeyState("ctrl" , "P")
	if (ControlDown)
		Run *RunAs "cmd.exe" /C "START %target%" ; Issues with file association using only *RunAs
	else
		Run, % target
}