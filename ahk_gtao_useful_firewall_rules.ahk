; GTAO Useful Firewall Rules v250915
#MaxThreadsPerHotkey 2
SetStoreCapsLockMode, Off
afkstate := 1
ipset=0.0.0.0-20.157.0.0,20.255.255.255-52.131.255.255,52.144.0.0-185.56.63.255,185.56.68.0-192.81.239.255,192.81.248.0-255.255.255.255

full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
	try { if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	} ExitApp
}
; MsgBox A_IsAdmin: %A_IsAdmin%`nCommand line: %full_command_line%

; Get initial firewall rule states for tray icon tooltip.
firstrunstate := funcDisplayStates()
TrayTip %firstrunstate%, GTAO Useful Firewall Rules

funcReadFWRule(rulename)
{
createpar := "No rules match the specified criteria."
togglepar := "Enabled:                              Yes"
cmdstr=netsh advfirewall firewall show rule name=%rulename%
DetectHiddenWindows On
Run %ComSpec%,, Hide, pid
WinWait ahk_pid %pid%
DllCall("AttachConsole", "UInt", pid)
WshShell := ComObjCreate("Wscript.Shell")
exec := WshShell.Exec("" . cmdstr . "")
outputRule := exec.StdOut.ReadAll()
DllCall("FreeConsole")
Process Close, %pid%
If InStr(outputRule, createpar) {
	StateStr=%rulename% Does not exist.
} else {
	If InStr(outputRule, togglepar) {
		StateStr=%rulename% Enabled.
	} else {
		StateStr=%rulename% Disabled.
	}
}
return %StateStr%
}

funcDisplayStates()
{
RuleStateA := funcReadFWRule("gtaoSoloRule")
RuleStateB := funcReadFWRule("gtaoRelayRule")
CombinedStateStr =
(
%RuleStateA%
%RuleStateB%
)
Menu, Tray, Tip, %CombinedStateStr%
return %CombinedStateStr%
}

funcInsDelFWRule(rulename, option)
{
create_parameter := "Does not exist"
RuleStateA := funcReadFWRule("" . rulename . "")
If InStr(RuleStateA, create_parameter) {
	run, *runas %comspec% /c netsh advfirewall firewall add rule name=%rulename% dir=out action=block enable=no protocol=udp localport=6672 remoteip=%option%,,hide
	Sleep, 2000
	funcDisplayStates()
	TrayTip %rulename% created., GTAO Useful Firewall Rules
	return
} else {
	run, *runas %comspec% /c netsh advfirewall firewall delete rule name=%rulename%,,hide
	Sleep, 2000
	funcDisplayStates()
	TrayTip %rulename% deleted., GTAO Useful Firewall Rules
	return
}
}

funcToggleFWRule(rulename)
{
create_parameter := "Does not exist"
toggle_parameter := "Enabled"
RuleStateB := funcReadFWRule("" . rulename . "")
If InStr(RuleStateB, create_parameter) {
	TrayTip %rulename% does not exist., GTAO Useful Firewall Rules
	return
} else {
	If InStr(RuleStateB, toggle_parameter) {
		run, *runas %comspec% /c netsh advfirewall firewall set rule name=%rulename% new enable=no,,hide
		Sleep, 2000
		funcDisplayStates()
		TrayTip %rulename% disabled., GTAO Useful Firewall Rules
		return
	} else {
		run, *runas %comspec% /c netsh advfirewall firewall set rule name=%rulename% new enable=yes,,hide
		Sleep, 2000
		funcDisplayStates()
		TrayTip %rulename% enabled., GTAO Useful Firewall Rules
		return
	}
}
}

funcTempEnable(rulename)
{
create_parameter := "Does not exist"
toggle_parameter := "Enabled"
RuleStateC := funcReadFWRule("" . rulename . "")
If InStr(RuleStateC, create_parameter) {
	TrayTip %rulename% does not exist., GTAO Useful Firewall Rules
	return
} else {
	If InStr(RuleStateC, toggle_parameter) {
		TrayTip %rulename% is already enabled., GTAO Useful Firewall Rules
		return
	} else {
		run, *runas %comspec% /c netsh advfirewall firewall set rule name=%rulename% new enable=yes,,hide
		funcDisplayStates()
		TrayTip %rulename% enabled for 10 seconds..., GTAO Useful Firewall Rules
		Sleep, 10000
		run, *runas %comspec% /c netsh advfirewall firewall set rule name=%rulename% new enable=no,,hide
		funcDisplayStates()
		TrayTip %rulename% disabled., GTAO Useful Firewall Rules
		return
	}
}
}

^+NumpadSub::
funcInsDelFWRule("gtaoSoloRule", "any")
return

^+NumpadMult::
funcInsDelFWRule("gtaoRelayRule", "" . ipset . "")
return

^NumpadSub::
funcToggleFWRule("gtaoSoloRule")
return

^NumpadMult::
funcToggleFWRule("gtaoRelayRule")
return

NumpadSub::
funcTempEnable("gtaoSoloRule")
return

+NumpadDiv::
{
	Toggle:=!Toggle
	While, Toggle
	{
		if afkstate
		{
			afkstate := 0
			TrayTip GTAO AFK Script Active..., GTAO Useful Firewall Rules
		}
		Random, randtimer, 10000, 20000
; 		ranrnd:=Round(randtimer/1000)
		Sleep, randtimer
		SendInput {F8 down}
		Sleep, 30
		SendInput {F8 up}
		Sleep, 60
		SendInput {F8 down}
		Sleep, 30
		SendInput {F8 up}
		TrayTip I like to move it move it, GTAO Useful Firewall Rules,,17
	}
	if not afkstate
	{
		afkstate := 1
		TrayTip GTAO AFK Script Inactive..., GTAO Useful Firewall Rules
	}
}
return
