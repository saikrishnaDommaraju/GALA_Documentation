@echo off

\install\Aut2Exe\Aut2exe.exe /in TechPackage_CLI_v6.au3 /out TDP_CLI.exe /console /nopack /x86
\install\Aut2Exe\Aut2exe.exe /in processqueue.au3 /out TDP_Queue.exe /x86

pause