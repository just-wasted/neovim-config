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
    max_lines = 2,
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


vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
})

-- vim.g.no_plugin_maps = true

require('nvim-treesitter-textobjects').setup({
select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V', -- linewise
    },
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
})

vim.keymap.set({ "x", "o" }, "am", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end, { desc = 'outer fuction' })
vim.keymap.set({ "x", "o" }, "im", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end, { desc = 'inner fuction' })
vim.keymap.set({ "x", "o" }, "ac", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end, { desc = 'outer class' })
vim.keymap.set({ "x", "o" }, "ic", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end, { desc = 'inner class' })


vim.keymap.set({ "n", "x", "o" }, "]f", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end, { desc = 'next function' })
vim.keymap.set({ "n", "x", "o" }, "[f", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end, { desc = 'prev function' })
vim.keymap.set({ "n", "x", "o" }, "]a", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
end, { desc = 'next parameter' })
vim.keymap.set({ "n", "x", "o" }, "[a", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
end, { desc = 'prev parameter' })

local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

-- vim: ts=2 sts=2 sw=2 et
