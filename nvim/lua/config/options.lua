-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local function expandEnsure(path)
  local expanded = vim.fn.expand(path)
  if not vim.fn.isdirectory(expanded) then
    vim.fn.mkdir(expanded, "p")
  end
  return expanded
end

local opt = vim.opt

-- persistent undo
if vim.fn.has("+undofile") then
  opt.undofile = true
  opt.undodir = expandEnsure("~/.nvim/undo")
end

-- backups
opt.backup = true
opt.backupdir = expandEnsure("~/.nvim/backup")

-- swap files
opt.directory = expandEnsure("~/.nvim/swap")
opt.swapfile = false

opt.modeline = false -- modelines have security risks associated with them
opt.showmatch = true -- highlight matching pairs

if not vim.g.vscode then
  opt.colorcolumn = "120" -- mark column 120 for a sensible guide for max line length
end

-- Enable break indent
opt.breakindent = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
