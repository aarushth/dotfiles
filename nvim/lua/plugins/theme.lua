return {
	"EdenEast/nightfox.nvim",
	config = function()
		require("nightfox").setup({
			options = { -- note: it's nested under "options"
				transparent = true,
			},
		})
		vim.cmd.colorscheme("carbonfox")
	end,
}
-- return {
-- 	"nyoom-engineering/oxocarbon.nvim",
-- 	build = false,
-- 	config = function()
-- 		vim.opt.background = "dark" -- set this to dark or light
-- 		vim.cmd.colorscheme("oxocarbon")
-- 		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- 	end,
-- }
