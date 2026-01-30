return {
  {
    "stevearc/conform.nvim",
    config = function()
      require "configs.conform"
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate" },
    config = function()
      require("mason-tool-installer").setup {
        ensure_installed = {
          "bash-language-server",
          "biome",
          "clangd",
          "cmake-language-server",
          "json-lsp",
          "lua-language-server",
          "marksman",
          "openscad-lsp",
          "ruff",
          "rust-analyzer",
          "taplo",
          "tinymist",
          "vtsls",
          "vue-language-server",
          "clang-format",
          "prettier",
          "stylua",
        },
      }
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "mason-org/mason.nvim",
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

  { "hrsh7th/nvim-cmp", enabled = false },

  -- custom plugins -----------------------------------------------------------
  {
    "wakatime/vim-wakatime",
    event = { "BufReadPost", "BufNewFile" },
  },

  {
    "mrjones2014/smart-splits.nvim",
    event = "VimEnter",
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    config = function()
      require("treesitter-context").setup {}
    end,
  },

  {
    "nvimdev/lspsaga.nvim",
    event = "VeryLazy",
    config = function()
      require("lspsaga").setup {
        lightbulb = {
          virtual_text = false,
        },
        outline = {
          win_width = 50,
        },
      }
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "nvim-mini/mini.nvim",
    event = "VeryLazy",
    version = false,
    config = function()
      require("mini.ai").setup {}
      require("mini.comment").setup {}
      require("mini.pairs").setup {}
      require("mini.surround").setup {}
      require("mini.jump").setup {
        mappings = {
          forward_till = "",
          backward_till = "",
          repeat_jump = "",
        },
      }
      require("mini.jump2d").setup {}
      require("mini.sessions").setup {}
      require("mini.cursorword").setup {
        delay = 0,
      }
      require("mini.hipatterns").setup {
        highlighters = {
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
          hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        },
      }
      require("mini.trailspace").setup {}

      vim.keymap.set("n", "<leader>tr", require("mini.trailspace").trim, { desc = "Trim all trailing whitespaces" })
      vim.keymap.set("n", "<leader>sl", require("mini.sessions").read, { desc = "Load Session" })
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          require("mini.sessions").write "default"
        end,
      })
    end,
  },

  -- text edit -----------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
      },
      exclude = {
        "notify",
        "noice",
        "cmp_menu",
        "TelescopePrompt",
      },
    },
    keys = {
      {
        "t",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "T",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  {
    "saghen/blink.cmp",
    event = "VeryLazy",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "enter" },
      completion = {
        documentation = { auto_show = true },
      },
    },
  },

  -- utils ---------------------------------------------------------------------
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
    cmd = { "SudaRead", "SudaWrite", "R", "W" },
    init = function()
      vim.api.nvim_create_user_command("R", function()
        vim.cmd "SudaRead"
      end, {})
      vim.api.nvim_create_user_command("W", function()
        vim.cmd "SudaWrite"
      end, {})
    end,
    config = function()
      vim.g.suda_smart_edit = 1
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
    "fasterius/simple-zoom.nvim",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "<leader>z", require("simple-zoom").toggle_zoom)
    end,
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

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
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
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    opts = {},
  },

  {
    "jannis-baum/vivify.vim",
    event = "VeryLazy",
  },

  -- ui ------------------------------------------------------------------------
  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {}, -- required, even if empty
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
    "nvim-telescope/telescope-fzf-native.nvim",
    event = "VeryLazy",
    build = "make",
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
}
