-- local lsp = require("lsp-zero")

-- lsp.preset("recommended")

-- lsp.ensure_installed({
--   'tsserver'
-- })

-- -- Fix Undefined global 'vim'
-- lsp.nvim_workspace()



-- lsp.setup()




local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup_servers({'tsserver', 'eslint'})


lsp.setup()

vim.diagnostic.config({
  virtual_text = true
})

