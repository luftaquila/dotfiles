# cp template.gdb launch.gdb

# set gdb server
target extended-remote localhost:3333

# set target arch
# set architecture i386:x86-64

# set target executable
# file ~/path/to/executable

# configs
set print pretty on

# breakpoints
# b boot
# b main
