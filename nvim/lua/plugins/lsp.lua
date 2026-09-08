return {
	"mason-org/mason-lspconfig.nvim",
	opts = {},
	config = function(_, opts)
		-- mason-lspconfig v2 removed `opts.handlers` entirely, so per-server
		-- tweaks have to go through vim.lsp.config now.
		--
		-- Mason prepends its own bin dir to PATH, and its `qmlls` is a
		-- standalone 0.6 build that doesn't know about the system Qt module
		-- path, so a bare "qmlls" resolves to a server that fails every
		-- QtQuick/Quickshell import. Qt's own qmlls finds them with no extra
		-- import paths, so pin it explicitly.
		local qmlls = vim.fn.executable("/usr/bin/qmlls") == 1 and "/usr/bin/qmlls" or "qmlls"
		vim.lsp.config("qmlls", { cmd = { qmlls } })

		require("mason-lspconfig").setup(opts)
	end,
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
		"folke/lazydev.nvim",
	},
}
