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
		-- The console terminal can be taller than its panel, leaving the
		-- program's output above the visible rows. Whenever it changes, scroll
		-- the panel so the last non-empty line sits at the bottom (unless the
		-- cursor is in the console, so manual scrolling isn't fought).
		local function scroll_to_output(buf)
			for _, win in ipairs(vim.fn.win_findbuf(buf)) do
				if win ~= vim.api.nvim_get_current_win() then
					local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					local last = #lines
					while last > 1 and not lines[last]:match("%S") do
						last = last - 1
					end
					vim.api.nvim_win_call(win, function()
						vim.api.nvim_win_set_cursor(win, { last, 0 })
						vim.cmd("normal! zb")
					end)
				end
			end
		end
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dapui_console",
			callback = function(args)
				vim.api.nvim_buf_attach(args.buf, false, {
					on_lines = function(_, buf)
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(buf) then
								scroll_to_output(buf)
							end
						end)
					end,
				})
			end,
		})

		-- Deliberately not closing on event_terminated/event_exited so the
		-- console output stays visible after the program ends; <leader>du closes it.
	end,
}
