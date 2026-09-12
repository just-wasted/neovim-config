-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
})
local diag_redraw_group = vim.api.nvim_create_augroup('diagnostic_redraw', { clear = true })
vim.api.nvim_create_autocmd('ModeChanged', {
  group = diag_redraw_group,
  callback = function()
    pcall(vim.diagnostic.show)
  end,
})

vim.cmd [[
  hi link DiagnosticVirtualTextError Comment
  hi link DiagnosticVirtualTextWarn  Comment
  hi link DiagnosticVirtualTextInfo  Comment
  hi link DiagnosticVirtualTextHint  Comment
]]
-- vim: ts=2 sts=2 sw=2 et
