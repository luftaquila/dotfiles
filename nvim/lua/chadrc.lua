-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

local function gen_block(icon, txt, sep_l_hlgroup, iconHl_group, txt_hl_group)
  local sep_l = '█'
  local sep_r = "%#St_sep_r#" .. '█' .. " %#ST_EmptySpace#"

  return sep_l_hlgroup .. sep_l .. iconHl_group .. icon .. " " .. txt_hl_group .. " " .. txt .. sep_r
end

M.ui = {
  theme = "onedark",

  statusline = {
    theme = "minimal",
    separator_style = "block",
    modules = {
      file = function()
        local utils = require "nvchad.stl.utils"
        local x = utils.file()
        x[2] = vim.fn.expand('%')
        return gen_block(x[1], x[2], "%#St_file_sep#", "%#St_file_bg#", "%#St_file_txt#")
      end,

      lsp = function()
        if rawget(vim, "lsp") then
          for _, client in ipairs(vim.lsp.get_active_clients()) do
            if client.attached_buffers[vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)] and client.name ~= "null-ls" then
              return gen_block("", client.name, "%#St_lsp_sep#", "%#St_lsp_bg#", "%#St_lsp_txt#")
            end
          end
        end

        return ""
      end,

      cursor = function()
        return gen_block("", "%3c/%3l (%2p%%)", "%#St_Pos_sep#", "%#St_Pos_bg#", "%#St_Pos_txt#")
      end
    }
  },

  tabufline = {
    enabled = true,
    lazyload = false,
    order = {"treeOffset", "buffers", "tabs" },
  }
}

return M
