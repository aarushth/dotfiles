return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"rcasia/neotest-java",
	},
	keys = {
		{
			"<leader>ta",
			function()
				require("neotest").run.run(vim.uv.cwd())
			end,
			desc = "Test: Run All",
		},
		{
			"<leader>tu",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Test: Toggle Summary",
		},
		{
			"<leader>to",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "Test: Toggle Output Panel",
		},
		{
			"<leader>tx",
			function()
				require("neotest").run.stop()
			end,
			desc = "Test: Stop",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-java")({
					-- Shared JUnit 5 jar (see config/javatest.lua) instead of the JUnit 6
					-- one `:NeotestJava setup` would download.
					junit_jar = require("config.javatest").junit_jar(),
					-- The "update available" prompt is about moving to JUnit 6.
					disable_update_notifications = true,
				}),
			},
		})
	end,
}
