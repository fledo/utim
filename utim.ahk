/*	utim
		Description:
			Creates a tray icon menu populated by folders and files relative to the executable. 
			Hold ctrl to run a file as administrator (via cmd.exe).
			
		Author:
			fred.uggla@gmail.com
			github.com/fledo/utim
			
		License:
			utim
			Copyright (C) 2015  Fred Uggla
		
			This program is free software; you can redistribute it and/or modify
			it under the terms of the GNU General Public License as published by
			the Free Software Foundation; either version 2 of the License, or
			(at your option) any later version.
		
			This program is distributed in the hope that it will be useful,
			but WITHOUT ANY WARRANTY; without even the implied warranty of
			MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			GNU General Public License for more details.
		
			You should have received a copy of the GNU General Public License along
			with this program; if not, write to the Free Software Foundation, Inc.,
			51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#Persistent
#SingleInstance off
#NoEnv 
SetBatchLines, -1

; Set working dir from parameter if available
if 1
	SetWorkingDir, %1%
else
	SetWorkingDir, %A_ScriptDir%

; Contains menus as sub-arrays with file paths.
global Item := Object()

; Build menu, start from Tray level
Menu, Tray, Tip, utim v1.0
Menu, Tray, NoStandard
Scan("Tray", A_WorkingDir)
Menu, Tray, Add, Scan
Menu, Tray, Add, Exit
return

Exit:
exitapp

Scan:
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
	Loop, Files, %path%\*, F 
	{
		Menu, % submenu, add, % A_LoopFileName, Handler
		Item[(submenu), (A_LoopFileName)] := A_LoopFileFullPath
	}
	if !(Item[(submenu)])	; Filler for folders only containing folders
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
	target := Item[(MenuName), (ItemName)]
	ControlDown := GetKeyState("ctrl" , "P")
	if (ControlDown)
		Run *RunAs "cmd.exe" /C "START %target%" ; Issues with file association using only *RunAs
	else
		Run, % target
}