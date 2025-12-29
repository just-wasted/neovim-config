---------------------------------------------------------------------
-- Based on kickstart.nvim https://github.com/nvim-lua/kickstart.nvim
---------------------------------------------------------------------

-- Sets colors to line numbers Above, Current and Below  in this order
function LineNumberColors()
	vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#6181a1", bold = false })
	vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#6181a1", bold = false })
end

vim.opt.number = true

vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

vim.opt.showmode = false

vim.o.winborder = "single"
-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true

vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.scrolloff = 5

-- set .h files as c headers, not cpp
vim.g.c_syntax_for_h = 1

vim.o.confirm = true

vim.cmd.highlight("MiniIndentScopeSymbol guifg=#6181a1")

-- vim.opt.foldtext = ""
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 2
