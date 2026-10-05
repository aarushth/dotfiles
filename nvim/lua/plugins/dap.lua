return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
		{ "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
		{ "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
		{ "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
		{
			"<leader>dB",
			function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
			desc = "Debug: Conditional Breakpoint",
		},
		{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: Toggle REPL" },
		{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
		{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
	},
	-- The Java adapter and launch configurations are registered by nvim-jdtls
	-- once jdtls attaches (see lsp.lua), since starting a session has to go
	-- through the `vscode.java.startDebugSession` LSP command.
}
