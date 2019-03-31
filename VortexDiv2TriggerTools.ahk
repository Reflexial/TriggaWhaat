;#####################
;#=====Commands====#
;#####################
SetWorkingDir %A_ScriptDir%
#NoEnv
#InstallKeybdHook
#InstallMouseHook
#KeyHistory 0
#UseHook
#MaxThreadsPerHotkey 1
#MaxThreads 30
#MaxThreadsBuffer on
SendMode Input
ListLines, Off
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High
SendMode Input
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

;#####################
;#====Initialization====#
;#####################
global _enabled := 0
global _autofire := 0
global _downVal = 2
global _rightVal = 0
global _rampdown = 1
global _shotdelay=0
global _readytofire = 1
global _timerRunning = 0
global crosshairX =
global crosshairY =

;####################
;#=====Hotkeys=====#
;####################
~F3:: ; Turn script on/off
_enabled := ! _enabled
_autofire = 0
ShowToolTip("Script Enabled= "_enabled)
return

~F4:: ;Change triggerbot to singleshot OR enable autofire if you also turn up duration with o / ctrl-o
_autofire := ! _autofire
ShowToolTip("Autofire= "_autofire)
return

~NumpadAdd:: ; Adds compensation.
_downVal := _downVal + 1
ShowToolTip("Downward compensation= " . _downVal)
return

~NumpadSub:: ; Substracts compensation.
if _downVal > 0
{
	_downVal := _downVal - 1
	ShowToolTip("Downward compensation= " . _downVal)
}
return

~^NumpadAdd:: ; Adds right adjust
_rightVal := _rightVal + 1
ShowToolTip("Right(+)/Left(-)= " . _rightVal)
return

~^NumpadSub:: ; Adds left adjust
_rightVal := _rightVal - 1
ShowToolTip("Right(+)/Left(-)= " . _rightVal)
return

~o:: ; Single shot timer up (zero is always fire)
_shotdelay := _shotdelay + 25
ShowToolTip("Single Shot Delay up= " _shotdelay)
Return

~^o:: ; Single shot timer down (zero is always fire)
if _shotdelay > 0
{
	_shotdelay := _shotdelay - 25
	ShowToolTip("Single Shot Delay down= " _shotdelay)
}
return

~LButton::lessrecoil()
~XButton1::lessrecoil_triggerbot()  ;"XButton1" is mouse 4.  If you change this, make sure you replace every XButton1 in the script.

;####################
;======Functions======
;####################
lessrecoil()
{
	While GetKeyState("LButton")
	{
		sleep 10
		if _enabled
		{
			ApplyReduction()
		}
		sleep 10
	}
	return
}
;==================
lessrecoil_triggerbot()
{
	While GetKeyState("XButton1")
	{
		{
			if _enabled
			{
				if CrosshairCheck()
				{
					TryToFire()
					ApplyReduction()
				}
			}
		}
	}
	Send, {j up}
	sleep 10
	_timerRunning = 0
	_readytofire = 1
	return
}
;==================
ApplyReduction()
{
	DllCall("mouse_event",uint,1,int,_rightVal,int,_downVal,uint,0,int,0)
	Sleep 40
	DllCall("mouse_event",uint,1,int,_rightVal,int,_downVal,uint,0,int,0)
	Sleep 60
	return
}
;==================
CrosshairCheck() ; returns as "true" if either autofire, or crosshair is found.
{
	if _autofire = 1
		return true
	else
	{
		crosshairX =
		MouseGetPos, mX, mY
		x1 :=(mX-35)
		x2 :=(mX+35)
		y1:=(mY-15)
		y2 :=(mY+15)
		PixelSearch, crosshairX, crosshairY, x1, y1, x2, y2, 0x3636F4, 0, Fast
	}
	if crosshairX > 0 ;this will be set to either the x coord of the red found, or "1" if the triggerbot is turned off.
	{
		return true
	}
	else{
		Send, {j up}
		sleep 10
		return false
	}
}
;==================
TryToFire()
{
	if _shotdelay = 0
	{
		Send, {j down}
		return
	}
	else
	{
		if _readytofire = 1
		{
			Send, {j up}
			sleep 15
			Send, {j down}
			_readytofire = 0
			ShotTimer()
			return
		}
		else
		{
			ShotTimer()
			return
			
		}
		ShotTimer()
		if _shotdelay > 0
		{
			Send, {j up}
			ShotTimer()
			Sleep 20
		}
		else
		{
			_readytofire = 1
		}
	}
	ApplyReduction()
}
;==================
ShotTimer()
{
	
	if _timerRunning = 0
	{
		SetTimer, ShotWait, %_shotdelay%
		_timerRunning = 1
		return
	}
	else
		return
	ShotWait:
	SetTimer, ShotWait, Off
	_timerRunning = 0
	_readytofire = 1
	return
}
;==================
ShowToolTip(Text)
{
	ToolTip, %Text%
	SetTimer, RemoveToolTip, 3000
	return
	RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
	return
}
;==================