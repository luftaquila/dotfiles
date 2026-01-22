require "nvchad.mappings"

local map = vim.keymap.set
local unmap = vim.keymap.del
local term = require "nvchad.term"

-- smart-splits.nvim
map("n", "<A-h>", require("smart-splits").resize_left)
map("n", "<A-j>", require("smart-splits").resize_down)
map("n", "<A-k>", require("smart-splits").resize_up)
map("n", "<A-l>", require("smart-splits").resize_right)

map("n", "<C-h>", require("smart-splits").move_cursor_left)
map("n", "<C-j>", require("smart-splits").move_cursor_down)
map("n", "<C-k>", require("smart-splits").move_cursor_up)
map("n", "<C-l>", require("smart-splits").move_cursor_right)
map("n", "<C-\\>", require("smart-splits").move_cursor_previous)

map("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
map("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
map("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
map("n", "<leader><leader>l", require("smart-splits").swap_buf_right)

-- Tabs
map("n", "tn", ":tabnew<CR>", { desc = "Tab create new" })
map("n", "tx", ":tabclose<CR>", { desc = "Tab close" })
map("n", "tl", ":tabnext<CR>", { desc = "Tab next" })
map("n", "th", ":tabprev<CR>", { desc = "Tab prev" })

-- Ctrl + P to previous window
map("n", "<C-p>", "<C-w>p", { desc = "Jump to previous window" })

-- LSP
map("n", "<leader>fi", ":Lspsaga incoming_calls<CR>", { desc = "LSP incoming calls" })
map("n", "<leader>fo", ":Lspsaga outgoing_calls<CR>", { desc = "LSP outgoing calls" })
map("n", "<leader>ca", ":Lspsaga code_action<CR>", { desc = "LSP code action" })
map("n", "<leader>fd", ":Lspsaga finder<CR>", { desc = "LSP finder" })
map("n", "K", ":Lspsaga hover_doc<CR>", { desc = "LSP documentation" })
map("n", "tt", ":Lspsaga outline<CR>", { desc = "LSP code outline" })

-- Telescope
local telescope = require "telescope.builtin"

map("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "Telescope find LSP symbols" })
map("n", "<leader>ft", telescope.lsp_dynamic_workspace_symbols, { desc = "Telescope find LSP tags" })
map("n", "<leader>fl", telescope.diagnostics, { desc = "Telescope find LSP diagnostics" })

map("n", "<leader>fu", telescope.grep_string, { desc = "Telescope grep string under cursor" })
map("n", "<leader>fw", telescope.live_grep, { desc = "Telescope live grep" })

map("n", "<leader>fk", telescope.keymaps, { desc = "Telescope find keymaps" })
map("n", "<leader>fr", telescope.registers, { desc = "Telescope find registers" })

-- macro
map("n", "<CR>", "@q", { desc = "Macro play @q" })

-- terminals
map("n", "<leader>tm", function()
  term.toggle { pos = "float", id = "floating" }
end, { desc = "Terminal Toggle Floating terminal" })
unmap("n", "<leader>h")
unmap("n", "<leader>v")
