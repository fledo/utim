/*
utim
	Description:
		Creates a tray icon menu populated with folders and files.
		Hold ctrl to run a file as administrator (via cmd.exe).
		
	Parameters
		1:	Path to scan. Default is where utim is executed from.
		
	Author:
		fred.uggla@gmail.com
		github.com/fledo/utim
		
	License:
		utim
		Copyright (C) 2016 Fred Uggla
	
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

; Build menu, start from Tray level
Menu, Tray, Tip, utim v1.1
If FileExist("utim.ico")
	Menu, Tray, Icon, utim.ico
Menu, Tray, NoStandard
Menu, Tray, UseErrorLevel ; Ignore errors about empty submenus
Scan("Tray", A_WorkingDir)
Menu, Tray, Add, Update
Menu, Tray, Add, Exit
return

Update:
Run, %A_ScriptFullPath% /restart "%A_WorkingDir%"
Exit:
ExitApp

/*
Scan(Parent, Path)
	Scan path for folders, attach them as submenus to the parent menu.
	Populate them and store path as menu name.
	
	Parent:	Name of parent menu.
	Path:	Location of folder to scan.

	Return:	True if content was found, false if empty or just empty folders.
*/
Scan(Parent, Path) 
{
	local ContentFound = False
	Loop, Files, %Path%\*, D 
	{
		if A_LoopFileAttrib not contains H,R,S
		{
			local ContentFound = True
			if(Scan(A_LoopFileFullPath, A_LoopFileFullPath))
				Menu, % Parent, add, % A_LoopFileName, :%A_LoopFileFullPath%
		}
	}
	Loop, Files, %Path%\*, F
	{
		local ContentFound = True
		Menu, % Parent, add, % A_LoopFileName, Handler
	}
	return ContentFound
}

/*
Handler(ItemName, ItemPos, MenuName)
	Run clicked menu item.  Run as administrator if ctrl is held down. 
	Via cmd which circumvent *RunAs file association limitations.
	
	ItemName:	Name of clicked item, contains file name.
	ItemPos:	Item position in menu.
	MenuName:	Name of menu containing item, Contains full folder path.
*/
Handler(ItemName, ItemPos, MenuName) 
{
	if (MenuName = "Tray")
		MenuName :=  A_WorkingDir
	target := MenuName "\" ItemName
	if (GetKeyState("ctrl" , "P"))
		Run *RunAs cmd.exe /C "START `"`" `"%target%`"", , Hide 
	else
		Run, %target%, , UseErrorLevel
}