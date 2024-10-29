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
    "lewis6991/satellite.nvim",
    event = "VimEnter",
    config = function()
      require("satellite").setup()
    end,
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
    "roobert/surround-ui.nvim",
    event = "VeryLazy",
    dependencies = {
      "kylechui/nvim-surround",
      "folke/which-key.nvim",
    },
    config = function()
      require("surround-ui").setup {
        root_key = "S",
      }
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
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-g>",
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
    "xolox/vim-session",
    event = "VeryLazy",
    dependencies = {
      "xolox/vim-misc",
    },
    config = function()
      vim.opt.sessionoptions:remove "buffers"
      vim.g.session_autosave = "yes"
      vim.g.session_autoload = "no"
      vim.g.session_autosave_periodic = 1
      vim.g.session_autosave_silent = 1
      vim.g.session_default_overwrite = 1
      vim.g.session_command_aliases = 1

      vim.api.nvim_create_user_command("O", "OpenSession default", {})

      vim.api.nvim_create_user_command("SS", function(opts)
        vim.cmd("SaveSession " .. opts.args)
      end, { nargs = 1 })

      vim.api.nvim_create_user_command("OS", function(opts)
        vim.cmd("OpenSession " .. opts.args)
      end, { nargs = 1 })

      vim.api.nvim_create_user_command("DS", function(opts)
        vim.cmd("DeleteSession " .. opts.args)
      end, { nargs = 1 })
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
      require("dapui").setup()
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
    "luftaquila/nibbler",
    event = "VeryLazy",
    config = function()
      require("nibbler").setup {
        display_enabled = true,
      }
    end,
  },
}
