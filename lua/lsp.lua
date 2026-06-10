
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

vim.lsp.enable({ 'lua_ls', 'bashls', 'clangd', 'rust_analyzer' })



local on_attach = function(args)
  vim.bo[args.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

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

  if client and client:supports_method('textDocument/declaration', args.buf) then
    map( "gD", vim.lsp.buf.declaration, "Declaration" )
  end

  if client and client:supports_method('textDocument/definition', args.buf) then
    map( "gd", vim.lsp.buf.definition, "Defijition")
  end

  --- make a small range for clangd so it will suggest code actions
  local ca_fake_range = function()
    if client and client.name ~= 'clangd' then
      vim.lsp.buf.code_action()
    else
      local cursor = vim.api.nvim_win_get_cursor(0)
      vim.lsp.buf.code_action({
        range = {
          start = { cursor[1], cursor[2] },
          ["end"] = { cursor[1], cursor[2] + 1 }
        }
      })
    end
  end

  if client and client:supports_method('textDocument/codeAction', args.buf) then
    map( "gra", ca_fake_range, 'Code Actions' )
  end

  if client and client:supports_method('textDocument/codeAction', args.buf) then
    map( "gra", vim.lsp.buf.code_action, 'Code Actions',  "v" )
  end


  if client and client:supports_method('textDocument/rename', args.buf) then
    map( "grn", vim.lsp.buf.rename, "Rename" )
  end

  if client and client:supports_method('textDocument/implementation', args.buf) then
    map( "gri", vim.lsp.buf.implementation, "Implementation")
  end

  if client and client:supports_method('callHierarchy/incomingCalls', args.buf) then
    map( "grc", vim.lsp.buf.incoming_calls, "Symbol incoming calls")
  end

  if client and client:supports_method('callHierarchy/incomingCalls', args.buf) then
    map( "grC", vim.lsp.buf.outgoing_calls, "Symbol outgoing calls")
  end

  if client and client:supports_method('textDocument/references', args.buf) then
    map( "grr", vim.lsp.buf.references, "References")
  end

  local toggle_codelens = function ()
   vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled())
  end

  if client and client:supports_method('codeLens/resolve', args.buf) then
    vim.lsp.codelens.enable()
    map( "grx", vim.lsp.codelens.run, "run CodeLens")
    map( "grX", toggle_codelens, "Toggle CodeLens")
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
