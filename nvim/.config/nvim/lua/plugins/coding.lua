return {
  -- {
  --   "zbirenbaum/copilot.lua",
  --   opts = {
  --     filetypes = { ["*"] = true },
  --     suggestion = { enabled = true },
  --     symbol_map = { Copilot = "" }
  --   },
  -- },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },

  -- {
  --   "echasnovski/mini.bracketed",
  --   event = "bufreadpost",
  --   enabled = false,
  --   config = function()
  --     local bracketed = require("mini.bracketed")
  --     bracketed.setup({
  --       file = { suffix = "" },
  --       window = { suffix = "" },
  --       quickfix = { suffix = "" },
  --       yank = { suffix = "" },
  --       treesitter = { suffix = "n" },
  --     })
  --   end,
  -- },

  -- better increase/descrease
  {
    "monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<c-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "increment" },
      { "<c-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "decrement" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%y/%m/%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "let", "const" } }),
        },
      })
    end,
  },

  -- {
  --   "simrat39/symbols-outline.nvim",
  --   keys = { { "<leader>cs", "<cmd>symbolsoutline<cr>", desc = "symbols outline" } },
  --   cmd = "symbolsoutline",
  --   opts = {},
  -- },

  {
    "nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

  -- {
  --   "wansmer/treesj",
  --   keys = {
  --     { "j", "<cmd>tsjtoggle<cr>", desc = "join toggle" },
  --   },
  --   opts = { use_default_keymaps = false, max_join_length = 150 },
  -- },

  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>rR",
        function()
          require("ssr").open()
        end,
        mode = { "n", "x" },
        desc = "Structural Replace",
      },
    },
  },
}
