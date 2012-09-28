@echo off

:: Enables settings & using variables inside FOR loops
setlocal ENABLEDELAYEDEXPANSION

:: Assign our parameters to variables
set bundlerDir=%~dp0
set contentDir=%1
set scriptsDir=%2
set CWD=%contentDir%

:: Put a nice little anchor here we can jump back to for multiple loops
:CheckoutLoopStart

:: Change to our /Content directory
cd %CWD%.

:: loop through all .bundle files off of our current directory
FOR /F "tokens=*" %%I in ('dir /b /s *.bundle') DO (

    REM echo "looking at "%%I

    SET PTH=%%~dpI

    REM echo "got path = "!PTH!

    FOR %%J in (%%~nI) DO (
        REM echo "got filename = "%%~nJ
        SET PTH=!PTH!%%~nJ
        SET EXT=%%~xJ
        REM echo "got extension = "!EXT!
    )

    SET PTH=!PTH!.min!EXT!
    echo "Checking out "!PTH!

    call "%VS100COMNTOOLS%..\IDE\tf" checkout !PTH!
)

:: Now go back through and do the same for the scripts directory
if %CWD%.==%contentDir%. (
    SET CWD=%scriptsDir%
    GOTO CheckoutLoopStart
)

:: change back to our bundler dir
cd

:: and run bundler! YAYAYAYAYAYAY!
start "bundler" /D%bundlerDir% /B /wait node.exe bundler.js %contentDir% %scriptsDir%

set CWD=%contentDir%
set PARAMS=checkin /comment:"Bundler Minification" /noprompt /override:"Post-Build minification and combination step"

:CheckinLoopStart

cd %CWD%

:: loop through all .bundle files off of our current directory
FOR /F "tokens=*" %%I in ('dir /b /s *.bundle') DO (

    REM echo "looking at "%%I

    SET PTH=%%~dpI

    REM echo "got path = "!PTH!

    FOR %%J in (%%~nI) DO (
        REM echo "got filename = "%%~nJ
        SET PTH=!PTH!%%~nJ
        SET EXT=%%~xJ
        REM echo "got extension = "!EXT!
    )

    SET PTH=!PTH!.min!EXT!
    echo "Checking in "!PTH!

    call "%VS100COMNTOOLS%..\IDE\tf" %PARAMS% !PTH!
)

:: Now go back through and do the same for the scripts directory
if %CWD%.==%contentDir%. (
    SET CWD=%scriptsDir%
    GOTO CheckinLoopStart
)

echo "All Done!"