@echo off
cd /d "C:\Users\Owner\Documents\Mudlet-Git"
echo Copying files... >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"
xcopy /E /Y /I "C:\Users\Owner\.config\mudlet\profiles\Caevora\Achaean System" "C:\Users\Owner\Documents\Mudlet-Git\Achaean System" >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
copy /Y "C:\Users\Owner\.config\mudlet\profiles\Caevora\Achaean System.xml" "C:\Users\Owner\Documents\Mudlet-Git\Achaean System.xml" >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1

if not exist .git (
  echo Initializing git repo... >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"
  "C:\Program Files\Git\mingw64\bin\git.exe" init >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" add -A >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" commit -m "Initial commit" >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" branch -M main >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
  "C:\Program Files\Git\mingw64\bin\git.exe" remote add origin https://github.com/caevora/core.git >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
)

echo Committing changes... >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"
"C:\Program Files\Git\mingw64\bin\git.exe" add -A >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1
"C:\Program Files\Git\mingw64\bin\git.exe" commit -am "🧩 Auto-backup: Profile snapshot on logout" >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1

echo Pulling from origin... >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"
"C:\Program Files\Git\mingw64\bin\git.exe" pull --rebase origin main >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1

echo Pushing to origin... >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"
"C:\Program Files\Git\mingw64\bin\git.exe" push origin main >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt" 2>&1

echo Done. >> "C:\Users\Owner\Documents\Mudlet-Git\gitlog.txt"
timeout /t 5
