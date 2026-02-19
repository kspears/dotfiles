-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- <C-p> as alias for find files (LazyVim uses <leader>ff)
vim.keymap.set("n", "<C-p>", function() require("telescope.builtin").find_files() end, { desc = "Find Files" })
