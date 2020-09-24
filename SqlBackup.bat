@ECHO OFF
SETLOCAL

REM Clear Backup files older than 5 days
forfiles /P C:\SQLBACKUP\ /M *.bak /D -5 /C "cmd /c Del @Path"

REM Build a list of databases to backup
SET DBList=C:\SQLBACKUP\SQLDBList.txt
SqlCmd -E -S 192.168.0.1\SQLEXPRESS -h -1 -W -Q "SET NoCount ON; SELECT Name FROM master.dbo.sysDatabases WHERE [Name] NOT IN ('master','model','msdb','tempdb')" > "%DBList%"

REM Backup each database, prepending the date to the filename
FOR /F "tokens=*" %%I IN (%DBList%) DO (
ECHO Backing up database: %%I
ECHO BACKUP DATABASE [%%I] TO Disk='C:\SQLBACKUP\Backup_%%I_%DATE:/=-%.bak'
SqlCmd -E -S 192.168.0.1\SQLEXPRESS -Q "BACKUP DATABASE [%%I] TO Disk='C:\SQLBACKUP\Backup_%%I_%DATE:/=-%.bak'"
ECHO.
)

REM Clear temporary file
IF EXIST "%DBList%" DEL /F /Q "%DBList%"

ENDLOCAL
