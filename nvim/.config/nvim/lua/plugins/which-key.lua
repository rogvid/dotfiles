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
      require('which-key').register({
        -- Keys that we don't want to display
        ['<leader>d'] = { name = '[d]ebug', t = { name = '[t]est', _ = 'which_key_ignore' } },
        ['<leader><Tab>'] = 'which_key_ignore',
        ['<leader>e'] = 'which_key_ignore',
        ['<leader><space>'] = 'which_key_ignore',
        ['<leader>a'] = { name = '[a]i', _ = 'which_key_ignore' },
        ['<leader>c'] = { name = '[c]oding', _ = 'which_key_ignore' },
        ['<leader>b'] = { name = '[b]uffer', _ = 'which_key_ignore' },
        -- ['<leader>n'] = { name = 'Neotest', _ = 'which_key_ignore' },
        ['<leader>o'] = { name = '[o]bsidian', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[s]earch', _ = 'which_key_ignore' },
        ['<leader>u'] = { name = '[u]i', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[g]it', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[t]rouble', _ = 'which_key_ignore' },
      }, { mode = 'n' })

      -- visual mode
      require('which-key').register({
        ['<leader>g'] = { '[g]it' },
      }, { mode = 'v' })
    end,
  },
}
