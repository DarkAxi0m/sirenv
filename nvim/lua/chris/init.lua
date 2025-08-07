print "hello chris"
require("chris.packer")

require("formatter").setup({
  logging = false,
  filetype = {
    lua = {
      function()
        return {
          exe = "stylua",
          args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
          stdin = true,
        }
      end,
    },
    python = {
      function()
        return {
          exe = "black",
          args = { "--quiet", "-" },
          stdin = true,
        }
      end,
    },
    javascript = {
      function()
        return {
          exe = "prettier",
          args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end,
    },
  },
})

