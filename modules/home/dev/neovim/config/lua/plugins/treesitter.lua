return {
	-- This file sets syntax highlighting using treesitter.
	-- Modify this file in order to not be too tedius when working with languages.
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				-- defaults
				"vim",
				"lua",
				"vimdoc",

				-- web dev
				"html",
				"css",
				"javascript",
				"typescript",
				"tsx",

				-- low level
				"c",
				"cpp",
				"rust",
				"zig",
			},
		},
	},
}
