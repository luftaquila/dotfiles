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

map('n', '<leader>rr', function ()
  require("nvchad.term").new { pos = "float", size = 0.3 }

  vim.api.nvim_chan_send(vim.b[0].channel, "ls\n")

end, { desc = "RTWORKS build" })

-- Floating terminal
map("n", "<leader>a", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal Toggle Floating term" })

