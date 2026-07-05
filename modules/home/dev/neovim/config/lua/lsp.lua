vim.lsp.enable({ "lua_ls", "rust_analyzer", "html", "cssls", "ts_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Declaration")
    map("n", "<leader>ds", vim.diagnostic.setloclist, "Diagnostics to loclist")
  end,
})
