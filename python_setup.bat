@echo off
set LOGFILE=setup_log.txt

echo ============================== >> %LOGFILE%
echo Setup started at %date% %time% >> %LOGFILE%
echo ============================== >> %LOGFILE%

:: ---- Check if VS Code is installed ----
echo Checking for Visual Studio Code...
where code >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo VS Code not found. Downloading and installing... >> %LOGFILE%
    powershell -Command "Invoke-WebRequest -Uri https://update.code.visualstudio.com/latest/win32-x64-user/stable -OutFile vscode_installer.exe"
    start /wait vscode_installer.exe /VERYSILENT
    del vscode_installer.exe
    echo VS Code installed successfully >> %LOGFILE%
) else (
    echo VS Code is already installed >> %LOGFILE%
)

:: ---- Check if Python is installed ----
echo Checking for Python...
where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Python not found. Downloading and installing... >> %LOGFILE%
    powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.12.6/python-3.12.6-amd64.exe -OutFile python_installer.exe"
    start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1
    del python_installer.exe
    echo Python installed successfully >> %LOGFILE%
) else (
    echo Python is already installed >> %LOGFILE%
)

:: ---- Check if pip is installed ----
echo Checking for pip...
python -m pip --version >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Pip not found. Installing... >> %LOGFILE%
    python -m ensurepip --upgrade >> %LOGFILE% 2>&1
) else (
    echo Pip is already installed >> %LOGFILE%
)

:: ---- Upgrade pip ----
echo Upgrading pip... >> %LOGFILE%
python -m pip install --upgrade pip >> %LOGFILE% 2>&1

:: ---- Install Python libraries from requirements.txt ----
if exist requirements.txt (
    echo Installing Python libraries... >> %LOGFILE%
    pip install -r requirements.txt >> %LOGFILE% 2>&1
) else (
    echo requirements.txt not found, skipping library installation >> %LOGFILE%
)

:: ---- Install VS Code extensions ----
echo Installing VS Code extensions... >> %LOGFILE%
(
    echo ms-python.python
    echo ms-python.vscode-pylance
    echo ms-toolsai.jupyter
    echo ms-toolsai.jupyter-renderers
    echo ms-toolsai.jupyter-keymap
    echo visualstudioexptteam.vscodeintellicode
    echo esbenp.prettier-vscode
    echo oderwat.indent-rainbow
    echo christian-kohler.path-intellisense
    echo aaron-bond.better-comments
    echo GitHub.copilot
) > extensions.txt




echo ================= DEBUG INFO =================
echo Current directory: %cd%
echo Files in this directory:
dir /b
echo ==============================================




:: ---- Extract StudentPythonActivity.zip ----
if exist StudentPythonActivity.zip (
    echo  Extracting StudentPythonActivity.zip...
    echo Extracting StudentPythonActivity.zip... >> %LOGFILE%

    :: Remove old folder if exists
    if exist StudentPythonActivity (
        echo Removing old StudentPythonActivity folder... >> %LOGFILE%
        rmdir /s /q StudentPythonActivity
    )
    mkdir StudentPythonActivity

    :: Try tar first
    tar -xf StudentPythonActivity.zip -C StudentPythonActivity >> %LOGFILE% 2>&1
    if %ERRORLEVEL% neq 0 (
        echo  tar failed, trying PowerShell unzip... >> %LOGFILE%
        powershell -Command ^
        "Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('StudentPythonActivity.zip','StudentPythonActivity')" >> %LOGFILE% 2>&1
    )

    :: Confirm extraction worked
    if exist StudentPythonActivity (
        echo  Extraction complete. >> %LOGFILE%
    ) else (
        echo  Extraction failed. >> %LOGFILE%
    )
) else (
    echo  StudentPythonActivity.zip not found in %cd% >> %LOGFILE%
)

:: ---- Open VS Code ----
echo Launching VS Code with StudentPythonActivity... >> %LOGFILE%
code StudentPythonActivity >> %LOGFILE% 2>&1

::---- installation of extension

for /f %%e in (extensions.txt) do (
    echo Installing extension %%e >> %LOGFILE%
    code --install-extension %%e >> %LOGFILE% 2>&1
)

echo ============================== >> %LOGFILE%
echo Setup completed at %date% %time% >> %LOGFILE%
echo ============================== >> %LOGFILE%

echo  Setup complete! Check %LOGFILE% for details.
echo Press any key to close this window...
pause >nul
