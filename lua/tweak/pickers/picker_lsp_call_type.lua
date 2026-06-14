local M = {}

-- own kind array incase MiniIcons.tweak_lsp_kind() is used
local symbolKind = {
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

local make_call_hierarchy_items = function (lsp_items, items, args)
  local buf_path = vim.api.nvim_buf_get_name(args.buf)
  for _, lsp_itm in ipairs(lsp_items) do
    local call_item = lsp_itm.from or lsp_itm.to
    for _, range in ipairs(lsp_itm.fromRanges) do
      local kind = symbolKind[call_item.kind]
      local kind_icon, kind_hl = MiniIcons.get('lsp', kind)
      local kind_full = string.format('%-16s ', kind_icon .. ' ' .. kind)
      local name = string.format('%-20s ', call_item.name)
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
        text = string.format('%s%s%s %d:%d', name, kind_full, rel_path, line, col),
        path = target_path,
        lnum = line,
        col = col,
        kind_hl = kind_hl or 'MiniPickMatchRanges',
        kind_len = kind_full:len(),
        name_len = name:len(),
        rel_path_len = rel_path:len(),
      })
    end
  end
end

local make_type_hierarchy_items = function (lsp_items, items)
  for _, lsp_itm in ipairs(lsp_items) do
    local target_path = vim.uri_to_fname(lsp_itm.uri)
    local kind = symbolKind[lsp_itm.kind]
    local kind_icon, kind_hl = MiniIcons.get('lsp', kind)
    local kind_full = string.format('%-16s ', kind_icon .. ' ' .. kind)
    local name = string.format('%-20s ', lsp_itm.name)
    local line = lsp_itm.range.start.line + 1
    local col = lsp_itm.range.start.character + 1
    local rel_path = vim.fn.fnamemodify(target_path, ':.')

    table.insert(items, {
      text = string.format('%s%s%s %d:%d', name, kind_full, rel_path, line, col),
      path = target_path,
      lnum = line,
      col = col,
      kind_hl = kind_hl or 'MiniPickMatchRanges',
      kind_len = kind_full:len(),
      name_len = name:len(),
      rel_path_len = rel_path:len(),
    })
  end
end

local namespace = vim.api.nvim_create_namespace('CustomPickerKind')

local apply_extmarks = function (buf_id, items)
  vim.api.nvim_buf_clear_namespace(buf_id, namespace, 0, -1)
  local offs = 4 -- offset for the columns
  for line_num = 0, #items - 1 do
    local item = items[line_num + 1]
    local kind_start_col = offs + item.name_len
    local kind_end_col = kind_start_col + item.kind_len + 1

    vim.api.nvim_buf_set_extmark(buf_id, namespace, line_num, kind_start_col, {
      end_row = line_num,
      end_col = kind_end_col,
      hl_group = items[line_num + 1].kind_hl,
      hl_mode = 'combine',
      priority = 200,
    })

    local path_start_col = kind_end_col - 1
    local path_end_col = path_start_col + item.rel_path_len + 1
    vim.api.nvim_buf_set_extmark(buf_id, namespace, line_num, path_start_col, {
      end_row = line_num,
      end_col = path_end_col,
      hl_group = 'comment',
      hl_mode = 'combine',
      priority = 200,
    })
  end
end

local error_lev = vim.log.levels.ERROR

---@param args table
---@param lspOperation string
MiniPick.registry.lsp_call_type_hierarchy = function(args, lspOperation)
  local client = vim.lsp.get_client_by_id(args.data.client_id)

  if not client then
    vim.notify('No LSP client is attached to the current buffer', error_lev)
    return
  end

  if type(lspOperation) ~= 'string' then
    vim.notify(
      'Parameter lspOperation is not of type string, found: ' .. type(lspOperation),
      error_lev
    )
    return
  end

  -- lookup table for strings used for LSP requests, picker_name and logic
  local str_lut = ({
    incomingCalls = {
      'Incoming Calls to ',
      'textDocument/prepareCallHierarchy',
      'callHierarchy/' .. lspOperation,
      'call',
    },
    outgoingCalls = {
      'Outgoing Calls from ',
      'textDocument/prepareCallHierarchy',
      'callHierarchy/' .. lspOperation,
      'call',
    },
    supertypes = {
      'Supertypes (Parent) from ',
      'textDocument/prepareTypeHierarchy',
      'typeHierarchy/' .. lspOperation,
      'type',
    },
    subtypes = {
      'Subtypes (Child) from ',
      'textDocument/prepareTypeHierarchy',
      'typeHierarchy/' .. lspOperation,
      'type',
    },
  })[lspOperation] or error('Parameter lspOperation has unknown value: ' .. lspOperation)

  local picker_name, prepare_statement, retrieve_statement, lsp_op =
    str_lut[1], str_lut[2], str_lut[3], str_lut[4]

  local cursor_symbol = "'" .. vim.fn.expand('<cword>') .. "'"
  picker_name = picker_name .. cursor_symbol

  local offs_encoding = client.offset_encoding
  local params = vim.lsp.util.make_position_params(0, offs_encoding)

  ---@cast prepare_statement '"textDocument/prepareCallHierarchy"' | '"textDocument/prepareTypeHierarchy"'
  vim.lsp.buf_request(args.buf, prepare_statement, params, function(err, hierarchy_item)
    if err then
      vim.notify('error: ' .. err.message .. '\nerr code: ' .. err.code, error_lev)
      return
    end

    if not hierarchy_item or #hierarchy_item == 0 then
      vim.notify('Not a valid symbol for ' .. lspOperation)
      return
    end

    vim.lsp.buf_request(
      args.buf,
      retrieve_statement,
      { item = hierarchy_item[1] },
      function(err2, lsp_items)
        if err2 then
          vim.notify('error: ' .. err2.message .. '\nerr code: ' .. err2.code, error_lev)
          return
        end

        if not lsp_items then
          vim.notify('No LSP Items received', error_lev)
          return
        end

        local items = {}

        if lsp_op == 'call' then
          make_call_hierarchy_items(lsp_items, items, args)
        end

        if lsp_op == 'type' then
          make_type_hierarchy_items(lsp_items, items)
        end

        MiniPick.start({
          source = {
            name = picker_name,
            items = items,
            -- items = lsp_items, -- debug
            ---@diagnostic disable-next-line: redefined-local
            show = function(buf_id, items, query)
              MiniPick.default_show(buf_id, items, query, {
                show_icons = true,
              })
              -- print(vim.inspect(items)) -- debug
              apply_extmarks(buf_id, items)
            end,
            match = MiniPick.default_match,
          },
        })
      end
    )
  end)
end

return M

-- vim: ts=2 sts=2 sw=2 et
