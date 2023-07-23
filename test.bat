@echo off
set themes= Hot Sun  , Hard Granite  ,  Shimmering Bright Twilight  
set prefix=test\
set collect=
for %%a in ("%themes:,=" "%") do (
    call :trim_and_collect %%~a
)
echo %collect%

exit /b

@rem https://stackoverflow.com/questions/3001999/how-to-remove-trailing-and-leading-whitespace-for-user-provided-input-in-a-batch
@rem I don't know why I can't do the collecting part in the loop, but it just doen't work :))) 
:trim_and_collect
set collect=%collect% "%prefix%%*"
exit /b