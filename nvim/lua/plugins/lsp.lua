return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		-- handlers = {
		-- 	lua_ls = function()
		-- 		require("lspconfig").lua_ls.setup({
		-- 			settings = {
		-- 				Lua = {
		-- 					runtime = { version = "LuaJIT" },
		-- 					workspace = {
		-- 						checkThirdParty = false,
		-- 						library = {
		-- 							vim.env.VIMRUNTIME,
		-- 						},
		-- 					},
		-- 				},
		-- 			},
		-- 		})
		-- 	end,
		-- },
	},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
		"folke/lazydev.nvim",
	},
}
