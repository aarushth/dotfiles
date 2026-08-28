return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"typescript",
			"javascript",
			"java",
			"javadoc",
			"kotlin",
			"python",
			"go",
			"cpp",
			"rust",
			"html",
			"css",
			"tsx",
			"jsx",
			"prisma",
			"yaml",
			"xml",
			"toml",
			"qmldir",
			"qmljs",
			"json",
			"glsl",
			"dockerfile",
			"bash",
			"terraform",
			"markdown",
			"markdown_inline",
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter.setup", {}),
			callback = function(args)
				local buf = args.buf
				local filetype = args.match

				local language = vim.treesitter.language.get_lang(filetype) or filetype
				if not vim.treesitter.language.add(language) then
					return
				end

				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

				vim.treesitter.start(buf, language)
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
