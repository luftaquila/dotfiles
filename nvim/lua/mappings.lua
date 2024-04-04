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

