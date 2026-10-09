@echo off
setlocal
cd /d "%~dp0"
for /f "delims=" %%B in ('git branch --show-current') do set "IBAGY_TEST_BRANCH=%%B"
if not "%IBAGY_TEST_BRANCH%"=="migracao-vercel-supabase" (
 echo Abra a branch migracao-vercel-supabase antes de executar. Nenhuma branch foi alterada.
 pause
 exit /b 1
)
where node >nul 2>nul
if errorlevel 1 (
 echo Instale Node.js 22 ou superior e abra novamente o terminal.
 pause
 exit /b 1
)
call npm --prefix tools\ui-tests install --no-audit --no-fund --package-lock=false
if errorlevel 1 goto :failed
pushd tools\ui-tests
call npx playwright install chromium
if errorlevel 1 goto :failed
call npm test -- %*
set "IBAGY_TEST_EXIT=%ERRORLEVEL%"
popd
pause
exit /b %IBAGY_TEST_EXIT%
:failed
echo Falha na instalacao. Copie a mensagem de erro, sem credenciais.
pause
exit /b 1
