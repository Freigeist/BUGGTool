; Author: Freigeist
; License: MIT (see LICENSE.md)
;
; WARNING! CODEGORE! I like to obscure my AHK code for no reasons ¯\_(ツ)_/¯

#SingleInstance force

SelectedLang = English (builtin)
version = 1.0.1

langs = English (builtin)

Menu, lang, Add, English (builtin), ChangeLangTray
Loop, Files, %A_ScriptDir%\lang\*.ini
{
	StringTrimRight, tmp, A_LoopFileName, 4
	langs = %langs%|%tmp%
	Menu, lang, Add, %tmp%, ChangeLangTray
}

Menu, Tray, NoDefault
Menu, Tray, NoStandard
Menu, Tray, Tip, BUGGTool

Gui, Add, Text, x12 y9 w230 h20, Please select a language:
Gui, Add, DropDownList, x12 y29 w230 h20 r10 Choose1 vSelectedLang gGuiSubmit, %langs%
Gui, Add, Button, x12 y59 w100 h30 gAfterGuiOK, OK
Gui, Add, Button, x142 y59 w100 h30 gExitApp, Exit

RegRead, SelectedLang, HKEY_CURRENT_USER, Software\BUGGTool, SelectedLang
if ErrorLevel
	goto GuiShow
Else
{
	If SelectedLang <> English (builtin)
	{
		IfNotExist, %A_ScriptDir%\lang\%SelectedLang%.ini
		{
			SelectedLang = English (builtin)
			goto GuiShow
		}
	}
	goto Init
}

AfterGuiOK:
Gui, Submit
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\BUGGTool, SelectedLang, %SelectedLang%
MsgBox, 64, BUGGTool, The language "%SelectedLang%" was applied. You can change it via the tray icon at any time.

Init:
gosub ChangeLang

Errors = 0
RegRead, Default, HKEY_CURRENT_USER, Software\BUGGTool, Default
Errors += %ErrorLevel%
RegRead, Ingame, HKEY_CURRENT_USER, Software\BUGGTool, Ingame
Errors += %ErrorLevel%
RegRead, Exe, HKEY_CURRENT_USER, Software\BUGGTool, Exe
Errors += %ErrorLevel%

If Errors > 0
{
	MsgBox, 36, BUGGTool, %lng_first_run_text%
	IfMsgBox, Yes
		goto InitialConfig
	IfMsgBox, No
		ExitApp
}

ProcessCheckLoop:
Process, Exist, %Exe%

Runs = %ErrorLevel%

Loop
{
	If Runs = 0
	{
		Process, Exist, %Exe%
		If ErrorLevel <> 0
		{
			gosub GracefulExplorerExit
			RegWrite, REG_BINARY, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings, %Ingame%
			Run, %A_WinDir%\explorer.exe, %A_WinDir%
			Runs = 1
		}
	}
	Else
	{
		Process, Exist, %Exe%
		If ErrorLevel = 0
		{
			gosub GracefulExplorerExit
			RegWrite, REG_BINARY, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings, %Default%
			Run, %A_WinDir%\explorer.exe, %A_WinDir%
			Runs = 0
		}
	}
	Sleep, 500
}
return

GracefulExplorerExit:
WinGet, exPID, PID, ahk_class Shell_TrayWnd
SendMessage, 0x5B4, 0, 0,, ahk_class Shell_TrayWnd
Loop
{
	Process, Exist, %exPID%
	If ErrorLevel = 0
		break
	Sleep, 500
}
return

ReRunInitialConfig:
MsgBox, 36, BUGGTool, %lng_rerun_wizard%
	IfMsgBox, Yes
		goto InitialConfig
return

InitialConfig:
Menu, Tray, Disable, %lng_run_wizard%
MsgBox, 64, BUGGTool, %lng_wizard_default%
gosub GracefulExplorerExit
RegRead, Default, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings
Run, %A_WinDir%\explorer.exe, %A_WinDir%

MsgBox, 64, BUGGTool, %lng_wizard_ingame%
gosub GracefulExplorerExit
RegRead, Ingame, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings
Run, %A_WinDir%\explorer.exe, %A_WinDir%

If Default = %Ingame%
{
	MsgBox, 36, BUGGTool, %lng_wizard_same_value%
	IfMsgBox, Yes
		goto InitialConfig
}

InputBox, Exe, BUGGTool, %lng_wizard_processname%,,,,,,,, TslGame.exe


RegWrite, REG_BINARY, HKEY_CURRENT_USER, Software\BUGGTool, Default, %Default%
RegWrite, REG_BINARY, HKEY_CURRENT_USER, Software\BUGGTool, Ingame, %Ingame%
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\BUGGTool, Exe, %Exe%

MsgBox, 64, BUGGTool, %lng_wizard_finish%

Menu, Tray, Enable, %lng_run_wizard%

goto ProcessCheckLoop
return

RunPUBG:
Run, steam://run/578080
return

RunPUBGTestserver:
Run, steam://run/622590
return

ChangeLangTray:
; Prefunction, if language is change by tray menu
Menu, lang, Uncheck, %SelectedLang%
SelectedLang = %A_ThisMenuItem%
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\BUGGTool, SelectedLang, %SelectedLang%


ChangeLang:
; Set anything to default, which will be kept if entries can't be read from ini files
lng_author = ThxAndBye
lng_exit = Exit
lng_first_run_text = The BUGGTool isn't set-up yet. Do you want to start the wizard now?
lng_rerun_wizard = Are you sure that you want to start the wizard again?
lng_run_wizard = Run the wizard
lng_start_pugb = Start PUBG
lng_start_pugb_testsrv = Start PUBG (Testserver)
lng_wizard_default = Please set your default task-bar values now (position, lock, etc.) and confirm with OK. To reliably read your configuration, your explorer will be restarted.
lng_wizard_finish = The wizard was successful. You can re-run it via the tray icon at any time.
lng_wizard_ingame = Please move the task-bar to the bottom position now. All other values can be configured as you wish. To reliably read the configuration, your explorer will be restarted.
lng_wizard_processname = Please specify the task name that should be monitored. (If you are unsure, leave the default value)
lng_wizard_same_value = The values for your default configuration and the position during gameplay are the same. Do you want to start the wizard again?

; Read from ini if not builtin
If SelectedLang <> English (builtin)
{
	IfExist, %A_ScriptDir%\lang\%SelectedLang%.ini
	{
		IniRead, lng_author, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_author, %lng_author%
		IniRead, lng_exit, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_exit, %lng_exit%
		IniRead, lng_first_run_text, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_first_run_text, %lng_first_run_text%
		IniRead, lng_rerun_wizard, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_rerun_wizard, %lng_rerun_wizard%
		IniRead, lng_run_wizard, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_run_wizard, %lng_run_wizard%
		IniRead, lng_start_pugb, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_start_pugb, %lng_start_pugb%
		IniRead, lng_start_pugb_testsrv, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_start_pugb_testsrv, %lng_start_pugb_testsrv%
		IniRead, lng_wizard_default, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_wizard_default, %lng_wizard_default%
		IniRead, lng_wizard_finish, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_wizard_finish, %lng_wizard_finish%
		IniRead, lng_wizard_ingame, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_wizard_ingame, %lng_wizard_ingame%
		IniRead, lng_wizard_processname, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_wizard_processname, %lng_wizard_processname%
		IniRead, lng_wizard_same_value, %A_ScriptDir%\lang\%SelectedLang%.ini, BUGGTool, lng_wizard_same_value, %lng_wizard_same_value%
	}
}

; Rebuild tray menu
Menu, lang, Check, %SelectedLang%

Menu, Tray, DeleteAll

Menu, Tray, Add, %lng_start_pugb%, RunPUBG
Menu, Tray, Add, %lng_start_pugb_testsrv%, RunPUBGTestserver
Menu, Tray, Add,
Menu, Tray, Add, %lng_run_wizard%, ReRunInitialConfig
Menu, Tray, Add,
Menu, Tray, Add, %SelectedLang% by %lng_author%, NoOp
Menu, Tray, Disable, %SelectedLang% by %lng_author%
Menu, Tray, Add, Change language, :lang
Menu, Tray, Add,
Menu, Tray, Add, v %version%, NoOp
Menu, Tray, Disable, v %version%
Menu, Tray, Add,
Menu, Tray, Add, %lng_exit%, ExitApp

Menu, Tray, Default, %lng_start_pugb%
return

NoOp:
return

GuiShow:
Gui, Show, x465 y341 Center, BUGGTool
Return

GuiSubmit:
Gui, Submit, NoHide
return

GuiClose:
ExitApp:
ExitApp
