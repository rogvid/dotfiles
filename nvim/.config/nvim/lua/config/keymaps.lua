-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "New Buffer" })
