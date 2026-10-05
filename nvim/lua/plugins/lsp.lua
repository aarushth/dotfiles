return {
	"mason-org/mason-lspconfig.nvim",
	opts = {},
	config = function(_, opts)
		local qmlls = vim.fn.executable("/usr/bin/qmlls") == 1 and "/usr/bin/qmlls" or "qmlls"
		vim.lsp.config("qmlls", { cmd = { qmlls } })

		-- jdtls only speaks DAP through the java-debug (and java-test) plugins,
		-- which have to be handed to it as bundles at startup.
		local mason = vim.fn.stdpath("data") .. "/mason/packages/"
		local bundles = vim.fn.glob(
			mason .. "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			true,
			true
		)
		for _, jar in ipairs(vim.fn.glob(mason .. "java-test/extension/server/*.jar", true, true)) do
			local name = vim.fn.fnamemodify(jar, ":t")
			if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
				table.insert(bundles, jar)
			end
		end
		vim.lsp.config("jdtls", {
			init_options = { bundles = bundles },
			-- lspconfig only starts jdtls under a build file or .git, so plain
			-- folders of .java files (class projects) got no LSP or debugging.
			-- Fall back to the file's own directory, like VS Code does.
			root_dir = function(bufnr, on_dir)
				on_dir(
					vim.fs.root(bufnr, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" })
						or vim.fs.root(bufnr, { "build.xml", "pom.xml", "build.gradle", "build.gradle.kts" })
						or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
				)
			end,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client or client.name ~= "jdtls" then
					return
				end
				local jdtls = require("jdtls")
				-- Also registers a provider that finds main classes on every
				-- dap.continue(). Don't call setup_dap_main_class_configs() here:
				-- it disables that provider and only looks once, at attach, when
				-- jdtls often hasn't imported the project yet.
				jdtls.setup_dap({ hotcodereplace = "auto" })
			end,
		})

		require("mason-lspconfig").setup(opts)
	end,
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
		"folke/lazydev.nvim",
		"mfussenegger/nvim-jdtls",
	},
}
