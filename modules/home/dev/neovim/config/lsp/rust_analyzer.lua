return {
  cmd = { "rust-analyzer" },
  cmd_env = { MALLOC_ARENA_MAX = "2" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "Cargo.lock", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        extraEnv = { SQLX_OFFLINE = "true" },
      },
    },
  },
}
