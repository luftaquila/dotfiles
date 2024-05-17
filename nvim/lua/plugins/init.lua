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
        "asm-lsp",
        "asmfmt",
        "bash-language-server",
        "black",
        "clang-format",
        "clangd",
        "cmake-language-server",
        "css-lsp",
        "harper-ls",
        "html-lsp",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "prettier",
        "pyright",
        "rust-analyzer",
        "stylua",
        "taplo",
        "write-good",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "asm",
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "csv",
        "diff",
        "disassembly",
        "doxygen",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "html",
        "ini",
        "java",
        "javascript",
        "json",
        "llvm",
        "lua",
        "make",
        "markdown_inline",
        "objdump",
        "python",
        "regex",
        "rst",
        "rust",
        "t32",
        "tmux",
        "toml",
        "verilog",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
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
    event = "VimEnter",
  },

  {
    "xolox/vim-misc",
    event = "VimEnter",
  },

  {
    "xolox/vim-session",
    event = "VeryLazy",
    config = function()
      vim.opt.sessionoptions:remove "buffers"
      vim.g.session_autosave = "yes"
      vim.g.session_autoload = "no"
      vim.g.session_autosave_periodic = 1
      vim.g.session_autosave_silent = 1
      vim.g.session_default_overwrite = 1
      vim.g.session_command_aliases = 1

      vim.api.nvim_create_user_command("O", function()
        vim.cmd "OpenSession"
      end, {})
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "unblevable/quick-scope",
    event = "VeryLazy",
  },

  {
    "easymotion/vim-easymotion",
    event = "VeryLazy",
  },

  {
    "aznhe21/actions-preview.nvim",
    event = "VeryLazy",
    config = function()
      require("actions-preview").setup {
        highlight_command = {
          require("actions-preview.highlight").delta(),
        },
        backend = { "telescope" },
        telescope = {
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
              return max_lines - 15
            end,
          },
        },
      }
    end,
  },

  {
    "shortcuts/no-neck-pain.nvim",
    event = "VeryLazy",
    config = function()
      require("no-neck-pain").setup {
        width = 140,
      }
    end,
  },

  {
    "liuchengxu/vista.vim",
    event = "VeryLazy",
    config = function()
      vim.cmd "let g:vista_blink = [0, 0]"
      vim.cmd "let g:vista_sidebar_position = 'vertical topleft'"
      vim.cmd "let g:vista_default_executive = 'nvim_lsp'"
    end,
  },

  {
    "abecodes/tabout.nvim",
    event = "VeryLazy",
    config = function()
      require("tabout").setup {
        act_as_tab = false;
      }
    end,
  },

  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  }

  -- {
  --   "bitc/vim-bad-whitespace",
  --   event = "VeryLazy",
  --   config = function()
  --     vim.cmd "ShowBadWhitespace"
  --     -- this plugin replaces:
  --     -- vim.opt.list = true
  --     -- vim.opt.listchars = { eol = ' ', trail = '█', tab = '>-', nbsp = '␣' }
  --   end,
  -- },

  -- {
  --   "lewis6991/satellite.nvim",
  --   event = 'VimEnter',
  --   config = function ()
  --     require('satellite').setup()
  --   end
  -- }
}

-- liuchengxu/vista.vim
