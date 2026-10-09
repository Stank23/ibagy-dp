@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
if not exist "package.json" (
 echo ERRO: Coloque este arquivo na pasta ibagy-dp extraida do ZIP, ao lado do package.json.
 pause
 exit /b 1
)
where git >nul 2>nul
if errorlevel 1 (
 echo ERRO: Instale Git for Windows antes de continuar: https://git-scm.com/downloads/win
 pause
 exit /b 1
)
if not exist ".git" git init -b main
if errorlevel 1 goto falha
git remote get-url origin >nul 2>nul
if errorlevel 1 git remote add origin https://github.com/Stank22/ibagy-dp.git
if errorlevel 1 goto falha
git add .
if errorlevel 1 goto falha
git diff --cached --quiet
if not errorlevel 1 (
 echo Nenhuma alteracao para registrar.
) else (
 git commit -m "Importar codigo completo IBAGY DP v77"
 if errorlevel 1 goto falha
)
echo.
echo Enviando ao GitHub. Pode ser necessario autenticar no navegador.
git push -u origin main
if errorlevel 1 goto falha
echo.
echo SUCESSO: confira https://github.com/Stank22/ibagy-dp
pause
exit /b 0
:falha
echo.
echo FALHA: o envio nao foi concluido. Nao use push --force.
pause
exit /b 1
