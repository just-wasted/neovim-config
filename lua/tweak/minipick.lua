local win_config = function()
  local height = math.floor(0.6 * vim.o.lines)
  local width = math.floor(0.5 * vim.o.columns)
  return {
    anchor = 'NW',
    height = height,
    width = width,
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

require('mini.pick').setup({
  window = {
    config = win_config,
  },
})

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
    local show_text = i.text:gsub("^%s*(.-)%s*$", "%1")
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

---@param args table
---@param lspOperation string
--- function to handle type and call hierarchy requests
MiniPick.registry.lsp_call_type_hyrarchy = function(args, lspOperation)
  local client = vim.lsp.get_client_by_id(args.data.client_id)

  if not client then
    vim.notify('No valid LSP client')
    return
  end

  if type(lspOperation) ~= type('') then
    error('Parameter lspOperation is not of type string, found: ' .. type(lspOperation))
  end

  local ui_name = ({
    incomingCalls = 'Incoming Calls',
    outgoingCalls = 'Outgoing Calls',
    supertypes = 'Supertypes (Parent)',
    subtypes = 'Subtypes (Child)',
  })[lspOperation] or error('Parameter lspOperation has unknown value: ' .. lspOperation)

  local prepare_statement = ''
  local retrieve_statement = ''
  if lspOperation == 'incomingCalls' or lspOperation == 'outgoingCalls' then
    prepare_statement = 'textDocument/prepareCallHierarchy'
    retrieve_statement = 'callHierarchy/' .. lspOperation
  else
    prepare_statement = 'textDocument/prepareTypeHierarchy'
    retrieve_statement = 'typeHierarchy/' .. lspOperation
  end

  local offs_encoding = client.offset_encoding
  local params = vim.lsp.util.make_position_params(0, offs_encoding)

  ---@cast prepare_statement '"textDocument/prepareCallHierarchy"' | '"textDocument/prepareTypeHierarchy"'
  vim.lsp.buf_request(args.bufnr, prepare_statement, params, function(err, hierarchy_item)
    if err then
      vim.notify('err message: ' .. err.message .. '\nerr code: ' .. err.code)
      return
    end
    if not hierarchy_item or #hierarchy_item == 0 then
      vim.notify('Not a valid symbol for ' .. lspOperation)
      return
    end

    vim.lsp.buf_request(
      args.bufnr,
      retrieve_statement,
      { item = hierarchy_item[1] },
      function(err2, calls)
        if err2 then
          vim.notify('err message: ' .. err2.message .. '\nerr code: ' .. err2.code)
          return
        end

        if not calls then
          vim.notify('not calls')
          return
        end

        local items = {}
        for _, call in ipairs(calls) do
          local call_item = call.from or call.to
          if not call_item then
            break
          end

          for _, range in ipairs(call.fromRanges) do
            local uri = vim.uri_to_fname(call_item.uri)
            local line = range.start.line + 1
            local col = range.start.character + 1
            local rel_path = vim.fn.fnamemodify(uri, ':.')
            table.insert(items, {
              text = string.format('%s│%3d│%3d│', rel_path, line, col ),
              path = uri,
              lnum = line,
              col = col,
            })
          end
        end

        MiniPick.start({
          source = {
            name = ui_name,
            items = items,
            show = function(buf_id, items, query)
              MiniPick.default_show(buf_id, items, query, {
                show_icons = true,
              })
            end,
            match = MiniPick.default_match,
          },
        })
      end
    )
  end)
end

-- vim: ts=2 sts=2 sw=2 et
