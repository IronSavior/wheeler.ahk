
#Persistent
#NoEnv
;;#NoTrayIcon

CoordMode, Mouse, Screen
SendMode, Input
SetMouseDelay, -1
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

;; Higher numbers mean less sensitivity
;; How far you need to move the mouse to trigger a scroll tick
esmb_ThresholdX := 3
esmb_ThresholdY := 5

;; How far away from initial click pos you need to move the mouse to start scroll
;; If you move less than this and release, it will right click
;; If set to -1, will only right click if you release before moving the mouse
esmb_InitialThreshold := 10

SetTimer, esmb_CheckForScrollEventAndExecute, 7
SetTimer, esmb_CheckForScrollEventAndExecute, Off

return

ScrollLock::Suspend

RButton::
  esmb_KeyDown := true
  esmb_Moved := false
  MouseGetPos, esmb_OldX, esmb_OldY
  esmb_AccumulatedDistanceX := 0
  esmb_AccumulatedDistanceY := 0
  SetTimer, esmb_CheckForScrollEventAndExecute, On
return

RButton Up::
  esmb_KeyDown := false
  SetTimer, esmb_CheckForScrollEventAndExecute, Off
  if (esmb_Moved == false) {
    Send, {RButton}
  }
return

esmb_CheckForScrollEventAndExecute:
  if (esmb_KeyDown == false) {
    SetTimer, esmb_CheckForScrollEventAndExecute, Off
    return
  }
  
  MouseGetPos, esmb_NewX, esmb_NewY

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

  esmb_AccumulatedDistanceX -= (esmb_TicksX * esmb_ThresholdX)
  esmb_AccumulatedDistanceY -= (esmb_TicksY * esmb_ThresholdY)

  if (esmb_TicksX < 0) {
    esmb_TicksX := Abs(esmb_TicksX)
    Click, WheelLeft, %esmb_TicksX%
  } else {
    Click, WheelRight, %esmb_TicksX%
  }
  
  if (esmb_TicksY < 0) {
    esmb_TicksY := Abs(esmb_TicksY)
    Click, WheelUp, %esmb_TicksY%
  } else {
    Click, WheelDown, %esmb_TicksY%
  }
return
