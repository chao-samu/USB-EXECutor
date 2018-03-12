#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Program Info ################################################################
/*
Example how you can pass parameters from USB_Executor to a script.
*/

; define #######################################################################
USB_drive_letter := Object()

; get cmd parameter ############################################################
for k, v in A_Args {
    Loop, parse, v, `,,
    {
        If(!A_LoopField)
            continue
        else
            USB_drive_letter.Push(A_LoopField)
    }
}

; main #########################################################################
; Example (Hello World)
for v, k in USB_drive_letter {
    partitions .= k . ","
}
partitions := RTrim(partitions, ",")
MsgBox % "We identified a device change, your device is attached at the moment.`nYour device partition/s: " . partitions

; Example (KeePass)
; first_partition := USB_drive_letter[1]
; Run, C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe C:\Users\%A_UserName%\Documents\NewDatabase.kdbx -preselect:%first_partition%"\NewDatabase.key"