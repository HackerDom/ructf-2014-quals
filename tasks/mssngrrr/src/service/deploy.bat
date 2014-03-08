set depl=%1deploy
set site=%1deploy\site
set sttc=%site%\static

md %depl%

rm -rf %depl%\site\*

md %depl%\site
md %depl%\site\bin
md %depl%\site\errors

xcopy /y /e %1static %sttc%\
dir /b /a:-d /s %sttc% | grep -vE "\.png|\.gif|\.jpg|\.js|\.css|\.ico|\.html" | xargs -n1 rm -fv

copy %1*.as?x %site%\
copy %1*.master %site%\
copy %1*.htm %site%\
copy %1*.html %site%\
copy %1*.config %site%\
copy %1*.txt %site%\
copy %1bin\*.dll %site%\bin\
copy %1bin\*.pdb %site%\bin\
copy %1errors\*.html %site%\errors\

del %site%\bin\*.vshost.*

echo OK