return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			-- Hyprland lua stubs, for hypr/ and hyprmoncfg/. These used to live
			-- in a .luarc.json, but LuaLS gives .luarc.json priority over the
			-- settings a client sends, so its `workspace.library` replaced the
			-- one lazydev provides -- which is what caused `undefined global
			-- 'vim'` in this config. Routing them through lazydev instead keeps
			-- a single source of truth and avoids the root-detection race.
			{ path = "/usr/share/hypr/stubs", words = { "hl%." } },
			-- { path = "lazy.nvim" },
		},
	},
}
