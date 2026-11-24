return {
	"saghen/blink.cmp",
	dependencies = {
		"saghen/blink.lib",
		"rafamadriz/friendly-snippets",
		"erooke/blink-cmp-latex",
		{
			"L3MON4D3/LuaSnip",
			config = function()
				local ls = require("luasnip")
				-- LuaSnip doesn't load VS Code-style snippets on its own
				require("luasnip.loaders.from_vscode").lazy_load()
				-- give markdown the tex/latex snippets too
				ls.filetype_extend("markdown", { "tex" })
			end,
		},
	},
	init = function()
		-- blink-cmp-latex still requires the pre-blink.lib module path
		package.preload["blink.cmp.lib.async"] = function()
			local task = require("blink.lib.task")
			return { task = {
				empty = function()
					return task.resolve()
				end,
			} }
		end
	end,
	build = function()
		require("blink.cmp").build():pwait()
	end,
	opts = {
		keymap = { preset = "super-tab" },
		completion = { documentation = { auto_show = true } },
		appearance = {
			nerd_font_variant = "mono",
		},
		snippets = {
			preset = "luasnip",
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				tex = { inherit_defaults = true, "latex" },
				markdown = { inherit_defaults = true, "latex" },
			},
			providers = {
				latex = {
					name = "Latex",
					module = "blink-cmp-latex",
					opts = {
						insert_command = true,
					},
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "rust" },
	},
}
