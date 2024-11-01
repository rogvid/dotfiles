return {
  { -- Org mode plugin
    'nvim-neorg/neorg',
    enabled = false,
    config = function()
      require('neorg').setup {}
    end,
  },

  { -- Markdown supercharged plugin
    'jakewvincent/mkdnflow.nvim',
    enabled = false,
    config = function()
      local mkdnflow = require 'mkdnflow'
      mkdnflow.setup {}
    end,
  },
  { -- Obsidian configurations
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    -- lazy = true,
    -- ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      'BufReadPre ~/work/PKM/Second-brain/**.md',
      'BufNewFile ~/work/PKM/Second-brain/**.md',
    },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-treesitter/nvim-treesitter',

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        -- {
        --   name = 'personal',
        --   path = '~/Dropbox/obsidian/brain',
        -- },
        {
          name = 'work',
          path = '~/work/PKM/Second-brain/',
        },
      },

      templates = {
        folder = 'resources/templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
        substitutions = {
          -- weight = function()
          --   local inp = vim.fn.input('What is your weight today [kg]?: ', '', '')
          --   return inp
          -- end,
          datetime = function()
            return os.date('%Y-%m-%d %H:%M', os.time())
          end,
        },
      },
      daily_notes = {
        -- Optional, if you keep daily notes in a separate directory.
        folder = 'areas/journal',
        -- Optional, if you want to change the date format for the ID of daily notes.
        date_format = '%Y-%m-%d',
        -- Optional, default tags to add to each new daily note created.
        default_tags = { 'daily-notes' },
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = 'daily.md',
      },

      ui = {
        enable = true, -- set to false to disable all additional syntax features
        update_debounce = 200, -- update delay after a text change (in milliseconds)
        max_file_length = 3000, -- disable UI features for files with more than this many lines
        -- Define how various check-boxes are displayed
        checkboxes = {
          -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
          [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '', hl_group = 'ObsidianDone' },
          ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
          ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
          ['!'] = { char = '', hl_group = 'ObsidianImportant' },
          -- Replace the above with this if you don't have a patched font:
          -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
          -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

          -- You can also add more custom ones...
        },
        -- Use bullet marks for non-checkbox lists.
        bullets = { char = '•', hl_group = 'ObsidianBullet' },
        external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
        -- Replace the above with this if you don't have a patched font:
        -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = 'ObsidianRefText' },
        highlight_text = { hl_group = 'ObsidianHighlightText' },
        tags = { hl_group = 'ObsidianTag' },
        block_ids = { hl_group = 'ObsidianBlockID' },
        hl_groups = {
          -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
          ObsidianTodo = { bold = true, fg = '#f78c6c' },
          ObsidianDone = { bold = true, fg = '#89ddff' },
          ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
          ObsidianTilde = { bold = true, fg = '#ff5370' },
          ObsidianImportant = { bold = true, fg = '#d73128' },
          ObsidianBullet = { bold = true, fg = '#89ddff' },
          ObsidianRefText = { underline = true, fg = '#c792ea' },
          ObsidianExtLinkIcon = { fg = '#c792ea' },
          ObsidianTag = { italic = true, fg = '#89ddff' },
          ObsidianBlockID = { italic = true, fg = '#89ddff' },
          ObsidianHighlightText = { bg = '#75662e' },
        },
      },
      -- Add a follow url command
      ---@param url string
      follow_url_func = function(url)
        -- Open the URL in the default web browser.
        -- vim.fn.jobstart { 'open', url } -- Mac OS
        vim.fn.jobstart { 'xdg-open', url } -- linux
      end,
    },
    keys = {
      {
        '<leader>on',
        '<cmd>ObsidianNew<cr>',
        desc = 'create [n]ew note',
      },
      {
        '<leader>of',
        '<cmd>ObsidianSearch<cr>',
        desc = '[f]ind note',
      },
      {
        '<leader>od',
        '<cmd>ObsidianToday<cr>',
        desc = 'create [d]aily note',
      },
      {
        '<leader>ot',
        '<cmd>ObsidianTag<cr>',
        desc = 'search for [t]ag in vault',
      },
    },
    config = function(_, opts)
      require('obsidian').setup(opts)
      vim.keymap.set('n', 'gf', function()
        if require('obsidian').util.cursor_on_markdown_link() then
          return '<cmd>ObsidianFollowLink<CR>'
        else
          return 'gf'
        end
      end, { noremap = false, expr = true })
    end,
  },
}
