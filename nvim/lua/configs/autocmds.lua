----- restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    vim.cmd 'silent! normal! g`"zv'
  end,
})

----- auto enter/leave insert mode on terminal buffers
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    vim.cmd "startinsert"
    -- vim.cmd('HideBadWhitespace')
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "term://*",
  callback = function()
    vim.cmd "stopinsert"
    -- vim.cmd('ShowBadWhitespace')
  end,
})

