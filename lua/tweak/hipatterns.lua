vim.api.nvim_set_hl(0, 'MiniHipatternsFixme', { fg = '#C52B53', bold = true, italic = true })
vim.api.nvim_set_hl(0, 'MiniHipatternsHack', { fg = '#FFC777', bold = true, italic = true })
vim.api.nvim_set_hl(0, 'MiniHipatternsTodo', { fg = '#0DB9D7', bold = true, italic = true })
vim.api.nvim_set_hl(0, 'MiniHipatternsNote', { fg = '#4FD6BE', bold = true, italic = true })

local hi_todo = function(words, hl_name)
  local patterns = vim
    .iter(words)
    :map(function(word)
      return { '%f[%w]' .. word .. '%f[%W]', word .. '[: ]' }
    end)
    :flatten()
    :totable()

  return {
    pattern = patterns,
    group = function(buf, _, data)
      if not buf or not vim.api.nvim_buf_is_valid(buf) then return nil end

      if not vim.treesitter.highlighter.active[buf] then return nil end

      local row = data.line - 1
      local col = data.from_col - 1
      local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
      for _, capture in ipairs(captures or {}) do
        if capture.capture:match("comment") then
          return hl_name
        end
      end
      return nil
    end
  }
end

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    fixme = hi_todo({ 'FIXME', 'FIX', 'BUG', 'ERROR' }, 'MiniHipatternsFixme'),
    hack = hi_todo({ 'HACK', 'WARN', 'WARNING' }, 'MiniHipatternsHack'),
    todo = hi_todo({ 'TODO' }, 'MiniHipatternsTodo'),
    note = hi_todo({ 'NOTE', 'INFO', 'HINT' }, 'MiniHipatternsNote'),
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
  delay = {
    text_change = 100,
    scroll = 50,
  },
})

-- vim: ts=2 sts=2 sw=2 et
