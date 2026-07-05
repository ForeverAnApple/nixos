local o = vim.o

o.number = true
o.relativenumber = true
o.mouse = "a"
o.termguicolors = true
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.signcolumn = "yes"
o.undofile = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true
o.updatetime = 250
o.timeoutlen = 400
o.laststatus = 3
o.showmode = false
o.cursorline = true
o.scrolloff = 8

vim.schedule(function()
  o.clipboard = "unnamedplus"
end)
