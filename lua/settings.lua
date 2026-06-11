----------------------------
---- options & settings ----
----------------------------

require('vim._core.ui2').enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- vim.opt.shada = "'100,<50,s10,:1000,/100,@100,h" -- Limit ShaDa file (for startup)

vim.g.have_nerd_font = true
vim.g.c_syntax_for_h = 1
vim.opt.termguicolors = true
vim.opt.laststatus = 3
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.winborder = 'rounded'
vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.spelloptions = 'camel'
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.iskeyword = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part
vim.opt.scrolloff = 5
vim.opt.confirm = true

vim.opt.completefunc = 'omnifunc'
-- vim.o.autocomplete = true
vim.opt.complete = '.,w,b,u,t'
vim.opt.completeopt = 'menuone,noinsert,fuzzy,nosort'
vim.opt.completetimeout = 100

vim.opt.shortmess:append('c')
vim.opt.pumheight = 7
vim.opt.pummaxwidth = 70
vim.opt.pumblend = 0
vim.opt.isfname:append('@-@')

vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99

-- UI characters.
vim.opt.fillchars = {
    eob = ' ',
    fold = ' ',
    foldclose = '',
    foldopen = ' ' ,
    foldsep = ' ',
    foldinner = ' ',
    msgsep = '─',
}


-----------------
---- Keymaps ----
-----------------

-- vim.keymap.del('n', 'gO')


vim.keymap.set('n', '-', function()
  if MiniFiles.get_explorer_state() ~= nil then
    return
  end
  local path = vim.api.nvim_buf_get_name(0)
  if path ~= "" and vim.loop.fs_stat(path) then
    MiniFiles.open(path)
  else
    MiniFiles.open()
  end
end)

local explore = '<Cmd>lua MiniFiles.open()<CR>'
vim.keymap.set('n', '_', explore, { desc = 'Explore File System', silent = true })


vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>:<CR>')
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })
-- vim.keymap.set('v', '<', '<gv', { desc = 'Unindent and keep selection' })
-- vim.keymap.set('v', '>', '>gv', { desc = 'Indent and keep selection' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result, centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result, centered' })
vim.keymap.set('n', '*', '*zzzv', { desc = 'Search word under cursor, centered' })

vim.keymap.set('n', 'gh', ': LspClangdSwitchSourceHeader<CR>', { desc = 'Goto [H]eader/ Source' })
vim.keymap.set('n', 'gb', ':b#<CR>', { desc = '[G]o to last buffer', silent = true })
vim.keymap.set('v', 'gj', ':join<CR>', { desc = 'Join selected lines' })

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

vim.keymap.set('n', '<leader>b', ':ls<CR>:b<Space>', { desc = 'List [B]uffers and choose' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show [E]rror Message' })
vim.keymap.set('n', '<leader>qq', vim.diagnostic.setqflist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>qc', ':cclose<CR>', { desc = '[C]lose Quickfix list' })
vim.keymap.set('n', '<leader>O', 'O<Esc>', { desc = 'Empty line above' })
vim.keymap.set('n', '<leader>o', 'o<Esc>', { desc = 'Empty line below' })
vim.keymap.set('n', '<leader>st', ':TodoQuickFix<CR>', { desc = '[T]odo-comments in [Q]ickfix List' })
vim.keymap.set('n', '<leader>T', ':tabnew<CR>', { desc = 'New [T]ab' })
vim.keymap.set('n', '<leader>u', ':Undotree<CR>', { desc = 'Undotree', silent = true })
vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste over selection, preserve register' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', 'j', function()
  return vim.v.count > 0 and 'j' or 'gj'
end, { expr = true })

vim.keymap.set('n', 'k', function()
  return vim.v.count > 0 and 'k' or 'gk'
end, { expr = true })

-- super tab for auto completion
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-Y>' or '<TAB>'
end, { expr = true })

---- snippet jump for builtin snippet engine
local jump_next = function()
  if vim.snippet.active({direction = 1}) then return vim.snippet.jump(1) end
end
local jump_prev = function()
  if vim.snippet.active({direction = -1}) then vim.snippet.jump(-1) end
end
vim.keymap.set({ 'i', 's' }, '<C-l>', jump_next)
vim.keymap.set({ 'i', 's' }, '<C-h>', jump_prev)
-- vim: ts=2 sts=2 sw=2 et
