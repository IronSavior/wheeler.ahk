;;
;; Author: Erik Elmore <erik@ironsavior.net>
;; Version: 1.1 (Aug 16, 2005)
;;
;; Enables you to use any key with cursor movement
;; to emulate a scrolling middle button.  While
;; the TriggerKey is held down, you may move the
;; mouse cursor up and down to send scroll wheel
;; events.  If the cursor does not move by the
;; time the TriggerKey is released, then a middle
;; button click is generated.  I wrote this for my
;; 4-button Logitech Marble Mouse (trackball),
;; which has no middle button or scroll wheel.
;;

;; Configuration

;#NoTrayIcon

;; Higher numbers mean less sensitivity
esmb_Threshold = 5

;; This key/Button activates scrolling
esmb_TriggerKey = XButton1

;; End of configuration

#Persistent
CoordMode, Mouse, Screen
Hotkey, %esmb_TriggerKey%, esmb_TriggerKeyDown
HotKey, %esmb_TriggerKey% Up, esmb_TriggerKeyUp
esmb_KeyDown = n
SetTimer, esmb_CheckForScrollEventAndExecute, 10
return

esmb_TriggerKeyDown:
esmb_Moved = n
esmb_FirstIteration = y
esmb_KeyDown = y
MouseGetPos,, esmb_OldY
return

esmb_TriggerKeyUp:
esmb_KeyDown = n
;; Send a middle-click if we did not scroll
if esmb_Moved = n
    MouseClick, Middle
return

esmb_CheckForScrollEventAndExecute:
if esmb_KeyDown = n
    return

MouseGetPos,, esmb_NewY
esmb_Distance := esmb_NewY - esmb_OldY
if esmb_Distance
    esmb_Moved = y

;; Do not send clicks on the first iteration
if esmb_FirstIteration = y
    esmb_FirstIteration = n
else if esmb_Distance > %esmb_Threshold%
{
    esmb_OldY := esmb_OldY + esmb_Threshold
    MouseClick, WheelDown
}
else if esmb_Distance < -%esmb_Threshold%
{
    esmb_OldY := esmb_OldY - esmb_Threshold
    MouseClick, WheelUp
}

return
