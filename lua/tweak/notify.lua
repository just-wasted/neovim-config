local state = {
  lsp_progress = {},
  win_id = nil,
  buf_id = nil,
  spinner_chars = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧" },
  spinner_timer = nil,
}

-- Persistent namespace for highlights
local ns = vim.api.nvim_create_namespace('NotifyHighlight')

local function update_window()
  local lines = {}
  local max_line_length = 40

  -- Collect LSP messages
  local message_line_indices = {}
  local status_line_indices = {}
  local active_clients = {}
  
  for _, progress in pairs(state.lsp_progress) do
    if progress then
      -- Message (if exists)
      local msg = progress.title or ''
      if progress.message and progress.message ~= '' then
        msg = msg .. (msg ~= '' and ' ' or '') .. progress.message
      end
      if msg ~= '' then
        msg = msg:gsub('%b()', ''):gsub('^%s+', ''):gsub('%s+$', '')
        -- Truncate to max_line_length chars with ...
        if vim.fn.strdisplaywidth(msg) > max_line_length then
          msg = vim.fn.strcharpart(msg, 0, max_line_length - 3) .. '...'
        end
        table.insert(lines, msg)
        table.insert(message_line_indices, #lines - 1)
      end
      
      -- Track active clients for single status line
      active_clients[progress.client] = progress
    end
  end

  -- Single status line combining all active clients
  if next(active_clients) then
    local client_names = {}
    for client, progress in pairs(active_clients) do
      local spinner = state.spinner_chars[(progress.spinner_index or 0) % #state.spinner_chars + 1]
      table.insert(client_names, spinner .. ' ' .. client)
    end
    local status_line = table.concat(client_names, ' | ')
    -- Truncate to max_line_length chars with ...
    if vim.fn.strdisplaywidth(status_line) > max_line_length then
      status_line = vim.fn.strcharpart(status_line, 0, max_line_length - 3) .. '...'
    end
    table.insert(lines, status_line)
    table.insert(status_line_indices, #lines - 1)
  end

  if #lines == 0 then
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
      vim.api.nvim_win_close(state.win_id, true)
      state.win_id = nil
    end
    return
  end

  -- Calculate maximum width for right-justification
  -- All lines are already truncated to 80 chars
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end
  max_width = math.min(max_width, vim.o.columns - 10)

  -- Right-justify all lines (max 80 chars each)
  for i, line in ipairs(lines) do
    lines[i] = string.rep(" ", max_width - vim.fn.strdisplaywidth(line)) .. line
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
  end

  vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, true, lines)

  -- Apply highlighting: messages as Comment, status lines as WarningMsg
  vim.api.nvim_buf_clear_namespace(state.buf_id, ns, 0, -1)

  for _, buf_line in ipairs(message_line_indices) do
    vim.api.nvim_buf_set_extmark(state.buf_id, ns, buf_line, 0, {
      end_row = buf_line + 1,
      hl_group = 'Comment',
      hl_eol = true,
    })
  end

  for _, buf_line in ipairs(status_line_indices) do
    vim.api.nvim_buf_set_extmark(state.buf_id, ns, buf_line, 0, {
      end_row = buf_line + 1,
      hl_group = 'WarningMsg',
      hl_eol = true,
    })
  end

  -- Create window config: reuse existing window if valid, otherwise create new one
  local win_config = {
    relative = 'editor',
    anchor = 'SE',
    width = max_width,
    height = height,
    row = vim.o.lines - vertical_pad - 1,
    col = vim.o.columns - vertical_pad,
    border = '',
    style = 'minimal',
  }

  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    state.win_id = vim.api.nvim_open_win(state.buf_id, false, win_config)
  else
    vim.api.nvim_win_set_config(state.win_id, win_config)
  end

  -- Match editor background
  vim.api.nvim_set_option_value('winhl', 'Normal:Normal', { win = state.win_id })

  -- Start spinner animation timer (only once)
  if not state.spinner_timer then
    state.spinner_timer = vim.loop.new_timer()
    state.spinner_timer:start(100, 100, vim.schedule_wrap(function()
      for _, progress in pairs(state.lsp_progress) do
        if progress then
          progress.spinner_index = (progress.spinner_index + 1) % #state.spinner_chars
        end
      end
      update_window()
    end))
  end

end

-- Handle LSP progress notifications ($/progress)
vim.lsp.handlers['$/progress'] = function(err, result, ctx)
  if err or not result or not result.value then
    return
  end
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then
    return
  end

  local progress_value = result.value
  local progress_id = client.name .. (result.token or '')

  if progress_value.kind == 'begin' then
    state.lsp_progress[progress_id] = {
      client = client.name,
      title = progress_value.title or '',
      message = '',
      percentage = 0,
      spinner_index = 0,
    }
  elseif progress_value.kind == 'report' then
    if state.lsp_progress[progress_id] then
      state.lsp_progress[progress_id].message = progress_value.message
        or state.lsp_progress[progress_id].message
      state.lsp_progress[progress_id].percentage = progress_value.percentage
        or state.lsp_progress[progress_id].percentage
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

require('mini.notify').setup({
  lsp_progress = {
    enable = false,
  },
  window = {
    config = {},
    max_width_share = 0.382,
    winblend = 0,
  },
})
local map = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc, silent = true }) end
map('<leader>nh', function() MiniNotify.show_history() end, 'Notify history')

-- vim: ts=2 sts=2 sw=2 et
