:: GTAO Useful Firewall Rules Script v260104
@echo off 
set "title=GTAO Useful Firewall Rules Script"
set "name_solo=gtaoSoloRule"
set "name_relay=gtaoRelayRule"
set "firewall_cmd=netsh advfirewall firewall "
set "display_rule=%firewall_cmd%show rule name="
set "toggle_rule=%firewall_cmd%set rule name="
set "add_rule=%firewall_cmd%add rule name="
set "del_rule=%firewall_cmd%delete rule name="
set "toggle_parameter=Enabled:                              Yes"
set "create_parameter=No rules match the specified criteria."
set "rule_parameters= dir=out action=block enable=no protocol=udp localport=6672"
set "remote_ip= remoteip=0.0.0.0-20.40.183.13,20.40.183.15-20.40.183.156,20.40.183.158-20.187.105.38,20.187.105.40-20.188.217.85,20.188.217.87-20.193.9.1,20.193.9.3-20.239.134.105,20.239.134.107-52.139.168.173,52.139.168.175-52.139.168.216,52.139.168.218-52.139.168.237,52.139.168.239,52.139.168.241-52.139.169.51,52.139.169.53-52.139.169.70,52.139.169.72-52.139.169.89,52.139.169.91-52.139.169.118,52.139.169.120-52.139.169.121,52.139.169.123-52.139.169.237,52.139.169.239-185.56.65.166,185.56.65.173-192.81.241.190,192.81.241.192-192.81.241.223,192.81.241.228-192.81.245.122,192.81.245.129-255.255.255.255"
set "tempSolo=EMPTY_SESSSION"
set "toggleSolo=TOGGLE_SOLO_MODE"
set "toggleRelay=TOGGLE_RELAY_MODE"
set "insDelSolo=INS/DEL_SOLO_FIREWALL_RULE"
set "insDelRelay=INS/DEL_RELAY_FIREWALL_RULE"
title %title%
color 0a
mode con:cols=72 lines=19

:check_Permissions
echo.
echo  Administrative permissions required. Detecting permissions...
net session >nul 2>&1 && (
	cls
	echo  %title%
	echo  ######################################################################
	echo  # Administrator privileges are present.                              #
	echo  #                                                                    #
	echo  #                                                                    #
	echo  ######################################################################
	echo.
) || (
	cls
	echo  %title%
	echo  ######################################################################
	echo  # Administrator privileges are not present.                          #
	echo  # Administrator privileges are required to modify firewall rules.    #
	echo  # Please run this script as administrator.                           #
	echo  ######################################################################
	echo.
	pause
	goto EOF
)
(timeout /t 5)>nul

:start
setlocal EnableDelayedExpansion
set /a current=1

:subpick
(%display_rule%"%name_solo%" | find /i "%create_parameter%")>nul && (
	set "solo_state=not installed."
) || (
(%display_rule%"%name_solo%" | find /i "%toggle_parameter%")>nul && (
	set "solo_state=enabled.      "
) || (
	set "solo_state=disabled.     "
)
)
(%display_rule%"%name_relay%" | find /i "%create_parameter%")>nul && (
	set "relay_state=not installed."
) || (
(%display_rule%"%name_relay%" | find /i "%toggle_parameter%")>nul && (
	set "relay_state=enabled.      "
) || (
	set "relay_state=disabled.     "
)
)
cls
echo  %title%
echo  ######################################################################
echo  # %name_solo% %solo_state%           Controls: Numpad8 (Up),      #
echo  # %name_relay% %relay_state%                    Numpad5 (Enter),   #
echo  #                                 Numpad0 (Exit), Numpad2 (Down)     #
echo  ######################################################################
set /a count=0
set "options=%tempSolo% %toggleSolo% %toggleRelay% %insDelSolo% %insDelRelay% EXIT"
for /f "delims=" %%M in ("%options%") do for %%N in (%%M) do (
	set /a count+=1
	set str!count!=%%N
	if !count! NEQ !current! (echo    %%N  ) else (
		set sel=%%N
		echo  ^> !sel! ^<)
)
echo  ######################################################################
choice /c 8250 /n /cs
if %errorlevel% EQU 0 echo error message & goto start
if %errorlevel% EQU 1 set /a current-=1 & goto subcheck
if %errorlevel% EQU 2 set /a current+=1 & goto subcheck 
if %errorlevel% EQU 3 goto MENU
if %errorlevel% EQU 4 goto EOF

:subcheck
cls
if !current! LSS 1 set /a current=!count!
if !current! GTR !count! set /a current=1
goto subpick

:MENU
if !current!==1 goto temp_solo_rule
if !current!==2 goto toggle_solo_rule
if !current!==3 goto toggle_relay_rule
if !current!==4 goto create_del_solo_rule
if !current!==5 goto create_del_relay_rule
if !current!==6 goto EOF

:temp_solo_rule
(%display_rule%"%name_solo%" | find /i "%create_parameter%")>nul && (
	echo  %name_solo% not installed... redirecting to install firewall rule. 
	(timeout /t 5)>nul
	goto create_del_solo_rule
) || (
(%display_rule%"%name_solo%" | find /i "%toggle_parameter%")>nul && (
	echo  %name_solo% already enabled.
	(timeout /t 5)>nul
) || (
	(%toggle_rule%"%name_solo%" new enable=yes)>nul
	(%display_rule%"%name_relay%" | find /i "%create_parameter%")>nul && (
		set "relay_state=not installed."
	) || (
	(%display_rule%"%name_relay%" | find /i "%toggle_parameter%")>nul && (
		set "relay_state=enabled.      "
	) || (
		set "relay_state=disabled.     "
	)
	)
	cls
	echo  %title%
	echo  ######################################################################
	echo  # %name_solo% enabled for 10 seconds.                               #
	echo  # %name_relay% %relay_state%                                       #
	echo  #                                                                    #
	echo  ######################################################################
	echo.
	(timeout /t 10 /nobreak)>nul
	(%toggle_rule%"%name_solo%" new enable=no)>nul
)
)
goto subpick

:toggle_solo_rule
(%display_rule%"%name_solo%" | find /i "%create_parameter%")>nul && (
	echo  %name_solo% not installed... redirecting to install firewall rule. 
	(timeout /t 5)>nul
	goto create_del_solo_rule
) || (
(%display_rule%"%name_solo%" | find /i "%toggle_parameter%")>nul && (
	echo Disabling %name_solo% rule...
	(%toggle_rule%"%name_solo%" new enable=no)>nul
) || (
	echo Enabling %name_solo% rule...
	(%toggle_rule%"%name_solo%" new enable=yes)>nul
)
)
goto subpick

:toggle_relay_rule
(%display_rule%"%name_relay%" | find /i "%create_parameter%")>nul && (
	echo  %name_relay% not installed... redirecting to install firewall rule. 
	(timeout /t 5)>nul
	goto create_del_relay_rule
) || (
(%display_rule%"%name_relay%" | find /i "%toggle_parameter%")>nul && (
	echo Disabling %name_relay% rule...
	(%toggle_rule%"%name_relay%" new enable=no)>nul
) || (
	echo Enabling %name_relay% rule...
	(%toggle_rule%"%name_relay%" new enable=yes)>nul
)
)
goto subpick

:create_del_relay_rule
(%display_rule%"%name_relay%" | find /i "%create_parameter%")>nul && (
	echo  Generating %name_relay% firewall rule...
	(%add_rule%%name_relay%%rule_parameters%%remote_ip%)>nul
) || (
	echo Deleting %name_relay% firewall rule...
	(%del_rule%"%name_relay%")>nul
)
goto subpick

:create_del_solo_rule
(%display_rule%"%name_solo%" | find /i "%create_parameter%")>nul && (
	echo  Generating %name_solo% firewall rule...
	(%add_rule%%name_solo%%rule_parameters%)>nul
) || (
	echo Deleting %name_solo% firewall rule...
	(%del_rule%"%name_solo%")>nul
)
goto subpick

:EOF

@exit

