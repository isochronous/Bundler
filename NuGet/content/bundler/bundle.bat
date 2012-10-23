@echo off

:: Enables settings & using variables inside FOR loops
setlocal ENABLEDELAYEDEXPANSION

:: Assign our parameters to variables
set contentDir=%1
set scriptsDir=%2

:: If there is ANY third paramter, will not check files back in
IF NOT [%3]==[] (
    SET nocheckinflag=%3
)

:: Start with our content directory
set CWD=%contentDir%

:: Put a nice little anchor here we can jump back to for multiple loops
:FileLoopStart

:: Change to our /Content directory
pushd %CWD%.

echo Searching for bundle files under %CWD%

:: loop through all .bundle files off of our current directory
FOR /F "tokens=*" %%I in ('dir /b /s *.bundle') DO (

    REM %%~dpI expands to Drive letter + directory path
    SET PTH=%%~dpI

    REM %%~nI expands to fileName without extension (strips .bundle off the filename)
    FOR %%J in (%%~nI) DO (
        REM %%~nI strips the *next* extension from the end (.js or .css)
        SET PTH=!PTH!%%~nJ
        REM %%~xJ gives us just the extension - save for later so we can re-add it
        SET EXT=%%~xJ
    )

    REM Generates the .min. filename from the segments we've collected
    SET MINPTH=!PTH!.min!EXT!
    REM Generate the non-.min. filename
    SET PTH=!PTH!!EXT!

    REM Add this file to the list of files to checkout
    IF NOT DEFINED devfilelist (
        IF EXIST "!PTH!" (
            SET devfilelist="!PTH!"
        )
        IF EXIST "!MINPTH!" (
            SET minfilelist="!MINPTH!"
        )
    ) ELSE (
        IF EXIST "!PTH!" (
            SET devfilelist=!devfilelist! "!PTH!"
        )
        IF EXIST "!MINPTH!" (
            SET minfilelist=!minfilelist! "!MINPTH!"
        )
    )
)
:: concatenate our two lists
IF DEFINED allfilelist (
    SET allfilelist=%allfilelist% %devfilelist% %minfilelist%
) ELSE (
    SET allfilelist=%devfilelist% %minfilelist%
)

:: change back to our bundler dir
popd

:: Now go back through and do the same for the scripts directory
if %CWD%.==%contentDir%. (
    SET CWD=%scriptsDir%
    GOTO FileLoopStart
)

:: Trim any extra whitespace from the beginning of the file list
FOR /f "tokens=* delims= " %%a IN ("%allfilelist%") DO SET allfilelist=%%a

:: Now we've got all the files we need to check out, check them out
::echo checkout command is "%VS100COMNTOOLS%..\IDE\tf" checkout %allfilelist%
call "%VS100COMNTOOLS%..\IDE\tf" checkout %allfilelist%

:: and run bundler! YAYAYAYAYAYAY!
call .\node.exe bundler.js %contentDir% %scriptsDir%

IF DEFINED nocheckinflag (
    goto End
)

SET PARAMS=checkin /comment:"Bundler Minification" /noprompt /override:"Post-Build minification and combination step" %allfilelist%

:CheckinLoopStart
::echo checkin command is "%VS100COMNTOOLS%..\IDE\tf" %PARAMS%
call "%VS100COMNTOOLS%..\IDE\tf" %PARAMS%

:End

echo Bundler script complete