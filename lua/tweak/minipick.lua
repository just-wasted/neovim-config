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
})

require('tweak.pickers.picker_lsp_call_type')

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

  local function transform_item(i)
    local rel_path = vim.fn.fnamemodify(i.filename, ':.')
    local show_text = i.text:gsub('^%s*(.-)%s*$', '%1')
    return {
      text = string.format('%s│%3d│%3d│ %s', rel_path, i.lnum, i.col, show_text),
      path = vim.fn.fnamemodify(i.filename, ':p'),
      lnum = i.lnum,
      col = i.col,
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
        show = function(buf_id, items, query)
          MiniPick.default_show(buf_id, items, query, {
            show_icons = true,
          })
        end,
      },
    })
  end
end

MiniPick.registry.lsp_definitions = function()
  picker_name = 'Definitions'
  vim.lsp.buf.definition({ on_list = autopick_first })
end

MiniPick.registry.lsp_declarations = function()
  picker_name = 'Declarations'
  vim.lsp.buf.declaration({ on_list = autopick_first })
end

-- vim: ts=2 sts=2 sw=2 et
