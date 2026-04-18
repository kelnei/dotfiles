-- mason: install and manage LSP servers, formatters, linters
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls",
    "pyright",
    "lua_ls",
    "intelephense",
  },
  automatic_installation = true,
})

require("mason-tool-installer").setup({
  ensure_installed = {
    "prettier",
  },
})

-- keymaps attached when an LSP server connects to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gr", vim.lsp.buf.references, "Go to references")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>f", function() require("conform").format({ lsp_format = "fallback" }) end, "Format buffer")

    -- enable built-in LSP completion for this buffer
    vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
      autotrigger = true,
    })
  end,
})

-- native completion settings
vim.o.completeopt = "menu,menuone,noselect,fuzzy"
vim.o.pumborder = "rounded"

-- completion keymaps for the native popup menu
vim.keymap.set("i", "<C-j>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-j>"
end, { expr = true, desc = "Next completion item" })

vim.keymap.set("i", "<C-k>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-k>"
end, { expr = true, desc = "Previous completion item" })

vim.keymap.set("i", "<C-e>", function()
  return vim.fn.pumvisible() == 1 and "<C-e>" or "<C-e>"
end, { expr = true, desc = "Abort completion" })

vim.keymap.set("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true, desc = "Confirm completion" })

vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })

-- configure servers via vim.lsp.config
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.enable({ "ts_ls", "pyright", "lua_ls", "intelephense" })
