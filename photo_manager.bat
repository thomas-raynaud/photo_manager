@echo off
setlocal enableextensions enabledelayedexpansion

set percentage=0
title Photo manager

REM INIT: Move everything in the "backup" folder
set actual_step=Moving to backup
echo Moving files to the backup folder...
if not exist backup md backup
for /d %%a IN ("%cd%\*") do (
    if NOT "%%~na" == "backup" (
        echo "%%a"| findstr /r ".*\\[0-9][0-9][0-9][0-9].[0-9][0-9]\" >nul 2>&1
        if !errorlevel! == 1 (
            move /y "%%~fa" backup >nul 2>&1
        )
    )
)
for %%a IN (*.*) do (
    if NOT "%%~na%%~xa" == "photo_manager.bat" (move /y "%%a" backup >nul 2>&1)
)

REM Count the number of files
set actual_step=Counting
echo.
echo Counting number of files...
set /a number_files=0
for /r backup\ %%a in (*.*) do (
    set good_extension=false
    call :CHECK_EXTENSION "%%~xa"
    if "!good_extension!" == "true" (
        set /a number_files=!number_files!+1
    )
)
echo There are !number_files! files in total.

if !number_files! equ 0 (
    echo.
    echo There are no photos to order.
    echo.
    pause
    exit
)

REM Generate the names of files + folders
set actual_step=Generating filenames
echo.
echo Generating filenames...
set /a i=0
for /r backup\ %%a in (*) do (
    set good_extension=false
    call :CHECK_EXTENSION "%%~xa"
    if "!good_extension!" == "true" (
        set files[!i!]=%%a

        set file_date=%%~ta
        set folder_name=!file_date:~6,4!.!file_date:~3,2!
        set file_name=!file_date:~0,2!-!file_date:~11,2!h!file_date:~14,2!m

        set folders[!i!]=!folder_name!
        set names[!i!]=!file_name!
        set extensions[!i!]=%%~xa

        set /a i=!i!+1
        
        set /a p=100*!i!/!number_files!
        call :NEW_STEP !p!
    )
)
if not !i! equ !number_files! echo Error: some files could not be processed.

REM Move renamed files to the folders
set actual_step=Moving files
echo.
echo.
echo Moving the sorted files...
set /a i=0
set percentage=0
set /a nb_elements=number_files-1
for /l %%x in (0, 1, !nb_elements!) do (
    set original_file="!files[%%x]!"
    set folder=!folders[%%x]!
    set name=!names[%%x]!
    set extension=!extensions[%%x]!
    call :MOVE_FILE
)
echo.
if not !i! equ !number_files! (
    echo Error: some files could not be moved.
) else (
    echo.
    echo Photos are ordered.
)
echo.
echo.

title Photo manager

pause


REM CHECK_EXTENSION: check the extension of the file
:CHECK_EXTENSION
if %1 == ".JPG" set good_extension=true& goto END_CHECK_EXTENSION
if %1 == ".jpg" set good_extension=true& goto END_CHECK_EXTENSION
if %1 == ".JPEG" set good_extension=true& goto END_CHECK_EXTENSION
if %1 == ".jpeg" set good_extension=true& goto END_CHECK_EXTENSION
if %1 == ".png" set good_extension=true& goto END_CHECK_EXTENSION
if %1 == ".mp4" set good_extension=true& goto END_CHECK_EXTENSION
if %1 == ".MP4" set good_extension=true& goto END_CHECK_EXTENSION
:END_CHECK_EXTENSION
exit /b

REM MOVE_FILE: move a file if it isn't a duplicate
:MOVE_FILE
set dest_file=!folder!\!name!!extension!
if exist !dest_file! (
    REM Compare the two files.
    echo N| comp !dest_file! !original_file! >nul 2>&1
    if not !errorlevel! == 0 (
        REM Ajouter un suffixe
        set /a suffix=1
        :check_dest_file
        set dest_file=!folder!\!name!_!suffix!!extension!
        if exist !dest_file! (
            echo N| comp !dest_file! !original_file! >nul 2>&1
            if not !errorlevel! == 0 (
                set /a suffix=!suffix!+1
                goto check_dest_file
            )
        ) else call :COPY_FILE
    )
) else call :COPY_FILE
set /a i=!i!+1
set /a p=100*!i!/!number_files!
call :NEW_STEP !p!
exit /b


REM COPY_FILE: copy file original_file to dest_file
:COPY_FILE
echo F| xcopy /I !original_file! !dest_file! >nul 2>&1
if not !errorlevel! == 0 (
    echo Error: file !original_file! could not be moved.
    set /a i=!i!-1
)
exit /b

REM NEW_STEP: update the progress bar
:NEW_STEP
set /a percentage_old_5=percentage/5
set percentage=%1%
set /a percentage_new_5=percentage/5
if not !percentage_old_5! equ !percentage_new_5! (
    echo|set /p=.
)
title PM - !actual_step! : !percentage!%%
exit /b


endlocal