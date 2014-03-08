set depl=%1deploy\

md %depl%

copy %2*.exe %depl%
copy %2*.dll %depl%
copy %2*.pdb %depl%
copy %2*.config %depl%

del %depl%*.vshost.*