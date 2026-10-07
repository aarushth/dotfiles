vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.wrap = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = "unnamedplus"

vim.opt.scrolloff = 999

vim.opt.virtualedit = "block"

vim.opt.ignorecase = true

vim.opt.termguicolors = true

vim.g.mapleader = " "

vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = "●",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.title = true
vim.opt.titlestring = "nvim"
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	command = "if mode() != 'c' && getcmdwintype() == '' | silent! checktime | endif",
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})
vim.keymap.set("n", "<leader>wr", "<CMD>set wrap!<CR>")
vim.api.nvim_create_user_command("W", function()
	vim.cmd("w")
end, { desc = "binds :W to w" })
vim.api.nvim_create_user_command("Q", function()
	vim.cmd("q")
end, { desc = "binds :Q to q" })
