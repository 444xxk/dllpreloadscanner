@ECHO OFF
REM research oriented semi auto script : scanning for DLL hijack potentials with procmon 
REM v0.00  
CLS
SET procmonloc=C:\Tools\ProcessMonitor\Procmon.exe
SET procmondir=C:\Tools\ProcessMonitor\


echo "Semi automatic scanner for DLL search order vulnerability, written in Batch so it can audit old WinOS natively"
echo "Please run as admin / disable UAC fully or run with UAC bypass wrapper (such as Powershell script)" 
echo ""
echo ""
echo "The script assume C:\Program Files folders and C:\Windows folders have correct ACLs and exclude them, in case these folders are badly protected then you are wasting your time with this script you can already elevate =D"
REM cleaning 
del C:\vulnscan.PML
del exestostart.txt 

echo "current dir %CD%"
REM start procmon with corresponding filters and output to PMC file 
start "procmon" %procmonloc% "/Quiet /LoadConfig '%CD%\vulnscanprocmon.pmc' /SaveApplyFilter"
echo "wait for procmon boot" 
timeout 2

REM now start a bunch (all?) of .exe or similar to check vulns from current dir and subf 
for /r "." %%a in (*.exe) do echo "%%~fa">> exestostart.txt

for /f %%i in (exestostart.txt) do start /b "tempwin" "%%~fi" && timeout 3 && taskkill /T /F /IM %%~ni%%~xi && taskkill /T /F /FI "WINDOWTITLE eq tempwin"

timeout 2 
REM kill procmon to start a new one for export 
start "procmon" %procmonloc% "/Terminate"


timeout 2 
REM exporting results to CSV 
echo "exporting results to CSV"
start "procmon" %procmonloc% /Openlog C:\vulnscan.PML /SaveAs %CD%\vulnscan.csv /SaveApplyFilter



