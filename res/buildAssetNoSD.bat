set DIRECTORY=%~dp0
set TPS_FOLDER=%DIRECTORY%asset\
set DIST=%DIRECTORY%..\bin\asset\textures\
set PATH=%PATH%;"D:\dev\PowerVR\GraphicsSDK\PVRTexTool\CLI\Windows_x86_64\"
set PATH=%PATH%;"C:\Program Files (x86)\Adobe Gaming SDK 1.3\Utilities\ATF Tools\"
set PATH=%PATH%;"D:\iosdev\atf"
cd "%TPS_FOLDER%"
for /d %%a in (*) do (
"C:\Program Files (x86)\CodeAndWeb\TexturePacker\bin\TexturePacker.exe" --texture-format png --sheet "%DIST%%%~na.png" --data "%DIST%%%~na.xml" --format sparrow --algorithm MaxRects %%~na
)
cd "%DIST%"
for %%b in (*.png) do (
png2atf.exe -4 -q 0 -i "%%~nb.png" -o "%%~nb.atf"
::PVRTexToolCLI.exe -m -dither -f r8g8b8a8 -i %%b
::pvr2atf.exe -4 -q 2 -r "%%~nb.pvr" -o "%%~nb.atf"
)
::del /f /q *.png
del /f /q *.pvr
pause