return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- optional but recommended
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local builtin = require("telescope.builtin")
		local root = require("config.root")

		vim.keymap.set("n", "<leader>ff", function()
			builtin.find_files({ cwd = root.neotree() })
		end, { desc = "Telescope find files" })

		vim.keymap.set("n", "<leader>fg", function()
			builtin.live_grep({ cwd = root.neotree() })
		end, { desc = "Telescope grep in files" })
	end,
}
