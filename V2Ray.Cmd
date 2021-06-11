@Echo off
SetLocal EnableDelayedExpansion
Title %~n0
CD /D "%~dp0"

If /I "%1"=="Start" (
    Start /Min Cmd /C "%~dpnx0"
    GoTo :EOF
) Else If /I "%1"=="Install" (
    Call :Install
    Pause
    GoTo :EOF
) Else If /I "%1"=="Remove" (
    TaskKill /F /IM v2ray*
    Call :DisableProxy
    Pause
    GoTo :EOF
)

Set localport=1080
Set direct=*.baidu.com;*.qq.com

Call :EnableProxy
Echo 启动 %~n0
v2ray.exe -c config.json
Set ExitCode=%ErrorLevel%
Call :DisableProxy
If Not "%ExitCode%"=="0" (
    Echo Exit Code: %ExitCode%
)
Pause
Exit %ExitCode%

:EnableProxy
Echo 设置代理
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "%direct%;<local>" /f >NUL
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "localhost:%localport%" /f >NUL
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >NUL
REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >NUL 2>NUL
Goto :EOF

:DisableProxy
Echo 取消代理
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >NUL
Rem REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "" /f >NUL
Rem REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f >NUL
Goto :EOF

:Install
Echo 开机启动
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v %~n0 /t REG_SZ /d "\"%~dpnx0\" Start" /f >NUL
Goto :EOF