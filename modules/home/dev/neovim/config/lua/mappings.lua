require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- :q -> :qa, :q! -> :qa!, :wq -> :wqa
vim.cmd "cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'qa' : 'q'"
vim.cmd "cnoreabbrev <expr> q! getcmdtype() == ':' && getcmdline() == 'q!' ? 'qa!' : 'q!'"
vim.cmd "cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() == 'wq' ? 'wqa' : 'wq'"

-- Window splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Terminal window navigation
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Navigate left" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Navigate down" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Navigate up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Navigate right" })

-- Menu
map("n", "<leader>m", function()
  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options)
end, { desc = "Open context menu" })
map("n", "<RightMouse>", function()
  require("menu.utils").delete_old_menus()
  local buf = vim.api.nvim_get_current_buf()
  local options = vim.bo[buf].ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true })
end, { desc = "Open context menu" })
