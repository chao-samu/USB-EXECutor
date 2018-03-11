; INFO =========================================================================
/*
Execute "your Code" if a specified device is plugged in, if a device change
is detected (receiving Windows message "WM_DEVICECHANGE").
*/

; INCLUDES AND FLAGS ===========================================================
#Include %A_ScriptDir%
#Include lib\GET_Devices.ahk

#NoEnv
; #Warn
; #NoTrayIcon    ; Its defined trough "state_hidden_taskbar"
SendMode Input
SetWorkingDir %A_ScriptDir%

; DEFINE =======================================================================
global PrgName := "USB EXECutor"
global PrgVersion := "0.9.0-beta"
global cfgName := "USB_EXECutor.cfg"

state_active := 0 ; ButtonSet (Activate/Inactive)
state_hidden := 0 ; ButtonHide
state_hidden_taskbar := 0 ; Hide from taskbar
state_exec := 0 ; CheckboxExec
state_exec_cmd := 0 ; Checkbox send parameter

; OS DETECTIONS ================================================================
If (A_PtrSize == 4)
    BitVersion := "x86"
else
    BitVersion := "x64"

; PARSE CFG FILE ===============================================================
If (FileExist(cfgName)) {
    Loop, read, %cfgName%
    {
        If (RegExMatch(A_LoopReadLine, "^#")) {
            continue
        }
        else If (RegExMatch(A_LoopReadLine, "^USB_ident := ")) {
            USB_ident := RegExReplace(A_LoopReadLine, "USB_ident := ")
        }
        else If (RegExMatch(A_LoopReadLine, "^exec_path := ")) {
            exec_path := RegExReplace(A_LoopReadLine, "^exec_path := ")
        }
        else If (RegExMatch(A_LoopReadLine, "^state_active := ")) {
            state_active := RegExReplace(A_LoopReadLine, "state_active := ")
        }
        else If (RegExMatch(A_LoopReadLine, "^state_hidden := ")) {
            state_hidden := RegExReplace(A_LoopReadLine, "state_hidden := ")
        }
        else If (RegExMatch(A_LoopReadLine, "^state_hidden_taskbar := ")) {
            state_hidden_taskbar := RegExReplace(A_LoopReadLine, "state_hidden_taskbar := ")
        }
        else If (RegExMatch(A_LoopReadLine, "^state_exec := ")) {
            state_exec := RegExReplace(A_LoopReadLine, "state_exec := ")
        }
        else If (RegExMatch(A_LoopReadLine, "^state_exec_cmd := ")) {
            state_exec_cmd := RegExReplace(A_LoopReadLine, "state_exec_cmd := ")
        }
    }
}
else {
    ;generate standard cfg
    SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
}

; GUI GET ======================================================================
; DDL items
device_list := GetDDLtems()
GuiControl,, DropDownList , |%device_list%

; GUI MAIN =====================================================================
Menu, Tray, Add, Show Gui, TrayShowGUI
Menu, Tray, Default, Show Gui
Menu, helpmenu, Add, Help , MenuHelp
Menu, helpmenu, Add
Menu, helpmenu, Add, License, MenuLicense
Menu, helpmenu, Add, About, MenuAbout
Menu, topmenu, Add, &Help, :helpmenu
Gui, Menu, topmenu
Gui, Add, DropDownList, x32 y40 w240 h200 vDropDownList, %device_list%
Gui, Add, Button, x302 y40 w90 h20 vButtonReload gButtonReload, Reload
Gui, Add, Button, x302 y70 w90 h20 vButtonSet gButtonSet, Activate
Gui, Add, Button, x302 y90 w90 h20 vButtonHide gButtonHide, Hide GUI
Gui, Add, Text, x32 y70 w250 h40 , NOTE: USB Devices can't be unquely identified. That means that two USB Sticks could possibly not distinguished. Read Help for further information.
Gui, Add, Checkbox, x19 y130 vstate_exec gstate_exec, Use own script/exe
Gui, Add, Checkbox, x145 y130 vstate_exec_cmd gstate_exec_cmd, Send parameters
Gui, Add, GroupBox, x12 y10 w390 h110 , Select USB Device
Gui, Add, GroupBox, x12 y150 w390 h50 , Select file to Run
Gui, Add, Edit, x22 y170 w250 h20 vEdit
Gui, Add, Button, x302 y170 w90 h20 vButtonSelect gButtonSelect, Select
; Generated using SmartGUI Creator for SciTE

; GUI Show command is initiated during "GUI SET CFG SETTINGS"

; GUI SET CFG SETTINGS =========================================================
; set GUI Show (state_hidden)
If (!state_hidden)
    Gui, Show, w420 h210, %PrgName%
else
    Gui, Cancel

; set tray icon (state_hidden_taskbar)
If(state_hidden_taskbar)
    Menu, Tray, NoIcon

; set old DDL item (USB_ident)
Loop, parse, device_list, |,
{
    If(!A_LoopField)
        continue
    If (A_LoopField == USB_ident) {
        current_attached_device := True
        GuiControl, ChooseString, DropDownList, %A_LoopField%
    }
}

If (!current_attached_device) {
    device_list .= USB_ident . "|"
    GuiControl,, DropDownList , |%device_list%
    GuiControl, ChooseString, DropDownList, %USB_ident%
}

; set Edit (exec_path)
GuiControl,, Edit, %exec_path%

; set checkbox (state_exec)
GuiControl,, state_exec, %state_exec%
If(state_exec) {
    GuiControl, Enable, Edit
    GuiControl, Enable, ButtonSelect
}
else {
    GuiControl, Disable, Edit
    GuiControl, Disable, ButtonSelect
    GuiControl,, Edit
}

; set checkbox (state_exec_cmd)
GuiControl,, state_exec_cmd, %state_exec_cmd%
If(state_exec) {
    GuiControl, Enable, state_exec_cmd
}
else {
    GuiControl, Disable, state_exec_cmd
}

; set ButtonSet (state_active)
If(state_active)
{
    GuiControl, Disable, ButtonReload
    GuiControl, Disable, ButtonSet
    GuiControl, Disable, ButtonSelect
    GuiControl, Disable, DropDownList
    GuiControl, Disable, Edit
    GuiControl, Disable, state_exec
    GuiControl, Disable, state_exec_cmd
    GuiControlGet, USB_ident,, DropDownList
    global USB_ident := USB_ident
    OnMessage(0x219, "notify_change")
    GuiControl,, ButtonSet, Deactivate
    GuiControl, Enable, ButtonSet
}
else
{
    GuiControl, Disable, ButtonSet
    GuiControl,, ButtonSet, Activate
    GuiControl, Enable, ButtonReload
    GuiControl, Enable, ButtonSet
    GuiControl, Enable, ButtonSelect
    GuiControl, Enable, DropDownList
    If (state_exec) {
        GuiControl, Enable, Edit
        GuiControl, Enable, state_exec_cmd
    }
    GuiControl, Enable, state_exec
}
return

; GUI TRAY =====================================================================
TrayShowGUI:
state_hidden := 0
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
Gui, Show
return

; GUI MENUBAR ==================================================================
HelpButtonOK:
HelpGuiClose:
HelpGuiEscape:
AboutButtonOK:
AboutGuiClose:
AboutGuiEscape:
LicenseButtonOK:
LicenseGuiClose:
LicenseGuiEscape:
Gui, 1:-Disabled
Gui Destroy
return

GuiClose:
ExitApp

MenuHelp:
Gui, Help:+owner1
Gui +Disabled
Gui, Help:Add, Text,,
(
What can this Tool do?
This tool detects an device change (e.g USB stick got attached, USB stick got pulled out)

If a device change has occured then it will check if your selected device got attached
to the system. If so it will execute your script/exe (Or the inbuild HelloWorld script if you
haven't selected anything).

Please Note:

1.  It will only detect device changes, so if a device change occur and your device
    is still attached it will execute the script/exe again. Im' looking for a solution, if you have
    an idea please share with me.

2.  USB Sticks have no unquie identifier, so two USB sticks from the same production line,
    has the same "devicePath"(identifier). If two of the same USB sticks got attached
    the deviePath got suffixed with "&1". Therefore the one stands for the first attached
    usb device 2 for the second and so on.

How to use?
Select your device, chose script/exe to execute, press activate.

Can you use it without GUI?
You can configure this tool with the "%cfgName%" completly without GUI, so you
can run it in the background.
(state_active, state_hidden and state_hidden_taskbar to 1)

Can you send the drive letters to the script/exe?
Yes, please tick the "Send parameter" checkbox. they will be attached at the end of the edit
line (not visible). E. g. "G:,H:" see "example1.ahk" how to use.
)

Gui, Help:Add, Button, Default, OK
Gui, Help:Show, w450 h420, Help
return

MenuLicense:
Gui, License:+owner1
Gui +Disabled
Gui, License:Add, Text, r9 vMeinEdit,
(
The MIT License (MIT)

Copyright (c) 2018 chao-samu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
)
Gui, License:Add, Button, Default, OK
Gui, License:Show, w540 h320, License
return

MenuAbout:
Gui, About:+owner1
Gui +Disabled
Gui, About:Add, Link,,
(
%PrgName% - Version %PrgVersion%

Tool compiled with: AHK %A_AhkVersion% %BitVersion%

Special thanks:
qwerty12 from the authotkey.com forum who has helped
me a lot with the DLL calls.

And of course all AHK developer and contributers!

Look for updates:`n<a href="https://github.com/chao-samu">https://github.com/chao-samu</a>

Made by chao-samu
)
Gui, About:Add, Button, Default, OK
Gui, About:Show, w300 h225, About
return

; GUI CONTROL ==================================================================
ButtonHide:
state_hidden := 1
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
Gui, Cancel
return

ButtonReload:
;clear previous generated DDL list
device_list  := ""

; Get + Set DDL items
device_list := GetDDLtems()
GuiControl,, DropDownList , |%device_list%
return

ButtonSelect:
FileSelectFile, exec_path
GuiControl,, Edit, %exec_path%
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
return

state_exec:
GuiControlGet, state_exec
If (state_exec) {
    GuiControl, Enable, Edit
    GuiControl, Enable, ButtonSelect
    GuiControl, Enable, state_exec_cmd
}
else {
    GuiControl, Disable, Edit
    GuiControl, Disable, ButtonSelect
    GuiControl, Disable, state_exec_cmd
    GuiControl,, Edit
}
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
return

state_exec_cmd:
GuiControlGet, state_exec_cmd
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
return

ButtonSet:
If(state_active)
{
    state_active := 0
    GuiControl, Disable, ButtonSet
    GuiControl,, ButtonSet, Activate
    GuiControl, Enable, ButtonReload
    GuiControl, Enable, ButtonSet
    GuiControl, Enable, ButtonSelect
    GuiControl, Enable, DropDownList
    If (state_exec) {
        GuiControl, Enable, Edit
        GuiControl, Enable, state_exec_cmd
    }
    GuiControl, Enable, state_exec
}
else
{
    state_active++
    GuiControl, Disable, ButtonReload
    GuiControl, Disable, ButtonSet
    GuiControl, Disable, ButtonSelect
    GuiControl, Disable, DropDownList
    GuiControl, Disable, Edit
    GuiControl, Disable, state_exec
    GuiControl, Disable, state_exec_cmd
    GuiControlGet, USB_ident,, DropDownList
    global USB_ident := USB_ident
    OnMessage(0x219, "notify_change")
    GuiControl,, ButtonSet, Deactivate
    GuiControl, Enable, ButtonSet
}
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd)
; requires better solution to stop OnMessageCall
If(!state_active)
    Run, %A_ScriptDir%\%A_ScriptName%
return

; FUNCTIONS ====================================================================
SaveConfig(USB_ident, exec_path, state_active, state_hidden, state_hidden_taskbar, state_exec, state_exec_cmd) {
    ; delete previous cfg file (truncate not support natively by ahk)
    FileDelete, %cfgName%

    ; write cfg file
    FileAppend,
    (LTrim
    # Read README.md or the GUI Help for additional information

    # script Active/Inactive
    state_active := %state_active%

    # device identifier string (DevicePath)
    USB_ident := %USB_ident%

    # exec settings
    exec_path := %exec_path%
    state_exec := %state_exec%
    state_exec_cmd := %state_exec_cmd%

    # GUI view settings
    state_hidden := %state_hidden%
    state_hidden_taskbar := %state_hidden_taskbar%
    ), %cfgName%

    if(ErrorLevel) {
    MsgBox % cfgName . " creation not possible. Error: " . A_LastError
    ExitApp
    }
}

GetDDLtems() {
    i_disk_seApi := GetDevices_from_SetupAPI()
    for k, v in i_disk_seApi {
        ; device_list .= i_disk_seApi[k, "device_number"]" - "i_disk_seApi[k, "devicePath"] . "|"
        device_list .= i_disk_seApi[k, "devicePath"] . "|"
    }
    return device_list
}

; Execute function (called by notify_change)
Execute(USB_drive_letter, count) {
    GuiControlGet, exec_path,, Edit
    GuiControlGet, state_exec_cmd,, Edit
    If(exec_path) {
        If(state_exec_cmd) {
            GuiControlGet, exec_path,, Edit
            for v, k in USB_drive_letter {
                partitions .= k . ","
            }
            Run, %exec_path% "%partitions%"
        }
        else {
            GuiControlGet, exec_path,, Edit
            Run, %exec_path%
        }
    }
    else {
        ; Hello World script
        for v, k in USB_drive_letter {
            partitions .= k . ","
        }
        MsgBox % "We identified an USB change, your device is attached at the moment:`n`n" USB_ident "`n`nYour device has " count " partition/s:`n" partitions
    }
}