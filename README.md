GTAO Useful Firewall Rules

The scripts can install, uninstall, enable, and disable two windows firewall rules: 
1. gtaoSoloRule - if enabled, blocks all outgoing traffic on udp port 6672 for any ip address. 
2. gtaoRelayRule - if enabled, blocks all outgoing traffic on udp port 6672 for a set of ip addresses (tunnels all traffic through t2's matchmaking servers).

- The controls for the ahk script are as follows: 

  AHK CONTROLS:
  Ctrl+Shift+NumpadMult = Ins/Del gtaoRelayRule
  Ctrl+NumpadMult = Toggle gtaoRelayRule
  Ctrl+Shift+NumpadSub = Ins/Del gtaoSoloRule
  Ctrl+NumpadSub = Toggle gtaoSoloRule
  NumpadSub = Enable gtaoSoloRule for 10 seconds then disable (empties session)
  Shift+NumpadDiv = Toggle AFK (Double-taps F8 every 10 to 20 seconds)

- The controls for the batch script are as follows: 

  Controls:
  Numpad8 (Up)
  Numpad5 (Enter)
  Numpad2 (Down)
  Numpad0 (Exit)
(the number keys above the letter keys will also work)

Both scripts have an option to empty the current session by enabling the gtaoSoloRule firewall rule for 10 seconds then disabling it afterwards. 
