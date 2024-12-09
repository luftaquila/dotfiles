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

-- adapter configurations
dap.adapters.gdb = {
  type = "executable",
  command = toolchain .. "-gdb",
  args = { "-i", "dap", "-x", home .. "/dotfiles/scripts/gdb/launch.gdb" },
}

-- language configurations
dap.configurations.c = {
  {
    name = "Launch",
    request = "launch",
    type = "gdb",
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = true,
  },
}

dap.configurations.asm = dap.configurations.c

-- event listeners
dap.listeners.after["event_initialized"]["custom"] = function(session, body)
  -- do something
end
