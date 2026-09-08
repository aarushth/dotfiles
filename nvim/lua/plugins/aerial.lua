return {
	"stevearc/aerial.nvim",
	opts = {
		layout = {
			width = 25,
		},
		filter_kind = {
			"Class",
			"Constructor",
			"Enum",
			"Function",
			"Interface",
			"Object",
			"Module",
			"Method",
			"Struct",
		},
	},
	keys = {
		{ "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
	}, -- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
}
