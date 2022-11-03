vim.cmd([[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

highlight LineNr ctermfg=red
]])

vim.opt.ts=4
vim.opt.sts=3
vim.opt.sw=4
vim.opt.expandtab=true
vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.mouse="r"
vim.opt.cursorline=true
vim.opt.termguicolors=true

vim.cmd([[
call plug#begin()
Plug 'scrooloose/nerdtree'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'wakatime/vim-wakatime'
Plug 'Yohannfra/Vim-Epitech'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'yuezk/vim-js'
Plug 'jasonwoodland/vim-html-indent'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'lewis6991/gitsigns.nvim'

Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

Plug 'mfussenegger/nvim-lint'
Plug 'VonHeikemen/lsp-zero.nvim'

Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'

Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip',

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

Plug 'Shatur/neovim-ayu'
Plug 'tomasr/molokai'
Plug 'phanviet/vim-monokai-pro'
Plug 'rebelot/kanagawa.nvim'

call plug#end()

colorscheme molokai
]])

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        virtual_text = true,
    }
)

local cmd = vim.cmd

-- Highlight on yank
cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Strip trailing white spaces

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function()
        local original_cursor = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(original_cursor)
    end
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- vim.api.nvim_create_autocmd({ "BufWritePre"}, {
--     pattern = { "*.tsx", "*.ts", "*.jsx", "*.js" },
--     command = "EslintFixAll"
-- })


-- nvim-cmp setup
-- cmp.setup {
--   snippet = {
--     expand = function(args)
--       luasnip.lsp_expand(args.body)
--     end,
--   },
--   mapping = cmp.mapping.preset.insert({
--     ['<C-d>'] = cmp.mapping.scroll_docs(-4),
--     ['<C-f>'] = cmp.mapping.scroll_docs(4),
--     ['<C-Space>'] = cmp.mapping.complete(),
--     ['<CR>'] = cmp.mapping.confirm {
--       behavior = cmp.ConfirmBehavior.Replace,
--       select = true,
--     },
--     ['<Tab>'] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_next_item()
--       elseif luasnip.expand_or_jumpable() then
--         luasnip.expand_or_jump()
--       else
--         fallback()
--       end
--     end, { 'i', 's' }),
--     ['<S-Tab>'] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_prev_item()
--       elseif luasnip.jumpable(-1) then
--         luasnip.jump(-1)
--       else
--         fallback()
--       end
--     end, { 'i', 's' }),
--   }),
--   sources = {
--     { name = 'nvim_lsp' },
--     { name = 'luasnip' },
--   },
-- }

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local luasnip = require 'luasnip'
local cmp = require'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.nvim_workspace()
lsp.setup()

local mason = require("mason").setup({
    ui = {
        icons = {
        }
    }
})

local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
local mason_lspconfig = require("mason-lspconfig")

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp

mason_lspconfig.setup({
    ensure_installed = servers
})

-- Function

function CopyToClipboard()
    vim.cmd(":call system('xclip -i -selection clipboard', @@)")
end

-- Key bindings

local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files, {})
vim.keymap.set('n', 'fg', builtin.live_grep, {})
vim.keymap.set('n', 'fb', builtin.buffers, {})
vim.keymap.set('n', 'fh', builtin.help_tags, {})
vim.api.nvim_set_keymap("n", "<C-t>", ":NERDTreeToggle<Cr>", { noremap = false })

--vim.keymap.set("v", "<C-c>", copyToClipboard, { noremap = true })

local DEFAULT_SETTINGS = {
    ui = {
        -- Whether to automatically check for new versions when opening the :Mason window.
        check_outdated_packages_on_open = true,

        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "none",

        keymaps = {
            -- Keymap to expand a package
            toggle_package_expand = "<CR>",
            -- Keymap to install the package under the current cursor position
            install_package = "i",
            -- Keymap to reinstall/update the package under the current cursor position
            update_package = "u",
            -- Keymap to check for new version for the package under the current cursor position
            check_package_version = "c",
            -- Keymap to update all installed packages
            update_all_packages = "U",
            -- Keymap to check which installed packages are outdated
            check_outdated_packages = "C",
            -- Keymap to uninstall a package
            uninstall_package = "X",
            -- Keymap to cancel a package installation
            cancel_installation = "<C-c>",
            -- Keymap to apply language filter
            apply_language_filter = "<C-f>",
        },
    },

    -- The directory in which to install packages.
    install_root_dir = vim.fn.stdpath("data").."/mason",

    pip = {
        -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
        -- and is not recommended.
        --
        -- Example: { "--proxy", "https://proxyserver" }
        install_args = {},
    },

    -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
    -- debugging issues with package installations.
    log_level = vim.log.levels.INFO,

    -- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
    -- packages that are requested to be installed will be put in a queue.
    max_concurrent_installers = 4,

    github = {
        -- The template URL to use when downloading assets from GitHub.
        -- The placeholders are the following (in order):
        -- 1. The repository (e.g. "rust-lang/rust-analyzer")
        -- 2. The release version (e.g. "v0.3.0")
        -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
        download_url_template = "https://github.com/%s/releases/download/%s/%s",
    },
}


require('nvim-treesitter.configs').setup ({
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
})

require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
})
