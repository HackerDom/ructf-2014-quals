@echo off
echo Generate...
vga2-manual.pl server/average.txt 0.3 14096 > test.txt
echo Solve...
vga2-solve-2.pl test.txt 1344 806 60 15 > test.png
echo test.png created
pause
