return {
  { -- Ayu colorscheme
    'Shatur/neovim-ayu',
    lazy = false,
    vscode = false,
    priority = 1000,
    opts = {
      mirage = true,
    },
    config = function(_, opts)
      if not vim.fn.has 'wsl' then
        opts["overrides"] = {
          Normal = { bg = 'None' },
          ColorColumn = { bg = 'None' },
          SignColumn = { bg = 'None' },
          Folded = { bg = 'None' },
          FoldColumn = { bg = 'None' },
          CursorLine = { bg = 'None' },
          CursorColumn = { bg = 'None' },
          WhichKeyFloat = { bg = 'None' },
          VertSplit = { bg = 'None' },
        }
      end
      require('ayu').setup(opts)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu",
    },
  },
}