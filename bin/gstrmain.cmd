@echo off
sed "/$$Pmain/,/ret $0/d" < %1 > sed.tmp && mv sed.tmp %1
