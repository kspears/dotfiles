require("nvchad.mappings")

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

-- Ghostty owns terminal pane nav via ctrl+h/j/k/l at the terminal level;
-- these mappings only fire when ghostty has no adjacent pane and passes the
-- key through, or when nvim runs outside ghostty.
map("n", "<C-h>", "<C-w>h", { desc = "Focus split left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus split down" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus split up" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus split right" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map("v", "<", "<gv", { desc = "Re-indent left, keep selection" })
map("v", ">", ">gv", { desc = "Re-indent right, keep selection" })

map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })

-- Muscle-memory bindings ported from the pre-NvChad config.
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })

map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })

map("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
