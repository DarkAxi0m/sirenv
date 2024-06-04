vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set({'n','i'}, "<F3>", "<cmd>w<cr>")

vim.keymap.set({'n','v'}, "<leader>oo", ":<c-u>lua require('ollama').prompt()<cr>")
vim.keymap.set({'n','v'}, "<leader>oG", ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>")



-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])


-- This is going to get me cancelled --ThePrimeagen
vim.keymap.set("i", "<C-c>", "<Esc>")




