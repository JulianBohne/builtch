@echo off

@rem The MIT license can be found at the bottom of the file
set builtch_version_string=--------- Version 0.1.1 ---------
@rem Note: keep aligned:   ---------------------------------

@rem ------------ Things for your `config.bat` ------------
@rem WARNING: Some of these comments are pretty dumb
@rem You can set the path to your compiler with this variable (I don't know of this works with anything but gcc though)
set compiler=gcc

@rem This is the name of the output file (yes, only .exe for now)
set output_file=a.exe

@rem I think directories should be relative to where you run this file
@rem This is the name of the source directory
set source_dir=src

@rem This is the name of the output directory
set output_dir=bin

@rem You can set args for debug and release with this variable
set common_args=

@rem You can set args for debug with this variable
set debug_args=

@rem You can set args for release with this variable
set release_args=

@rem This is the name of the test directory
set test_dir=test

@rem You can set args for all tests with this variable
set test_args=-D TESTING

@rem ------------------- Parse arguments -------------------

set task="%~1"
shift

set comp_args=
set prog_args=
set show_debug=false
set add_local_builtch=false

@rem First test everything where we have to show help
if %task%==""       goto :show_help
if %task%=="--help" goto :show_help
if %task%=="-help"  goto :show_help
if %task%=="help"   goto :show_help
if %task%=="/?"     goto :show_help
@rem If we have to build or run, then we can start parsing the rest
if %task%=="run" goto :parse_builtch_args
if %task%=="build" goto :parse_builtch_args
if %task%=="test" goto :parse_builtch_args
if %task%=="init" goto :parse_init_args
call :logger ERROR "Unknown argument: %task%"
@rem Yes, this is not good/reusable. I just don't know how to pass the pipes to the logger :(
echo [94m[INFO][0m Expected one of these [build ^| run ^| test ^| init]
call :logger INFO "Try calling --help for help"
exit /b

:parse_init_args
set current_arg=%~1
if "%current_arg%"=="" goto :initialize_project
if "%current_arg%"=="--show_debug" (set show_debug=true&goto :next_init_arg)
if "%current_arg%"=="--portable" (set add_local_builtch=true&goto :next_init_arg)
if "%current_arg:~0,1%"=="-" (call :logger ERROR "Unknown argument '%current_arg%'"&exit /b 1)
set project_name=%current_arg%
:next_init_arg
shift
goto :parse_init_args

:parse_builtch_args
set current_arg=%~1
if "%current_arg%"=="" goto :load_config
if "%current_arg:~0,3%"=="---" goto :load_config

if "%current_arg%"=="--release" (set build_mode=release&goto :next_builtch_arg)
if "%current_arg%"=="--show_debug" (set show_debug=true&goto :next_builtch_arg)

call :logger ERROR "Unknown argument '%current_arg%'"
call :logger INFO "Consider adding ---comp or ---prog before that to send it to the right process"
exit /b

:next_builtch_arg
shift
goto :parse_builtch_args

@rem --------------------- Load config ---------------------
:load_config
call config 2>nul
if %ERRORLEVEL% neq 0 (
    call :logger ERROR "No configuration file found %ERRORLEVEL%" &call :logger INFO "Try adding a `config.bat`." &exit /b
)

@rem Validating config
if "%source_file%"=="" (call :logger ERROR "No source file set in `config.bat`" &call :logger INFO "Try: set source_file=your_source.c" &exit /b)

goto :collect_other_args

@rem ----------------- Collect other args ------------------
:collect_other_args
if "%~1"=="" goto :done_with_args
set current_arg=%~1
shift
if "%current_arg%"=="---comp" goto :add_comp_args
if "%current_arg%"=="---prog" goto :add_prog_args

call :logger ERROR "Unknown argument '%current_arg%'"
call :logger INFO "Consider adding ---comp or ---prog before that to send it to the right process"
exit /b

:add_comp_args
if "%~1"=="" goto :done_with_args
@rem https://stackoverflow.com/questions/36228474/batch-file-if-string-starts-with
set current_comp_arg=%~1
if "%current_comp_arg:~0,3%"=="---" goto :collect_other_args
set comp_args=%comp_args% %~1
shift
goto :add_comp_args

:add_prog_args
if "%~1"=="" goto :done_with_args
@rem https://stackoverflow.com/questions/36228474/batch-file-if-string-starts-with
set current_prog_arg=%~1
if "%current_prog_arg:~0,3%"=="---" goto :collect_other_args
set prog_args=%prog_args% %~1
shift
goto :add_prog_args

:done_with_args

if not "%comp_args%"=="" goto :got_some_comp_args
call :logger DEBUG "No additional compiler arguments provided"
goto done_printing_comp_args
:got_some_comp_args
call :logger DEBUG "Compiler arguments:%comp_args%"
:done_printing_comp_args

if not "%prog_args%"=="" goto :got_some_prog_args
call :logger DEBUG "No program arguments provided"
goto done_printing_prog_args
:got_some_prog_args
call :logger DEBUG "Program arguments:%prog_args%"
:done_printing_prog_args

@rem Switch on task and build mode
if %task%=="test" goto :run_all_tests
if "%build_mode%"=="release" goto :build_release
goto :build_debug

@rem -------------------- Build debug ---------------------
:build_debug
if not exist bin mkdir bin
call :logger DEBUG "%compiler% '%source_dir%%source_file%' %common_args% %debug_args%%comp_args% -o '%output_dir%%output_file%'"
call :logger INFO "Compiling for debug..."

call %compiler% "%source_dir%\%source_file%" %common_args% %debug_args% %comp_args% -o "%output_dir%\%output_file%" ||  (call :logger ERROR "Compilation failed" &exit /b)

call :over_logger SUCCESS "Compiled successfully"

if %task%=="run" goto :run_program
exit /b

@rem ------------------- Build release --------------------
:build_release
if not exist bin mkdir bin
call :logger INFO "Compiling for release..."
call :logger DEBUG "%compiler% '%source_dir%%source_file%' %common_args% %release_args%%comp_args% -o '%output_dir%%output_file%'"

call %compiler% "%source_dir%\%source_file%" %common_args% %release_args% %comp_args% -o "%output_dir%\%output_file%" ||  (call :logger ERROR "Compilation failed" &exit /b)

call :logger SUCCESS "Compiled successfully"

if %task%=="run" goto :run_program
exit /b

@rem ------------------------ Run -------------------------
:run_program
call :logger INFO "Running program..."
call :logger DEBUG "'%output_dir%\%output_file%'%prog_args%"
echo.

call "%output_dir%\%output_file%" %prog_args%

echo.
if %ERRORLEVEL% neq 0 (
    call :logger ERROR "Program exited with non zero exit code: %ERRORLEVEL%" &exit /b
)

call :logger SUCCESS "Everything done :D"
exit /b

@rem ------------------- Run all tests --------------------
:run_all_tests
if not exist %test_dir%\tmp mkdir %test_dir%\tmp
set /a test_count = 0
set /a successful_tests = 0
set could_not_compile=
set failed_names=

for /r %%i in (%test_dir%\*) do call :run_test "%%i"

echo.
call :logger SUMMARY
if not %test_count%==%successful_tests% goto :some_tests_failed
@rem All tests successful here
call :logger SUCCESS "[%successful_tests%/%test_count%] tests finished successfully"
goto :end_of_testing

:some_tests_failed
call :logger ERROR "[%successful_tests%/%test_count%] tests finished successfully"
if not "%could_not_compile%"=="" call :logger ERROR "Could not compile:%could_not_compile%"
if not "%failed_names%"=="" call :logger ERROR "Failed tests:%failed_names%"

:end_of_testing
rmdir %test_dir%\tmp
exit /b

:run_test
@rem https://stackoverflow.com/questions/10393248/get-filename-from-string-path
set current_file_name=%~nx1
set /a test_count = %test_count% + 1

@rem Compile...
call :logger INFO "Compiling '%current_file_name%'"
call %compiler% "%test_dir%\%current_file_name%" %common_args% %test_args% %comp_args% -o "%test_dir%\tmp\%current_file_name%.exe"
if %ERRORLEVEL% neq 0 (
    call :logger ERROR "Could not compile '%current_file_name%'"& set could_not_compile=%could_not_compile% '%current_file_name%'&goto :test_cleanup
)

@rem and run!
call :over_logger INFO "Running '%current_file_name%'"
call "%test_dir%\tmp\%current_file_name%.exe" %prog_args%
if %ERRORLEVEL% neq 0 (
    call :logger ERROR "'%current_file_name%' failed"& set failed_names=%failed_names% '%current_file_name%'&goto :test_cleanup
)

call :over_logger SUCCESS "'%current_file_name%' finished"
set /a successful_tests = %successful_tests% + 1
goto :test_cleanup

:test_cleanup
if exist "%test_dir%\tmp\%current_file_name%.exe" del /f "%test_dir%\tmp\%current_file_name%.exe"
exit /b

@rem ----------------- Initialize project -----------------
:initialize_project
if "%project_name%"=="" call :set_project_name_to_folder_name "%CD%"

dir /b /s /a "%CD%" | findstr .>nul || goto :folder_empty_or_allowed_to_overwrite

call :logger WARNING "This folder is not empty!"
set /p allowed_to_overwrite=Proceed anyways? [y^|n] 

if "%allowed_to_overwrite%"=="Y" goto :folder_empty_or_allowed_to_overwrite
if "%allowed_to_overwrite%"=="y" goto :folder_empty_or_allowed_to_overwrite
if "%allowed_to_overwrite%"=="Yes" goto :folder_empty_or_allowed_to_overwrite
if "%allowed_to_overwrite%"=="yes" goto :folder_empty_or_allowed_to_overwrite

call :logger ERROR "Cancelled initialization"
exit /b 1

:folder_empty_or_allowed_to_overwrite
if not exist src mkdir src
if not exist bin mkdir bin
if not exist test mkdir test

echo @rem ----- Builtch Configuration ----->config.bat
echo @rem %builtch_version_string%>>config.bat
echo. >>config.bat
echo @rem ------------- Files ------------->>config.bat
echo set source_file=%project_name%.c>>config.bat
echo set output_file=%project_name%.exe>>config.bat
echo. >>config.bat
echo @rem ----------- Arguments ----------->>config.bat
echo set common_args=-Wall>>config.bat
echo set debug_args=-D _DEBUG>>config.bat
echo set release_args=-D NDEBUG>>config.bat
echo set test_args=-D _DEBUG -D TESTING>>config.bat
echo. >>config.bat
echo @rem I don't know why, but you have to add this.>>config.bat
echo @rem Otherwise this doesn't always return 0 when used in cmd.>>config.bat
echo @rem I think it's fine in other terminals.>>config.bat
echo exit /b 0 >>config.bat

echo #include ^<stdio.h^> >"src\%project_name%.c"
echo. >>src\"%project_name%.c"
echo int main(int argc, char** argv) {>>"src\%project_name%.c"
echo.    printf("Hello %project_name%!\n");>>"src\%project_name%.c"
echo.    return 0;>>"src\%project_name%.c"
echo }>>"src\%project_name%.c"


if "%add_local_builtch%"=="false" goto :done_with_init
call :actual_batch_path
call :logger DEBUG "%actual_batch_path%"
if exist "builtch.bat" call :logger DEBUG "builtch.bat already exists"
if not exist "builtch.bat" copy "%actual_batch_path%" "builtch.bat" >nul

:done_with_init
call :logger SUCCESS "Project '%project_name%' created" successfully
exit /b

@rem https://answers.microsoft.com/en-us/windows/forum/all/how-to-get-my-own-path-in-a-batch-file/7a451f44-abce-4dff-aaab-dc8d18c4fe12
:actual_batch_path
set actual_batch_path=%~dpnx0
exit /b

:set_project_name_to_folder_name
set project_name=%~nx1
exit /b

@rem ------------------------ Help -------------------------
:show_help
echo [92m[Usage][0m
echo builtch [build ^| run ^| test] (Flags) (---comp ^<your additional compiler args^>) (---prog ^<arguments that you want to pass to your program^>)
echo You can do as many ---comp or ---prog blocks as you want.
echo Additional compiler args specified with ---comp will be supplied after the ones specified in `config.bat`
echo.
echo builtch [--help ^| -help ^| help ^| /?]
echo builtch init ^<optional project name^> (Flags)
echo.
echo You can find all settable variables at the top of `builtch.bat`
echo.
echo [92m[Flags][0m
echo --release           Use release compiler args from `config.bat` instead of debug args (does not apply to test)
echo --show_debug        Show some debug information while running the script
echo --portable          Copy builtch.bat into project folder when initializing project
echo.
echo [94m[Example][0m builtch init my_cool_project --portable
echo [94m[Example][0m builtch run --release ---comp -O3 -D NDEBUG ---prog one two three
echo.
exit /b

@rem ---------------------- Loggers -----------------------
@rem Colors: https://www.codeproject.com/Questions/5250523/How-to-change-color-of-a-specific-line-in-batch-sc
:logger
set logger_prepend=
goto :internal_logger

@rem This one overwrites the previous line
:over_logger
set logger_prepend=[1F[0J
goto :internal_logger

:internal_logger
set color=[90m
set type=%~1
if "%type%"=="DEBUG" (
    if "%show_debug%"=="false" exit /b
)
if "%type%"=="ERROR" set color=[91m
if "%type%"=="INFO" set color=[94m
if "%type%"=="SUCCESS" set color=[92m
if "%type%"=="WARNING" set color=[93m
echo %logger_prepend%%color%[%type%][0m %~2
exit /b

@rem ----------------------- LICENSE -----------------------
@rem MIT License

@rem Copyright (c) 2023 JulianBohne

@rem Permission is hereby granted, free of charge, to any person obtaining a copy
@rem of this software and associated documentation files (the "Software"), to deal
@rem in the Software without restriction, including without limitation the rights
@rem to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@rem copies of the Software, and to permit persons to whom the Software is
@rem furnished to do so, subject to the following conditions:

@rem The above copyright notice and this permission notice shall be included in all
@rem copies or substantial portions of the Software.

@rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@rem IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@rem FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@rem AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@rem LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@rem OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@rem SOFTWARE.