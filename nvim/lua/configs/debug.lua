local dap = require "dap"

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read "*a")
  f:close()
  if raw then
    return s
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

local toolchain = os.capture("test -e $HOME/rtworks/bsp.sh && . $HOME/rtworks/bsp.sh && echo $TOOLCHAIN", false)
local home = os.getenv "HOME" or ""

dap.adapters.gdb = {
  type = "executable",
  command = toolchain .. "-gdb",
  args = { "-i", "dap" },
}

dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = home .. "/rtworks/builder/build.kernel/rtworks.elf",
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
}
