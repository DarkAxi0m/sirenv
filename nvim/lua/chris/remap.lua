vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set({'n','i'}, "<F3>", "<cmd>w<cr>")

vim.keymap.set({'n','v'}, "<leader>oo", ":<c-u>lua require('ollama').prompt()<cr>")
vim.keymap.set({'n','v'}, "<leader>oG", ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>")







