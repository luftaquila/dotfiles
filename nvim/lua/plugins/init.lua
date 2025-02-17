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
    "lambdalisue/vim-suda",
    event = "VimEnter",
    config = function()
      vim.g.suda_smart_edit = 1
      vim.api.nvim_create_user_command("R", "SudaRead", {})
      vim.api.nvim_create_user_command("W", "SudaWrite", {})
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

  {
    "unblevable/quick-scope",
    event = "VeryLazy",
  },

  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "shortcuts/no-neck-pain.nvim",
    event = "VeryLazy",
    config = function()
      require("no-neck-pain").setup {
        width = 150,
      }
    end,
  },

  {
    "liuchengxu/vista.vim",
    event = "VeryLazy",
    config = function()
      vim.cmd "let g:vista_blink = [0, 0]"
      vim.cmd "let g:vista_default_executive = 'nvim_lsp'"
    end,
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
    "kosayoda/nvim-lightbulb",
    event = "VeryLazy",
    config = function()
      require("nvim-lightbulb").setup {
        autocmd = { enabled = true },
      }
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    event = "VeryLazy",
    build = "make",
  },

  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
  },

  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require "configs.debug"
      require("dapui").setup {
        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 0.40,
              },
              {
                id = "breakpoints",
                size = 0.20,
              },
              {
                id = "stacks",
                size = 0.20,
              },
              {
                id = "watches",
                size = 0.20,
              },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              {
                id = "repl",
                size = 1,
              },
              -- {
              --   id = "console",
              --   size = 0.5,
              -- },
            },
            position = "bottom",
            size = 20,
          },
        },
      }
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
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

      require("noice").setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      }
    end,
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
    "Skosulor/nibbler",
    event = "VeryLazy",
    config = function()
      require("nibbler").setup {
        display_enabled = true,
      }
    end,
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
      require("lspsaga").setup {}
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },

  {
    "fasterius/simple-zoom.nvim",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "<leader>z", require("simple-zoom").toggle_zoom)
    end,
  },

  {
    "gorbit99/codewindow.nvim",
    event = "VeryLazy",
    config = function()
      local codewindow = require "codewindow"
      codewindow.setup {
        auto_enable = true,
      }
      codewindow.apply_default_keybinds()
      vim.api.nvim_set_hl(0, "CodewindowBorder", { fg = "#1e222a" })
    end,
  },
}
