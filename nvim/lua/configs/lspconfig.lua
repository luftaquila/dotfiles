local servers = {
  "asm_lsp",
  "bashls",
  "biome",
  "clangd",
  "cmake",
  "cssls",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "openscad_lsp",
  "ruff",
  "rust_analyzer",
  "taplo",
  "tinymist",
  "vale_ls",
  "vtsls",
}

vim.api.nvim_create_user_command("LspFormat", function()
  -- Use null-ls if present
  if vim.fn.exists ":NullFormat" == 2 then
    vim.cmd "NullFormat"
    return
  end

  -- Fallback to whatever lsp server has formatting capabilities
  vim.lsp.buf.format()
end, { desc = "Format current buffer" })

-- disable default lsp code action keymap
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.schedule(function()
      -- ignore error despite failure
      pcall(vim.keymap.del, { "n", "v" }, "<leader>ca", { buffer = args.buf })
    end)
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

vim.lsp.config("clangd", {
  settings = {
    clangd = {
      InlayHints = {
        Designators = true,
        Enabled = true,
        ParameterNames = true,
        DeducedTypes = true,
      },
      fallbackFlags = { "-std=c++20" },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      inlayHints = {
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
          useParameterNames = false,
        },
        maxLength = 25,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "never",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
    },
  },
})

vim.lsp.config("html", {
  filetypes = { "html", "vue" },
})

vim.lsp.config("tinymist", {
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType",
    semanticTokens = "disable",
  },
})

for _, lsp in ipairs(servers) do
  vim.lsp.enable(lsp)
end
