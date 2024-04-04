return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server", "stylua",
        "html-lsp", "css-lsp" , "prettier",
        "bash-language-server", "clangd", "cmake-language-server",
        "grammarly-languageserver", "json-lsp", "marksman", "pyright", "rust-analyzer",
        "clang-format"
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "asm", "disassembly", "objdump",
        "c", "cpp", "java", "javascript", "lua", "python", "rust", "verilog",
        "html", "css", "csv", "doxygen", "json", "latex", "markdown_inline", "regex", "rst", "toml", "xml", "yaml",
        "arduino", "bash", "diff", "make", "cmake", "llvm", "t32", "tmux", "vim", "vimdoc",
        "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  -- custom plugins
  {
    "wakatime/vim-wakatime",
    event = 'VimEnter'
  },

  {
    "xolox/vim-misc",
    event = 'VimEnter'
  },

  {
    "xolox/vim-session",
    event = 'VimEnter'
  },

  -- {
  --   "lewis6991/satellite.nvim",
  --   event = 'VimEnter',
  --   config = function ()
  --     require('satellite').setup()
  --   end
  -- }
}

-- easymotion/vim-easymotion
-- tpope/vim-surround
-- liuchengxu/vista.vim
