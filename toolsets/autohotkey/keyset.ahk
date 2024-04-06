#Include ".env"

#SingleInstance force
Return

Exit:
  ExitApp()
Return

; Control + ESC to send backtick
^Esc::Send("{Raw}``")

; Capslock to Control
Capslock::Ctrl

; Right shift to Backspace
RShift::Backspace

; Toggle language
^Space::VK15
<+Space::VK15
Tab::Tab
Tab & Space::VK15

; Cursor controls
!h::Send("{LEFT}")
!j::Send("{DOWN}")
!k::Send("{UP}")
!l::Send("{RIGHT}")

!u::Send("{HOME}")
!i::Send("{END}")

^!h::Send("^{LEFT}")
^!l::Send("^{RIGHT}")

; Simulating extra buttons on mouse
#HotIf !WinActive("ahk_exe RainbowSix.exe", )
~LButton & RButton Up::Send("{XButton2}")
~RButton & LButton Up::Send("{XButton1}")

; ESC to english mode for VIM
$Esc::
{ ; V1toV2: Added bracket
    if(IME_CHECK("A"))
        Send("{VK15}")
    Send("{Escape}")
    return
} ; Added bracket before function

IME_CHECK(WinTitle) {
  hWnd := WinGetID(WinTitle)
  Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd),0x001,"") 
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

; Special characters
:*:wheart::♡
:*:bheart::♥
:*:wstar::☆
:*:bstar::★
:*C:ud`n::_
:*:.deg::°
:*:.dot::•
:*:mnote::♪♫
:*:krwon::₩
:*:ohm::Ω

; Arrows
:*:arrr::->
:*:arre::=>
:*:uarr::↑
:*:darr::↓
:*:larr::←
:*:rarr::→
:*:ularr::↖
:*:urarr::↗
:*:dlarr::↙
:*:drarr::↘
:*:barr::⟷

; Greek alphabets
:*:.alpha::α
:*:.beta::β
:*:.gamma::γ
:*:.delta::δ
:*:.epsilon::ε
:*:.zeta::ζ
:*:.eta::η
:*:.theta::θ
:*:.iota::ι
:*:.kappa::κ
:*:.lambda::λ
:*:.mu::μ
:*:.nu::ν
:*:.xi::ξ
:*:.omikron::ο
:*:.pi::π
:*:.rho::ρ
:*:.sigma::σ
:*:.tau::τ
:*:.upsilon::υ
:*:.phi::φ
:*:.chi::χ
:*:.psi::ψ
:*:.omega::ω

:*:.gALPHA::Α
:*:.gBETA::Β
:*:.gGAMMA::Γ
:*:.gDELTA::Δ
:*:.gEPSILON::Ε
:*:.gZETA::Ζ
:*:.gETA::Η
:*:.gTHETA::Θ
:*:.gIOTA::Ι
:*:.gKAPPA::Κ
:*:.gLAMBDA::Λ
:*:.gMU::Μ
:*:.gNU::Ν
:*:.gXI::Ξ
:*:.gOMIKRON::Ο
:*:.gPI::Π
:*:.gRHO::Ρ
:*:.gSIGMA::Σ
:*:.gTAU::Τ
:*:.gUPSILON::Υ
:*:.gPHI::Φ
:*:.gCHI::Χ
:*:.gPSI::Ψ
:*:.gOMEGA::Ω

; Aliases
:*R:em`n::mail@luftaquila.io

:*R:kk`n::
{
  pw := EnvGet("kakaoTalkPassword")
  Send("{Raw}" pw)
Return
}

:*R:svr`n::
{
  pw := EnvGet("serverPassword")
  Send("{Raw}" pw)
Return
}

:*R:lin`n::
{
  pw := EnvGet("linuxPassword")
  Send("{Raw}" pw)
Return
}
