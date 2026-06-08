local state = {
  lsp_progress = {},
  win_id = nil,
  buf_id = nil,
}


local function update_window()
  local lines = {}

  -- LSP messages (above status lines)
  for _, progress in pairs(state.lsp_progress) do
    if progress then
      local msg = progress.title or ""
      if progress.message and progress.message ~= "" then
        msg = msg .. (msg ~= "" and " " or "") .. progress.message
      end
      if msg ~= "" then
        -- Clean up parentheses and whitespace
        msg = msg:gsub("%b()", ""):gsub("^%s+", ""):gsub("%s+$", "")
        table.insert(lines, msg)
      end
    end
  end

  -- Status lines (bottom): PERCENT Client
  for _, progress in pairs(state.lsp_progress) do
    if progress then
      local percent_str = progress.percentage and string.format("%d%%", progress.percentage) or ""
      table.insert(lines, string.format("%-4s %s", percent_str, progress.client))
    end
  end

  if #lines == 0 then
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
      vim.api.nvim_win_close(state.win_id, true)
      state.win_id = nil
    end
    return
  end

  -- Calculate maximum width for right-justification
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end
  max_width = math.min(max_width, vim.o.columns - 10)

  -- Right-justify all lines
  for i, line in ipairs(lines) do
    lines[i] = string.format("%" .. max_width .. "s", line)
  end

  local has_statusline = vim.o.laststatus > 0
  local vertical_pad = vim.o.cmdheight + (has_statusline and 1 or 0)
  local height = math.min(#lines, vim.o.lines - vertical_pad - 1)

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
  end

  vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, true, lines)

  -- Highlighting only for status lines (last lines)
  local ns = vim.api.nvim_create_namespace('NotifyHighlight')
  vim.api.nvim_buf_clear_namespace(state.buf_id, ns, 0, -1)

  local status_line_count = 0
  for _, progress in pairs(state.lsp_progress) do
    if progress then status_line_count = status_line_count + 1 end
  end

  if status_line_count > 0 and #lines >= status_line_count then
    local status_start_line = #lines - status_line_count
    vim.api.nvim_buf_set_extmark(state.buf_id, ns, status_start_line, 0, {
      end_row = #lines,
      hl_group = 'Comment',
      -- hl_eol = true,
    })
  end

  -- Create window config: reuse existing window if valid, otherwise create new one
  local win_config = {
    relative = "editor",
    anchor = "SE",
    width = max_width,
    height = height,
    row = vim.o.lines - vertical_pad - 1,
    col = vim.o.columns - vertical_pad,
    border = "",
    style = "minimal",
  }

  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    state.win_id = vim.api.nvim_open_win(state.buf_id, false, win_config)
  else
    vim.api.nvim_win_set_config(state.win_id, win_config)
  end
end

-- Handle LSP progress notifications ($/progress)
vim.lsp.handlers['$/progress'] = function(err, result, ctx)
  if err or not result or not result.value then return end
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then return end

  local progress_value = result.value
  local progress_id = client.name .. (result.token or "")

  if progress_value.kind == 'begin' then
    state.lsp_progress[progress_id] = {
      client = client.name,
      title = progress_value.title or "",
      message = "",
      percentage = 0,
    }
  elseif progress_value.kind == 'report' then
    if state.lsp_progress[progress_id] then
      state.lsp_progress[progress_id].message = progress_value.message or state.lsp_progress[progress_id].message
      state.lsp_progress[progress_id].percentage = progress_value.percentage or state.lsp_progress[progress_id].percentage
    end
  elseif progress_value.kind == 'end' then
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
