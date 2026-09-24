return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = false, -- for hidden files
        ignored = true, -- for .gitignore files
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    opts = {
      -- open_cmd = "qutebrowser %s",
    }, -- lazy.nvim will implicitly calls `setup {}`
  },
  {
    "Piotr1215/presenterm.nvim",
    build = false,
    dependencies = {
      -- Choose one (or install separately):
      "nvim-telescope/telescope.nvim", -- Option 1: Telescope
      -- "ibhagwan/fzf-lua",            -- Option 2: fzf-lua
      -- "folke/snacks.nvim",           -- Option 3: Snacks
    },
    opts = {},
  },
}
