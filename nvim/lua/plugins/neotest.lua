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
		-- Which classes count as tests (both for finding test files and for
		-- JUnit's --include-classname). The defaults plus *Testing, which
		-- course projects use (e.g. Testing.java).
		local test_patterns = { "^.*Tests?$", "^.*IT$", "^.*Spec$", "^.*Testing$" }

		-- neotest-java only recognizes Maven/Gradle (or .git) projects, but it
		-- compiles and gets classpaths through jdtls, so plain folders of .java
		-- files (class projects) work too once it's given a
		-- root and a build tool for them. Every folder holding .java files is a
		-- module, the same way jdtls gives each its own project (see lsp.lua).
		local default_root_finder = require("neotest-java.core.root_finder")
		local build_tools = require("neotest-java.build_tool")
		local Path = require("neotest-java.model.path")
		-- JUnit writes its XML reports under <module>/<this>/junit-reports.
		-- neotest-java deletes the reports once read; results() below removes
		-- the folders.
		local PLAIN_BUILD_DIR = ".neotest-java"

		--- Whether `dir` has .java files at most `depth` folders down.
		local function has_java(dir, depth)
			for name, type in vim.fs.dir(dir) do
				if type == "file" and name:match("%.java$") then
					return true
				elseif type == "directory" and depth > 0 and name:sub(1, 1) ~= "." then
					if has_java(dir .. "/" .. name, depth - 1) then
						return true
					end
				end
			end
			return false
		end

		local root_finder = {
			find_root = function(dir)
				local root = default_root_finder.find_root(dir)
				if root then
					return root
				end
				-- Anything under nvim's cwd belongs to the cwd's project; rooting a
				-- subfolder separately would add a second tree to the summary.
				local cwd = vim.uv.cwd()
				if vim.startswith(dir, cwd .. "/") then
					dir = cwd
				end
				return has_java(dir, 4) and dir or nil
			end,
		}

		local plain_build_tool = {
			get_project_filename = function()
				return "%.java$"
			end,
			get_build_dirname = function()
				return Path(PLAIN_BUILD_DIR)
			end,
			get_artifact_id = function(base_dir)
				return base_dir:name()
			end,
			get_spring_property_filepaths = function()
				return {}
			end,
		}

		local nio = require("nio")

		--- The initialized jdtls with a workspace folder holding `dir` (the
		--- deepest one). Plain folders share one jdtls (see lsp.lua).
		local function find_jdtls(dir)
			local best, best_len = nil, 0
			for _, c in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
				for _, folder in ipairs(c.initialized and c.workspace_folders or {}) do
					local root = folder.name
					if (dir == root or vim.startswith(dir, root .. "/")) and #root > best_len then
						best, best_len = c, #root
					end
				end
			end
			return best
		end

		local junit_jar = require("config.javatest").junit_jar()

		--- Whether jdtls has imported `dir` into a project yet. A plain folder's
		--- project exists a moment before jdtls adds the shared JUnit jar to it
		--- (see lsp.lua), and tests compiled before then have no tests to run.
		local function imported(client, dir)
			local plain = not default_root_finder.find_root(dir)
			local future = nio.control.future()
			vim.schedule(function()
				client:request("workspace/executeCommand", {
					command = "java.project.getClasspaths",
					arguments = { vim.uri_from_fname(dir), vim.json.encode({ scope = "test" }) },
				}, function(err, res)
					future.set(not err and (not plain or vim.tbl_contains(res.classpaths or {}, junit_jar)))
				end)
			end)
			return future.wait()
		end

		-- neotest-java's own client provider reuses whichever jdtls it found
		-- first, and asks it about folders it may not serve yet (a problem
		-- folder whose files were never opened), so those requests hang. Pick
		-- the jdtls for the folder instead, adding the folder (by loading one of
		-- its .java files) and waiting for the import if it isn't served yet.
		local ready = {}
		-- Folders compiled at least once, by client id .. path (see lsp_compiler).
		local built = {}
		local function client_provider(dir_path)
			local dir = dir_path:to_string()
			local client = find_jdtls(dir)
			if not client then
				nio.scheduler()
				local file = vim.fn.globpath(dir, "**/*.java", false, true)[1]
				if not file then
					error("No Java file found in " .. dir, 0)
				end
				local buf = vim.fn.bufadd(file)
				vim.fn.bufload(buf)
				-- FileType is what attaches LSP servers; bufload doesn't fire it.
				vim.bo[buf].filetype = "java"
				for _ = 1, 120 do
					client = find_jdtls(dir)
					if client then
						break
					end
					nio.sleep(500)
				end
				assert(client, "jdtls didn't start for " .. dir)
			end
			if not ready[client.id .. dir] then
				for _ = 1, 120 do
					if imported(client, dir) then
						break
					end
					nio.sleep(1000)
				end
				ready[client.id .. dir] = true
			end
			return client
		end

		local java = require("neotest-java")({
			-- Shared JUnit 5 jar (see config/javatest.lua) instead of the JUnit 6
			-- one `:NeotestJava setup` would download.
			junit_jar = require("config.javatest").junit_jar(),
			-- The "update available" prompt is about moving to JUnit 6.
			disable_update_notifications = true,
			test_classname_patterns = test_patterns,
		}, {
			root_finder = root_finder,
			client_provider = client_provider,
			-- neotest-java's compiler uses its own client provider and doesn't
			-- wait for the build (its java/buildWorkspace parameter isn't even
			-- one jdtls answers), so JUnit can start before jdtls has compiled a
			-- folder it just added, and finds no tests. Build the folder's own
			-- project instead, in full the first time, and wait for it.
			lsp_compiler = {
				compile = function(args)
					local dir = args.base_dir:to_string()
					local client = client_provider(args.base_dir)
					local full = args.compile_mode == "full" or not built[client.id .. dir]
					local future = nio.control.future()
					vim.schedule(function()
						client:request("java/buildProjects", {
							identifiers = { { uri = vim.uri_from_fname(dir) } },
							isFullBuild = full,
						}, function()
							future.set()
						end)
					end)
					future.wait()
					built[client.id .. dir] = true
				end,
			},
			build_tool_getter = function(project_type)
				return project_type == "unknown" and plain_build_tool or build_tools.get(project_type)
			end,
		})

		-- neotest-java identifies classes and tests by name alone
		-- (LocationTest#test0()), so same-named classes in different problem
		-- folders collide in the tree and one folder's results are lost. Prefix
		-- those ids with the file path (path::LocationTest#test0()), and strip it
		-- again wherever neotest-java hands an id to JUnit or matches results.
		local Tree = require("neotest.types").Tree

		--- `id` without its file path prefix.
		local function unprefixed(id)
			return id:match(".*::(.*)$") or id
		end

		--- A copy of `tree` with each position replaced by `map(position)`.
		local function map_tree(tree, map)
			local function map_list(list)
				local out = { map(list[1]) }
				for i = 2, #list do
					out[i] = map_list(list[i])
				end
				return out
			end
			return Tree.from_list(map_list(tree:to_list()), function(pos)
				return pos.id
			end)
		end

		local discover_positions = java.discover_positions
		java.discover_positions = function(path)
			local tree = discover_positions(path)
			return tree
				and map_tree(tree, function(pos)
					if pos.type ~= "namespace" and pos.type ~= "test" then
						return pos
					end
					return vim.tbl_extend("force", pos, {
						id = pos.path .. "::" .. pos.id,
						-- The JUnit selector for a test. neotest-java attaches it to
						-- the original position after discovery, so look it up then.
						ref = function()
							return pos.ref and pos.ref() or pos.id
						end,
					})
				end)
		end

		-- Class selectors are taken straight from the position id.
		local CommandBuilder = require("neotest-java.command.junit_command_builder")
		local add_test_class = CommandBuilder.add_test_class
		CommandBuilder.add_test_class = function(self, name)
			return add_test_class(self, unprefixed(name))
		end

		local results = java.results
		java.results = function(spec, result, tree)
			-- Results come back keyed by JUnit's ids, and are matched against the
			-- tree's; match them on an unprefixed copy, then key them by the real
			-- ids. A run never spans two folders, so the copy's ids are unique.
			local real_ids = {}
			local plain_tree = map_tree(tree, function(pos)
				local id = unprefixed(pos.id)
				real_ids[id] = pos.id
				return id == pos.id and pos or vim.tbl_extend("force", pos, { id = id })
			end)
			local ok, res = pcall(results, spec, result, plain_tree)
			local reports_dir = spec.context and spec.context.reports_dir
			if reports_dir and reports_dir:contains(PLAIN_BUILD_DIR) then
				nio.scheduler()
				local dir = reports_dir:to_string()
				vim.fn.delete(dir, "rf")
				-- junit-reports/, then .neotest-java/ itself, if now empty.
				vim.fn.delete(vim.fs.dirname(dir), "d")
				vim.fn.delete(vim.fs.dirname(vim.fs.dirname(dir)), "d")
				-- neotest-java also creates the build dir relative to nvim's cwd.
				vim.fn.delete(PLAIN_BUILD_DIR, "d")
			end
			if not ok then
				error(res, 0)
			end
			local keyed = {}
			for id, r in pairs(res) do
				keyed[real_ids[id] or id] = r
			end
			return keyed
		end

		-- neotest-java can only run a folder that sits inside one module, and
		-- errors on a folder spanning several (run-all in a multi-folder
		-- project, one module per problem folder). Returning nil makes neotest
		-- split the run into the folder's children instead.
		--
		-- For debug runs, neotest-java also passes the folder name as
		-- projectName, but jdtls names plain-folder projects differently (e.g.
		-- Location_3d6b38ec), so evaluating watches fails with "Project ...
		-- cannot be found". Ask jdtls for the test file's real project name.

		--- A test file to identify the project by: the position itself, or the
		--- first test file under the module when debugging a whole folder.
		local function test_file(position, cwd)
			if position.path:match("%.java$") then
				return position.path
			end
			return vim.fs.find(function(name)
				local stem = name:match("^(.*)%.java$")
				return stem ~= nil and vim.iter(test_patterns):any(function(p)
					return stem:match(p) ~= nil
				end)
			end, { path = cwd, limit = 1 })[1]
		end

		local function jdtls_project_name(file)
			local client = file and find_jdtls(file)
			if not client then
				return nil
			end
			local future = nio.control.future()
			vim.schedule(function()
				client:request("workspace/executeCommand", {
					command = "vscode.java.test.findTestTypesAndMethods",
					arguments = { vim.uri_from_fname(file) },
				}, function(err, items)
					future.set(not err and items and items[1] and items[1].projectName or nil)
				end)
			end)
			return future.wait()
		end

		local build_spec = java.build_spec
		java.build_spec = function(args)
			-- A folder or file whose test classes have no tests yet (e.g. a TODO
			-- Testing.java) would give JUnit nothing to select, which errors.
			-- Returning nil lets neotest look for tests further down and find none.
			local has_tests = vim.iter(args.tree:iter()):any(function(_, pos)
				return pos.type == "test"
			end)
			if not has_tests then
				return nil
			end
			local ok, spec = pcall(build_spec, args)
			if not ok then
				-- Created before the error; results() never runs to remove it.
				nio.scheduler()
				vim.fn.delete(PLAIN_BUILD_DIR, "d")
			end
			if ok then
				if spec and type(spec.strategy) == "table" and spec.strategy.request == "attach" then
					local file = test_file(args.tree:data(), spec.cwd)
					spec.strategy.projectName = jdtls_project_name(file) or spec.strategy.projectName
				end
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
