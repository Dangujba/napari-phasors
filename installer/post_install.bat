REM Post-install script: create shortcuts. napari-phasors and its dependencies
REM are bundled into the env by constructor (see specs in the build workflow),
REM so nothing is downloaded here and the install needs no network.

REM Create a launcher batch file
echo @echo off > "%PREFIX%\napari-phasors.bat"
echo set "PATH=%PREFIX%;%PREFIX%\Library\bin;%PREFIX%\Scripts;%%PATH%%" >> "%PREFIX%\napari-phasors.bat"
echo set "CONDA_PREFIX=%PREFIX%" >> "%PREFIX%\napari-phasors.bat"
echo set "PYTHONHOME=" >> "%PREFIX%\napari-phasors.bat"
echo set "PYTHONPATH=" >> "%PREFIX%\napari-phasors.bat"
echo set "PYTHONNOUSERSITE=1" >> "%PREFIX%\napari-phasors.bat"
echo if not defined QT_API set "QT_API=pyqt6" >> "%PREFIX%\napari-phasors.bat"
echo if not defined NUMBA_CACHE_DIR set "NUMBA_CACHE_DIR=%%LOCALAPPDATA%%\napari-phasors\numba-cache" >> "%PREFIX%\napari-phasors.bat"
echo start "" "%PREFIX%\pythonw.exe" "%PREFIX%\launch_napari_phasors.pyw" %%* >> "%PREFIX%\napari-phasors.bat"

REM Automated tests can verify the install without replacing existing links.
if "%NAPARI_PHASORS_SKIP_SHORTCUTS%"=="1" goto :eof

REM Detect icon file (if shipped via constructor extra_files)
set "ICON_PATH="
if exist "%PREFIX%\icon.ico" set "ICON_PATH=%PREFIX%\icon.ico"

REM Create shortcuts via VBScript (always available, unlike PowerShell in NSIS)
echo Set ws = CreateObject("WScript.Shell") > "%PREFIX%\create_shortcuts.vbs"
echo Set desktop = ws.CreateShortcut(ws.SpecialFolders("Desktop") ^& "\napari-phasors.lnk") >> "%PREFIX%\create_shortcuts.vbs"
echo desktop.TargetPath = "%PREFIX%\pythonw.exe" >> "%PREFIX%\create_shortcuts.vbs"
echo desktop.Arguments = """%PREFIX%\launch_napari_phasors.pyw""" >> "%PREFIX%\create_shortcuts.vbs"
echo desktop.WorkingDirectory = "%USERPROFILE%" >> "%PREFIX%\create_shortcuts.vbs"
echo desktop.Description = "napari-phasors" >> "%PREFIX%\create_shortcuts.vbs"
echo desktop.WindowStyle = 7 >> "%PREFIX%\create_shortcuts.vbs"
if defined ICON_PATH (
    echo desktop.IconLocation = "%ICON_PATH%" >> "%PREFIX%\create_shortcuts.vbs"
)
echo desktop.Save >> "%PREFIX%\create_shortcuts.vbs"
echo Set startmenu = ws.CreateShortcut(ws.SpecialFolders("StartMenu") ^& "\napari-phasors.lnk") >> "%PREFIX%\create_shortcuts.vbs"
echo startmenu.TargetPath = "%PREFIX%\pythonw.exe" >> "%PREFIX%\create_shortcuts.vbs"
echo startmenu.Arguments = """%PREFIX%\launch_napari_phasors.pyw""" >> "%PREFIX%\create_shortcuts.vbs"
echo startmenu.WorkingDirectory = "%USERPROFILE%" >> "%PREFIX%\create_shortcuts.vbs"
echo startmenu.Description = "napari-phasors" >> "%PREFIX%\create_shortcuts.vbs"
echo startmenu.WindowStyle = 7 >> "%PREFIX%\create_shortcuts.vbs"
if defined ICON_PATH (
    echo startmenu.IconLocation = "%ICON_PATH%" >> "%PREFIX%\create_shortcuts.vbs"
)
echo startmenu.Save >> "%PREFIX%\create_shortcuts.vbs"
cscript //nologo "%PREFIX%\create_shortcuts.vbs"
del "%PREFIX%\create_shortcuts.vbs"
