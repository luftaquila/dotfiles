require "nvchad.mappings"

local map = vim.keymap.set
local term = require("nvchad.term")
local telescope = require('telescope.builtin')

-- utils
local function opts_to_id(id)
  for _, opts in pairs(vim.g.nvchad_terms) do
    if opts.id == id then
      return opts
    end
  end
end

local function terminal_launch(mode, cmd, id, size)
  local ch

  if (id) then
    term.toggle { pos = mode, size = size and size or 0.25, id = id }
    ch = vim.b[opts_to_id(id).buf].terminal_job_id
  else
    term.new { pos = mode, size = size and size or 0.25 }
    ch = vim.b[vim.api.nvim_get_current_buf()].terminal_job_id
  end

  -- note: send cmd to toggled channel is not working
  vim.api.nvim_chan_send(ch, cmd .. "\n")
end

-- LSP
map('n', '<leader>lf', vim.diagnostic.open_float, { desc = "Show diagnostics under cursor" })

-- Telescope
map('n', '<leader>br', telescope.git_branches, { desc = "Telescope Git Branches" })
map('n', '<leader>fr', telescope.lsp_references, { desc = "Telescope find LSP references" })
map('n', '<leader>fs', telescope.lsp_workspace_symbols, { desc = "Telescope find LSP symbols" })
map('n', '<leader>fi', telescope.lsp_implementations, { desc = "Telescope find LSP implementations" })
map('n', '<leader>fd', telescope.lsp_definitions, { desc = "Telescope find LSP definitions" })
map('n', '<leader>fp', telescope.diagnostics, { desc = "Telescope find LSP diagnostics" })
map('n', '<leader>fu', telescope.grep_string , { desc = "Telescope grep string under cursor" })
map('n', '<leader>fk', telescope.keymaps, { desc = "Telescope find keymaps" })
map('n', '<leader>ca', require("actions-preview").code_actions, { desc = "Telescope LSP code action preview" })

-- Gitsigns
map('n', '<leader>df', require("gitsigns").diffthis, { desc = "Git diff" })

-- No Neck Pain
map('n', 'cn', ':NoNeckPain<CR>', { desc = "NoNeckPain toggle" })

-- Vista
map('n', 'tt', ':Vista!!<CR>', { desc = "Vista toggle tag window" })
map('n', '<leader>i', ':Vista focus<CR>', { desc = "Vista focus tag window" })

-- macro
map('n', '<CR>', '@q', { desc = "Macro play @q" })

-- Tabs
map('n', 'tn', ':tabnew<CR>', { desc = "Tab create new" })
map('n', 'tx', ':tabclose<CR>', { desc = "Tab close" })
map('n', 'tl', ':tabnext<CR>', { desc = "Tab next" })
map('n', 'th', ':tabprev<CR>', { desc = "Tab prev" })

-- terminals
map('n', '<leader>v', function()
  term.toggle { pos = "vsp", id = "vertical", size = 0.25 }
end, { desc = "Terminal Toggle vertical terminal" })

map('n', '<leader>h', function()
  term.toggle { pos = "sp" }
end, { desc = "Terminal Toggle horizontal terminal" })

map('n', '<leader>a', function()
  term.toggle { pos = "float", id = "floating" }
end, { desc = "Terminal Toggle Floating terminal" })

map('t', '<C-w>', function()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_close(win, true)
end, { desc = "Terminal Close term in terminal mode" })

map("t", "<ESC>", "<C-\\><C-N>", { desc = "Terminal Escape terminal mode" })

-- Ctrl + P to previous window
map('n', '<C-p>', '<C-w>p', { desc = "Jump to previous window" })
map('t', '<C-p>', '<C-\\><C-o><C-w>p', { desc = "Jump to previous window" })

-- RTWORKS
map('n', '<leader>sm', function ()
  terminal_launch("vsp", "cons", "serial")
end, { desc = "Serial monitor open" })

map('n', '<leader>bb', function ()
  terminal_launch("float", "bb")
end, { desc = "RTWORKS build" })

map('n', '<leader>bl', function ()
  terminal_launch("float", "bb l4")
end, { desc = "RTWORKS build verbose" })

map('n', '<leader>le', function ()
  terminal_launch("float", "le")
end, { desc = "RTWORKS local build and execute" })

map('n', '<leader>ll', function ()
  terminal_launch("float", "le l4")
end, { desc = "RTWORKS local build and execute verbose" })

map('n', '<leader>ls', function ()
  terminal_launch("float", "les l4")
end, { desc = "RTWORKS local build and execute verbose serialized" })

map('n', '<leader>mk', function ()
  terminal_launch("sp", "mm k")
end, { desc = "RTWORKS misra kernel" })

map('n', '<leader>mp', function ()
  terminal_launch("sp", "mm p")
end, { desc = "RTWORKS misra partition" })

map('n', '<leader>lr', function ()
  local cmd = 'source ~/dotfiles/scripts/rtworks/commands.zsh;'
  vim.cmd('echom system(' .. "'zsh -c " .. '"' .. cmd .. 'fn_rtworks_local_run"' .. "')")
end, { desc = "RTWORKS local launch" })

map('t', '<C-l><C-r>', function ()
  local cmd = 'source ~/dotfiles/scripts/rtworks/commands.zsh;'
  vim.cmd('echom system(' .. "'zsh -c " .. '"' .. cmd .. 'fn_rtworks_local_run"' .. "')")
end, { desc = "RTWORKS local launch" })

map('n', '<leader>re', function ()
  terminal_launch("sp", "re")
end, { desc = "RTWORKS remote build and execute" })

map('n', '<leader>rr', function ()
  terminal_launch("sp", "rr")
end, { desc = "RTWORKS remote launch" })

