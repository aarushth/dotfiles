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
			"<CMD>LazyGit<CR>",
			desc = "LazyGit (neo-tree root)",
		},
	},
}
