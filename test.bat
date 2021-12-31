::File to test writing file, then extracting contents to utilize with if statements

@echo off
Setlocal EnableDelayedExpansion
set ping_iter=4
set numitersfound=0
Ping 192.168.1.199 -n %ping_iter% | find /C "TTL" > C:\temp\test_temp.txt
for /F %%A in (C:\temp\test_temp.txt) do set numitersfound=%%A
echo numitersfound = %numitersfound%
::Ping 192.168.1.199 -n 4 | find /C "TTL"
::Ping 192.168.1.199 -n 4 | findstr /r /c:"[0-9] *ms"
if %numitersfound% == %ping_iter% (
    echo SUCCESS: All %numitersfound%/%ping_iter% pings were successful
) else if %numitersfound% == 0 (
    echo FAILURE: %numitersfound%/%ping_iter% pings were successful
) else (
    echo Alert: %numitersfound%/%ping_iter% pings were successful
)
pause