local M = {}

--- Directory neo-tree is currently rooted at, falling back to the cwd.
function M.neotree()
	local ok, manager = pcall(require, "neo-tree.sources.manager")
	if ok then
		local state = manager.get_state("filesystem")
		if state and state.path and state.path ~= "" then
			return state.path
		end
	end
	return vim.uv.cwd()
end

--- Root of the git worktree containing `path`, or nil when there is none.
function M.git(path)
	path = path or M.neotree()
	local dot = vim.fs.find(".git", { upward = true, path = path })[1]
	return dot and vim.fs.dirname(dot)
end

return M
