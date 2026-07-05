local terminal = {
  cmd = "opencode --port",
  opts = { win = { position = "right", width = 0.35, enter = false } },
}

vim.g.opencode_opts = {
  server = {
    start = function()
      require("snacks.terminal").open(terminal.cmd, terminal.opts)
    end,
  },
  select = {
    prompts = {
      unsafe_review = "Review @this for unsafe Rust correctness and potential UB",
      cargo_fix = "Suggest fixes for these Cargo/clippy warnings: @diagnostics",
      refactor = "Refactor @this for better readability and maintainability",
      types = "Add or improve type annotations for @this",
    },
    snacks = {
      layout = { preset = "vscode" },
    },
  },
}

vim.o.autoread = true

return terminal
