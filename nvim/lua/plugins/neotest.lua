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
		local java = require("neotest-java")({
			-- Shared JUnit 5 jar (see config/javatest.lua) instead of the JUnit 6
			-- one `:NeotestJava setup` would download.
			junit_jar = require("config.javatest").junit_jar(),
			-- The "update available" prompt is about moving to JUnit 6.
			disable_update_notifications = true,
		})

		-- neotest-java can only run a folder that sits inside one module, and
		-- errors on a folder spanning several (run-all in a :JavaTestInit
		-- multi-folder project, one module per problem folder). Returning nil
		-- makes neotest split the run into the folder's children instead.
		local build_spec = java.build_spec
		java.build_spec = function(args)
			local ok, spec = pcall(build_spec, args)
			if ok then
				return spec
			end
			if
				args.tree:data().type == "dir"
				and tostring(spec):find("module not found in multimodule project", 1, true)
			then
				return nil
			end
			error(spec, 0)
		end

		require("neotest").setup({
			adapters = { java },
			-- Run split-up folders one at a time: several neotest-java runs at
			-- once all ask jdtls to compile and stall.
			running = { concurrent = false },
		})
	end,
}
