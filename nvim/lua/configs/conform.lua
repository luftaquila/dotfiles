local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    html = { "biome" },
    css = { "biome" },
    vue = { "biome", "prettier" },
  },
  formatters = {
    ["clang-format"] = {
      prepend_args = {
        "--style=file:" .. vim.fn.expand "~/dotfiles/tools/clang/.clang-format",
      },
    },
    biome = {
      args = {
        "format",
        "--config-path",
        vim.fn.expand "~/dotfiles/tools/biome",
        "--stdin-file-path",
        "$FILENAME",
      },
      stdin = true,
    },
    prettier = {
      prepend_args = { "--print-width", "120" },
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

require("conform").setup(options)
