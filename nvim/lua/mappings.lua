require "nvchad.mappings"

local map = vim.keymap.set
local term = require "nvchad.term"

-- utils
local function opts_to_id(id)
  for _, opts in pairs(vim.g.nvchad_terms) do
    if opts.id == id then
      return opts
    end
  end
end

-- LSP
map("n", "<leader>lf", vim.diagnostic.open_float, { desc = "Diagnostics under cursor" })

-- Buffer
map("n", "<leader>bb", "<cmd>enew<CR>", { desc = "buffer new" })

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
map("t", "<C-p>", "<C-\\><C-o><C-w>p", { desc = "Jump to previous window" })

-- Telescope
local telescope = require "telescope.builtin"

map("n", "<leader>br", telescope.git_branches, { desc = "Telescope Git Branches" })
map("n", "<leader>gs", telescope.git_status, { desc = "Telescope Git Status" })
map("n", "<leader>gt", telescope.git_stash, { desc = "Telescope Git Stash" })

map("n", "<leader>ca", require("actions-preview").code_actions, { desc = "Telescope LSP code action preview" })
map("n", "<leader>fl", telescope.diagnostics, { desc = "Telescope find LSP diagnostics" })

map("n", "<leader>fc", telescope.commands, { desc = "Telescope find commands" })
map("n", "<leader>fr", telescope.registers, { desc = "Telescope find registers" })
map("n", "<leader>fu", telescope.grep_string, { desc = "Telescope grep string under cursor" })
map("n", "<leader>fb", telescope.current_buffer_fuzzy_find, { desc = "Telescope find current buffer" })

map("n", "<leader>fk", telescope.keymaps, { desc = "Telescope find keymaps" })
map("n", "<leader>fj", telescope.marks, { desc = "Telescope find marks" })
map("n", "<leader>fp", telescope.filetypes, { desc = "Telescope find filetypes" })
map("n", "<leader>fs", telescope.spell_suggest, { desc = "Telescope spell suggestion" })

map("n", "<leader>ft", telescope.lsp_dynamic_workspace_symbols, { desc = "Telescope find LSP tags" })

map("n", "<leader>fw", telescope.live_grep, { desc = "Telescope live grep" })
map("n", "<leader>fz", function()
  telescope.grep_string { search = "" }
end, { desc = "Telescope fuzzy grep string" })

-- Gitsigns
map("n", "<leader>df", require("gitsigns").diffthis, { desc = "Git diff" })

-- Vista
map("n", "tt", ":Vista!!<CR>", { desc = "Vista toggle tag window" })
map("n", "<leader>i", ":Vista focus<CR>", { desc = "Vista focus tag window" })

-- Leap
map("n", "s", "<Plug>(leap-forward)")
map("n", "S", "<Plug>(leap-backward)")
map("n", "gs", "<Plug>(leap-from-window)")

-- Inlay Hints
map("n", "H", ":InlayHintsToggle<CR>", { desc = "Toggle Inlay Hints" })

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

-- macro
map("n", "<CR>", "@q", { desc = "Macro play @q" })

-- terminals
map("n", "<leader>v", function()
  term.toggle { pos = "bo vsp", id = "vertical", size = 0.25 }
end, { desc = "Terminal Toggle vertical terminal" })

map("n", "<leader>h", function()
  term.toggle { pos = "bo sp", id = "horizontal" }
end, { desc = "Terminal Toggle horizontal terminal" })

map("n", "<leader>a", function()
  term.toggle { pos = "float", id = "floating" }
end, { desc = "Terminal Toggle Floating terminal" })

map("t", "<C-f>", function()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_close(win, true)
end, { desc = "Terminal Close term in terminal mode" })

map("t", "<ESC>", "<C-\\><C-N>", { desc = "Terminal Escape terminal mode" })

-- RTWORKS
map("n", "<leader>sm", function()
  term.runner { pos = "bo vsp", id = "console", cmd = "cons" }
end, { desc = "Serial monitor open" })

map("n", "<leader>lr", function()
  vim.cmd("echom system('zsh -c \" source ~/rtworks/rt.zsh; fn_rtworks lr; \"')")
end, { desc = "RTWORKS local launch" })

map("n", "<leader>b", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt b" }
end, { desc = "RTWORKS build" })

map("n", "<leader>bl", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt b l4" }
end, { desc = "RTWORKS build verbose" })

map("n", "<leader>le", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt le" }
end, { desc = "RTWORKS local build and execute" })

map("n", "<leader>ll", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt le l4" }
end, { desc = "RTWORKS local build and execute verbose" })

map("n", "<leader>ls", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt les l4" }
end, { desc = "RTWORKS local build and execute verbose serialized" })

map("n", "<leader>mk", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt m k" }
end, { desc = "RTWORKS misra kernel" })

map("n", "<leader>mp", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt m p" }
end, { desc = "RTWORKS misra partition" })

map("n", "<leader>re", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt re" }
end, { desc = "RTWORKS remote build and execute" })

map("n", "<leader>rr", function()
  term.runner { pos = "bo sp", id = "build", cmd = "rt rr" }
end, { desc = "RTWORKS remote launch" })
