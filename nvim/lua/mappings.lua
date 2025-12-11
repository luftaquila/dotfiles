require "nvchad.mappings"

local map = vim.keymap.set
local term = require "nvchad.term"

-- Zellij
local zellij = require "zellij-nav"

map("n", "<C-h>", zellij.left, { desc = "Zellij navigate left" })
map("n", "<C-k>", zellij.up, { desc = "Zellij navigate up" })
map("n", "<C-j>", zellij.down, { desc = "Zellij navigate down" })
map("n", "<C-l>", zellij.right, { desc = "Zellij navigate right" })

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

map("n", "<leader>br", telescope.git_branches, { desc = "Telescope Git Branches" })
map("n", "<leader>gs", telescope.git_status, { desc = "Telescope Git Status" })
map("n", "<leader>gt", telescope.git_stash, { desc = "Telescope Git Stash" })

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

-- Leap
map("n", "s", "<Plug>(leap-forward)")
map("n", "S", "<Plug>(leap-backward)")
map("n", "gs", "<Plug>(leap-from-window)")

-- Inlay Hints
map("n", "H", ":InlayHintsToggle<CR>", { desc = "Toggle Inlay Hints" })

-- macro
map("n", "<CR>", "@q", { desc = "Macro play @q" })

-- terminals
map("n", "<leader>a", function()
  term.toggle { pos = "float", id = "floating" }
end, { desc = "Terminal Toggle Floating terminal" })

-- Debug
-- https://configure.zsa.io/moonlander/layouts/b750V/latest/3
local dap = require "dap"

map("n", "<leader>gg", require("dapui").toggle, { desc = "Debug open UI" })
map("n", "g?", dap.status, { desc = "Debug DAP status" })

map("n", "<F1>", dap.continue, { desc = "Debug continue" }) -- C
map("n", "<F2>", dap.run_last, { desc = "Debug run last configuration" }) -- R

map("n", "<F3>", dap.toggle_breakpoint, { desc = "Debug toggle breakpoint" }) -- B
map("n", "<F4>", dap.clear_breakpoints, { desc = "Debug clear all breakpoints" }) -- W
map("n", "<F5>", dap.run_to_cursor, { desc = "Debug run to the current cursor" }) -- V

map("n", "<F6>", dap.step_over, { desc = "Debug step over (next)" }) -- T
map("n", "<F7>", dap.step_into, { desc = "Debug step into (step)" }) -- S
map("n", "<F8>", function()
  dap.repl.execute "stepi"
end, { desc = "Debug step instruction (stepi)" }) -- A
map("n", "<F9>", dap.step_out, { desc = "Debug step out (finish)" }) -- F
