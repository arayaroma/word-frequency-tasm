:: remove all files from target
del target\*.*

:: assemble the files
bin\tasm /z src\main.asm
bin\tasm /z src\word.asm
bin\tasm /z src\ascii.asm
bin\tasm /z src\graphic.asm
bin\tasm /z src\mouse.asm
bin\tasm /z src\file.asm
pause

:: copy bin files into target
copy *.obj target
del *.obj

:: link the files
bin\tlink target\main.obj target\word.obj target\ascii.obj target\graphic.obj target\mouse.obj target\file.obj, target\main.exe

:: execute it
target\main.exe