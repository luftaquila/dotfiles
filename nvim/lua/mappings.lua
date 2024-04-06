require "nvchad.mappings"

-- add yours here
local map = vim.keymap.set

-- Telescope
local builtin = require('telescope.builtin')
map('n', '<leader>ft', builtin.tags, { desc = "Telescope find tags" })

-- Tabs
map('n', 'tn', ':tabnew<CR>', { desc = "Tab create new" })
map('n', 'tc', ':tabclose<CR>', { desc = "Tab close" })
map('n', 'tl', ':tabnext<CR>', { desc = "Tab next" })
map('n', 'th', ':tabprev<CR>', { desc = "Tab prev" })

-- Floating terminal
map('n', '<leader>a', function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal Toggle Floating term" })

-- Ctrl + P to previous window
map('n', '<C-p>', '<C-w>p<ESC>')
map('t', '<C-p>', '<C-\\><C-o><C-w>p<ESC>')

-- Easymotion
map('n', '<leader>m', '<Plug>(easymotion-prefix)')

-- RTWORKS
map('n', '<leader>sm', function ()
  require("nvchad.term").new { pos = "vsp", size = 0.3 }
  local ch = vim.b[vim.api.nvim_get_current_buf()].terminal_job_id
  vim.api.nvim_chan_send(ch, "cons\n")
end, { desc = "Serial monitor open" })

map('n', '<leader>le', function ()
  require("nvchad.term").new { pos = "float", size = 0.3 }
  local ch = vim.b[vim.api.nvim_get_current_buf()].terminal_job_id
  vim.api.nvim_chan_send(ch, "le\n")
end, { desc = "RTWORKS local build and execute" })

map('n', '<leader>lr', function ()
  require("nvchad.term").new { pos = "float", size = 0.3 }
  local ch = vim.b[vim.api.nvim_get_current_buf()].terminal_job_id
  vim.api.nvim_chan_send(ch, "lr\n")
end, { desc = "RTWORKS local launch target" })

