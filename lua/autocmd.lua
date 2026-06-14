---- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
  desc = 'Highlight when yanking (copying) text',
})

---- don't auto-insert comment leader when using 'o' or 'O'
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('wasted/no_auto-comment', { clear = true }),
  pattern = '*',
  callback = function()
    vim.cmd('setlocal formatoptions-=o')
  end,
  desc = 'dont auto-insert comment leader',
})

--- open mini.map on startup
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup('wasted/show_map', { clear = true }),
	callback = function()
		require("mini.map").open()
	end,
  desc = 'show map on startup',
})

---- set height of help splits
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('wasted/help_window_size', { clear = true }),
  pattern = '*.txt',
  callback = function()
    if vim.bo.filetype == 'help' then
      vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.4))
    end
  end,
  desc = 'set height of help splits',
})

---- close with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('wasted/close_with_q', { clear = true }),
  pattern = {
    'git',
    'help',
    'man',
    'qf',
  },
  callback = function(args)
    if not vim.bo[args.buf].modifiable then
      vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
    end
  end,
  desc = 'Close with <q>',
})

---- delete buffer with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('wasted/delete_buf_with_q', { clear = true }),
  pattern = {
    'mininotify-history',
  },
  callback = function(args)
    vim.keymap.set('n', 'q', ':bd<CR>', { buffer = args.buf })
  end,
  desc = 'delete buffer with <q>',
})

---- Go to the last location when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('wasted/last_location', { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd('normal! g`"zz')
    end
  end,
  desc = 'Go to the last location when opening a buffer',
})

---- limit window height of qflist
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('wasted/qfheight', { clear = true }),
  pattern = 'qf',
  callback = function()
    vim.cmd('resize 5')
  end,
  desc = 'limit window height of qflist',
})

---- command line completion
vim.api.nvim_create_autocmd('CmdlineChanged', {
  pattern = '[:\\/\\?]',
  callback = function()
    vim.fn.wildtrigger()
  end
})

---- insert only necessary characters when completing right of the cursor
---- NOTE still struggles with snippets
-- vim.api.nvim_create_autocmd('CompleteDone', {
--   group = vim.api.nvim_create_augroup('wasted/smart_complete', { clear = true }),
--   callback = function()
--     local item = vim.v.completed_item
--     if not item then
--       return
--     end
--
--     local completed_text = item.word or item.abbr or ''
--     if completed_text == '' then
--       return
--     end
--
--     local suffix = vim.api.nvim_get_current_line():sub(vim.fn.col('.'), vim.fn.col('.') + 60)
--
--     local match_len = 0
--     for len = math.min(#suffix, #completed_text), 1, -1 do
--       if completed_text:sub(-len) == suffix:sub(1, len) then
--         match_len = len
--         break
--       end
--     end
--
--     if match_len > 0 then
--       vim.cmd('normal! d' .. match_len .. 'l')
--     end
--   end,
--   desc = 'smart complete',
-- })

-- vim: ts=2 sts=2 sw=2 et
