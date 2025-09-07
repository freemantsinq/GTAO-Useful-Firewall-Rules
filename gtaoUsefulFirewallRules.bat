:: GTAO Useful Firewall Rules Script v250904
:: 
:: REFERENCES, LINKS, NOTES:
:: https://whois.arin.net/ui/
:: https://lookup.icann.org/en
:: https://www.iplocation.net/ip-lookup
:: https://www.ipaddressguide.com/cidr
:: 
::     MSFT
::     52.132.0.0 - 52.143.255.255    
::     52.132.0.0/14
::     52.136.0.0/13
::     T2OE-EU
::     185.56.64.0 - 185.56.67.255
::     185.56.64.0/22
::     T2OE-NA
::     192.81.240.0 - 192.81.247.255
::     192.81.240.0/21
:: 
:: https://whois.arin.net/rest/org/TTIS-4/nets
:: Network Resources
:: RSONET-NA2 (NET-104-255-104-0-1)     104.255.104.0 - 104.255.107.255
:: TTIS-4 (NET-139-138-224-0-1)         139.138.224.0 - 139.138.255.255
:: RSONET-NA4 (NET-164-153-136-0-1)     164.153.136.0 - 164.153.139.255
:: ZYNGANET02 (NET-184-75-160-0-1)     184.75.160.0 - 184.75.175.255
:: T2OE-NA (NET-192-81-240-0-1)         192.81.240.0 - 192.81.247.255
:: RSONET-NA3 (NET-198-133-210-0-1)     198.133.210.0 - 198.133.210.255
:: ZYNGA-CORP (NET-199-48-104-0-1)     199.48.104.0 - 199.48.107.255
:: TTIS-4 (NET-209-204-240-0-1)         209.204.240.0 - 209.204.255.255
:: ZYNGANET03 (NET6-2620-102-8000-1)     2620:102:8000:: - 2620:102:800F:FFFF:FFFF:FFFF:FFFF:FFFF
:: V6-T2OE-NA (NET6-2620-11B-C000-1)     2620:11B:C000:: - 2620:11B:C00F:FFFF:FFFF:FFFF:FFFF:FFFF
:: V6-T2EE-1 (NET6-2620-132-F000-1)     2620:132:F000:: - 2620:132:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
:: ZYNGA-CORP-02 (NET-74-114-8-0-1)     74.114.8.0 - 74.114.15.255
:: 
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
set "remote_ip= remoteip=0.0.0.0-52.131.255.255,52.144.0.0-185.56.63.255,185.56.68.0-192.81.239.255,192.81.248.0-255.255.255.255"
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