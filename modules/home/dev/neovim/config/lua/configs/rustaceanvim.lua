local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

vim.g.rustaceanvim = {
  server = {
    on_attach = on_attach,
    capabilities = capabilities,
    -- Limit memory usage (glibc malloc arena limit)
    cmd_env = {
      MALLOC_ARENA_MAX = "2",
    },
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          extraEnv = { SQLX_OFFLINE = "true" },
        },
        -- Memory reduction settings
        procMacro = {
          enable = true,
          attributes = { enable = true },
        },
        checkOnSave = {
          command = "check", -- "clippy" is heavier
        },
      },
    },
  },
}
