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
        "typescript-language-server",
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

  -- custom plugins -----------------------------------------------------------
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
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
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
  },

  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-g>",
      }
    end,
  },

  {
    "lewis6991/satellite.nvim",
    event = "VimEnter",
    config = function()
      require("satellite").setup()
    end,
  },

  {
    "luftaquila/nvim-cursorline",
    event = "VimEnter",
    config = function()
      require("nvim-cursorline").setup {}
    end,
  },

  {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("inlay-hints").setup()
    end,
  },
}
