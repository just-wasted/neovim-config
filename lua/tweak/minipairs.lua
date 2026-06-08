require('mini.pairs').setup({
  -- mappings = {
  --   ['<'] = { action = 'open', pair = '<>', neigh_pattern = '^[^\\]', register = { cr = true }},
  --   ['>'] = { action = 'close', pair = '<>', neigh_pattern = '^[^\\]' , register = { cr = true }},
  -- },
})

---- https://github.com/nvim-mini/mini.nvim/discussions/2030#discussioncomment-14533323
---Counts unbalanced open or close characters.
---@param line string
---@param op string # open character
---@param cl string # close character
---@return integer,integer # count of open and close characters
local count_unlanced = function(line, op, cl)
  local no, nc = 0, 0
  for i = 1, #line do
    local ch = line:sub(i, i)
    if ch == op then
      -- Found an unbalanced open character
      no = no + 1
    elseif ch ~= cl then
    -- Ignore non-pairing characters
    elseif no > 0 then
      -- Found a balanced pair
      no = no - 1
    else
      -- Found an unbalanced close character
      nc = nc + 1
    end
  end
  return no, nc
end

local smart_open = function(open, pair, neigh_pattern)
  if vim.fn.getcmdline() ~= '' then
    return open(pair, neigh_pattern)
  end

  local op, cl = pair:sub(1, 1), pair:sub(2, 2)
  local line, cur = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1], cur[2]

  -- Handle triple quotes
  if op == cl and line:sub(col - 1, col) == op:rep(2) then
    return op .. '\n' .. op:rep(3) .. vim.api.nvim_replace_termcodes('<Up>', true, true, true)
  end

  -- Disable pairing in string literals
  local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, row - 1, math.max(col - 1, 0))
  if ok and #captures == 1 and captures[1].capture == 'string' then
    return op
  end

  -- Emit only an opening if unbalanced
  if line:len() < 500 then
    if op ~= cl then -- pairs
      local left, right = line:sub(1, col), line:sub(col + 1)
      local no, _ = count_unlanced(left, op, cl)
      local _, nc = count_unlanced(right, op, cl)
      if no < nc then
        return op
      end
    else -- quotes
      local _, n = line:gsub('%' .. op, '')
      if n % 2 ~= 0 then
        return op
      end
    end
  end

  return open(pair, neigh_pattern)
end

local orig_open = MiniPairs.open
---@diagnostic disable-next-line: duplicate-set-field
MiniPairs.open = function(...)
  return smart_open(orig_open, ...)
end

-- vim: ts=2 sts=2 sw=2 et
