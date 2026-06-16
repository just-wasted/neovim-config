local win_config = function()
  local win_pad = 2
  local height = math.floor(0.768 * (vim.o.lines - win_pad))
  local width = math.floor(0.768 * vim.o.columns)
  return {
    anchor = 'NW',
    height = height,
    width = width,
    row = math.floor(0.5 * ((vim.o.lines - win_pad) - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

require('mini.pick').setup({
  window = {
    config = win_config,
  },
  options = {
    content_from_bottom = false,
    use_cache = true,
  },
})

-- mapping for deleting buffers in the picker
local wipeout_cur = function()
  vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
end
local buffer_mappings = { wipeout = { char = '<C-d>', func = wipeout_cur } }

require('tweak.pickers.picker_lsp_call_type')

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = desc })
end

map('<leader>pf', MiniPick.builtin.files, 'Files')
map('<leader>po', MiniExtra.pickers.oldfiles, 'Old Files')
map('<leader>pm', MiniExtra.pickers.manpages, 'Man Pages')
map('<leader>pg', MiniPick.builtin.grep_live, 'Grep')
map('<leader>pr', MiniPick.builtin.resume, 'Resume last')
map('<leader>ph', MiniPick.builtin.help, 'Help')
map('<leader>pl', MiniExtra.pickers.buf_lines, 'Buf Lines')
map('<leader>pt', MiniExtra.pickers.hipatterns, 'Todo Comments')
map('<leader>hp', MiniExtra.pickers.git_hunks, 'Pick Hunks')
map('<leader>gc', MiniExtra.pickers.git_commits, 'Pick Commits')
map('<leader>gb', MiniExtra.pickers.git_branches, 'Pick Branches')
map('<leader>gf', MiniExtra.pickers.git_files, 'Pick Git Files')
map('<leader>d', MiniExtra.pickers.diagnostic, 'Diagnostics')
map('<leader>pb', function()
  MiniPick.builtin.buffers( { include_current = false },{ mappings = buffer_mappings })
end, 'Buffers')
map('<leader>pp', function()
  MiniPick.registry.registry()
end, 'Pickers')
map('<leader>pn', function()
  vim.cmd('cd ~/.config/nvim')
  MiniPick.builtin.files()
  vim.cmd('cd -')
end, 'Man Pages')

---- pick pickers
MiniPick.registry.registry = function()
  local items = vim.tbl_keys(MiniPick.registry)
  table.sort(items)
  local source = { items = items, name = 'Registry', choose = function() end }
  local chosen_picker_name = MiniPick.start({ source = source })
  if chosen_picker_name == nil then
    return
  end
  return MiniPick.registry[chosen_picker_name]()
end

local picker_name = ''
---- function to auto pick first if only one item got returned
local autopick_first = function(results)
  local items = results.items
  -- print(vim.inspect(items)) --debug

  local function transform_item(i)
    local rel_path = vim.fn.fnamemodify(i.filename, ':.')
    local show_text = i.text:gsub('^%s*(.-)%s*$', '%1')
    return {
      text = string.format('%s %s %3d:%3d', show_text, rel_path, i.lnum, i.col),
      path = vim.fn.fnamemodify(i.filename, ':p'),
      lnum = i.lnum,
      col = i.col,
      text_len = show_text:len(),
      rel_path_len = rel_path:len(),
    }
  end
  if #items == 1 then
    MiniPick.default_choose(transform_item(items[1]))
  else
    local transformed_items = vim.tbl_map(transform_item, items)
    MiniPick.start({
      source = {
        name = picker_name,
        items = transformed_items,
        -- items = items,
        ---@diagnostic disable-next-line: redefined-local
        show = function(buf_id, items, query)
          MiniPick.default_show(buf_id, items, query, {
            show_icons = true,
          })
          -- print(vim.inspect(items)) --debug
        end,
      },
    })
  end
end

-- local lsp_picky = function(results)
--   local items = results.items
--   print(vim.inspect(items)) --debug
--
--   local function transform_item(i)
--     local rel_path = vim.fn.fnamemodify(i.filename, ':.')
--     local show_text = i.text:gsub('^%s*(.-)%s*$', '%1')
--     return {
--       text = string.format('%s %s %3d:%3d', show_text, rel_path, i.lnum, i.col),
--       path = vim.fn.fnamemodify(i.filename, ':p'),
--       lnum = i.lnum,
--       col = i.col,
--       text_len = show_text:len(),
--       rel_path_len = rel_path:len(),
--     }
--   end
--   if #items == 1 then
--     MiniPick.default_choose(transform_item(items[1]))
--   else
--     local transformed_items = vim.tbl_map(transform_item, items)
--     MiniPick.start({
--       source = {
--         name = picker_name,
--         items = transformed_items,
--         -- items = items,
--         show = function(buf_id, items, query)
--           MiniPick.default_show(buf_id, items, query, {
--             show_icons = true,
--           })
--           -- print(vim.inspect(items)) --debug
--         end,
--       },
--     })
--   end
-- end

MiniPick.registry.lsp_definitions = function()
  picker_name = 'Definitions'
  vim.lsp.buf.definition({ on_list = autopick_first })
end

MiniPick.registry.lsp_declarations = function()
  picker_name = 'Declarations'
  vim.lsp.buf.declaration({ on_list = autopick_first })
end

-- MiniPick.registry.workspace_symbol = function()
--   vim.lsp.buf.workspace_symbol('', {on_list = lsp_picky })
-- end
-- vim: ts=2 sts=2 sw=2 et
