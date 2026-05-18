return {
	-- In order to modify the `lspconfig` configuration:
	{
		"neovim/nvim-lspconfig",
		 config = function()
				require("nvchad.configs.lspconfig").defaults()
				require "configs.lspconfig"
		 end,
	},
}
