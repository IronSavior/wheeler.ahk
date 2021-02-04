;; Contributors:
;; * Erik Elmore <erik@elmore.io>
;; * Jakob Kofod Beyer <jkb@hvalfisk.dk>
;; AutoHotkey Version 1.1.33

#Persistent
#NoEnv
CoordMode, Mouse, Screen

;; Hold this button to scroll
ActivateKey := "XButton1"

;; If the ActivateKey is pressed and released without moving, send this keypress instead
NonScrollAction := "MButton"

;; How far away from initial click pos you need to move the mouse to start scroll
;; If you move less than this and release, it will send the NonScrollAction instead
xActivateThreshold := 10
yActivateThreshold := 8

;; Higher numbers mean less sensitivity
;; How far you need to move the mouse to trigger a scroll tick, once scrolling is activated
xScrollSensitivity := 10
yScrollSensitivity := 8

;; Minimum response time of the loop
LoopInterval := 7

Hotkey, %ActivateKey%, KeyDown
Hotkey, %ActivateKey% Up, KeyUp

return

ScrollLock::Suspend

KeyDown:
  KeyDown := true
  ScrollMode := ""
  MouseGetPos, xLast, yLast
  xDistance := 0
  yDistance := 0
  SetTimer, Scroll, %LoopInterval%
return

KeyUp:
  KeyDown := false
  SetTimer, Scroll, Off
  if (ScrollMode == "") {
    SendInput, {%NonScrollAction%}
  }
return

Scroll:
  if (KeyDown == false) {
    SetTimer, Scroll, Off
    return
  }

  MouseGetPos, xNow, yNow

  xDistance += (xNow - xLast)
  yDistance += (yNow - yLast)

  xLast := xNow
  yLast := yNow

  if (ScrollMode == "") {
    switch
    {
    case Abs(yDistance) > yActivateThreshold:
      ScrollMode := "Y"
    case Abs(xDistance) > xActivateThreshold:
      ScrollMode := "X"
     default:
      return
    }
  }

  Clicks := 0
  switch ScrollMode {
  case "Y":
    Clicks := (yDistance // yScrollSensitivity)
    yDistance -= (Clicks * yScrollSensitivity)
    dir := Clicks < 0 ? "WheelUp" : "WheelDown"
  case "X":
    Clicks := (xDistance // xScrollSensitivity)
    xDistance -= (Clicks * xScrollSensitivity)
    dir := Clicks < 0 ? "WheelLeft" : "WheelRight"
  }

  if (Clicks != 0) {
    Click, %dir%, Abs(Clicks)
  }
return
