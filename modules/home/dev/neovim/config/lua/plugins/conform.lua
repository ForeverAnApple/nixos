require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    nix = { "nixfmt" },
    rust = { "rustfmt" },
  },
})
