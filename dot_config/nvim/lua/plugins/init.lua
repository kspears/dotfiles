return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require("configs.conform"),
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("configs.lspconfig")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "hcl",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "terraform",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
}
