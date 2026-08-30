return {
	"EdenEast/nightfox.nvim",
	priority = 1000,
	config = function()
		require("nightfox").setup({
			options = {
				transparent = true,
			},
		})

		-- auto assign these groups to transparent so bufferline and lualine pick them up correctly
		local function clear_bar_backgrounds()
			for _, group in ipairs({ "StatusLine", "StatusLineNC", "TabLineFill" }) do
				local cur = vim.api.nvim_get_hl(0, { name = group, link = false })
				cur.bg = nil
				cur.ctermbg = nil
				vim.api.nvim_set_hl(0, group, cur)
			end
		end

		vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bar_backgrounds })

		vim.cmd.colorscheme("carbonfox")
	end,
}
