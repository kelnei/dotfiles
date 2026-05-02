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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("*", { capabilities = capabilities })

vim.diagnostic.config({
  float = { border = "rounded", source = true },
  severity_sort = true,
})

local intelephense_stubs = {
  "apache",
  "bcmath",
  "bz2",
  "calendar",
  "com_dotnet",
  "Core",
  "ctype",
  "curl",
  "date",
  "dba",
  "dom",
  "enchant",
  "exif",
  "FFI",
  "fileinfo",
  "filter",
  "fpm",
  "ftp",
  "gd",
  "gettext",
  "gmp",
  "hash",
  "iconv",
  "imap",
  "intl",
  "json",
  "ldap",
  "libxml",
  "mbstring",
  "meta",
  "mysqli",
  "oci8",
  "odbc",
  "openssl",
  "pcntl",
  "pcre",
  "PDO",
  "pgsql",
  "Phar",
  "posix",
  "pspell",
  "random",
  "readline",
  "Reflection",
  "session",
  "shmop",
  "SimpleXML",
  "snmp",
  "soap",
  "sockets",
  "sodium",
  "SPL",
  "sqlite3",
  "standard",
  "superglobals",
  "sysvmsg",
  "sysvsem",
  "sysvshm",
  "tidy",
  "tokenizer",
  "uri",
  "wordpress",
  "xml",
  "xmlreader",
  "xmlrpc",
  "xmlwriter",
  "xsl",
  "Zend OPcache",
  "zip",
  "zlib",
}

local function env_or_default(name, default)
  local value = vim.env[name]
  return value ~= nil and value ~= "" and value or default
end

local function existing_dir(path)
  if not path or path == "" then return nil end

  path = vim.fs.normalize(vim.fn.expand(path))
  local stat = vim.uv.fs_stat(path)

  return stat and stat.type == "directory" and path or nil
end

local function readable_file(path)
  if not path or path == "" then return nil end

  path = vim.fs.normalize(vim.fn.expand(path))
  return vim.fn.filereadable(path) == 1 and path or nil
end

local function add_include_path(paths, seen, path)
  path = existing_dir(path)

  if path and not seen[path] then
    paths[#paths + 1] = path
    seen[path] = true
  end
end

local function add_include_paths(paths, seen, value)
  if not value or value == "" then return end

  for path in vim.gsplit(value, ":", { plain = true, trimempty = true }) do
    add_include_path(paths, seen, path)
  end
end

local function valid_wordpress_root(path)
  path = existing_dir(path)

  if path and vim.fn.filereadable(vim.fs.joinpath(path, "wp-includes", "version.php")) == 1 then return path end
end

local function find_wordpress_root(start)
  start = existing_dir(start)
  if not start then return nil end

  local wp_includes = vim.fs.find("wp-includes", { path = start, upward = true, type = "directory" })[1]
  return wp_includes and valid_wordpress_root(vim.fs.dirname(wp_includes)) or nil
end

local function configured_wordpress_root(root_dir)
  return valid_wordpress_root(vim.env.INTELEPHENSE_WORDPRESS_ROOT)
    or find_wordpress_root(root_dir)
    or find_wordpress_root(vim.uv.cwd())
    or valid_wordpress_root(vim.env.WORDPRESS_ROOT)
    or valid_wordpress_root("~/code/wordpress")
end

local function intelephense_wordpress_paths(root_dir)
  local paths = {}
  local seen = {}
  local root = configured_wordpress_root(root_dir)

  if root then
    add_include_path(paths, seen, vim.fs.joinpath(root, "wp-includes"))
    add_include_path(paths, seen, vim.fs.joinpath(root, "wp-admin"))
  end

  add_include_paths(paths, seen, vim.env.INTELEPHENSE_INCLUDE_PATHS)

  return root, paths
end

local function intelephense_licence_key()
  return env_or_default("INTELEPHENSE_LICENSE_KEY", nil)
    or env_or_default("INTELEPHENSE_LICENCE_KEY", nil)
    or readable_file("~/.config/intelephense/licence.txt")
    or readable_file("~/.config/intelephense/license.txt")
    or readable_file("~/.intelephense/licence.txt")
    or readable_file("~/.intelephense/license.txt")
    or readable_file("~/intelephense/licence.txt")
    or readable_file("~/intelephense/license.txt")
end

local intelephense_config = {
  settings = {
    intelephense = {
      telemetry = { enabled = false },
      stubs = intelephense_stubs,
      files = { maxSize = 5000000 },
      environment = {
        phpVersion = env_or_default("INTELEPHENSE_PHP_VERSION", "8.3.0"),
      },
      completion = {
        fullyQualifyGlobalConstantsAndFunctions = false,
        insertUseDeclaration = true,
        triggerParameterHints = true,
      },
      diagnostics = {
        enable = true,
        run = "onType",
        typeErrors = true,
        undefinedConstants = true,
        undefinedFunctions = true,
        undefinedSymbols = true,
        undefinedTypes = true,
        undefinedVariables = true,
      },
    },
  },
  before_init = function(_, config)
    config.settings = vim.deepcopy(config.settings)

    local root, include_paths = intelephense_wordpress_paths(config.root_dir)
    local environment = config.settings.intelephense.environment

    if root then environment.documentRoot = root end
    if #include_paths > 0 then environment.includePaths = include_paths end
  end,
}

local licence_key = intelephense_licence_key()
if licence_key then intelephense_config.init_options = { licenceKey = licence_key } end

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
    map("gl", vim.diagnostic.open_float, "Line diagnostics")
    map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
    map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

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

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  if vim.snippet.active({ direction = 1 }) then return "<Cmd>lua vim.snippet.jump(1)<CR>" end
  return "<Tab>"
end, { expr = true, desc = "Next completion item or snippet jump" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-p>" end
  if vim.snippet.active({ direction = -1 }) then return "<Cmd>lua vim.snippet.jump(-1)<CR>" end
  return "<S-Tab>"
end, { expr = true, desc = "Previous completion item or snippet jump" })

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

vim.lsp.config("intelephense", intelephense_config)

vim.lsp.enable({ "ts_ls", "pyright", "lua_ls", "intelephense" })
