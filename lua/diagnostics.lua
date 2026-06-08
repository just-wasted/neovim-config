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
  -- virtual_lines = {
  --   current_line = true,
  --   format = function(diagnostic)
  --     local diagnostic_message = {
  --       [vim.diagnostic.severity.ERROR] = diagnostic.message,
  --       [vim.diagnostic.severity.WARN] = diagnostic.message,
  --       [vim.diagnostic.severity.INFO] = diagnostic.message,
  --       [vim.diagnostic.severity.HINT] = diagnostic.message,
  --     }
  --     return diagnostic_message[diagnostic.severity]
  --   end,
  -- },
})

-- local og_virt_text
-- local og_virt_line
-- vim.api.nvim_create_autocmd({ 'CursorMoved', 'DiagnosticChanged' }, {
--   group = vim.api.nvim_create_augroup('diagnostic_only_virtlines', {}),
--   callback = function()
--     if og_virt_line == nil then
--       og_virt_line = vim.diagnostic.config().virtual_lines
--     end
--
--     -- ignore if virtual_lines.current_line is disabled
--     if not (og_virt_line and og_virt_line.current_line) then
--       if og_virt_text then
--         vim.diagnostic.config({ virtual_text = og_virt_text })
--         og_virt_text = nil
--       end
--       return
--     end
--
--     if og_virt_text == nil then
--       og_virt_text = vim.diagnostic.config().virtual_text
--     end
--
--     local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
--
--     if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
--       vim.diagnostic.config({ virtual_text = og_virt_text })
--     else
--       vim.diagnostic.config({ virtual_text = false })
--     end
--   end,
-- })
local diag_redraw_group = vim.api.nvim_create_augroup('diagnostic_redraw', { clear = true })
vim.api.nvim_create_autocmd('ModeChanged', {
  group = diag_redraw_group,
  callback = function()
    pcall(vim.diagnostic.show)
  end,
})

-- vim: ts=2 sts=2 sw=2 et
