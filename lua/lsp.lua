vim.lsp.config('lua_ls',  {
  on_attach = function(client)
    client.server_capabilities.completionProvider.triggerCharacters =
      { '.', ':', '#', '(', '[', '{' }
  end,
  settings = {
    Lua = {
      completion = {
        keywordSnippet = 'Replace',
      },
      runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
      diagnostics = {
        -- Don't analyze whole workspace, as it consumes too much CPU and RAM
        workspaceDelay = -1,
      },
      workspace = {
        -- Don't analyze code from submodules
        ignoreSubmodules = true,
        -- https://github.com/neovim/nvim-lspconfig/issues/3189#issuecomment-3021345989
        library = vim.tbl_filter(function(d)
          return not d:match(vim.fn.stdpath('config') .. '/?a?f?t?e?r?')
        end, vim.api.nvim_get_runtime_file('', true)),
      },
    },
  },
})

vim.lsp.config('bashls', {
  filetypes = {
    'bash',
    'sh',
    'zsh',
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--compile-commands-dir=build",
    -- "--query-driver=/**/*gcc,/**/*g++",
    "--query-driver=/usr/bin/g++,/usr/bin/gcc",
    "--background-index",
    "--clang-tidy",
  },
})

vim.lsp.enable({ 'lua_ls', 'bashls', 'clangd', 'rust_analyzer' })


local on_attach = function(args)
  ---- for MiniCompletion
  -- vim.bo[args.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

  local client = vim.lsp.get_client_by_id(args.data.client_id)


  if client and client:supports_method('textDocument/documentHighlight', args.buf) then
    vim.b.minicursorword_disable = true
    local highlight_augroup =
      vim.api.nvim_create_augroup('cursor-lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = args.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = args.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('wasted/lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.b.minicursorword_disable = false
        vim.api.nvim_clear_autocmds({ group = 'cursor-lsp-highlight', buffer = event2.buf })
      end,
    })
  end

  ---- keymaps when LSP is attached ----
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = desc })
  end

  if client and client.name == 'clangd' then
    map('grh', '<cmd>LspClangdSwitchSourceHeader<CR>', 'Goto [H]eader/ Source')
    map('grs', '<cmd>LspClangdShowSymbolInfo<CR>', '[S]ymbol Info')
  end

  if client and client:supports_method('textDocument/references', args.buf) then
    map('grr', function()
      MiniExtra.pickers.lsp({ scope = 'references' })
    end, 'References')
  end

  if client and client:supports_method('textDocument/definition', args.buf) then
    map('gd', MiniPick.registry.lsp_definitions, 'Definition')
  end

  if client and client:supports_method('textDocument/declaration', args.buf) then
    map('gD', MiniPick.registry.lsp_declarations, 'Declaration')
  end

  if client and client:supports_method('textDocument/documentSymbol', args.buf) then
    map('grd', function ()
      MiniExtra.pickers.lsp({scope = 'document_symbol'})
    end , 'Document Symbols')
  end

  if client and client:supports_method('workspace/symbol', args.buf) then
    map('grw', function ()
      MiniExtra.pickers.lsp({scope = 'workspace_symbol'})
    end, 'Workspace Symbols')
  end

  if client and client:supports_method('workspace/symbol', args.buf) then
    map('grW', function ()
      MiniExtra.pickers.lsp({scope = 'workspace_symbol_live'})
    end, 'Workspace Symbols Live')
  end

  if client and client:supports_method('textDocument/implementation', args.buf) then
    map('gri', function()
      MiniExtra.pickers.lsp({ scope = 'implementation' })
    end, 'Implementation')
  end

  if client and client:supports_method('textDocument/typeDefinition', args.buf) then
    map('grt', function()
      MiniExtra.pickers.lsp({ scope = 'type_definition' })
    end, 'Type Definition')
  end

  if client and client:supports_method('typeHierarchy/subtypes', args.buf) then
    map('grT', function()
      MiniPick.registry.lsp_call_type_hierarchy(args, 'subtypes')
    end, 'Subtypes')
  end

  if client and client:supports_method('typeHierarchy/supertypes', args.buf) then
    map('grp', function()
      MiniPick.registry.lsp_call_type_hierarchy(args, 'supertypes')
    end, 'Supertypes')
  end

  if client and client:supports_method('callHierarchy/incomingCalls', args.buf) then
    map('grc', function()
      MiniPick.registry.lsp_call_type_hierarchy(args, 'incomingCalls')
    end, 'Symbol incoming calls')
  end

  if client and client:supports_method('callHierarchy/outgoingCalls', args.buf) then
    map('grC', function()
      MiniPick.registry.lsp_call_type_hierarchy(args, 'outgoingCalls')
    end, 'Symbol outgoing calls')
  end

  if client and client:supports_method('textDocument/rename', args.buf) then
    map('grn', vim.lsp.buf.rename, 'Rename')
  end

  if client and client:supports_method('textDocument/codeLens', args.buf) then
    map('grx', vim.lsp.codelens.run, 'run CodeLens')
    map('grX', function()
      vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
    end, 'Toggle CodeLens')
  end

  if client and client:supports_method('textDocument/inlayHint', args.buf) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
    end, 'Toggle inlay hints')
  end

  ---- make a small range for clangd so it will suggest code actions in normal mode
  local ca_fake_range = function()
    if client and client.name ~= 'clangd' then
      vim.lsp.buf.code_action()
    else
      local cursor = vim.api.nvim_win_get_cursor(0)
      vim.lsp.buf.code_action({
        range = {
          start = { cursor[1], cursor[2] },
          ['end'] = { cursor[1], cursor[2] + 1 },
        },
      })
    end
  end
  if client and client:supports_method('textDocument/codeAction', args.buf) then
    map('gra', ca_fake_range, 'Code Actions')
  end

  if client and client:supports_method('textDocument/codeAction', args.buf) then
    map('gra', vim.lsp.buf.code_action, 'Code Actions', 'v')
  end
end

vim.api.nvim_create_autocmd('LspAttach', { callback = on_attach })

---- stuff for nvim native autocomplete
-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if client then
--       if client.server_capabilities.completionProvider then
--         if not vim.bo.complete:find('o', 1, true) then
--           vim.bo.complete = 'o,' .. vim.bo.complete
--         end
--
--         vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
--           convert = function(item)
--
--
--             local abbr = item.label:match('[%w_.]+.*') or item.label
--             return {
--               abbr = #abbr > 25 and abbr:sub(1, 24) .. '…' or abbr,
--               menu = '',
--             }
--           end,
--         })
--       end
--     end
--   end,
-- })

-- vim: ts=2 sts=2 sw=2 et
