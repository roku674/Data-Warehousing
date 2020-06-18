@echo off
copy "C:\TK463\Chapter19\Lesson3\Solution\TK463 Chapter 19\TK463.CalculateCheckSum\bin\Release\TK463.CalculateCheckSum.dll" "%ProgramFiles(x86)%\Microsoft SQL Server\110\DTS\PipelineComponents" /Y
copy "C:\TK463\Chapter19\Lesson3\Solution\TK463 Chapter 19\TK463.CalculateCheckSum\bin\Release\TK463.CalculateCheckSum.dll" "%ProgramFiles%\Microsoft SQL Server\110\DTS\PipelineComponents" /Y
echo.
"%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.0A\bin\NETFX 4.0 Tools\x64\gacutil" /u TK463.CalculateCheckSum
echo.
"%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.0A\bin\NETFX 4.0 Tools\x64\gacutil" /i "%ProgramFiles%\Microsoft SQL Server\110\DTS\PipelineComponents\TK463.CalculateCheckSum.dll"
echo.
"%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.0A\bin\NETFX 4.0 Tools\x64\gacutil" /i "%ProgramFiles(x86)%\Microsoft SQL Server\110\DTS\PipelineComponents\TK463.CalculateCheckSum.dll"
