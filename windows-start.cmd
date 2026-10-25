@echo off
setlocal
cd /d "%~dp0"
if not exist "%~dp0adb.exe" (
  echo Copy this file into the extracted official scrcpy Windows folder first.
  pause
  exit /b 1
)
if not exist "%~dp0scrcpy.exe" (
  echo scrcpy.exe is missing from this folder.
  pause
  exit /b 1
)
"%~dp0adb.exe" start-server
if errorlevel 1 (
  pause
  exit /b 1
)
"%~dp0adb.exe" devices -l
"%~dp0scrcpy.exe" --select-usb --no-audio --max-size=1280 --max-fps=30 --video-bit-rate=4M --window-title="Redmi Note 5" --pause-on-exit=if-error
