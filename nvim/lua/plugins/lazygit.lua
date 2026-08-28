return {
	"kdheepak/lazygit.nvim",
	lazy = true,
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	keys = {
		{
			"<leader>lg",
			function()
				local root = require("config.root")
				local dir = root.neotree()
				require("lazygit").lazygit(root.git(dir) or dir)
			end,
			desc = "LazyGit (neo-tree root)",
		},
	},
}
