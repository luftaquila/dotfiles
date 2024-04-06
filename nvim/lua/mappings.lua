require "nvchad.mappings"

local map = vim.keymap.set

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
    require("nvchad.term").toggle { pos = mode, size = size and size or 0.3, id = id }
    ch = vim.b[opts_to_id(id).buf].terminal_job_id
  else
    require("nvchad.term").new { pos = mode, size = size and size or 0.3 }
    ch = vim.b[vim.api.nvim_get_current_buf()].terminal_job_id
  end

  -- note: send cmd to toggled channel is not working
  vim.api.nvim_chan_send(ch, cmd .. "\n")
end

-- Telescope
map('n', '<leader>ft', require('telescope.builtin').tags, { desc = "Telescope find tags" })

-- macro
map('n', '<CR>', '@q', { desc = "Macro play @q" })

-- Tabs
map('n', 'tn', ':tabnew<CR>', { desc = "Tab create new" })
map('n', 'tc', ':tabclose<CR>', { desc = "Tab close" })
map('n', 'tl', ':tabnext<CR>', { desc = "Tab next" })
map('n', 'th', ':tabprev<CR>', { desc = "Tab prev" })

-- terminals
map('n', '<leader>v', function()
  require("nvchad.term").toggle { pos = "vsp", id = "vertical" }
end, { desc = "Terminal Toggle vertical terminal" })

map('n', '<leader>h', function()
  require("nvchad.term").toggle { pos = "sp", id = "horizontal" }
end, { desc = "Terminal Toggle horizontal terminal" })

map('n', '<leader>a', function()
  require("nvchad.term").toggle { pos = "float", id = "floating" }
end, { desc = "Terminal Toggle Floating terminal" })

-- Ctrl + P to previous window
map('n', '<C-p>', '<C-w>p<ESC>', { desc = "Jump to previous window" })
map('t', '<C-p>', '<C-\\><C-o><C-w>p<ESC>', { desc = "Jump to previous window" })

-- RTWORKS
map('n', '<leader>sm', function ()
  terminal_launch("vsp", "cons", "serial")
end, { desc = "Serial monitor open" })

map('n', '<leader>bb', function ()
  terminal_launch("sp", "bb")
end, { desc = "RTWORKS build" })

map('n', '<leader>bl', function ()
  terminal_launch("sp", "bb l4")
end, { desc = "RTWORKS build verbose" })

map('n', '<leader>mk', function ()
  terminal_launch("sp", "mm k")
end, { desc = "RTWORKS misra kernel" })

map('n', '<leader>mp', function ()
  terminal_launch("sp", "mm p")
end, { desc = "RTWORKS misra partition" })

map('n', '<leader>le', function ()
  terminal_launch("sp", "le")
end, { desc = "RTWORKS local build and execute" })

map('n', '<leader>lr', function ()
  local cmd = 'source ~/dotfiles/scripts/rtworks/commands.zsh;'
  vim.cmd('echom system(' .. "'zsh -c " .. '"' .. cmd .. 'fn_rtworks_local_run"' .. "')")
end, { desc = "RTWORKS local launch" })

map('n', '<leader>re', function ()
  terminal_launch("sp", "re")
end, { desc = "RTWORKS remote build and execute" })

map('n', '<leader>rr', function ()
  terminal_launch("sp", "rr")
end, { desc = "RTWORKS remote launch" })

