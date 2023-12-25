@rem ----- Builtch Configuration -----
@rem --------- Version 0.2.0 ---------

@rem ------------- Files -------------
set source_files=example.c, hello.c
set output_file=example.exe

@rem ----------- Arguments -----------
set common_args=-Wall -Werror=return-type -Werror=int-conversion -Werror=implicit-function-declaration
set debug_args=-D _DEBUG
set release_args=-D NDEBUG -O3
set test_args=-D _DEBUG -D TESTING

@rem I don't know why, but you have to add this.
@rem Otherwise this doesn't always return 0 when used in cmd.
@rem I think it's fine in other terminals.
exit /b 0 
