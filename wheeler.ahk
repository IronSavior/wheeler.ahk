
#Persistent
#NoEnv
SendMode, Input
SetKeyDelay, 0
Process, Priority,, H 
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
;;#NoTrayIcon

;; Higher numbers mean less sensitivity
;; How far you need to move the mouse to trigger a scroll tick
esmb_ThresholdX := 2
esmb_ThresholdY := 6

;; How far away from initial click pos you need to move the mouse to start scroll
;; If you away move less than this and release, it will right click
;; If set to -1, will only right click if you release before moving the mouse
esmb_InitialThreshold := 10

SetTimer, esmb_CheckForScrollEventAndExecute, 10 ;; change number for how often it updates
SetTimer, esmb_CheckForScrollEventAndExecute, Off

;; Delay before starting the timer after button has been clicked
;; This is to fix a bug where the "RButton Up" hotkey is not being triggered if you do ButtonDown-Move-ButtonUp swoop very fast
;; It also allows you to right click while moving your mouse a bit too fast
;; This makes it feel less responsive, but it is very preferable to the bug
esmb_StartTimerDelay := -100

return

*RButton::
  esmb_KeyDown := true
  esmb_Moved := false
  esmb_FirstIteration := true
  MouseGetPos, esmb_OldX, esmb_OldY
  esmb_AccumulatedDistanceX := 0
  esmb_AccumulatedDistanceY := 0
  SetTimer, esmb_StartTimer, % esmb_StartTimerDelay ;; starting timer after delay because "RButton Up" might not be triggered otherwise
return

*RButton Up::
  esmb_KeyDown := false
  Gosub, esmb_StopTimers
  if (esmb_Moved == false) {
    Send, {Blind}{RButton}
  }
  esmb_FirstIteration := true
  esmb_Moved := false
return

esmb_StartTimer:
  if (esmb_KeyDown == true) {
    SetTimer, esmb_CheckForScrollEventAndExecute, On
  }
return

esmb_StopTimers:
  SetTimer, esmb_CheckForScrollEventAndExecute, Off
  SetTimer, esmb_StartTimer, Off
return

esmb_CheckForScrollEventAndExecute:
  if (esmb_KeyDown == false) {
    Gosub, esmb_StopTimers
    return
  }

  MouseGetPos, esmb_NewX, esmb_NewY
  
  if (esmb_NewX == esmb_OldX && esmb_NewY == esmb_OldY) {
    return
  }
  
  esmb_DistanceX := (esmb_NewX - esmb_OldX)
  esmb_DistanceY := (esmb_NewY - esmb_OldY)
  
  esmb_OldX := esmb_NewX
  esmb_OldY := esmb_NewY

  esmb_AccumulatedDistanceX += esmb_DistanceX
  esmb_AccumulatedDistanceY += esmb_DistanceY
  
  ;; check if mouse moved far enough from initial point
  if (esmb_Moved == false) {
    if ((Abs(esmb_AccumulatedDistanceX) > esmb_InitialThreshold) || (Abs(esmb_AccumulatedDistanceY) > esmb_InitialThreshold)) {
      esmb_Moved := true
    } else {
      return
    }
  }

  esmb_TicksX := (esmb_AccumulatedDistanceX // esmb_ThresholdX)
  esmb_TicksY := (esmb_AccumulatedDistanceY // esmb_ThresholdY)
  
  esmb_AccumulatedDistanceX := (esmb_AccumulatedDistanceX - (esmb_TicksX * esmb_ThresholdX))
  esmb_AccumulatedDistanceY := (esmb_AccumulatedDistanceY - (esmb_TicksY * esmb_ThresholdY))
  
  esmb_WheelDirectionX := "WheelRight"
  esmb_WheelDirectionY := "WheelDown"
  
  
  if (esmb_TicksX < 0) {
    esmb_WheelDirectionX := "WheelLeft"
    esmb_TicksX := (-1 * esmb_TicksX)
  }
  if (esmb_TicksY < 0) {
    esmb_WheelDirectionY := "WheelUp"
    esmb_TicksY := (-1 * esmb_TicksY)
  }
  ;; Do not send clicks on the first iteration
  if (esmb_FirstIteration = true) {
    esmb_FirstIteration := false
  } else {
    Loop % esmb_TicksX {
      MouseClick, %esmb_WheelDirectionX%
    }
    Loop % esmb_TicksY {
      MouseClick, %esmb_WheelDirectionY%
    }
  }
return

ScrollLock::Suspend
