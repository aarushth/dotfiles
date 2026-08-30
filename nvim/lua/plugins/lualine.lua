return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress", "EdenEast/nightfox.nvim" },
	config = function()
		require("lualine").setup({
			options = {
				disabled_filetypes = { "NvimTree", "help" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = {
					{ "filename", path = 1 },
					{ "diagnostics", sources = { "nvim_lsp" } },
				},
				lualine_x = {
					"lsp_progress",
					"diff",
					"encoding",
					"fileformat",
				},
				lualine_y = { "filetype" },
				lualine_z = {
					{ "location", padding = { left = 0 } },
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "filetype" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
