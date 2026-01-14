require "nvchad.mappings"

local map = vim.keymap.set
local term = require "nvchad.term"

-- smart-splits.nvim
vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)

vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)

vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)

-- Tabs
map("n", "tn", ":tabnew<CR>", { desc = "Tab create new" })
map("n", "tx", ":tabclose<CR>", { desc = "Tab close" })
map("n", "tl", ":tabnext<CR>", { desc = "Tab next" })
map("n", "th", ":tabprev<CR>", { desc = "Tab prev" })

-- Ctrl + P to previous window
map("n", "<C-p>", "<C-w>p", { desc = "Jump to previous window" })

-- LSP
map("n", "<leader>lf", vim.diagnostic.open_float, { desc = "Diagnostics under cursor" })

-- Telescope
local telescope = require "telescope.builtin"

map("n", "<leader>ca", require("actions-preview").code_actions, { desc = "Telescope LSP code action preview" })
map("n", "<leader>fd", telescope.lsp_definitions, { desc = "Telescope find LSP definitions" })
map("n", "<leader>fp", telescope.lsp_type_definitions, { desc = "Telescope find LSP type definitions" })
map("n", "<leader>fc", telescope.lsp_incoming_calls, { desc = "Telescope find LSP incoming calls" })
map("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Telescope find LSP symbols" })
map("n", "<leader>ft", telescope.lsp_dynamic_workspace_symbols, { desc = "Telescope find LSP tags" })
map("n", "<leader>fl", telescope.diagnostics, { desc = "Telescope find LSP diagnostics" })

map("n", "<leader>fu", telescope.grep_string, { desc = "Telescope grep string under cursor" })
map("n", "<leader>fw", telescope.live_grep, { desc = "Telescope live grep" })

map("n", "<leader>fk", telescope.keymaps, { desc = "Telescope find keymaps" })
map("n", "<leader>fr", telescope.registers, { desc = "Telescope find registers" })

-- Inlay Hints
map("n", "H", ":InlayHintsToggle<CR>", { desc = "Toggle Inlay Hints" })

-- macro
map("n", "<CR>", "@q", { desc = "Macro play @q" })

-- terminals
map("n", "<leader>a", function()
  term.toggle { pos = "float", id = "floating" }
end, { desc = "Terminal Toggle Floating terminal" })

