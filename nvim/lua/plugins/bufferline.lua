return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				mode = "buffers",
				indicator = {
					-- icon = '▎', -- this should be omitted if indicator style is not 'icon'
					style = "underline",
				},
				-- style_preset = bufferline.style_preset.default,
				themable = true,
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						separator = true,
					},
				},
				custom_filter = function(buf_number)
					-- filter out filetypes yo
					if vim.fn.bufname(buf_number) ~= "" then
						return true
					else
						return false
					end
				end,
			},
		})
	end,
}
