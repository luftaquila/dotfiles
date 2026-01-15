return {
  {
    "stevearc/conform.nvim",
    config = function()
      require "configs.conform"
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "bashls",
        "biome",
        "clangd",
        "cmake",
        "jsonls",
        "lua_ls",
        "marksman",
        "openscad_lsp",
        "ruff",
        "rust_analyzer",
        "stylua",
        "taplo",
        "tinymist",
        "vtsls",
        "vue_ls",
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
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
        "comment",
        "cpp",
        "css",
        "csv",
        "diff",
        "disassembly",
        "dockerfile",
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
        "json5",
        "kconfig",
        "latex",
        "llvm",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "nginx",
        "ninja",
        "objdump",
        "passwd",
        "powershell",
        "printf",
        "python",
        "regex",
        "rst",
        "rust",
        "sql",
        "ssh_config",
        "t32",
        "tmux",
        "toml",
        "typescript",
        "typst",
        "udev",
        "vhdl",
        "vim",
        "vue",
        "xml",
        "yaml",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- custom plugins -----------------------------------------------------------
  {
    "luftaquila/nvim-cursorline",
    event = "VimEnter",
    config = function()
      require("nvim-cursorline").setup {
        cursorline = {
          timeout = 0,
        },
      }
    end,
  },

  {
    "wakatime/vim-wakatime",
    event = "VimEnter",
  },

  {
    "mrjones2014/smart-splits.nvim",
    event = "VimEnter",
  },

  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {}, -- required, even if empty
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    lazy = false,
    cmd = "Copilot",
    config = function()
      -- exclude copilot in certain paths
      local augroup = vim.api.nvim_create_augroup("copilot-disable-patterns", { clear = true })

      for _, pattern in ipairs { "*/*rtworks*/*" } do
        vim.api.nvim_create_autocmd("LspAttach", {
          group = augroup,
          pattern = pattern,
          callback = vim.schedule_wrap(function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if client.name == "copilot" then
              vim.cmd "Copilot detach"
            end
          end),
        })
      end

      require("copilot").setup {
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<Right>",
            next = "<Down>",
            prev = "<Up>",
            dismiss = "<Left>",
          },
        },
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    config = function()
      require("treesitter-context").setup {}
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    event = "VeryLazy",
    build = "make",
  },

  {
    "nvimdev/lspsaga.nvim",
    event = "VeryLazy",
    config = function()
      require("lspsaga").setup {
        lightbulb = {
          virtual_text = false,
        },
      }
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "ojroques/nvim-osc52",
    event = "VeryLazy",
    config = function()
      require("osc52").setup {}
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            require("osc52").copy_register '"'
          end
        end,
      })
    end,
  },

  {
    "lambdalisue/vim-suda",
    event = "VeryLazy",
    config = function()
      vim.g.suda_smart_edit = 1
      vim.api.nvim_create_user_command("R", "SudaRead", {})
      vim.api.nvim_create_user_command("W", "SudaWrite", {})
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
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup {}
    end,
  },

  {
    "folke/persistence.nvim",
    event = "VeryLazy",
    config = function()
      local persistence = require "persistence"
      persistence.setup {}
      vim.keymap.set("n", "<leader>qs", persistence.load, { desc = "Load session for the current directory" })
      vim.keymap.set("n", "<leader>qS", persistence.select, { desc = "Load a selected session" })
      vim.keymap.set("n", "<leader>ql", persistence.load, { desc = "Load last session" })
      vim.keymap.set("n", "<leader>qd", persistence.stop, { desc = "Do not save session on exit" })
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("notify").setup {
        fps = 3,
        render = "default",
        stages = "static",
        timeout = 3000,
      }
      require("noice").setup {}
    end,
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config { virtual_text = false }
    end,
  },

  {
    "Skosulor/nibbler",
    event = "VeryLazy",
    config = function()
      require("nibbler").setup {
        display_enabled = true,
      }
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function(_, opts)
      local highlight = { "RainbowRed", "RainbowBlue", "RainbowOrange", "RainbowGreen", "RainbowViolet", "RainbowCyan" }

      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        vim.api.nvim_set_hl(0, "IndentGray", { fg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg })
      end)

      vim.g.rainbow_delimiters = { highlight = highlight }

      require("ibl").setup {
        indent = { highlight = { "IndentGray" } },
        scope = { highlight = highlight },
        whitespace = { remove_blankline_trail = true },
      }

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
    dependencies = { "HiPhish/rainbow-delimiters.nvim" },
  },

  {
    "fasterius/simple-zoom.nvim",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "<leader>z", require("simple-zoom").toggle_zoom)
    end,
  },

  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    opts = {},
  },

  {
    "jannis-baum/vivify.vim",
    event = "VeryLazy",
  },

  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      vim.keymap.set("n", "<leader>o", require("neogit").open, { desc = "Open NeoGit" })
    end,
  },

  -- {
  --   "echasnovski/mini.nvim",
  --   event = "VeryLazy",
  --   version = "*",
  -- },
}
