-- One shared JUnit 5 jar for every Java project: jdtls puts it on each
-- project's classpath (plugins/lsp.lua) and neotest runs tests with it
-- (plugins/neotest.lua) instead of :NeotestJava setup's JUnit 6.
local M = {}

-- Platform 1.14.4 = Jupiter 5.14.4, still JUnit 5.
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

return M
