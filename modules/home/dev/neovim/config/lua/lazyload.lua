local map = vim.keymap.set

local function packadd(...)
  for _, p in ipairs({ ... }) do
    vim.cmd.packadd(p)
  end
end

local group = vim.api.nvim_create_augroup("lazyload", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  once = true,
  callback = function()
    packadd("blink.cmp")
    require("plugins.blink")
  end,
})

vim.treesitter.language.register("tsx", "typescriptreact")
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = {
    "vim",
    "lua",
    "help",
    "html",
    "css",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "c",
    "cpp",
    "rust",
    "zig",
    "nix",
    "toml",
    "markdown",
  },
  callback = function(ev)
    packadd("nvim-treesitter")
    pcall(vim.treesitter.start, ev.buf)
  end,
})

local fzf = {
  ["<leader>ff"] = "files",
  ["<leader>fw"] = "live_grep",
  ["<leader>fb"] = "buffers",
  ["<leader>fh"] = "helptags",
  ["<leader>fo"] = "oldfiles",
}
for lhs, fn in pairs(fzf) do
  map("n", lhs, function()
    packadd("fzf-lua")
    require("fzf-lua")[fn]()
  end, { desc = "fzf " .. fn })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    packadd("conform.nvim")
    require("plugins.conform")
    require("conform").format({ bufnr = ev.buf, timeout_ms = 500, lsp_fallback = true })
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = group,
  once = true,
  callback = function()
    vim.schedule(function()
      packadd("gitsigns.nvim")
      require("plugins.gitsigns")
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "toml",
  callback = function()
    packadd("crates.nvim")
    require("plugins.crates")
    require("crates").show()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "opencode_output" },
  callback = function()
    packadd("render-markdown.nvim")
    require("plugins.render-markdown")
  end,
})

local function snacks()
  packadd("snacks.nvim")
  return require("plugins.snacks")
end

map("n", "<leader>lg", function()
  snacks().terminal.toggle("lazygit", { win = { position = "float", width = 0.9, height = 0.9 } })
end, { desc = "Lazygit" })

map("n", "<leader>pi", function()
  snacks().terminal.toggle("pi", {
    win = { position = "right", width = 0.35 },
    interactive = true,
  })
end, { desc = "Toggle Pi Agent" })

local claude_loaded = false
local function claude(cmd)
  if not claude_loaded then
    claude_loaded = true
    packadd("plenary.nvim", "claude-code.nvim")
    require("plugins.claude-code")
  end
  vim.cmd(cmd)
end

map("n", "<leader>cc", function()
  claude("ClaudeCode")
end, { desc = "Toggle Claude Code" })
map("n", "<leader>cC", function()
  claude("ClaudeCodeContinue")
end, { desc = "Continue conversation" })
map("n", "<leader>cR", function()
  claude("ClaudeCodeResume")
end, { desc = "Resume conversation" })
map("n", "<leader>cV", function()
  claude("ClaudeCodeVerbose")
end, { desc = "Verbose mode" })

local function opencode()
  local terminal = require("plugins.opencode")
  snacks()
  packadd("render-markdown.nvim", "opencode.nvim")
  return require("opencode"), terminal
end

map({ "n", "x" }, "<leader>oa", function()
  opencode().ask("")
end, { desc = "Ask opencode" })
map({ "n", "x" }, "<leader>os", function()
  opencode().select()
end, { desc = "Execute opencode action" })
map("n", "<leader>oo", function()
  local _, terminal = opencode()
  require("snacks.terminal").toggle(terminal.cmd, terminal.opts)
end, { desc = "Toggle opencode" })
map({ "n", "x" }, "go", function()
  return opencode().operator("@this ")
end, { expr = true, desc = "Add range to opencode" })
map("n", "goo", function()
  return opencode().operator("@this ") .. "_"
end, { expr = true, desc = "Add line to opencode" })
map("n", "<leader>ou", function()
  opencode().command("session.half.page.up")
end, { desc = "opencode half page up" })
map("n", "<leader>od", function()
  opencode().command("session.half.page.down")
end, { desc = "opencode half page down" })
map({ "n", "v" }, "<leader>oA", function()
  opencode().ask("@buffer ")
end, { desc = "Ask opencode about current file" })
map("n", "<leader>on", function()
  opencode().command("session.new")
end, { desc = "New session" })
map("n", "<leader>oe", function()
  opencode().prompt("Explain @this and its context")
end, { desc = "Explain code near cursor" })
map("n", "<leader>or", function()
  opencode().prompt("Review @buffer for correctness and readability")
end, { desc = "Review file" })
map("n", "<leader>of", function()
  opencode().prompt("Fix these @diagnostics")
end, { desc = "Fix errors" })
map("v", "<leader>oO", function()
  opencode().prompt("Optimize @this for performance and readability")
end, { desc = "Optimize selection" })
map("v", "<leader>oD", function()
  opencode().prompt("Add documentation comments for @this")
end, { desc = "Document selection" })
map("v", "<leader>ot", function()
  opencode().prompt("Add tests for @this")
end, { desc = "Test selection" })
