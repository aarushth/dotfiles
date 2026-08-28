return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons", -- optional, but recommended
	},
	keys = {
		vim.keymap.set("n", "<leader>nt", "<CMD>Neotree toggle<CR>"),
	},
	opts = {
		filesystem = {
			filtered_items = {
				visible = false,
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_ignored = true,
				ignore_files = {
					".neotreeignore",
				},
			},
		},
		window = {
			width = 30, -- Set your desired pixel/character width here
		},
	},
	lazy = false, -- neo-tree will lazily load itself
}
