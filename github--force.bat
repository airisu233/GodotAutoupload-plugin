@echo off
chcp 65001 >nul
cd /d "C:\Users\Administrator\Documents\kenneyDungeon"
:: :: 自动检测 git 路径自动检测 git 路径
if exist "C:\Program Files\Git\bin\git.exe" (
    set "GIT=C:\Program Files\Git\bin\git.exe"
) else if exist "C:\Program Files\Git\cmd\git.exe" (
    set "GIT=C:\Program Files\Git\cmd\git.exe"
) else if exist "C:\Program Files (x86)\Git\bin\git.exe" (
    set "GIT=C:\Program Files (x86)\Git\bin\git.exe"
) else (
    echo Git not found!
    exit /b 1
)
"%GIT%" init 2>nul
"%GIT%" remote add origin https://github.com/airisu233/kenneyDungeon 2>nul
"%GIT%" branch -m main 2>nul
"%GIT%" add .
"%GIT%" commit -m "backup: %date% %time%"
"%GIT%" push origin main --force