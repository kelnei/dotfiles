-- plugin management via built-in vim.pack (neovim 0.12+)

-- build hooks (must be defined before vim.pack.add)
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind

    -- rebuild treesitter parsers on install or update
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

-- all plugins in a single vim.pack.add call
vim.pack.add({
  -- colorscheme
  "https://github.com/folke/tokyonight.nvim",

  -- treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

  -- lsp and tooling
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",

  -- formatting
  "https://github.com/stevearc/conform.nvim",

  -- fuzzy finder
  "https://github.com/ibhagwan/fzf-lua",

  -- file explorer
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/stevearc/oil.nvim",

  -- git
  "https://github.com/lewis6991/gitsigns.nvim",

  -- statusline
  "https://github.com/nvim-lualine/lualine.nvim",
})
