return {
    { -- Ayu colorscheme
        'Shatur/neovim-ayu',
        lazy = false,
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
        cond = not vim.g.vscode,
        init = function()
            vim.cmd.colorscheme 'ayu'
        end,
    },

    { -- status line improvements
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        cond = not vim.g.vscode,
        opts = {},
    },

    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

    { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
                'bash',
                'css',
                'diff',
                'dockerfile',
                'go',
                'html',
                'ini',
                'java',
                'javascript',
                'json',
                'json5',
                'jsonc',
                'jsonnet',
                'kotlin',
                'lua',
                'make',
                'markdown',
                'markdown_inline',
                'promql',
                'proto',
                'python',
                'regex',
                'rego',
                'ruby',
                'rust',
                'scala',
                'sql',
                'terraform',
                'toml',
                'tsx',
                'typescript',
                'vim',
                'yaml',
            },
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                additional_vim_regex_highlighting = { 'ruby' },
            },
            indent = { enable = true, disable = { 'ruby' } },
        },
        config = function(_, opts)
            -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

            ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup(opts)

            -- There are additional nvim-treesitter modules that you can use to interact
            -- with nvim-treesitter. You should go explore a few and see what interests you:
            --
            --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
            --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
            --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
        end,
    },

    { -- context for treesitter-enabled languages
        'nvim-treesitter/nvim-treesitter-context',
        opts = {},
        cond = not vim.g.vscode,
    },

    -- 'gc' to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require('which-key').setup()

            -- Document existing key chains
            -- require('which-key').register {
            --     ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
            --     ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
            --     ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
            --     ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
            --     ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
            -- }
        end,
        cond = not vim.g.vscode,
    },

    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
            add = { text = '┃' },
            change = { text = '┃' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
            untracked = { text = '┆' },
            },
        },
        cond = not vim.g.vscode,
    },
}
