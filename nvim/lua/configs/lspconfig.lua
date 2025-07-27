local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
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
  "ruff",
  "rust_analyzer",
  "taplo",
  "vale_ls",
  "vtsls",
}

-- custom lsp servers
local configs = require "lspconfig.configs"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

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

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}

lspconfig.clangd.setup {
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
}

lspconfig.rust_analyzer.setup {
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
}

lspconfig.html.setup {
  filetypes = { "html", "vue" },
}
