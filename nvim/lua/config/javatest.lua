-- One shared JUnit 5 jar for every Java project, plus :JavaTestInit, the
-- nvim version of VS Code's "Enable Java Tests" for plain (src/ + test/)
-- projects:
--   * lib/ gets a symlink to the shared jar (what VS Code downloads per project)
--   * a minimal Gradle build is written, since neotest-java only runs tests
--     in Gradle/Maven projects. It points at lib/, so nothing is downloaded.
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

local SETTINGS_GRADLE = [[
rootProject.name = '%s'
]]

local BUILD_GRADLE = [[
plugins { id 'java' }

dependencies {
    %s files('lib/%s')
}

sourceSets {
%s
}

test {
    useJUnitPlatform()%s
}
]]

--- build.gradle for either layout VS Code uses for plain projects: src/ +
--- test/ folders, or every .java file flat in the project root. Flat projects
--- are one source set (tests included), so JUnit goes on the main classpath
--- and the test task looks at the main classes.
local function build_gradle(root)
	if vim.fn.isdirectory(root .. "/test") == 1 then
		local main = vim.fn.isdirectory(root .. "/src") == 1 and "src" or "."
		return BUILD_GRADLE:format(
			"testImplementation",
			JUNIT_JAR,
			("    main { java { srcDirs = ['%s'] } }\n    test { java { srcDirs = ['test'] } }"):format(main),
			""
		)
	end
	return BUILD_GRADLE:format(
		"implementation",
		JUNIT_JAR,
		"    main { java { srcDirs = ['.'] } }",
		"\n    testClassesDirs = sourceSets.main.output.classesDirs\n    classpath = sourceSets.main.runtimeClasspath"
	)
end

--- Write `content` to `path` unless the file already exists.
local function write_new(path, content, done)
	if vim.uv.fs_stat(path) then
		return
	end
	vim.fn.writefile(vim.split(content, "\n", { trimempty = true }), path)
	table.insert(done, vim.fn.fnamemodify(path, ":t"))
end

vim.api.nvim_create_user_command("JavaTestInit", function()
	local root = vim.fn.getcwd()
	local done = {}

	vim.fn.mkdir(root .. "/lib", "p")
	local link = root .. "/lib/" .. JUNIT_JAR
	if not vim.uv.fs_lstat(link) then
		assert(vim.uv.fs_symlink(M.junit_jar(), link))
		table.insert(done, "lib/" .. JUNIT_JAR)
	end
	write_new(root .. "/settings.gradle", SETTINGS_GRADLE:format(vim.fn.fnamemodify(root, ":t")), done)
	write_new(root .. "/build.gradle", build_gradle(root), done)

	if #done == 0 then
		vim.notify("JavaTestInit: already set up")
	else
		vim.notify("JavaTestInit: created " .. table.concat(done, ", ") .. "\nRestart nvim so jdtls imports the project.")
	end
end, { desc = "Set up JUnit 5 + a minimal Gradle build for a plain Java project" })

return M
