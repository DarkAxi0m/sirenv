print('LuaSnip')

local ls = require("luasnip")

vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true})


ls.add_snippets('all', {
    ls.parser.parse_snippet("expand", "als;dfjasldkflasdfj"),
})
ls.add_snippets('lua', {
    ls.parser.parse_snippet('lf', 'local $1 = function($2)\n  $0\nend')
})

ls.add_snippets('tsx', {
    ls.parser.parse_snippet('usestate', 'const [$1, set$1] = React.useState<$2>($3)')
})


