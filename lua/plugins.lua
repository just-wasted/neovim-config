vim.cmd('packadd nvim.undotree')
vim.cmd('packadd nvim.difftool')

vim.pack.add({
  --
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/sainnhe/gruvbox-material' },
  { src = 'https://github.com/rebelot/kanagawa.nvim' },

  { src = 'https://github.com/nvim-mini/mini.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },

  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/ibhagwan/fzf-lua' },
  --
})

require('colors/tokyonight')
require('mini.icons').setup({
  lsp = {
    snippet = { glyph = '󰁌', hl = 'MiniIconsGreen' },
    method = { hl = 'MiniIconsOrange' },
    constructor = { hl = 'MiniIconsBlue' }
  },
})
MiniIcons.mock_nvim_web_devicons()
-- MiniIcons.tweak_lsp_kind('replace')

---- status line ----
require('mini.statusline').setup({
  use_icons = vim.g.have_nerd_font,
})
---@diagnostic disable-next-line: duplicate-set-field
MiniStatusline.section_location = function()
  return '%2l:%-2v %2L'
end

local map = require('mini.map')
map.setup({
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.diagnostic({
      error = 'DiagnosticFloatingError',
      warn = 'DiagnosticFloatingWarn',
    }),
    map.gen_integration.diff(),
  },
  symbols = {
    scroll_line = '┃',
    scroll_view = '│',
  },
  window = {
    focusable = false,
    side = 'right',
    show_integration_count = false,
    width = 2,
    winblend = 25,
    zindex = 10,
  },
})
vim.keymap.set('n', '<leader>mc', map.close, { desc = '[M]ap [C]lose' })
vim.keymap.set('n', '<leader>mf', map.toggle_focus, { desc = '[M]ap [F]ocus' })
vim.keymap.set('n', '<leader>mm', map.toggle, { desc = '[M]ap Toggle' })
vim.keymap.set('n', '<leader>mr', map.refresh, { desc = '[M]ap [R]efresh' })
vim.api.nvim_set_hl(0, 'MiniMapNormal', { fg = '#7B83A1', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'MiniMapSymbolView', { fg = '#7B83A1', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'MiniMapSymbolLine', { fg = '#7B83A1', bg = 'NONE' })

-- which-key ----
require('which-key').setup({
  preset = 'helix',
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
  },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>r', group = '[L]sp' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = 'Toggle' },
    { '<leader>g', group = '[G]it Pickers', mode = { 'n', 'v' } },
    { '<leader>h', group = 'Git [H]unks' },
    { '<leader>m', group = '[M]ap' },
    { '<leader>q', group = '[Q]uickfix' },
  },
})
require('treesitter')
require('tweak/notify')

require('mason').setup()
--- misc
require('mini.diff').setup({
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '-' },
    priority = 0,
  },
  mappings = {
    apply = '<leader>ha',
    reset = '<leader>hr',
    textobject = 'gh',
    goto_first = '<leader>hf',
    goto_prev = '<leader>hp',
    goto_next = '<leader>hn',
    goto_last = '<leader>hl',
  },
})
vim.keymap.set('n', '<leader>ho', MiniDiff.toggle_overlay, { desc = 'Toggle diff [O]verlay' })
vim.api.nvim_set_hl(0, 'MiniDiffSignDelete', { fg = '#B26A75', bg = 'NONE' })

require('mini.extra').setup()
require('mini.ai').setup({
  custom_textobjects = {
    X = MiniExtra.gen_ai_spec.buffer(),
  },
})
require('mini.indentscope').setup({
  symbol = '▏',
})
require('tweak/hipatterns')
require('lsp')
require('mini.surround').setup()
require('tweak/minipick')
require('tweak/minipairs')
require('tweak.blinkcmp')
-- require('tweak/minicmp')
require('mini.cursorword').setup()
require('tweak/minifiles')

require('mini.jump2d').setup({
  labels = 'asdfjklghiowevntbcmpqruxyz',
  view = {
    dim = true,
    n_steps_ahead = 1,
  },
})
vim.keymap.set(
  { 'o', 'x', 'n' },
  '<Cr>',
  '<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>',
  { desc = 'Jump' }
)

---- user commands
vim.api.nvim_create_user_command('PackCheckUpdates', function()
  vim.pack.update(nil, { offline = true })
end, {})

vim.api.nvim_create_user_command('PackUpdate', function()
  vim.pack.update()
end, {})

-- vim: ts=2 sts=2 sw=2 et
