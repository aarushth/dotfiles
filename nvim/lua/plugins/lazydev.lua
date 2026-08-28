return {
	"folke/lazydev.nvim",
	ft = "luza",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			-- { path = "lazy.nvim" },
		},
	},
}
