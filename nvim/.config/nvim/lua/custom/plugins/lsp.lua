return {
  -- NOTE: Disabling the lsp removes the annoying popup
  -- NOTE: Base plugin setup doesn't do anything
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[g]oto [d]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[g]oto [r]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, 'goto [I]mplementation')
          map('<leader>ct', require('telescope.builtin').lsp_type_definitions, 'search [t]ype Definition')
          map('<leader>cl', require('telescope.builtin').lsp_document_symbols, 'list [b]uffer Symbols')
          map('<leader>cw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'list [w]orkspace symbols')
          map('<leader>cr', vim.lsp.buf.rename, '[r]ename variable')
          map('<leader>ca', vim.lsp.buf.code_action, 'select and execute a LSP [a]ction')
          map('K', vim.lsp.buf.hover, '[K] hover documentation')
          map('gD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }
      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      --
      -- local ruff_on_attach = function(client, bufnr)
      --   if client.name == 'ruff_lsp' then
      --     -- Disable hover in favor of Pyright
      --     client.server_capabilities.hoverProvider = false
      --   end
      -- end
      local servers = {
        -- -- clangd = {},
        -- -- gopls = {},
        -- ruff_lsp = {
        --   filetypes = { 'python' },
        --   on_attach = ruff_on_attach,
        -- },
        -- pyright = {},
        marksman = {
          filetypes = { 'markdown', 'quarto' },
        },
        -- -- rust_analyzer = {},
        -- -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        -- --
        -- -- Some languages (like typescript) have entire language plugins that can be useful:
        -- --    https://github.com/pmizio/typescript-tools.nvim
        -- --
        -- -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        -- --
        yamlls = {
          flags = lsp_flags,
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
                url = '',
              },
            },
          },
        },

        bashls = {
          flags = lsp_flags,
          filetypes = { 'sh', 'bash' },
        },

        dotls = {
          flags = lsp_flags,
        },
        -- lua_ls = {
        --   flags = lsp_flags,
        -- },
        --
        -- lua_ls = {
        --   -- cmd = {...},
        --   -- filetypes = { ...},
        --   flags = lsp_flags,
        --   workspace = {
        --     checkThirdParty = false,
        --     library = {
        --       vim.env.VIMRUNTIME,
        --     },
        --   },
        --   settings = {
        --     Lua = {
        --       completion = {
        --         callSnippet = 'Replace',
        --       },
        --       -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        --       diagnostics = { disable = { 'missing-fields' } },
        --     },
        --   },
        -- },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      -- TODO: Fix this
      -- vim.lsp.handlers['textDocument/publishDiagnostics'] = function() end
      -- vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      --   -- delay update diagnostics
      --   update_in_insert = false,
      -- })
    end,
  },
}
