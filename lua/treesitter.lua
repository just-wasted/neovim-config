---- https://github.com/nvim-lua/kickstart.nvim/blob/cfdc17be3ae1607d4427332de0b29d556f9dda13/init.lua#L889

vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

-- Ensure basic parsers are installed
local parsers = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
}
require('nvim-treesitter').install(parsers)

local function ts_context()

  vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  })

  require('treesitter-context').setup({
    enable = false,
    max_lines = 4,
    multiline_threshold = 2,
    mode = 'topline',
  })
  vim.keymap.set('n', '[c', function()
    require('treesitter-context').go_to_context(vim.v.count1)
  end, { desc = 'Go to Function [C]ontext', silent = true })

  vim.keymap.set('n', '<leader>tc', function()
    require('treesitter-context').toggle()
  end, { desc = 'Toggle Function [C]ontext', silent = true })

  -- vim.cmd.highlight('TreesitterContextBottom gui=underline guisp=Grey')

end

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- Check if a parser exists and load it
  if not vim.treesitter.language.add(language) then
    return
  end
  -- Enable syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)
  ts_context()
  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.wo.foldmethod = 'expr'
  -- Check if treesitter indentation is available for this language, and if so enable it
  -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

  -- Enable treesitter based indentation
  if has_indent_query then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local available_parsers = require('nvim-treesitter').get_available()

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    local installed_parsers = require('nvim-treesitter').get_installed('parsers')

    if vim.tbl_contains(installed_parsers, language) then
      -- Enable the parser if it is already installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- If a parser is available in `nvim-treesitter`, auto-install it and
      -- enable it after the installation is done
      require('nvim-treesitter').install(language):await(function()
        treesitter_try_attach(buf, language)
      end)
    else
      -- Try to enable treesitter features in case the parser exists but is
      -- not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
