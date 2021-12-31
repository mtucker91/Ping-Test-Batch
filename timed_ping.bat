::Title: INFINITT Ping Test
::Author: Matthew Tucker
::Date Created: 9/24/2021
::Date Edit: 12/23/2021
::Description: Batch file created to both ping a location and log the success or failure of that ping throughout the day.
::             Utilizes writing a temporary file in the same directory as the logs for logging purposes

@echo off
Setlocal EnableDelayedExpansion
Call :time_update
::*************************************************************
:: *************** EDIT Variables Here ************************
::*************************************************************
:: location you are looking to ping
set networklocation=192.169.1.199
:: Log file location you want the log to end up in
:: IMPORTANT: Keep a backslash (\) at the end of the fileloc variable
set fileloc=D:\INFINITT\Logs\LDAP_connect_test\
::filename before the date
set filenmepre=connection_test_
::file extension
set filenmepost=.txt
::%logdatestamp%
:: Seconds to wait between pings
set ping_seconds=30
:: number of iterations you want the ping to go before its confirmed either successful or not
set ping_iter=10
:: number of seconds you want a single ping iteration to last before it decides it failed.
:: Note: Math will be done later to turn to milleseconds so just put the number of seconds here.
set ping_iter_sec=4
:: set the number of days old a log file can be before its deleted
set logfileage=30
:: ***********************************************************
:: *************** End Variable Edit *************************
:: ***********************************************************
set numitersfound=0
set /a ping_iter_mill=%ping_iter_sec%*1000
set filenme=%filenmepre%%logdatestamp%%filenmepost%
set filefullpath=%fileloc%%filenme%
::echo %ping_iter_mill%
echo see all this program is doing in the log file at %filefullpath%
echo -------------------------------------------------------------------- >> %filefullpath%
echo -------------------------- Started Program ------------------------- >> %filefullpath%
echo -------------------------------------------------------------------- >> %filefullpath%
echo DateTime Started: %logdatestamp% - %_hour%:%_minute%:%_second% >> %filefullpath%
Call :deloldfiles
echo Confirm milleseconds calculated for single ping iteration is %ping_iter_mill% >> %filefullpath%
:rerun
Call :time_update
set filenme=%filenmepre%%logdatestamp%%filenmepost%
set filefullpath=%fileloc%%filenme%
echo %_hour%:%_minute%:%_second% -  I: Starting Ping >> %filefullpath%
Ping %networklocation% -n %ping_iter% -w %ping_iter_sec% | find /C "TTL" > %fileloc%test_temp.txt
for /F %%A in (%fileloc%test_temp.txt) do set numitersfound=%%A
Call :time_update
if %numitersfound% == %ping_iter% (
    echo %_hour%:%_minute%:%_second% -  I: SUCCESS: All %numitersfound%/%ping_iter% pings were successful >> %filefullpath%
) else if %numitersfound% == 0 (
    echo %_hour%:%_minute%:%_second% -  E: FAILED: %numitersfound%/%ping_iter% pings were successful >> %filefullpath%
) else (
    echo %_hour%:%_minute%:%_second% -  A: WARNING: %numitersfound%/%ping_iter% pings were successful >> %filefullpath%
)
echo %_hour%:%_minute%:%_second% -  I: Waiting %ping_seconds% seconds >> %filefullpath%
Timeout /t %ping_seconds% > nul
goto rerun

:time_update
:: Check WMIC is available
WMIC.EXE Alias /? >NUL 2>&1 || GOTO s_error

:: Use WMIC to retrieve date and time
FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
   IF "%%~L"=="" goto s_done
      Set _yyyy=%%L
      Set _mm=00%%J
      Set _dd=00%%G
      Set _hour=00%%H
      SET _minute=00%%I
      SET _second=00%%K
)
:s_done

:: Pad digits with leading zeros
      Set _mm=%_mm:~-2%
      Set _dd=%_dd:~-2%
      Set _hour=%_hour:~-2%
      Set _minute=%_minute:~-2%
      Set _second=%_second:~-2%

::Set logtimestamp=%_yyyy%-%_mm%-%_dd%_%_hour%_%_minute%_%_second%
Set logdatestamp=%_yyyy%-%_mm%-%_dd%
goto make_dump


:s_error
echo WMIC is not available, using default log filename
::Set logtimestamp=_
Set logdatestamp=_

:make_dump
::set FILENAME=database_dump_%logtimestamp%.sql
EXIT /B 0
:: End of Time Update function

:deloldfiles
forfiles -p %fileloc% -s -m *.* -d %logfileage% -c "cmd /c del @path"
echo 'Delete Files Older Than %logfileage%' function ran at this time. >> %filefullpath%
EXIT /B 0