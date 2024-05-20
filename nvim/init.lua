vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins ---------------------------------------------
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins ---------------------------------------------------------------
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

-- load theme -----------------------------------------------------------------
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- options --------------------------------------------------------------------
vim.o.scrolloff = 5

-- highlights -----------------------------------------------------------------
require('configs.highlights')
vim.cmd('highlight Search ctermfg=white ctermbg=gray guifg=white guibg=gray')
vim.cmd('highlight CurSearch ctermfg=black ctermbg=lightgray guifg=black guibg=lightgray')

-- utils ----------------------------------------------------------------------
local utils = require('configs.utils')

-- abbreviabtions -------------------------------------------------------------
utils.cabbrev('sh', 'suspend')

-- filetypes ------------------------------------------------------------------
utils.set_filetype("*.cmm", "t32")

-- configs --------------------------------------------------------------------
vim.api.nvim_command('set modeline')

-- restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    vim.api.nvim_exec('silent! normal! g`"zv', false)
  end,
})

-- auto enter/leave insert mode on terminal buffers
vim.api.nvim_create_autocmd({"BufWinEnter", "WinEnter", "TermOpen"}, {
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
    -- vim.cmd('HideBadWhitespace')
  end
})

vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "term://*",
  callback = function()
    vim.cmd("stopinsert")
    -- vim.cmd('ShowBadWhitespace')
  end
})

-- gitsigns
local gitsigns = require("gitsigns")

gitsigns.setup {
  numhl = true,
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 1500
  },
  current_line_blame_formatter = '<abbrev_sha>: <author> (<author_time:%Y-%m-%d>) - <summary>'
}
