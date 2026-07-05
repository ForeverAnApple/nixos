require("render-markdown").setup({
  file_types = { "markdown", "opencode_output" },
  heading = {
    sign = false,
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
  },
  bullet = {
    icons = { "●", "○", "◆", "◇" },
  },
  sign = {
    enabled = true,
    highlight = "RenderMarkdownSign",
  },
})
