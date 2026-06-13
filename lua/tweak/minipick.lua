
-- own kind struct for compatibity with MiniIcons.tweak_lsp_kind()
local SymbolKind = {
  'File',
  'Module',
  'Namespace',
  'Package',
  'Class',
  'Method',
  'Property',
  'Field',
  'Constructor',
  'Enum',
  'Interface',
  'Function',
  'Variable',
  'Constant',
  'String',
  'Number',
  'Boolean',
  'Array',
  'Object',
  'Key',
  'Null',
  'EnumMember',
  'Struct',
  'Event',
  'Operator',
  'TypeParameter',
}

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

---@param args table
---@param lspOperation string
--- function to handle type and call hierarchy requests
MiniPick.registry.lsp_call_type_hierarchy = function(args, lspOperation)
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

  local lsp_op = ''
  local prepare_statement = ''
  local retrieve_statement = ''
  if lspOperation == 'incomingCalls' or lspOperation == 'outgoingCalls' then
    prepare_statement = 'textDocument/prepareCallHierarchy'
    retrieve_statement = 'callHierarchy/' .. lspOperation
    lsp_op = 'call'
  else
    prepare_statement = 'textDocument/prepareTypeHierarchy'
    retrieve_statement = 'typeHierarchy/' .. lspOperation
    lsp_op = 'type'
  end

  local offs_encoding = client.offset_encoding
  local params = vim.lsp.util.make_position_params(0, offs_encoding)

  ---@cast prepare_statement '"textDocument/prepareCallHierarchy"' | '"textDocument/prepareTypeHierarchy"'
  vim.lsp.buf_request(args.bufnr, prepare_statement, params, function(err, hierarchy_item)
    if err then
      error('error: ' .. err.message .. '\nerr code: ' .. err.code)
    end
    if not hierarchy_item or #hierarchy_item == 0 then
      vim.notify('Not a valid symbol for ' .. lspOperation)
      return
    end

    vim.lsp.buf_request(
      args.bufnr,
      retrieve_statement,
      { item = hierarchy_item[1] },
      function(err2, lsp_items)
        if err2 then
          error('error: ' .. err2.message .. '\nerr code: ' .. err2.code)
        end

        if not lsp_items then
          error('No LSP Items')
        end

        local items = {}

        if lsp_op == 'call' then
          local buf_path = vim.api.nvim_buf_get_name(args.buf)
          for _, lsp_itm in ipairs(lsp_items) do
            local call_item = lsp_itm.from or lsp_itm.to
            for _, range in ipairs(lsp_itm.fromRanges) do
              local kind = SymbolKind[call_item.kind]
              local kind_icon, kind_hl = MiniIcons.get('lsp', kind)
              local kind_full = kind_icon .. ' ' .. kind
              local name = string.format('%-20s %s', call_item.name, kind_full)
              local line = range.start.line + 1
              local col = range.start.character + 1
              local target_path = ''

              if call_item == lsp_itm.from then
                target_path = vim.uri_to_fname(call_item.uri)
              else
                target_path = buf_path
              end

              local rel_path = vim.fn.fnamemodify(target_path, ':.')

              table.insert(items, {
                text = string.format('%-35s %s %d:%d', name, rel_path, line, col),
                path = target_path,
                lnum = line,
                col = col,
                kind_hl = kind_hl,
                kind_len = kind_full:len(),
                name_len = name:len(),
              })
            end
          end
        end

        if lsp_op == 'type' then
          for _, lsp_itm in ipairs(lsp_items) do
            vim.notify(lsp_op)

            local uri = vim.uri_to_fname(lsp_itm.uri)
            local kind = vim.lsp.protocol.SymbolKind[lsp_itm.kind]
            local icon, kind_hl = MiniIcons.get('lsp', kind)
            local name = string.format('%s %s %s', lsp_itm.name, icon, kind)
            local line = lsp_itm.range.start.line + 1
            local col = lsp_itm.range.start.character + 1
            local rel_path = vim.fn.fnamemodify(uri, ':.')

            table.insert(items, {
              text = string.format('%s\t%s %d:%d', name, rel_path, line, col),
              path = uri,
              lnum = line,
              col = col,
              kind_hl = kind_hl,
              name_len = name:len(),
            })
          end
        end

        MiniPick.start({
          source = {
            name = ui_name,
            items = items,
            -- items = lsp_items, -- debug
            ---@diagnostic disable-next-line: redefined-local
            show = function(buf_id, items, query)
              MiniPick.default_show(buf_id, items, query, {
                show_icons = true,
              })
              local namespace = vim.api.nvim_create_namespace('CustomPickerKind')
              for line_num = 0, #items - 1 do
                local start_col = 4 -- i don't know why but we need 4 here
                local end_col = start_col + items[line_num + 1].name_len + 1

                vim.api.nvim_buf_set_extmark(buf_id, namespace, line_num, start_col, {
                  end_row = line_num,
                  end_col = end_col,
                  hl_group = items[line_num + 1].kind_hl,
                  hl_mode = 'combine',
                  priority = 200
                })
              end
            end,
            match = MiniPick.default_match,
          },
        })
      end
    )
  end)
end

-- vim: ts=2 sts=2 sw=2 et
