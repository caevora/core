@echo off
cd /d "C:\Users\Owner\Documents\Mudlet-Git"
set log="C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"

echo Copying files... >> %log%
xcopy /E /Y /I "C:\Users\Owner\.config\mudlet\profiles\Caevora\Achaean System" "C:\Users\Owner\Documents\Mudlet-Git\Achaean System" >> %log% 2>&1

if exist "C:\Users\Owner\.config\mudlet\profiles\Caevora\Achaean System.xml" (
  copy /Y "C:\Users\Owner\.config\mudlet\profiles\Caevora\Achaean System.xml" "C:\Users\Owner\Documents\Mudlet-Git\Achaean System.xml" >> %log% 2>&1
) else (
  echo Warning: Achaean System.xml not found >> %log%
)

if not exist .git (
  echo Initializing git repo... >> %log%
  "C:\Program Files\Git\mingw64\bin\git.exe" init >> %log% 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" add -A >> %log% 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" commit -m "Initial commit" >> %log% 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" branch -M main >> %log% 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" remote add origin https://github.com/caevora/core.git >> %log% 2>&1
)

echo Committing changes... >> %log%
"C:\Program Files\Git\mingw64\bin\git.exe" add -A >> %log% 2>&1
"C:\Program Files\Git\mingw64\bin\git.exe" commit -am "🧩 Auto-backup: Profile snapshot on logout" >> %log% 2>&1 || echo No changes to commit >> %log%

echo Stashing before pull... >> %log%
"C:\Program Files\Git\mingw64\bin\git.exe" stash push -m "Auto-stash before pull" >> %log% 2>&1

echo Pulling from origin... >> %log%
"C:\Program Files\Git\mingw64\bin\git.exe" pull --rebase origin main >> %log% 2>&1 || echo Pull failed >> %log%

echo Applying stash... >> %log%
"C:\Program Files\Git\mingw64\bin\git.exe" stash pop >> %log% 2>&1 || echo No stash to apply >> %log%

echo Pushing to origin... >> %log%
"C:\Program Files\Git\mingw64\bin\git.exe" push origin main >> %log% 2>&1

echo Done. >> %log%
timeout /t 5
