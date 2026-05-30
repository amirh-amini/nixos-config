-- Editor options. Sensible IDE defaults for an ex-Emacs/evil user.
local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes" -- avoid layout shift when diagnostics/git appear
opt.termguicolors = true
opt.showmode = false -- shown in the statusline instead
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "" }
opt.pumheight = 12
opt.winminwidth = 5

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.breakindent = true
opt.virtualedit = "block"
opt.formatoptions = "jcroqlnt"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit" -- live preview of :s
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Files / persistence
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.confirm = true -- prompt to save instead of failing on :q
opt.autowrite = true

-- Performance / behaviour
opt.updatetime = 200
opt.timeoutlen = 400
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- system clipboard (wl-clipboard on Wayland)
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- let render plugins hide markup
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Folding via treesitter (nvim-ufo refines this in its spec)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Diagnostics: virtual text is handled by tiny-inline-diagnostic; keep core tidy.
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = false, -- tiny-inline-diagnostic renders these
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  float = { border = "rounded", source = true },
})

-- Use ripgrep/fd-friendly path; disable some providers we don't use.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
