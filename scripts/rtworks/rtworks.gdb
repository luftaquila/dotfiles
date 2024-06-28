target extended-remote localhost:3333

set output-radix 16

file /Users/luftaquila/rtworks/builder/build.kernel/rtworks.elf
add-symbol-file /Users/luftaquila/rtworks/builder/build.kernel/rtworks.elf
add-symbol-file /Users/luftaquila/rtworks/builder/build.partition1/rtworks_partition.elf
