local state = {
  lsp_progress = {},
  win_id = nil,
  buf_id = nil,
}


local function update_window()
  local lines = {}

  -- LSP-Messages (darüber)
  for _, p in pairs(state.lsp_progress) do
    if p then
      local msg = p.title or ""
      if p.message and p.message ~= "" then
        msg = msg .. (msg ~= "" and " " or "") .. p.message
      end
      if msg ~= "" then
        -- Bereinige Klammern und Leerzeichen
        msg = msg:gsub("%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(lines, msg)
      end
    end
  end

  -- Statuszeilen (ganz unten): PERCENT Client
  for _, p in pairs(state.lsp_progress) do
    if p then
      local percent_str = p.percentage and string.format("%d%%", p.percentage) or ""
      table.insert(lines, string.format("%-4s %s", percent_str, p.client))
    end
  end

  if #lines == 0 then
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
      vim.api.nvim_win_close(state.win_id, true)
      state.win_id = nil
    end
    return
  end

  -- Berechne maximale Breite
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end
  max_width = math.min(max_width, vim.o.columns - 10)

  -- Right-justify alle Zeilen
  for i, line in ipairs(lines) do
    lines[i] = string.format("%" .. max_width .. "s", line)
  end

  local has_statusline = vim.o.laststatus > 0
  local pad = vim.o.cmdheight + (has_statusline and 1 or 0)
  local height = math.min(#lines, vim.o.lines - pad - 1)

  if height < 1 then
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
      vim.api.nvim_win_close(state.win_id, true)
      state.win_id = nil
    end
    return
  end

  if not state.buf_id or not vim.api.nvim_buf_is_valid(state.buf_id) then
    state.buf_id = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf_id].filetype = 'mininotify'
    vim.notify("new buffer")
  end

  vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, true, lines)

  -- Highlighting für LSP-Progress-Zeilen
  local ns = vim.api.nvim_create_namespace('NotifyHighlight')
  vim.api.nvim_buf_clear_namespace(state.buf_id, ns, 0, -1)

  -- Highlighting für alle LSP-Zeilen
  -- end_row = #lines, bleibt so. kein -1
  vim.api.nvim_buf_set_extmark(state.buf_id, ns, 0, 0, {
    end_row = #lines,
    hl_group = 'Comment',
  })

  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    state.win_id = vim.api.nvim_open_win(state.buf_id, false, {
      relative = "editor",
      anchor = "SE",
      width = max_width,
      height = height,
      row = vim.o.lines - pad - height,
      col = vim.o.columns,
      border = "",
      style = "minimal",
    })
  else
    vim.api.nvim_win_set_config(state.win_id, {
      relative = "editor",
      width = max_width,
      height = height,
      row = vim.o.lines - pad - height,
      col = vim.o.columns,
    })
  end
end

vim.lsp.handlers['$/progress'] = function(err, result, ctx)
  if err or not result or not result.value then return end
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then return end

  local value = result.value
  local progress_id = client.name .. (result.token or "")

  if value.kind == 'begin' then
    state.lsp_progress[progress_id] = {
      client = client.name,
      title = value.title or "",
      message = "",
      percentage = 0,
    }
  elseif value.kind == 'report' then
    if state.lsp_progress[progress_id] then
      state.lsp_progress[progress_id].message = value.message or state.lsp_progress[progress_id].message
      state.lsp_progress[progress_id].percentage = value.percentage or state.lsp_progress[progress_id].percentage
    end
  elseif value.kind == 'end' then
    if state.lsp_progress[progress_id] then
      state.lsp_progress[progress_id].percentage = 100
    end
    vim.defer_fn(function()
      state.lsp_progress[progress_id] = nil
      update_window()
    end, 1000)
  end

  update_window()
end

require("mini.notify").setup({ lsp_progress = { enable = false } })

-- dont delete:
-- vim: ts=2 sts=2 sw=2 et
