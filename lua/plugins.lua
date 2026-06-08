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
  --
})

require('colors/tokyonight')
require('mini.icons').setup({
  lsp = {
    snippet = { glyph = '󰁌', hl = 'MiniIconsGreen' },
  },
})
MiniIcons.mock_nvim_web_devicons()

---- status line ----
require('mini.statusline').setup({
  use_icons = vim.g.have_nerd_font,
})
---@diagnostic disable-next-line: duplicate-set-field
MiniStatusline.section_location = function()
  return '%2l:%-2v %2L'
end


-- which-key ----
require('which-key').setup({
  preset = 'helix',
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
  },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>r', group = '[L]sp' },
    { '<leader>s', group = '[S]earch' },
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
require('mini.indentscope').setup({ symbol = '│' })

require('tweak/hipatterns')
require('mason').setup()

--- misc
require('mini.extra').setup()
require('mini.ai').setup({
  custom_textobjects = {
    B = MiniExtra.gen_ai_spec.buffer(),
  },
})
require('mini.surround').setup()
require('tweak/minipairs')
-- require('tweak/minicmp')
require('tweak.blinkcmp')
require('mini.cursorword').setup()
require('lsp')
require('tweak/minifiles')


---- user commands
vim.api.nvim_create_user_command('PackCheckUpdates', function()
  vim.pack.update(nil, { offline = true })
end, {})

vim.api.nvim_create_user_command('PackUpdate', function()
  vim.pack.update()
end, {})

-- vim: ts=2 sts=2 sw=2 et
