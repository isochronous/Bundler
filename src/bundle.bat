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

echo Searching for bundle files under %CWD%

:: loop through all .bundle files off of our current directory
FOR /F "tokens=*" %%I in ('dir /b /s *.bundle') DO (

    SET PTH=%%~dpI

    FOR %%J in (%%~nI) DO (
        SET PTH=!PTH!%%~nJ
        SET EXT=%%~xJ
    )

    SET PTH=!PTH!.min!EXT!

    call "%VS100COMNTOOLS%..\IDE\tf" checkout !PTH!
)

:: Now go back through and do the same for the scripts directory
if %CWD%.==%contentDir%. (
    SET CWD=%scriptsDir%
    GOTO CheckoutLoopStart
)

:: change back to our bundler dir
cd %bundlerDir%.

:: and run bundler! YAYAYAYAYAYAY!
call .\node.exe bundler.js %contentDir% %scriptsDir%


set CWD=%contentDir%
set PARAMS=checkin /comment:"Bundler Minification" /noprompt /override:"Post-Build minification and combination step"

:CheckinLoopStart

cd %CWD%

:: loop through all .bundle files off of our current directory
FOR /F "tokens=*" %%I in ('dir /b /s *.bundle') DO (

    SET PTH=%%~dpI

    FOR %%J in (%%~nI) DO (
        SET PTH=!PTH!%%~nJ
        SET EXT=%%~xJ
    )

    SET PTH=!PTH!.min!EXT!

    call "%VS100COMNTOOLS%..\IDE\tf" %PARAMS% !PTH!
)

:: Now go back through and do the same for the scripts directory
if %CWD%.==%contentDir%. (
    SET CWD=%scriptsDir%
    GOTO CheckinLoopStart
)

echo Bundler script complete