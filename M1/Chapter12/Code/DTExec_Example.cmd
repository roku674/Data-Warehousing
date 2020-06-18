@echo off
"%ProgramFiles%\Microsoft SQL Server\110\DTS\Binn\DtExec" /Server localhost /ISServer "\SSISDB\TK 463 Chapter 11\TK 463 Chapter 10\Master.dtsx" /Par $ServerOption::LOGGING_LEVEL(Int32);1
