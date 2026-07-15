-- Set NvChad's LSP defaults first (cmp capabilities, on_attach, on_init).
-- User-configured servers below inherit these.
require("nvchad.configs.lspconfig").defaults()

-- Diagnostic display: keep the E/W/H/I severity signs from the pre-migration
-- config, but layer on virtual_lines for the current line only (0.11+ built-in
-- alternative to plugins like tiny-inline-diagnostic).
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = { spacing = 4, prefix = "●" },
  virtual_lines = { current_line = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.HINT] = "H",
      [vim.diagnostic.severity.INFO] = "I",
    },
  },
})

if vim.fn.executable("ruff") == 1 then
  vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.py", ".git" },
  })
  vim.lsp.enable("ruff")
end

if vim.fn.executable("terraform-ls") == 1 then
  vim.lsp.config("terraformls", {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "terraform-vars", "hcl" },
    root_markers = { ".terraform", ".git" },
  })
  vim.lsp.enable("terraformls")
end

if vim.fn.executable("typescript-language-server") == 1 then
  vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  })
  vim.lsp.enable("ts_ls")
end

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
