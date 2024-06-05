return {
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').register {
        ['<leader>c'] = { name = 'Coding', _ = 'which_key_ignore' },
        ['<leader>b'] = { name = 'Buffer', _ = 'which_key_ignore' },
        ['<leader>o'] = { name = 'Obsidian', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = 'Search/Find', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = 'Toggle', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git Hunk', _ = 'which_key_ignore' },
      }
      -- visual mode
      require('which-key').register({
        ['<leader>h'] = { 'Git Hunk' },
      }, { mode = 'v' })
    end,
  },
}
