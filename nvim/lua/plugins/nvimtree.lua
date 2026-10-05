return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		sort = {
			sorter = "case_sensitive",
		},
		view = {
			width = 30,
		},
		renderer = {
			group_empty = true,
		},
		filters = {
			dotfiles = false,
		},
	},
	keys = {
		vim.keymap.set("n", "<leader>nt", "<CMD>NvimTreeToggle<CR>"),
	},
	lazy = false,
}
