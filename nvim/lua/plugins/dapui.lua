return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dapui.setup({
			layouts = {
				{
					position = "left",
					size = 25, -- columns (default 40)
					elements = {
						{ id = "scopes", size = 0.25 },
						{ id = "breakpoints", size = 0.25 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
				},
				{
					position = "bottom",
					size = 10, -- lines
					elements = {
						-- The repl holds the play/step controls; keep it narrow so
						-- the program's output gets most of the width.
						{ id = "repl", size = 0.2 },
						{ id = "console", size = 0.8 },
					},
				},
			},
		})
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		-- Deliberately not closing on event_terminated/event_exited so the
		-- console output stays visible after the program ends; <leader>du closes it.
	end,
}
