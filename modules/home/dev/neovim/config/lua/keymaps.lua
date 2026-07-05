local map = vim.keymap.set

map("n", ";", ":", { desc = "Command mode" })
map("i", "jk", "<ESC>")
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.cmd("cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'qa' : 'q'")
vim.cmd("cnoreabbrev <expr> q! getcmdtype() == ':' && getcmdline() == 'q!' ? 'qa!' : 'q!'")
vim.cmd("cnoreabbrev <expr> wq getcmdtype() == ':' && getcmdline() == 'wq' ? 'wqa' : 'wq'")

map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Window left" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Window down" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Window up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Window right" })

map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
