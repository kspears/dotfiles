require("nvchad.autocmds")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  group = augroup("filetype-indent", { clear = true }),
  pattern = { "yaml", "json", "javascript", "typescript", "html", "terraform", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

autocmd("FileType", {
  group = augroup("markdown-prose", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})

-- Follow markdown links under the cursor: [text](path) opens files or URLs,
-- [[wiki]] opens sibling files (with or without .md).
local function follow_markdown_link()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  local start = 1
  while true do
    local s, e, path = line:find("%[.-%]%((.-)%)", start)
    if not s then
      break
    end
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

autocmd("FileType", {
  group = augroup("markdown-link-follow", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<CR>", follow_markdown_link, { buffer = args.buf, desc = "Follow link" })
    vim.keymap.set("n", "<BS>", "<C-o>", { buffer = args.buf, desc = "Go back" })
  end,
})

autocmd("BufWritePre", {
  group = augroup("strip-trailing-whitespace", { clear = true }),
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

autocmd("BufReadPost", {
  group = augroup("restore-cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("checktime", { clear = true }),
  command = "checktime",
})

autocmd("TextYankPost", {
  group = augroup("yank-highlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})
