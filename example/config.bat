@rem ----- Builtch Configuration -----
@rem --------- Version 0.1.1 ---------
 
@rem ------------- Files -------------
set source_file=example.c
set output_file=example.exe
 
@rem ----------- Arguments -----------
set common_args=-Wall
set debug_args=-D _DEBUG
set release_args=-D NDEBUG
set test_args=-D _DEBUG -D TESTING
 
@rem I don't know why, but you have to add this.
@rem Otherwise this doesn't always return 0 when used in cmd.
@rem I think it's fine in other terminals.
exit /b 0 
