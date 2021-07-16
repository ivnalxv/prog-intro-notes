@echo off
git add .
if "%1" == "" (
	git commit -m "still trying"
) else (
	git commit -m "%1"
)
git push
exit