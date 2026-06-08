vim.pack.add({
  'https://github.com/antonk52/filepaths_ls.nvim',
})
vim.lsp.enable('filepaths_ls')

MiniIcons.tweak_lsp_kind()

vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-e><CR>' or '<CR>'
end, { expr = true })

-- super tab for auto completion
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-Y>' or '<TAB>'
end, { expr = true })

-- snippets & completion ----
local gen_loader = require('mini.snippets').gen_loader
local config_path = vim.fn.stdpath('config')
require('mini.snippets').setup({
  snippets = {
    gen_loader.from_file(config_path .. '/snippets/global.json'),
    gen_loader.from_lang(),
  },
})
MiniSnippets.start_lsp_server()

require('mini.cmdline').setup()

local process_items_opts = {
  filtersort = 'fuzzy',
  kind_priority = {
    Class = 7,
    Color = 16,
    Constant = 99,
    Constructor = 4,
    Enum = 13,
    EnumMember = 20,
    Event = 23,
    Field = 5,
    File = 17,
    Folder = 19,
    Function = 3,
    Interface = 8,
    Keyword = 14,
    Method = 2,
    Module = 9,
    Operator = 24,
    Property = 10,
    Reference = 18,
    Snippet = 99,
    Struct = 22,
    Text = 1,
    TypeParameter = 25,
    Unit = 11,
    Value = 12,
    Variable = 6,
  },
}

require('mini.completion').setup({
  delay = {
    completion = 10,
    info = 50,
    signature = 50,
  },
  lsp_completion = {
    -- snippet_insert = vim.snippet.expand,
    source_func = 'omnifunc',
    auto_setup = false,
    process_items = function(items, base)
      local Function = vim.lsp.protocol.CompletionItemKind.Function
      for _, item in ipairs(items) do
        if item.kind == Function then
          local text = item.insertText or item.label or ''

          if not text:match('%(.-%)$') then
            item.insertTextFormat = 2
            item.insertText = text .. '($0)'
          end

          if
            item.textEdit
            and item.textEdit.newText
            and not item.textEdit.newText:match('%(.-%)$')
          then
            item.textEdit.newText = item.textEdit.newText .. '($0)'
          end
        end
      end

      return MiniCompletion.default_process_items(items, base, process_items_opts)
    end,
  },
})

---- place signature help window below cursor
local change_signature_window = function(args)
  if args.data.kind == 'signature' then
    local win_id = args.data.win_id
    local current_config = vim.api.nvim_win_get_config(win_id)

    local new_config = vim.tbl_extend('force', current_config, {
      relative = current_config.relative,
      anchor = 'NW',
      row = current_config.height - 1,
      col = current_config.col,
    })

    vim.api.nvim_win_set_config(win_id, new_config)
  end
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniCompletionWindowOpen',
  callback = change_signature_window,
  group = vim.api.nvim_create_augroup('wasted/signature_win', { clear = true }),
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniCompletionWindowChanged',
  callback = change_signature_window,
  group = vim.api.nvim_create_augroup('wasted/signature_win', { clear = true }),
})

vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })

-- vim: ts=2 sts=2 sw=2 et
