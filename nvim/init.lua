vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})

-- highlight whitespaces
vim.opt.list = true
vim.opt.listchars = { eol = ' ', trail = '█', tab = '>-', nbsp = '␣' }

-- session.vim
vim.opt.sessionoptions:remove("buffers")

vim.g.session_autosave = 'yes'
vim.g.session_autoload = 'no'
vim.g.session_autosave_periodic = 1
vim.g.session_autosave_silent = 1
vim.g.session_default_overwrite = 1
vim.g.session_command_aliases = 1

vim.api.nvim_create_user_command('O', function()
  vim.cmd('OpenSession')
end, {})

