; GTAO Useful Firewall Rules v241009
; 
; AHK CONTROLS:
; 	Ctrl+Shift+NumpadMult = Ins/Del GTAO_RELAY_RULE
; 	Ctrl+NumpadMult = Toggle GTAO_RELAY_RULE
; 	Ctrl+Shift+NumpadSub = Ins/Del GTAO_SOLO_RULE
; 	Ctrl+NumpadSub = Toggle GTAO_SOLO_RULE
; 	NumpadSub = Enable GTAO_SOLO_RULE for 10 seconds then disable (empties session)
; 	Shift+NumpadDiv = Toggle AFK (Double-taps F8 every 10 to 20 seconds)
; 
; REFERENCES, LINKS, NOTES:
; https://github.com/AutoHotkey/AutoHotkey
; https://www.autohotkey.com/docs/v1/KeyList.htm
; 
; https://whois.arin.net/ui/
; https://lookup.icann.org/en
; https://www.iplocation.net/ip-lookup
; https://www.ipaddressguide.com/cidr
; 
; 	MSFT
; 	52.132.0.0 - 52.143.255.255	
; 	52.132.0.0/14
; 	52.136.0.0/13
; 	T2OE-EU
; 	185.56.64.0 - 185.56.67.255
; 	185.56.64.0/22
; 	T2OE-NA
; 	192.81.240.0 - 192.81.247.255
; 	192.81.240.0/21
; 
; https://whois.arin.net/rest/org/TTIS-4/nets
; Network Resources
; RSONET-NA2 (NET-104-255-104-0-1) 	104.255.104.0 - 104.255.107.255
; TTIS-4 (NET-139-138-224-0-1) 		139.138.224.0 - 139.138.255.255
; RSONET-NA4 (NET-164-153-136-0-1) 	164.153.136.0 - 164.153.139.255
; ZYNGANET02 (NET-184-75-160-0-1) 	184.75.160.0 - 184.75.175.255
; T2OE-NA (NET-192-81-240-0-1) 		192.81.240.0 - 192.81.247.255
; RSONET-NA3 (NET-198-133-210-0-1) 	198.133.210.0 - 198.133.210.255
; ZYNGA-CORP (NET-199-48-104-0-1) 	199.48.104.0 - 199.48.107.255
; TTIS-4 (NET-209-204-240-0-1) 		209.204.240.0 - 209.204.255.255
; ZYNGANET03 (NET6-2620-102-8000-1) 2620:102:8000:: - 2620:102:800F:FFFF:FFFF:FFFF:FFFF:FFFF
; V6-T2OE-NA (NET6-2620-11B-C000-1) 2620:11B:C000:: - 2620:11B:C00F:FFFF:FFFF:FFFF:FFFF:FFFF
; V6-T2EE-1 (NET6-2620-132-F000-1) 	2620:132:F000:: - 2620:132:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
; ZYNGA-CORP-02 (NET-74-114-8-0-1) 	74.114.8.0 - 74.114.15.255
; 
#MaxThreadsPerHotkey 2
SetStoreCapsLockMode, Off
afkstate := 1
ipset=0.0.0.0-52.131.255.255,52.144.0.0-185.56.63.255,185.56.68.0-192.81.239.255,192.81.248.0-255.255.255.255

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
RuleStateA := funcReadFWRule("GTAO_SOLO_RULE")
RuleStateB := funcReadFWRule("GTAO_RELAY_RULE")
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
funcInsDelFWRule("GTAO_SOLO_RULE", "any")
return

^+NumpadMult::
funcInsDelFWRule("GTAO_RELAY_RULE", "" . ipset . "")
return

^NumpadSub::
funcToggleFWRule("GTAO_SOLO_RULE")
return

^NumpadMult::
funcToggleFWRule("GTAO_RELAY_RULE")
return

NumpadSub::
funcTempEnable("GTAO_SOLO_RULE")
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
