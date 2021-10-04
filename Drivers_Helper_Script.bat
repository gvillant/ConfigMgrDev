REM This script will add a new file on each folder and subfolder. 
REM Name of the file = NameOfBat.txt 
REM Remember to rename the script as needed. 

@ECHO OFF 
for /f "tokens=*" %%G IN ('dir /ad /b /s') DO ( 
echo. > "%%G\%~n0.txt" 
)
