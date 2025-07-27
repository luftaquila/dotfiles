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
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "term://*",
  callback = function()
    vim.cmd "stopinsert"
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = { "*.html", "*.vue", "*.js", "*.ts" },
  callback = function()
    vim.bo.expandtab   = true
    vim.bo.tabstop     = 2
    vim.bo.shiftwidth  = 2
    vim.bo.softtabstop = 2
  end,
})
