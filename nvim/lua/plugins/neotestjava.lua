return {
	"rcasia/neotest-java",
	ft = "java",
	dependencies = {
		"mfussenegger/nvim-jdtls",
		"mfussenegger/nvim-dap", -- for debugging (optional)
		"rcarriga/nvim-dap-ui", -- recommended
		"theHamsta/nvim-dap-virtual-text", -- recommended
	},
	-- Only `:NeotestJava` lives here; the adapter itself is configured in
	-- neotest.lua. Don't run `:NeotestJava setup`, it downloads JUnit 6.
}
