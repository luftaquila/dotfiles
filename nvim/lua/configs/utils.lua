local M = {}
local fn = vim.fn

function M.command(cmd, match)
  if fn.getcmdtype() == ":" and fn.getcmdline():match("^" .. cmd) then
    return match
  else
    return cmd
  end
end

function M.cabbrev(input, replace)
  local cmd = "cnoreabbrev <expr> %s v:lua.require'configs.utils'.command('%s', '%s')"

  vim.cmd(cmd:format(input, input, replace))
end

function M.set_filetype(pattern, filetype)
  vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
    pattern = pattern,
    callback = function()
      vim.bo.filetype = filetype
    end,
  })
end

return M
