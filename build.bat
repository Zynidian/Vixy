@echo off
c:\cc65\bin\ca65 src\vixy.asm -g -I src -o v.o
c:\cc65\bin\ld65 -C ldscripts\vixy.ld -o vixy.nes -vm v.o
