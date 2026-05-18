local cmp = require "cmp"

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    dependencies = "neovim/nvim-lspconfig",
    config = function()
      require "configs.rustaceanvim"
    end,
  },
  { "nvzone/volt", lazy = true },
  { "nvzone/menu", lazy = true },

  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>lg",
        function()
          require("snacks").terminal.toggle("lazygit", { win = { position = "float", width = 0.9, height = 0.9 } })
        end,
        desc = "Lazygit",
      },
      {
        "<leader>pi",
        function()
          require("snacks").terminal.toggle("pi", {
            win = {
              position = "right",
              width = 0.35,
            },
            interactive = true,
          })
        end,
        desc = "Toggle Pi Agent",
      },
    },
    opts = { input = {}, picker = {}, terminal = {} },
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        width = 25,
      },
      git = {
        ignore = false,
      },
      renderer = {
        highlight_git = "all",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 0
    end,
  },
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      require("cmp").setup.buffer {
        sources = { { name = "crates" } },
      }
      crates.show()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local M = require "plugins.configs.cmp"
      M.completion.completeopt = "menu,menuone,noselect"
      M.mapping["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
      }
      table.insert(M.sources, { name = "crates" })
      return M
    end,
  },

  -- Claude Code
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<CR>", mode = "n", desc = "Toggle Claude Code" },
      { "<leader>cC", "<cmd>ClaudeCodeContinue<CR>", desc = "Continue conversation" },
      { "<leader>cR", "<cmd>ClaudeCodeResume<CR>", desc = "Resume conversation" },
      { "<leader>cV", "<cmd>ClaudeCodeVerbose<CR>", desc = "Verbose mode" },
    },
    opts = {
      window = {
        position = "vertical",
        split_ratio = 0.3,
        enter_insert = true,
        hide_numbers = true,
        hide_signcolumn = true,
      },
      keymaps = {
        toggle = {
          normal = false,
          terminal = false,
        },
        window_navigation = true,
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "norg", "rmd", "org", "opencode_output" },
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
      },
      sign = {
        enabled = true,
        highlight = "RenderMarkdownSign",
      },
    },
  },

  -- Opencode
  {
    "NickvanDyke/opencode.nvim",

    dependencies = {
      "MeanderingProgrammer/render-markdown.nvim",
      "folke/snacks.nvim",
    },

    -- Lazy load on these keymaps
    keys = {
      -- Core functionality
      {
        "<leader>oa",
        function()
          require("opencode").ask("", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "Ask opencode",
      },
      {
        "<leader>os",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "Execute opencode action…",
      },
      {
        "<leader>oo",
        function()
          require("opencode").toggle()
        end,
        mode = "n",
        desc = "Toggle opencode",
      },
      {
        "go",
        function()
          return require("opencode").operator "@this "
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Add range to opencode",
      },
      {
        "goo",
        function()
          return require("opencode").operator "@this " .. "_"
        end,
        mode = "n",
        expr = true,
        desc = "Add line to opencode",
      },
      {
        "<leader>ou",
        function()
          require("opencode").command "session.half.page.up"
        end,
        mode = "n",
        desc = "opencode half page up",
      },
      {
        "<leader>od",
        function()
          require("opencode").command "session.half.page.down"
        end,
        mode = "n",
        desc = "opencode half page down",
      },
      -- Prompts
      {
        "<leader>oA",
        function()
          require("opencode").ask "@file "
        end,
        desc = "Ask opencode about current file",
        mode = { "n", "v" },
      },
      {
        "<leader>on",
        function()
          require("opencode").command "/new"
        end,
        desc = "New session",
      },
      {
        "<leader>oe",
        function()
          require("opencode").prompt "Explain @cursor and its context"
        end,
        desc = "Explain code near cursor",
      },
      {
        "<leader>or",
        function()
          require("opencode").prompt "Review @file for correctness and readability"
        end,
        desc = "Review file",
      },
      {
        "<leader>of",
        function()
          require("opencode").prompt "Fix these @diagnostics"
        end,
        desc = "Fix errors",
      },
      {
        "<leader>oO",
        function()
          require("opencode").prompt "Optimize @selection for performance and readability"
        end,
        desc = "Optimize selection",
        mode = "v",
      },
      {
        "<leader>oD",
        function()
          require("opencode").prompt "Add documentation comments for @selection"
        end,
        desc = "Document selection",
        mode = "v",
      },
      {
        "<leader>ot",
        function()
          require("opencode").prompt "Add tests for @selection"
        end,
        desc = "Test selection",
        mode = "v",
      },
    },

    config = function()
      vim.g.opencode_opts = {
        -- Enable blink.cmp completion in ask input
        ask = {
          blink_cmp_sources = { "opencode", "buffer" },
        },

        -- Custom prompts (including Rust-specific)
        prompts = {
          unsafe_review = { prompt = "Review @this for unsafe Rust correctness and potential UB", submit = true },
          cargo_fix = { prompt = "Suggest fixes for these Cargo/clippy warnings: @diagnostics", submit = true },
          refactor = { prompt = "Refactor @this for better readability and maintainability", submit = true },
          types = { prompt = "Add or improve type annotations for @this", submit = true },
        },

        -- Picker layout
        select = {
          snacks = {
            layout = {
              preset = "vscode",
            },
          },
        },

        -- Provider settings (change 'enabled' to switch: "snacks", "kitty", "terminal")
        provider = {
          enabled = "snacks", -- Currently active provider
          snacks = {
            win = {
              position = "right",
              width = 0.35,
            },
          },
        },
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true
    end,
  },

  -- Opencode (new)
  {
    "sudo-tee/opencode.nvim",
    enabled = false,
    name = "opencode-sudotee",
    keys = {
      { "<leader>oo", desc = "Toggle opencode" },
      { "<leader>oi", desc = "Open input" },
      { "<leader>oI", desc = "Open input (new session)" },
      { "<leader>og", desc = "Open output" },
      { "<leader>os", desc = "Select session" },
      { "<leader>oq", desc = "Close" },
      { "<leader>ot", desc = "Toggle focus" },
      { "<leader>oT", desc = "Timeline" },
      { "<leader>oz", desc = "Toggle zoom" },
      { "<leader>op", desc = "Configure provider" },
      { "<leader>od", desc = "Diff open" },
      { "<leader>o]", desc = "Diff next" },
      { "<leader>o[", desc = "Diff prev" },
      { "<leader>oc", desc = "Diff close" },
      { "<leader>ox", desc = "Swap position" },
      { "<leader>oR", desc = "Rename session" },
      { "<leader>on", desc = "Open input new session" },
      { "<leader>ov", desc = "Paste image" },
      { "<leader>ora", desc = "Diff revert all last prompt" },
      { "<leader>ort", desc = "Diff revert this last prompt" },
      { "<leader>orA", desc = "Diff revert all" },
      { "<leader>orT", desc = "Diff revert this" },
      { "<leader>orr", desc = "Diff restore snapshot file" },
      { "<leader>orR", desc = "Diff restore snapshot all" },
      { "<leader>opa", desc = "Permission accept" },
      { "<leader>opA", desc = "Permission accept all" },
      { "<leader>opd", desc = "Permission deny" },
      { "<leader>ott", desc = "Toggle tool output" },
      { "<leader>otr", desc = "Toggle reasoning output" },
    },
    config = function()
      require("opencode").setup {
        preferred_picker = "snacks",
        preferred_completion = "blink",
        default_global_keymaps = true,
        keymap_prefix = "<leader>o",
        keymap = {
          editor = {
            ["<leader>oo"] = { "toggle" },
            ["<leader>oi"] = { "open_input" },
            ["<leader>oI"] = { "open_input_new_session" },
            ["<leader>og"] = { "open_output" },
            ["<leader>os"] = { "select_session" },
            ["<leader>oq"] = { "close" },
            ["<leader>ot"] = { "toggle_focus" },
            ["<leader>oT"] = { "timeline" },
            ["<leader>oz"] = { "toggle_zoom" },
            ["<leader>op"] = { "configure_provider" },
            ["<leader>od"] = { "diff_open" },
            ["<leader>o]"] = { "diff_next" },
            ["<leader>o["] = { "diff_prev" },
            ["<leader>oc"] = { "diff_close" },
            ["<leader>ox"] = { "swap_position" },
            ["<leader>oR"] = { "rename_session" },
            ["<leader>on"] = { "open_input_new_session" },
            ["<leader>ov"] = { "paste_image" },
            ["<leader>ora"] = { "diff_revert_all_last_prompt" },
            ["<leader>ort"] = { "diff_revert_this_last_prompt" },
            ["<leader>orA"] = { "diff_revert_all" },
            ["<leader>orT"] = { "diff_revert_this" },
            ["<leader>orr"] = { "diff_restore_snapshot_file" },
            ["<leader>orR"] = { "diff_restore_snapshot_all" },
            ["<leader>opa"] = { "permission_accept" },
            ["<leader>opA"] = { "permission_accept_all" },
            ["<leader>opd"] = { "permission_deny" },
            ["<leader>ott"] = { "toggle_tool_output" },
            ["<leader>otr"] = { "toggle_reasoning_output" },
          },
          input_window = {
            ["<cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
            ["<esc>"] = { "close" },
            ["<C-c>"] = { "cancel" },
            ["~"] = { "mention_file", mode = "i" },
            ["@"] = { "mention", mode = "i" },
            ["/"] = { "slash_commands", mode = "i" },
            ["#"] = { "context_items", mode = "i" },
            ["<tab>"] = { "toggle_pane", mode = { "n", "i" } },
            ["<up>"] = { "prev_prompt_history", mode = { "n", "i" } },
            ["<down>"] = { "next_prompt_history", mode = { "n", "i" } },
            ["<M-m>"] = { "switch_mode" },
          },
          output_window = {
            ["<esc>"] = { "close" },
            ["<C-c>"] = { "cancel" },
            ["]]"] = { "next_message" },
            ["[["] = { "prev_message" },
            ["<tab>"] = { "toggle_pane", mode = { "n", "i" } },
            ["i"] = { "focus_input", "n" },
          },
        },
        ui = {
          position = "right",
          window_width = 0.35,
          output = {
            auto_scroll = true,
          },
          input = {
            text = {
              wrap = true,
            },
          },
        },
        context = {
          current_file = {
            enabled = false,
          },
          selection = {
            enabled = true, -- Keep selections automatic (useful)
          },
          diagnostics = {
            info = false,
            warn = false,
            error = true,
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
      "folke/snacks.nvim",
    },
  },
}
