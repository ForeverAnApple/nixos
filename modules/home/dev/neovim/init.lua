vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1

require("options")

vim.cmd.colorscheme("catppuccin-frappe")

require("keymaps")
require("lazyload")
require("lsp")
