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
      border = 'none',
    },
    documentation = {
      auto_show = true,
    },
    keyword = {
      -- range = 'full',
      range = 'prefix',
    },
  },
  cmdline = {
    keymap = { preset = 'super-tab' },
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
