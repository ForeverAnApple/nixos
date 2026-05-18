require "nvchad.autocmds"

-- Open nvim-tree on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
    vim.cmd("wincmd p")  -- Focus back to the editing buffer
  end,
})

-- Dim gitignored files in nvim-tree
vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { fg = "#51576d" })
vim.api.nvim_set_hl(0, "NvimTreeGitFileIgnoredHL", { fg = "#51576d" })
vim.api.nvim_set_hl(0, "NvimTreeGitFolderIgnoredHL", { fg = "#51576d" })
