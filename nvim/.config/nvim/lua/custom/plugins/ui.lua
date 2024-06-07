return {
  { -- oil nvim
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        win_options = {
          signcolumn = 'yes',
        },
        delete_to_trash = true,
      }

      -- Set key mapping to toggle Oil window using toggle_float
      vim.keymap.set('n', '\\', function()
        require('oil').toggle_float '.'
      end, { noremap = true, silent = true })
      vim.keymap.set('n', '|', function()
        local plug = require 'oil'
        plug.toggle_float(plug.get_current_dir())
      end, { noremap = true, silent = true })
    end,
    -- keys = {
    --   -- { '\\', ":lua require('oil').toggle_float '.'<cr>", desc = 'Oil: reveal workspace root' },
    --   -- { '|', '<CMD>Oil.toggle_float(Oil.get_current_dir())<cr>', { desc = 'Oil: reveal workspace here', silent = true } },
    -- },
  },
  { -- Add minimalist file explorer
    'nvim-tree/nvim-tree.lua',
    enable = false,
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {}
      -- vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
    end,
  },
  -- { -- Another option is to use neo-tree instead of nvim-tree
  --   'nvim-neo-tree/neo-tree.nvim',
  --   version = '*',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
  --     'MunifTanjim/nui.nvim',
  --   },
  --   cmd = 'Neotree',
  --   keys = {
  --     { '<leader>e', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  --   },
  --   opts = {
  --     filesystem = {
  --       window = {
  --         mappings = {
  --           ['<leader>e'] = 'close_window',
  --         },
  --       },
  --     },
  --   },
  -- },
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = true },
  },
  -- This is actually quite annoying. Is there anything simpler?
  -- { -- Add indentation guides even on blank lines
  --   -- This is really helpful when working on files where
  --   -- it is useful to know whether the code has tabs or spaces
  --   -- like Makefile, Jenkinsfiles, etc.
  --   'lukas-reineke/indent-blankline.nvim',
  --   -- Enable `lukas-reineke/indent-blankline.nvim`
  --   -- See `:help ibl`
  --   main = 'ibl',
  --   opts = {},
  -- },
  { -- Noice is the awesome floating terminal
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
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
  { -- LazyGit
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>ug', '<cmd>LazyGit<cr>', desc = '[u]i show lazy[g]it' },
    },
  },
}
