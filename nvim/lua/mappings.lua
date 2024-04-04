require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

local builtin = require('telescope.builtin')
map('n', '<leader>ft', builtin.tags, { desc = "Telescope find tags" })

