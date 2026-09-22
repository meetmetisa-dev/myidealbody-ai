@echo off
where gradle >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  gradle %*
  exit /b %ERRORLEVEL%
)
echo Install Gradle 8.13 or regenerate the standard wrapper with: flutter create . --platforms=android
exit /b 1

