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
        "html", "css", "csv", "doxygen", "json", "markdown_inline", "regex", "rst", "toml", "xml", "yaml",
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
    event = "VimEnter",
  },

  {
    "xolox/vim-session",
    event = "VeryLazy",
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  {
    "unblevable/quick-scope",
    event = "VeryLazy"
  },

  {
    "easymotion/vim-easymotion",
    event = "VeryLazy"
  },

  {
    'bitc/vim-bad-whitespace',
    event = "VeryLazy",
    config = function()
      vim.cmd('ShowBadWhitespace')
      -- this plugin replaces:
      -- vim.opt.list = true
      -- vim.opt.listchars = { eol = ' ', trail = '█', tab = '>-', nbsp = '␣' }
    end
  }

  -- {
  --   "lewis6991/satellite.nvim",
  --   event = 'VimEnter',
  --   config = function ()
  --     require('satellite').setup()
  --   end
  -- }
}

-- liuchengxu/vista.vim

