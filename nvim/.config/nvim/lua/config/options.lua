-- leader keys must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = true

-- tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- line wrapping
opt.wrap = false

-- search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- behaviour
opt.hidden = true
opt.errorbells = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.iskeyword:append("-")
opt.updatetime = 50
opt.clipboard = "unnamedplus"

-- clipboard over SSH: force OSC 52 when remote, so yanks/pastes travel to the
-- local terminal's clipboard instead of trying (and failing) to reach a Wayland
-- display on the remote. Locally this branch is skipped and Neovim keeps using
-- wl-copy/wl-paste. SSH_CONNECTION is used because tmux propagates it by default
-- (SSH_TTY is not in tmux's update-environment list).
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end
