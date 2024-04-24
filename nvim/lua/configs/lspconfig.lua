local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "asm_lsp", "bashls", "clangd", "cssls", "cmake", "html", "jsonls", "marksman", "pyright", "rust_analyzer" }

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
      vim.keymap.del({ "n", "v" }, "<leader>ca", { buffer = args.buf })
    end)
  end,
})
