; ESC to english mode for VIM
$Esc::
{ ; V1toV2: Added bracket
    if(IME_CHECK("A"))
        Send("{VK15}")
    Send("{Escape}")
    return
} ; Added bracket before function

IME_CHECK(WinTitle) {
  try
  {
    hWnd := WinGetID(WinTitle)
    Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd),0x001,"")
  }
  catch TargetError
  {
    Return False
  }
}

Send_ImeControl(DefaultIMEWnd, wParam, lParam) {
  DetectSave := A_DetectHiddenWindows
  DetectHiddenWindows(true)
   ErrorLevel := SendMessage(0x283, wParam, lParam, , "ahk_id " DefaultIMEWnd)
  if (DetectSave != A_DetectHiddenWindows)
      DetectHiddenWindows(DetectSave)
  return ErrorLevel
}

ImmGetDefaultIMEWnd(hWnd) {
  return DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
}