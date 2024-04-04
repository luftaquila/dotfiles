-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
	theme = "onedark",

  statusline = {
    theme = "default",
    separator_style = "block",
    order = nil,
    modules = nil,
  },

  tabufline = {
    enabled = true,
    lazyload = false,
    order = {"treeOffset", "buffers", "tabs" },
    modules = nil
  }
}

return M
