-- Zero-plugin neovim 0.11 config
-- Uses only built-in LSP, treesitter, completion, and diagnostics

-- Leader keys (set before anything else)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── Options ──────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "120"
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", extends = "▸", precedes = "◂" }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250
vim.opt.mouse = "a"
vim.opt.hidden = true
vim.opt.confirm = true
vim.opt.showmode = false
vim.opt.showmatch = true
vim.opt.completeopt = "menuone,noselect,popup"
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.pyc", "__pycache__", "*.o", ".git", "node_modules" })
vim.opt.timeoutlen = 500
vim.opt.laststatus = 3

-- Use ripgrep for :grep
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25

local map = vim.keymap.set

-- Window/kitty navigation
local function kitty_navigate(direction)
  local win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. direction)
  if vim.api.nvim_get_current_win() == win then
    local kitty_dir = ({ h = "left", j = "bottom", k = "top", l = "right" })[direction]
    vim.fn.system({ "kitty", "@", "focus-window", "--match", "neighbor:" .. kitty_dir })
  end
end

map("n", "<C-h>", function() kitty_navigate("h") end, { desc = "Navigate left" })
map("n", "<C-j>", function() kitty_navigate("j") end, { desc = "Navigate down" })
map("n", "<C-k>", function() kitty_navigate("k") end, { desc = "Navigate up" })
map("n", "<C-l>", function() kitty_navigate("l") end, { desc = "Navigate right" })

-- ── Keymaps ──────────────────────────────────────────────────────────

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>")
map("n", "<S-l>", "<cmd>bnext<cr>")
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Clear search
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==")
map("n", "<A-k>", "<cmd>m .-2<cr>==")
map("v", "<A-j>", ":m '>+1<cr>gv=gv")
map("v", "<A-k>", ":m '<-2<cr>gv=gv")

-- File explorer
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })

-- Quickfix
map("n", "]q", "<cmd>cnext<cr>")
map("n", "[q", "<cmd>cprev<cr>")
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })

-- ── fzf float (no plugin needed) ────────────────────────────────────
if vim.fn.executable("fzf") == 1 then
  local function fzf_float(cmd, on_choice)
    local tmpfile = vim.fn.tempname()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.7)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = "minimal",
      border = "rounded",
    })
    vim.fn.termopen(cmd .. " > " .. tmpfile, {
      on_exit = function(_, code)
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
        if code == 0 then
          local lines = vim.fn.readfile(tmpfile)
          local result = vim.trim(lines[1] or "")
          if result ~= "" then
            vim.schedule(function() on_choice(result) end)
          end
        end
        vim.fn.delete(tmpfile)
      end,
    })
    vim.cmd("startinsert")
  end

  local fzf_base = "rg --files --hidden --glob '!.git'"
    .. " | fzf --reverse --preview 'head -80 {}'"

  map("n", "<C-p>", function()
    fzf_float(fzf_base, function(f) vim.cmd("edit " .. vim.fn.fnameescape(f)) end)
  end, { desc = "Find files" })

  map("n", "<leader>ff", function()
    fzf_float(fzf_base, function(f) vim.cmd("edit " .. vim.fn.fnameescape(f)) end)
  end, { desc = "Find files" })

  map("n", "<leader>fb", function()
    local bufs = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(b) then
        local name = vim.api.nvim_buf_get_name(b)
        if name ~= "" then table.insert(bufs, name) end
      end
    end
    if #bufs == 0 then
      vim.notify("No buffers open", vim.log.levels.INFO)
      return
    end
    local input = table.concat(bufs, "\n")
    fzf_float("echo " .. vim.fn.shellescape(input) .. " | fzf --reverse",
      function(f) vim.cmd("edit " .. vim.fn.fnameescape(f)) end)
  end, { desc = "Find buffers" })

  map("n", "<leader>sg", function()
    local pattern = vim.fn.input("Grep: ")
    if pattern == "" then return end
    local rg_cmd = "rg --vimgrep --smart-case " .. vim.fn.shellescape(pattern)
    fzf_float(rg_cmd .. " | fzf --reverse --delimiter : --preview 'head -80 {1}'",
      function(line)
        local file, lnum = line:match("^(.+):(%d+):")
        if file then
          vim.cmd("edit +" .. lnum .. " " .. vim.fn.fnameescape(file))
        end
      end)
  end, { desc = "Grep project (fzf)" })
else
  -- Fallback grep without fzf
  map("n", "<leader>sg", function()
    local pattern = vim.fn.input("Grep: ")
    if pattern ~= "" then
      vim.cmd("silent grep! " .. vim.fn.shellescape(pattern))
      vim.cmd("copen")
    end
  end, { desc = "Grep project" })

  map("n", "<leader>sw", function()
    vim.cmd("silent grep! " .. vim.fn.shellescape(vim.fn.expand("<cword>")))
    vim.cmd("copen")
  end, { desc = "Grep word under cursor" })
end

-- ── Diagnostics ──────────────────────────────────────────────────────
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, prefix = "●" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.HINT] = "H",
      [vim.diagnostic.severity.INFO] = "I",
    },
  },
})

map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- ── LSP ──────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "gr", vim.lsp.buf.references, "References")
    bmap("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
    bmap("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
    bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    bmap("n", "K", vim.lsp.buf.hover, "Hover")
    bmap("n", "gK", vim.lsp.buf.signature_help, "Signature help")
    bmap("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    bmap("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")

    -- Built-in completion from LSP
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end
  end,
})

-- Ruff (python)
if vim.fn.executable("ruff") == 1 then
  vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.py", ".git" },
  })
  vim.lsp.enable("ruff")
end

-- terraform-ls
if vim.fn.executable("terraform-ls") == 1 then
  vim.lsp.config("terraformls", {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "terraform-vars", "hcl" },
    root_markers = { ".terraform", ".git" },
  })
  vim.lsp.enable("terraformls")
end

-- TypeScript
if vim.fn.executable("typescript-language-server") == 1 then
  vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  })
  vim.lsp.enable("ts_ls")
end

-- Lua (for editing nvim config)
if vim.fn.executable("lua-language-server") == 1 then
  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", "stylua.toml", ".git" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          library = { vim.env.VIMRUNTIME },
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  })
  vim.lsp.enable("lua_ls")
end

-- ── Format on save ───────────────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.tf", "*.tfvars", "*.py" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ── Treesitter ───────────────────────────────────────────────────────
vim.opt.runtimepath:prepend(vim.fn.stdpath("config"))

vim.treesitter.language.register("bash", "sh")
vim.treesitter.language.register("terraform", "terraform")
vim.treesitter.language.register("hcl", "terraform-vars")

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- ── Filetype overrides ───────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "json", "javascript", "typescript", "html", "terraform", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})

-- ── Markdown link navigation ─────────────────────────────────────────
local function follow_markdown_link()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  local start = 1
  while true do
    local s, e, path = line:find("%[.-%]%((.-)%)", start)
    if not s then break end
    if col >= s and col <= e then
      if path:match("^https?://") then
        vim.fn.system({ "open", path })
        return
      end
      local target = vim.fn.simplify(vim.fn.expand("%:p:h") .. "/" .. path)
      if vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
      else
        vim.notify("File not found: " .. target, vim.log.levels.WARN)
      end
      return
    end
    start = e + 1
  end

  local wiki = line:match("%[%[(.-)%]%]")
  if wiki then
    local base = vim.fn.simplify(vim.fn.expand("%:p:h") .. "/" .. wiki)
    if vim.fn.filereadable(base) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(base))
    elseif vim.fn.filereadable(base .. ".md") == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(base .. ".md"))
    else
      vim.notify("File not found: " .. base, vim.log.levels.WARN)
    end
    return
  end

  vim.notify("No link under cursor", vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    map("n", "<CR>", follow_markdown_link, { buffer = args.buf, desc = "Follow link" })
    map("n", "<BS>", "<C-o>", { buffer = args.buf, desc = "Go back" })
  end,
})

-- ── Quality of life autocmds ─────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})

-- ── Highlight on yank ────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- ── Statusline ───────────────────────────────────────────────────────
local function stl_git()
  local head = vim.b.git_branch
  if head and head ~= "" then return "  " .. head .. " " end
  return ""
end

local function stl_diagnostics()
  if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then return "" end
  local d = vim.diagnostic.count(0)
  local parts = {}
  if (d[vim.diagnostic.severity.ERROR] or 0) > 0 then
    table.insert(parts, "E:" .. d[vim.diagnostic.severity.ERROR])
  end
  if (d[vim.diagnostic.severity.WARN] or 0) > 0 then
    table.insert(parts, "W:" .. d[vim.diagnostic.severity.WARN])
  end
  if #parts == 0 then return " ok " end
  return " " .. table.concat(parts, " ") .. " "
end

local function stl_lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end
  local names = {}
  for _, cl in ipairs(clients) do table.insert(names, cl.name) end
  return " [" .. table.concat(names, ",") .. "] "
end

function Statusline()
  return table.concat({
    " %f %m%r",
    stl_git(),
    "%=",
    stl_diagnostics(),
    stl_lsp(),
    " %{&filetype} ",
    " %l:%c %p%% ",
  })
end

vim.opt.statusline = "%!v:lua.Statusline()"

-- Track git branch for statusline
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "BufWritePost" }, {
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    if dir == "" then return end
    local branch = vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " branch --show-current 2>/dev/null")
    vim.b.git_branch = vim.trim(branch)
  end,
})

-- ── Git signs (no plugins) ───────────────────────────────────────────
local git_ns = vim.api.nvim_create_namespace("git_signs")

local function update_git_signs(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, git_ns, 0, -1)

  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" then return end

  local toplevel = vim.trim(vim.fn.system({ "git", "-C", vim.fn.fnamemodify(path, ":h"), "rev-parse", "--show-toplevel" }))
  if vim.v.shell_error ~= 0 then return end
  local rel_path = path:sub(#toplevel + 2)

  local git_content = vim.fn.system({ "git", "-C", toplevel, "show", "HEAD:" .. rel_path })
  if vim.v.shell_error ~= 0 then return end

  local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local buf_content = table.concat(buf_lines, "\n") .. "\n"

  local ok, hunks = pcall(vim.diff, git_content, buf_content, { result_type = "indices" })
  if not ok or not hunks then return end

  for _, hunk in ipairs(hunks) do
    local _, count_a, start_b, count_b = hunk[1], hunk[2], hunk[3], hunk[4]

    if count_b == 0 then
      local line = math.max(0, start_b - 1)
      pcall(vim.api.nvim_buf_set_extmark, buf, git_ns, line, 0, {
        sign_text = "▁",
        sign_hl_group = "GitSignDelete",
      })
    elseif count_a == 0 then
      for i = start_b, start_b + count_b - 1 do
        pcall(vim.api.nvim_buf_set_extmark, buf, git_ns, i - 1, 0, {
          sign_text = "▎",
          sign_hl_group = "GitSignAdd",
        })
      end
    else
      for i = start_b, start_b + count_b - 1 do
        pcall(vim.api.nvim_buf_set_extmark, buf, git_ns, i - 1, 0, {
          sign_text = "▎",
          sign_hl_group = "GitSignChange",
        })
      end
      if count_a > count_b then
        local line = math.min(start_b + count_b - 1, vim.api.nvim_buf_line_count(buf) - 1)
        pcall(vim.api.nvim_buf_set_extmark, buf, git_ns, line, 0, {
          sign_text = "▁",
          sign_hl_group = "GitSignDelete",
        })
      end
    end
  end
end

local git_sign_timers = {}
local function update_git_signs_debounced(buf)
  if git_sign_timers[buf] then
    git_sign_timers[buf]:stop()
  end
  git_sign_timers[buf] = vim.defer_fn(function()
    git_sign_timers[buf] = nil
    update_git_signs(buf)
  end, 200)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  callback = function(args) update_git_signs(args.buf) end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function(args) update_git_signs_debounced(args.buf) end,
})

-- ── RPC server for external tools (lola, cursor, etc.) ───────────────
local kitty_pid = vim.fn.getenv("KITTY_PID")
if kitty_pid ~= vim.NIL and kitty_pid ~= "" then
  pcall(vim.fn.serverstart, "/tmp/nvim-kitty-" .. kitty_pid .. ".sock")
end

-- ── Colorscheme ──────────────────────────────────────────────────────
vim.cmd.colorscheme("ayu-dark")
