vim.pack.add({
  'https://github.com/antonk52/filepaths_ls.nvim',
})
vim.lsp.enable('filepaths_ls')

MiniIcons.tweak_lsp_kind()

vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-e><CR>' or require('mini.pairs').cr()
end, { expr = true })

---- super tab for auto completion
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-Y>' or '<TAB>'
end, { expr = true })

---- snippets & completion ----
local gen_loader = require('mini.snippets').gen_loader
local config_path = vim.fn.stdpath('config')
require('mini.snippets').setup({
  mappings = { expand = '' },
  snippets = {
    gen_loader.from_file(config_path .. '/snippets/global.json'),
    gen_loader.from_lang(),
  },
})
MiniSnippets.start_lsp_server()

require('mini.cmdline').setup()

---- get default values with
---- :lua print(vim.inspect(vim.lsp.protocol.CompletionItemKind))
local process_items_opts = {
  filtersort = 'fuzzy',
  kind_priority = {
    Text = 1,
    Method = 2,
    Constructor = 3,
    Constant = 4,
    Property = 5,
    Interface = 6,
    Module = 7,
    Snippet = 8,
    Class = 9,
    Unit = 10,
    Value = 11,
    EnumMember = 12,
    Enum = 13,
    Color = 14,
    File = 15,
    Folder = 16,
    TypeParameter = 17,
    Reference = 18,
    Field = 19,
    Struct = 20,
    Event = 21,
    Keyword = 22,
    Operator = 23,
    Variable = 24,
    Function = 25,
  },
}

require('mini.completion').setup({
  delay = {
    completion = 10,
    info = 50,
    signature = 50,
  },
  window = {
        signature = { height = 3, width = 90, border = 'single' },
      },

  lsp_completion = {
    -- snippet_insert = vim.snippet.expand,
    source_func = 'omnifunc',
    auto_setup = false,
    process_items = function(items, base)
      local Function = vim.lsp.protocol.CompletionItemKind.Function
      local Method = vim.lsp.protocol.CompletionItemKind.Method
      for _, item in ipairs(items) do
        if item.kind == Function or item.kind == Method then
          local text = item.insertText or item.label or ''

          if not text:match('%(.-%).-$') then
            item.insertTextFormat = 2
            item.insertText = text .. '($0)'
          end

          if
            item.textEdit
            and item.textEdit.newText
            and not item.textEdit.newText:match('%(.-%).-$')
          then
            item.textEdit.newText = item.textEdit.newText .. '($0)'
          end
        end
      end

      return MiniCompletion.default_process_items(items, base, process_items_opts)
    end,
  },
})

vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })


---- place signature help window below cursor
-- local change_signature_window = function(args)
--   if args.data.kind == 'signature' then
--     local win_id = args.data.win_id
--     local current_config = vim.api.nvim_win_get_config(win_id)
--
--     local new_config = vim.tbl_extend('force', current_config, {
--       relative = current_config.relative,
--       anchor = 'NW',
--       row = current_config.height,
--       col = current_config.col,
--     })
--
--     vim.api.nvim_win_set_config(win_id, new_config)
--   end
-- end
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MiniCompletionWindowOpen',
--   callback = change_signature_window,
--   group = vim.api.nvim_create_augroup('wasted/signature_win', { clear = true }),
-- })


-- vim: ts=2 sts=2 sw=2 et
