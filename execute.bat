:: remove all files from target
del target\*.*

:: assemble the files
bin\tasm /zi src\main.asm
bin\tasm /zi src\word.asm
bin\tasm /zi src\ascii.asm
bin\tasm /zi src\graphic.asm
bin\tasm /zi src\keyboard.asm
bin\tasm /zi src\mouse.asm
bin\tasm /zi src\file.asm

:: copy bin files into target
copy *.obj target
del *.obj

:: link the files
bin\tlink /v target\main.obj target\word.obj target\ascii.obj target\graphic.obj target\keyboard.obj target\mouse.obj target\file.obj

:: execute it
target\main.exe