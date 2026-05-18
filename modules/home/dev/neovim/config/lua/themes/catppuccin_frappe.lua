local M = {}

M.base_30 = {
  white = "#c6d0f5",
  darker_black = "#232634",
  black = "#303446",
  black2 = "#292c3c",
  one_bg = "#414559",
  one_bg2 = "#51576d",
  one_bg3 = "#626880",
  grey = "#737994",
  grey_fg = "#838ba7",
  grey_fg2 = "#949cbb",
  light_grey = "#a5adce",
  red = "#e78284",
  baby_pink = "#f4b8e4",
  pink = "#f4b8e4",
  line = "#414559",
  green = "#a6d189",
  vibrant_green = "#b7e0c6",
  nord_blue = "#85c1dc",
  blue = "#8caaee",
  yellow = "#e5c890",
  sun = "#ebd3a5",
  purple = "#ca9ee6",
  dark_purple = "#b898d8",
  teal = "#81c8be",
  orange = "#ef9f76",
  cyan = "#99d1db",
  statusline_bg = "#292c3c",
  lightbg = "#3a3e50",
  pmenu_bg = "#a6d189",
  folder_bg = "#8caaee",
  lavender = "#babbf1",
}

M.base_16 = {
  base00 = "#303446",
  base01 = "#292c3c",
  base02 = "#414559",
  base03 = "#51576d",
  base04 = "#626880",
  base05 = "#c6d0f5",
  base06 = "#b5bfe2",
  base07 = "#a5adce",
  base08 = "#e78284",
  base09 = "#ef9f76",
  base0A = "#e5c890",
  base0B = "#a6d189",
  base0C = "#81c8be",
  base0D = "#8caaee",
  base0E = "#ca9ee6",
  base0F = "#ea999c",
}

M.polish_hl = {
  treesitter = {
    ["@variable"] = { fg = M.base_30.lavender },
    ["@property"] = { fg = M.base_30.teal },
    ["@variable.builtin"] = { fg = M.base_30.red },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "catppuccin_frappe")

return M
