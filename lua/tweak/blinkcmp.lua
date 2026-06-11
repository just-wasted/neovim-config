vim.pack.add({ 'https://github.com/saghen/blink.lib', 'https://github.com/saghen/blink.cmp' })

local cmp = require('blink.cmp')

cmp.build():pwait()

cmp.setup({
  keymap = {
    preset = 'super-tab',
  },

  signature = {
    enabled = true,
  },
  completion = {
    menu = {
      max_height = 7,
      border = 'none',
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind_icon', gap = 1, 'kind' },
        },
      },
    },
    documentation = {
      auto_show = true,
    },
    keyword = {
      range = 'full',
      -- range = 'prefix',
    },
  },
  cmdline = {
    keymap = { preset = 'none' },
    completion = {
      menu = {
        auto_show = true,
        border = 'none',
      },
    },
  },
  sources = {
    default = {
      'lsp',
      'path',
      'snippets',
      'buffer',
    },
  },
  fuzzy = {
    implementation = 'prefer_rust_with_warning',
  },
})

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(nil, true),
})

-- vim: ts=2 sts=2 sw=2 et
