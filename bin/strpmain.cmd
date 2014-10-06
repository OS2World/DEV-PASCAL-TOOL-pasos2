@echo off
sed "/_$$Pmain/,/endp/d" < %1 > sed.tmp && mv sed.tmp %1
