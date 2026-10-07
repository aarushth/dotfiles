-- One shared JUnit 5 jar for every Java project, plus :JavaTestInit, the
-- nvim version of VS Code's "Enable Java Tests" for plain (no build tool)
-- projects:
--   * lib/ gets a symlink to the shared jar (what VS Code downloads per
--     project), unless lib/ already has a JUnit 5 standalone jar.
--   * a minimal Gradle build is written, since neotest-java only runs tests
--     in Gradle/Maven projects. It uses whatever jar is in lib/, so nothing is
--     downloaded.
-- Run it once per project (again only after adding a new problem folder).
local M = {}

-- Platform 1.14.4 = Jupiter 5.14.4, still JUnit 5. Also what neotest runs
-- tests with (see plugins/neotest.lua) instead of :NeotestJava setup's JUnit 6.
local JUNIT_JAR = "junit-platform-console-standalone-1.14.4.jar"
local JUNIT_SHA256 = "7c6968cbcaf4301c729f202b23b7d736c5d88be625fc7d27ad5d746146a8bc28"

--- Path to the shared JUnit jar, downloading it on first use.
function M.junit_jar()
	local jar = vim.fn.expand("~/.local/share/java/") .. JUNIT_JAR
	if vim.uv.fs_stat(jar) then
		return jar
	end

	vim.fn.mkdir(vim.fn.fnamemodify(jar, ":h"), "p")
	local url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.14.4/"
		.. JUNIT_JAR
	local out = vim.fn.system({ "curl", "-fsSL", "-o", jar, url })
	local f = io.open(jar, "rb")
	local sha = f and vim.fn.sha256(f:read("*a"))
	if f then
		f:close()
	end
	if vim.v.shell_error ~= 0 or sha ~= JUNIT_SHA256 then
		vim.fn.delete(jar)
		vim.notify("Failed to download " .. JUNIT_JAR .. "\n" .. out, vim.log.levels.ERROR)
	end
	return jar
end

-- Folders that never hold sources: build output, jars, and dot-dirs.
local function is_skipped(name)
	return name:sub(1, 1) == "." or name == "bin" or name == "build" or name == "lib"
end

-- A project whose sources sit directly in its folder (no src/). Build output
-- (bin/, which is also where neotest-java looks for classes) lives inside the
-- source folder, so exclude it, or Eclipse copies bin/ into itself. Tests and
-- code share one source set, so the test task looks at the main classes.
local FLAT_BUILD_GRADLE = [[
plugins { id 'java' }

dependencies {
    implementation fileTree(dir: "${rootDir}/lib", include: '*.jar')
}

sourceSets {
    main {
        java {
            srcDirs = ['.']
            exclude 'bin/**', 'build/**', 'lib/**', '*.gradle'
        }
        resources { srcDirs = [] }
    }
}

test {
    useJUnitPlatform()
    testClassesDirs = sourceSets.main.output.classesDirs
    classpath = sourceSets.main.runtimeClasspath
}
]]

local SRC_TEST_BUILD_GRADLE = [[
plugins { id 'java' }

dependencies {
    testImplementation fileTree(dir: "${rootDir}/lib", include: '*.jar')
}

sourceSets {
    main { java { srcDirs = ['%s'] } }
    test { java { srcDirs = ['test'] } }
}

test { useJUnitPlatform() }
]]

-- Each folder with its own build.gradle is a separate project, so problem
-- folders can reuse class names (Client, LocationTest, ...).
local MULTI_SETTINGS_GRADLE = [[
rootProject.name = '%s'

rootDir.eachFileRecurse(groovy.io.FileType.FILES) { f ->
    def rel = rootDir.toPath().relativize(f.toPath()).toString()
    if (f.name == 'build.gradle' && f.parentFile != rootDir
            && !(rel =~ /(^|\/)(bin|build|lib|\.[^\/]*)\//)) {
        def name = rootDir.toPath().relativize(f.parentFile.toPath()).toString().replaceAll(/[^A-Za-z0-9_-]+/, '_')
        include name
        project(":$name").projectDir = f.parentFile
    }
}
]]

--- Directories under `root` that directly contain .java files. Doesn't
--- descend into a directory once it has .java files.
local function java_dirs(root)
	local dirs = {}
	local function walk(dir)
		local has_java, subdirs = false, {}
		for name, type in vim.fs.dir(dir) do
			if type == "file" and name:match("%.java$") then
				has_java = true
			elseif type == "directory" and not is_skipped(name) then
				table.insert(subdirs, dir .. "/" .. name)
			end
		end
		if has_java then
			table.insert(dirs, dir)
			return
		end
		for _, sub in ipairs(subdirs) do
			walk(sub)
		end
	end
	walk(root)
	return dirs
end

--- Write `content` to `path` unless the file already exists.
local function write_new(path, content, root, done)
	if vim.uv.fs_stat(path) then
		return
	end
	vim.fn.writefile(vim.split(content, "\n", { trimempty = true }), path)
	table.insert(done, path:sub(#root + 2))
end

--- Make sure lib/ has a JUnit 5 standalone jar: keep an existing one,
--- otherwise symlink the shared jar. Returns false if lib/ only has JUnit 6.
local function ensure_jar(root, done)
	local lib = root .. "/lib"
	local existing = vim.fn.glob(lib .. "/junit-platform-console-standalone-*.jar", true, true)
	for _, jar in ipairs(existing) do
		-- JUnit 5 is Platform 1.x; JUnit 6 numbers the platform 6.x.
		if vim.fn.fnamemodify(jar, ":t"):match("^junit%-platform%-console%-standalone%-1%.") then
			return true
		end
	end
	if #existing > 0 then
		vim.notify(
			"JavaTestInit: lib/ has "
				.. table.concat(vim.tbl_map(function(p) return vim.fn.fnamemodify(p, ":t") end, existing), ", ")
				.. " (JUnit 6). Delete it and rerun to use JUnit 5.",
			vim.log.levels.ERROR
		)
		return false
	end
	vim.fn.mkdir(lib, "p")
	assert(vim.uv.fs_symlink(M.junit_jar(), lib .. "/" .. JUNIT_JAR))
	table.insert(done, "lib/" .. JUNIT_JAR)
	return true
end

-- Everything :JavaTestInit, jdtls (Eclipse metadata) and Gradle generate. No
-- slash = matches at any depth, which covers per-folder build.gradle files.
local GITIGNORE = {
	"build.gradle",
	"settings.gradle",
	"bin/",
	"build/",
	".gradle/",
	".classpath",
	".project",
	".settings/",
}

--- Add the generated-file patterns missing from root/.gitignore, keeping
--- whatever is already there.
local function update_gitignore(root, done)
	local path = root .. "/.gitignore"
	local entries = vim.deepcopy(GITIGNORE)
	-- Only the symlink is generated; a jar someone put in lib/ stays tracked.
	local link = vim.uv.fs_lstat(root .. "/lib/" .. JUNIT_JAR)
	if link and link.type == "link" then
		table.insert(entries, "lib/" .. JUNIT_JAR)
	end

	local existing = vim.uv.fs_stat(path) and vim.fn.readfile(path) or {}
	local have = {}
	for _, line in ipairs(existing) do
		have[vim.trim(line)] = true
	end
	local missing = vim.tbl_filter(function(e)
		return not have[e]
	end, entries)
	if #missing == 0 then
		return
	end

	local lines = {}
	if #existing > 0 then
		table.insert(lines, "")
	end
	table.insert(lines, "# Generated by :JavaTestInit (nvim), jdtls and Gradle")
	vim.list_extend(lines, missing)
	-- readfile drops a missing final newline, so rewrite the whole file
	-- rather than appending onto a possibly unterminated last line.
	vim.fn.writefile(vim.list_extend(existing, lines), path)
	table.insert(done, ".gitignore")
end

vim.api.nvim_create_user_command("JavaTestInit", function()
	local root = vim.fn.getcwd()
	local done = {}
	if not ensure_jar(root, done) then
		return
	end

	local name = vim.fn.fnamemodify(root, ":t"):gsub("[^%w_-]+", "_")
	local dirs = java_dirs(root)
	if vim.fn.isdirectory(root .. "/test") == 1 then
		local main = vim.fn.isdirectory(root .. "/src") == 1 and "src" or "."
		write_new(root .. "/settings.gradle", ("rootProject.name = '%s'\n"):format(name), root, done)
		write_new(root .. "/build.gradle", SRC_TEST_BUILD_GRADLE:format(main), root, done)
	elseif #dirs == 1 and dirs[1] == root then
		write_new(root .. "/settings.gradle", ("rootProject.name = '%s'\n"):format(name), root, done)
		write_new(root .. "/build.gradle", FLAT_BUILD_GRADLE, root, done)
	elseif #dirs > 0 then
		write_new(root .. "/settings.gradle", MULTI_SETTINGS_GRADLE:format(name), root, done)
		for _, dir in ipairs(dirs) do
			write_new(dir .. "/build.gradle", FLAT_BUILD_GRADLE, root, done)
		end
	else
		vim.notify("JavaTestInit: no .java files found under " .. root, vim.log.levels.WARN)
		return
	end
	update_gitignore(root, done)

	if #done == 0 then
		vim.notify("JavaTestInit: already set up")
	else
		vim.notify("JavaTestInit: created\n  " .. table.concat(done, "\n  ") .. "\nRestart nvim so jdtls imports the project.")
	end
end, { desc = "Set up JUnit 5 + a minimal Gradle build for a plain Java project" })

return M
