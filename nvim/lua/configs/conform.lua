local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    vue = { "biome" },
  },
  formatters = {
    prettier = {
      prepend_args = {
        "--print-width", "120",
      },
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

require("conform").setup(options)
