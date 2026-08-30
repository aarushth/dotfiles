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

-- return {
-- 	"nvim-neo-tree/neo-tree.nvim",
-- 	branch = "v3.x",
-- 	dependencies = {
-- 		"nvim-lua/plenary.nvim",
-- 		"MunifTanjim/nui.nvim",
-- 		"nvim-tree/nvim-web-devicons", -- optional, but recommended
-- 	},
-- 	keys = {
-- 		vim.keymap.set("n", "<leader>nt", "<CMD>Neotree toggle<CR>"),
-- 	},
-- 	opts = {
-- 		filesystem = {
-- 			filtered_items = {
-- 				visible = false,
-- 				hide_dotfiles = false,
-- 				hide_gitignored = false,
-- 				hide_ignored = true,
-- 				ignore_files = {
-- 					".neotreeignore",
-- 				},
-- 			},
-- 		},
-- 		window = {
-- 			width = 30, -- Set your desired pixel/character width here
-- 			max_width = 30,
-- 		},
-- 	},
-- 	lazy = false, -- neo-tree will lazily load itself
-- }
