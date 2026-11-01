return {
	"mason-org/mason-lspconfig.nvim",
	opts = {},
	config = function(_, opts)
		local qmlls = vim.fn.executable("/usr/bin/qmlls") == 1 and "/usr/bin/qmlls" or "qmlls"
		vim.lsp.config("qmlls", { cmd = { qmlls } })

		vim.lsp.config("clangd", { cmd = { "clangd", "--query-driver=/usr/bin/gcc" } })

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
		-- Roots that are just a folder of .java files (see root_dir below).
		local plain_roots = {}
		-- Workspace folders added to a jdtls before it finished initializing,
		-- by client id; servers ignore notifications sent before that.
		local pending_folders = {}

		local function add_workspace_folders(client, folders)
			client:notify("workspace/didChangeWorkspaceFolders", { event = { added = folders, removed = {} } })
		end

		vim.lsp.config("jdtls", {
			init_options = { bundles = bundles },
			-- lspconfig only starts jdtls under a build file or .git, so plain
			-- folders of .java files (class projects) got no LSP or debugging.
			-- Fall back to the file's own directory, like VS Code does.
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" })
					or vim.fs.root(bufnr, { "build.xml", "pom.xml", "build.gradle", "build.gradle.kts" })
				if not root then
					root = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
					plain_roots[root] = true
				end
				on_dir(root)
			end,
			-- Each plain folder is its own project, so problem folders can reuse
			-- class names, but a jdtls per folder is a 1GB+ JVM each. Serve them
			-- all from one jdtls instead: it makes each workspace folder its own
			-- project.
			reuse_client = function(client, config)
				if client.name ~= config.name or client:is_stopped() then
					return false
				end
				local folder = { uri = vim.uri_from_fname(config.root_dir), name = config.root_dir }
				client.workspace_folders = client.workspace_folders or {}
				if vim.iter(client.workspace_folders):any(function(f)
					return f.uri == folder.uri
				end) then
					return true
				end
				if not (plain_roots[config.root_dir] and plain_roots[client.config.root_dir]) then
					return false
				end
				table.insert(client.workspace_folders, folder)
				if client.initialized then
					add_workspace_folders(client, { folder })
				else
					pending_folders[client.id] = pending_folders[client.id] or {}
					table.insert(pending_folders[client.id], folder)
				end
				return true
			end,
			on_init = function(client)
				local folders = pending_folders[client.id]
				pending_folders[client.id] = nil
				if folders then
					add_workspace_folders(client, folders)
				end
			end,
			-- Plain folders (no build tool) only get jars from lib/ next to
			-- them. Also give every project the shared JUnit 5 jar, so tests
			-- compile and run without copying JUnit into each folder.
			settings = {
				java = {
					project = {
						referencedLibraries = { "lib/**/*.jar", require("config.javatest").junit_jar() },
					},
				},
			},
		})

		-- nvim only briefly waits for servers on exit, so a slow one (jdtls)
		-- can outlive it. Ask every server to stop, give them a second, then
		-- force-stop whatever is still running.
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				local clients = vim.lsp.get_clients()
				for _, client in ipairs(clients) do
					client:stop()
				end
				local all_stopped = vim.wait(1000, function()
					return vim.iter(clients):all(function(c)
						return c:is_stopped()
					end)
				end, 50)
				if not all_stopped then
					for _, client in ipairs(clients) do
						if not client:is_stopped() then
							client:stop(true)
						end
					end
				end
				-- A stopped client only means the connection is closed: a jdtls JVM
				-- still shutting down (or starting up) can outlive nvim and keep
				-- using CPU, and stop(true) does nothing once a client is closing.
				-- Give those a second to exit, then kill them.
				local function jdtls_pids()
					return vim.iter(vim.api.nvim_get_proc_children(vim.fn.getpid()))
						:filter(function(pid)
							local f = io.open("/proc/" .. pid .. "/cmdline")
							local cmdline = f and f:read("*a")
							if f then
								f:close()
							end
							return cmdline ~= nil and cmdline:find("org.eclipse.jdt.ls", 1, true) ~= nil
						end)
						:totable()
				end
				vim.wait(1000, function()
					return #jdtls_pids() == 0
				end, 50)
				for _, pid in ipairs(jdtls_pids()) do
					vim.uv.kill(pid, "sigkill")
				end
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

				-- jdtls's own test runner (what LazyVim uses), for running tests
				-- without the neotest panel. Tests always run under the debugger,
				-- so breakpoints hit; results go to the dap-repl, failures to the
				-- quickfix list.
				local test = require("jdtls.dap")
				for _, map in ipairs({
					{ "<leader>tt", test.test_class, "Test: Run Class" },
					{ "<leader>tr", test.test_nearest_method, "Test: Run Nearest" },
					{ "<leader>tT", test.pick_test, "Test: Pick and Run" },
				}) do
					vim.keymap.set("n", map[1], function()
						map[2]()
					end, { buffer = args.buf, desc = map[3] })
				end

				-- The adapter fills in mainClass/javaExec/classpaths for every
				-- session by looking the project up. neotest-java's debug runs
				-- *attach* to a JVM it already started, which needs none of that,
				-- and the lookup can fail ("Could not resolve java executable").
				-- Skip it for attach. (neotest.lua sets the right projectName.)
				local dap = require("dap")
				if not vim.g.jdtls_attach_wrapped then
					vim.g.jdtls_attach_wrapped = true
					local start_adapter = dap.adapters.java
					dap.adapters.java = function(callback, config)
						start_adapter(function(adapter)
							if config.request == "attach" then
								adapter.enrich_config = nil
							end
							callback(adapter)
						end, config)
					end
				end
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
