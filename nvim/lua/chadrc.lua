-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

local function gen_block(icon, txt, sep_l_hlgroup, iconHl_group, txt_hl_group)
  local sep_l = "█"
  local sep_r = "%#St_sep_r#" .. "█" .. " %#ST_EmptySpace#"

  return sep_l_hlgroup .. sep_l .. iconHl_group .. icon .. " " .. txt_hl_group .. " " .. txt .. sep_r
end

M.base46 = {
  theme = "onedark", -- default theme
  hl_add = {},
  hl_override = {},
  integrations = {},
  changed_themes = {},
  transparency = false,
  theme_toggle = { "onedark", "one_light" },
}

M.ui = {
  statusline = {
    theme = "minimal",
    separator_style = "block",
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "filetype", "cursor" },
    modules = {
      file = function()
        local cwd = vim.loop.cwd()
        cwd = cwd:match "([^/\\]+)[/\\]*$" or cwd

        local file = vim.fn.fnamemodify(vim.fn.expand "%", ":.")
        file = (string.find(file, "NvimTree") and "" or file)

        local path = cwd .. (file ~= "" and "/" or "") .. file
        return gen_block("", path, "%#St_file_sep#", "%#St_file_bg#", "%#St_file_txt#")
      end,

      filetype = function()
        return gen_block("", vim.bo.filetype, "%#St_cwd_sep#", "%#St_cwd_bg#", "%#St_cwd_txt#")
      end,

      lsp = function()
        if rawget(vim, "lsp") then
          for _, client in ipairs(vim.lsp.get_active_clients()) do
            if
              client.attached_buffers[vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)]
              and client.name ~= "null-ls"
            then
              return gen_block("", client.name, "%#St_lsp_sep#", "%#St_lsp_bg#", "%#St_lsp_txt#")
            end
          end
        end

        return ""
      end,

      cursor = function()
        return gen_block("", "%3c/%3l (%2p%%)", "%#St_Pos_sep#", "%#St_Pos_bg#", "%#St_Pos_txt#")
      end,
    },
  },

  tabufline = {
    enabled = true,
    lazyload = false,
    order = { "treeOffset", "buffers", "tabs" },
  },
}

M.lsp = {
  signature = false,
}

return M
