@echo off
chcp 65001 >nul
cd /d "C:\Users\Administrator\Documents\kenneyDungeon"

:: 自动检测 git 路径
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
"%GIT%" checkout main
"%GIT%" add .
"%GIT%" commit -m "backup: %date% %time%"

:: 尝试 push main
"%GIT%" push origin main >nul 2>&1

:: 检查 push 结果
if %errorlevel% == 0 (
    echo Push main OK
    exit /b 0
)

:: push 失败，创建新分支
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd-HHmmss'"`) do set "BRANCH=main-%%a"

"%GIT%" checkout -b %BRANCH%
"%GIT%" push origin %BRANCH%

echo Push main failed, saved to branch: %BRANCH%

:: 清理旧分支：远程+本地，各保留最近3个
echo Cleaning old branches...
powershell -NoProfile -Command "$remote=git branch -r --list 'origin/main-*' | ForEach-Object { $_.Trim().Replace('origin/','') }; $remoteDelete=$remote | Select-Object -Skip 3; foreach ($b in $remoteDelete) { git push origin --delete $b }; git checkout main 2>$null; $local=git branch --list 'main-*' | ForEach-Object { $_.Trim().Replace('* ','').Replace(' ','') }; $localDelete=$local | Select-Object -Skip 3; foreach ($b in $localDelete) { git branch -D $b 2>$null }"

"%GIT%" fetch --prune 2>nul
echo Done
