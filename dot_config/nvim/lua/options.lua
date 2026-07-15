require("nvchad.options")

local o = vim.opt

o.relativenumber = true
o.scrolloff = 8
o.colorcolumn = "120"
o.cursorline = true
o.wrap = false
o.linebreak = true
o.list = true
o.listchars = { tab = "→ ", trail = "·", extends = "▸", precedes = "◂" }
o.undofile = true
o.splitright = true
o.splitbelow = true
o.updatetime = 250
o.confirm = true
o.showmatch = true
o.wildmode = "longest:full,full"
o.wildignore:append({ "*.pyc", "__pycache__", "*.o", ".git", "node_modules" })
o.timeoutlen = 500
o.laststatus = 3

if vim.fn.executable("rg") == 1 then
  o.grepprg = "rg --vimgrep --smart-case"
  o.grepformat = "%f:%l:%c:%m"
end

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
