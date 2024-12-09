# cp template.gdb launch.gdb

# set gdb server
target extended-remote localhost:3333

# set target executable
# file ~/path/to/executable

# set target arch
# set architecture i386:x86-64

# configs
set print pretty on
