
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

vim.lsp.enable({ 'lua_ls', 'bashls', 'clangd' })

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
        vim.api.nvim_clear_autocmds({ group = 'cursor-lsp-highlight', buffer = event2.buf })
      end,
    })
  end
end
vim.api.nvim_create_autocmd('LspAttach', { callback = on_attach })

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
