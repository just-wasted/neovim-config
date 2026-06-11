vim.lsp.config['lua_ls'] = {
  on_attach = function(client)
    client.server_capabilities.completionProvider.triggerCharacters =
      { '.', ':', '#', '(', '[', '{' }
    -- Use this function to define buffer-local mappings and behavior that depend
    -- on attached client or only makes sense if there is language server attached.
  end,
  settings = {
    Lua = {
      completion = {
        -- Prevents aggressive workspace indexing over 1 character
        keywordSnippet = 'Replace',
      },
      runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
      diagnostics = {
        -- Don't analyze whole workspace, as it consumes too much CPU and RAM
        -- workspaceDelay = -1,
      },
      workspace = {
        -- Don't analyze code from submodules
        ignoreSubmodules = true,
        -- Add Neovim's methods for easier code writing
        -- https://github.com/neovim/nvim-lspconfig/issues/3189#issuecomment-3021345989
        library = vim.tbl_filter(function(d)
          return not d:match(vim.fn.stdpath('config') .. '/?a?f?t?e?r?')
        end, vim.api.nvim_get_runtime_file('', true)),
      },
    },
  },
}

vim.lsp.config['bashls'] = {
  filetypes = {
    'bash',
    'sh',
    'zsh',
  },
}

vim.lsp.config["clangd"]= {
  cmd = {
    "clangd",
    "--compile-commands-dir=build",
    "--query-driver=/**/*gcc,/**/*g++",
    "--background-index",
    "--clang-tidy",
  },
}

vim.lsp.enable({ 'lua_ls', 'bashls', 'clangd', 'rust_analyzer' })


local on_attach = function(args)
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

  if client and client:supports_method('textDocument/references', args.buf) then
    map('grr', function()
      MiniExtra.pickers.lsp({ scope = 'references' })
    end, 'References')
  end

  if client and client:supports_method('textDocument/definition', args.buf) then
    map('gd', MiniPick.registry.lsp_definitions, 'Definition')
  end

  if client and client:supports_method('textDocument/declaration', args.buf) then
    map('grD', MiniPick.registry.lsp_declarations, 'Declaration')
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
      MiniPick.registry.lsp_call_type_hyrarchy(args, 'subtypes')
    end, 'Subtypes')
  end

  if client and client:supports_method('typeHierarchy/supertypes', args.buf) then
    map('grp', function()
      MiniPick.registry.lsp_call_type_hyrarchy(args, 'supertypes')
    end, 'Supertypes')
  end

  if client and client:supports_method('callHierarchy/incomingCalls', args.buf) then
    map('grc', function()
      MiniPick.registry.lsp_call_type_hyrarchy(args, 'incomingCalls')
    end, 'Symbol incoming calls')
  end

  if client and client:supports_method('callHierarchy/outgoingCalls', args.buf) then
    map('grC', function()
      MiniPick.registry.lsp_call_type_hyrarchy(args, 'outgoingCalls')
    end, 'Symbol outgoing calls')
  end

  if client and client:supports_method('textDocument/codeAction', args.buf) then
    map('gra', vim.lsp.buf.code_action, 'Code Actions', 'v')
  end

  if client and client:supports_method('textDocument/rename', args.buf) then
    map('grn', vim.lsp.buf.rename, 'Rename')
  end

  if client and client:supports_method('textDocument/codeLens', args.buf) then
    -- vim.lsp.codelens.enable()
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
