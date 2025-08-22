-- IDE Mode Keybinding Configuration
-- 2025.01.08 - Comprehensive keybindings for IDE features
-- Organized by functionality for easy reference and maintenance

local M = {}

-- Helper function for setting keymaps with consistent options
local function keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap ~= false
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- File Explorer and Navigation keymaps
function M.setup_file_navigation()
  -- Neo-tree file explorer
  keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Explorer" })
  keymap("n", "<leader>o", ":Neotree focus<CR>", { desc = "Focus Explorer" })
  keymap("n", "<leader>gf", ":Neotree git_status<CR>", { desc = "Git Files" })
  keymap("n", "<leader>bf", ":Neotree buffers<CR>", { desc = "Buffer Explorer" })
  
  -- Telescope enhanced navigation
  keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
  keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
  keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find Buffers" })
  keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help Tags" })
  keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent Files" })
  keymap("n", "<leader>fc", "<cmd>Telescope colorscheme<CR>", { desc = "Colorschemes" })
  keymap("n", "<leader>fs", "<cmd>Telescope grep_string<CR>", { desc = "Find String" })
  keymap("n", "<leader>fp", "<cmd>Telescope projects<CR>", { desc = "Projects" })
  
  -- Advanced search
  keymap("n", "<leader>/", ":Telescope live_grep_args<CR>", { desc = "Live Grep Args" })
  keymap("n", "<leader>fw", "<cmd>Telescope grep_string search=<C-r><C-w><CR>", { desc = "Find Word" })
end

-- LSP and Code Intelligence keymaps
function M.setup_lsp_keymaps()
  -- LSP navigation (these will be set per buffer in lsp config)
  -- Included here for reference in help docs
  
  -- Diagnostics and trouble
  keymap("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { desc = "Toggle Trouble" })
  keymap("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Workspace Diagnostics" })
  keymap("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Document Diagnostics" })
  keymap("n", "<leader>xl", "<cmd>TroubleToggle loclist<CR>", { desc = "Location List" })
  keymap("n", "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", { desc = "Quickfix List" })
  keymap("n", "gR", "<cmd>TroubleToggle lsp_references<CR>", { desc = "LSP References" })
  
  -- Telescope LSP
  keymap("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })
  keymap("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Workspace Symbols" })
  keymap("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "LSP Info" })
  keymap("n", "<leader>lI", "<cmd>LspInstallInfo<CR>", { desc = "LSP Install Info" })
  keymap("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "LSP Restart" })
end

-- Git integration keymaps
function M.setup_git_keymaps()
  -- Gitsigns
  keymap("n", "]h", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true, desc = "Next Hunk" })
  keymap("n", "[h", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true, desc = "Prev Hunk" })
  keymap("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
  keymap("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
  keymap("v", "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
  keymap("v", "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
  keymap("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage Buffer" })
  keymap("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo Stage Hunk" })
  keymap("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset Buffer" })
  keymap("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview Hunk" })
  keymap("n", "<leader>hb", "<cmd>lua require'gitsigns'.blame_line{full=true}<CR>", { desc = "Blame Line" })
  keymap("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle Line Blame" })
  keymap("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff This" })
  keymap("n", "<leader>hD", "<cmd>lua require'gitsigns'.diffthis('~')<CR>", { desc = "Diff This ~" })
  keymap("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>", { desc = "Toggle Deleted" })
  
  -- Fugitive
  keymap("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git Status" })
  keymap("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git Commit" })
  keymap("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git Push" })
  keymap("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git Pull" })
  keymap("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
  keymap("n", "<leader>gB", "<cmd>Telescope git_branches<CR>", { desc = "Git Branches" })
  
  -- Diffview
  keymap("n", "<leader>dv", "<cmd>DiffviewOpen<CR>", { desc = "Diff View" })
  keymap("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Close Diff View" })
  keymap("n", "<leader>dh", "<cmd>DiffviewFileHistory<CR>", { desc = "File History" })
  keymap("n", "<leader>df", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current File History" })
end

-- Testing keymaps
function M.setup_testing_keymaps()
  -- Neotest
  keymap("n", "<leader>tr", "<cmd>lua require('neotest').run.run()<CR>", { desc = "Run Test" })
  keymap("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Run File Tests" })
  keymap("n", "<leader>ts", "<cmd>lua require('neotest').run.stop()<CR>", { desc = "Stop Test" })
  keymap("n", "<leader>to", "<cmd>lua require('neotest').output.open({ enter = true })<CR>", { desc = "Test Output" })
  keymap("n", "<leader>tO", "<cmd>lua require('neotest').output_panel.toggle()<CR>", { desc = "Toggle Test Output Panel" })
  keymap("n", "<leader>tS", "<cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle Test Summary" })
  keymap("n", "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", { desc = "Debug Test" })
  
  -- Test navigation
  keymap("n", "]t", "<cmd>lua require('neotest').jump.next({ status = 'failed' })<CR>", { desc = "Next Failed Test" })
  keymap("n", "[t", "<cmd>lua require('neotest').jump.prev({ status = 'failed' })<CR>", { desc = "Prev Failed Test" })
end

-- Terminal and task management keymaps
function M.setup_terminal_keymaps()
  -- ToggleTerm
  keymap("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Float Terminal" })
  keymap("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "Horizontal Terminal" })
  keymap("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<CR>", { desc = "Vertical Terminal" })
  
  -- Terminal mode navigation
  keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Terminal Left" })
  keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Terminal Down" })
  keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Terminal Up" })
  keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Terminal Right" })
  keymap("t", "<esc>", "<C-\\><C-n>", { desc = "Terminal Normal Mode" })
  
  -- Overseer task management
  keymap("n", "<leader>or", "<cmd>OverseerRun<CR>", { desc = "Run Task" })
  keymap("n", "<leader>ot", "<cmd>OverseerToggle<CR>", { desc = "Toggle Tasks" })
  keymap("n", "<leader>oo", "<cmd>OverseerOpen<CR>", { desc = "Open Tasks" })
  keymap("n", "<leader>oc", "<cmd>OverseerClose<CR>", { desc = "Close Tasks" })
  keymap("n", "<leader>oa", "<cmd>OverseerTaskAction<CR>", { desc = "Task Action" })
end

-- Documentation and code generation keymaps
function M.setup_documentation_keymaps()
  -- Neogen documentation generation
  keymap("n", "<leader>nf", "<cmd>lua require('neogen').generate()<CR>", { desc = "Generate Function Docs" })
  keymap("n", "<leader>nc", "<cmd>lua require('neogen').generate({ type = 'class' })<CR>", { desc = "Generate Class Docs" })
  keymap("n", "<leader>nt", "<cmd>lua require('neogen').generate({ type = 'type' })<CR>", { desc = "Generate Type Docs" })
  keymap("n", "<leader>nF", "<cmd>lua require('neogen').generate({ type = 'file' })<CR>", { desc = "Generate File Docs" })
end

-- Refactoring keymaps
function M.setup_refactoring_keymaps()
  -- Refactoring.nvim
  keymap("v", "<leader>rf", "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<CR>", { desc = "Extract Function" })
  keymap("v", "<leader>rv", "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<CR>", { desc = "Extract Variable" })
  keymap("v", "<leader>ri", "<Esc><cmd>lua require('refactoring').refactor('Inline Variable')<CR>", { desc = "Inline Variable" })
  
  -- Extract block
  keymap("n", "<leader>rb", "<cmd>lua require('refactoring').refactor('Extract Block')<CR>", { desc = "Extract Block" })
  keymap("n", "<leader>rbf", "<cmd>lua require('refactoring').refactor('Extract Block To File')<CR>", { desc = "Extract Block to File" })
  
  -- Inline variable
  keymap("n", "<leader>ri", "<cmd>lua require('refactoring').refactor('Inline Variable')<CR>", { desc = "Inline Variable" })
end

-- Buffer and window management keymaps
function M.setup_buffer_keymaps()
  -- Buffer navigation
  keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })
  keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous Buffer" })
  keymap("n", "<leader>bd", ":Bdelete!<CR>", { desc = "Delete Buffer" })
  keymap("n", "<leader>bD", ":bufdo :Bdelete<CR>", { desc = "Delete All Buffers" })
  
  -- Window management
  keymap("n", "<leader>sv", "<C-w>v", { desc = "Split Vertical" })
  keymap("n", "<leader>sh", "<C-w>s", { desc = "Split Horizontal" })
  keymap("n", "<leader>se", "<C-w>=", { desc = "Equal Windows" })
  keymap("n", "<leader>sx", ":close<CR>", { desc = "Close Window" })
  
  -- Tab management
  keymap("n", "<leader>to", ":tabnew<CR>", { desc = "New Tab" })
  keymap("n", "<leader>tx", ":tabclose<CR>", { desc = "Close Tab" })
  keymap("n", "<leader>tn", ":tabn<CR>", { desc = "Next Tab" })
  keymap("n", "<leader>tp", ":tabp<CR>", { desc = "Previous Tab" })
end

-- IDE mode specific keymaps
function M.setup_ide_mode_keymaps()
  -- IDE mode controls (lowercase commands work via abbreviations)
  keymap("n", "<leader>im", ":ide<CR>", { desc = "Switch to IDE Mode" })
  keymap("n", "<leader>mm", ":minimal<CR>", { desc = "Switch to Minimal Mode" })
  keymap("n", "<leader>ih", ":idehelp<CR>", { desc = "IDE Help" })
  keymap("n", "<leader>is", ":idestatus<CR>", { desc = "IDE Status" })
  
  -- Quick access to IDE features
  keymap("n", "<leader>it", ":TroubleToggle<CR>", { desc = "Toggle Trouble" })
  keymap("n", "<leader>ie", ":Neotree toggle<CR>", { desc = "Toggle Explorer" })
  keymap("n", "<leader>ig", ":Git<CR>", { desc = "Git Status" })
  keymap("n", "<leader>id", ":lua require('dapui').toggle()<CR>", { desc = "Toggle Debugger" })
end

-- Language-specific keymaps
function M.setup_language_keymaps()
  -- Python specific
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      keymap("n", "<leader>rp", ":!python %<CR>", { desc = "Run Python File", buffer = true })
      keymap("n", "<leader>ri", ":!python -i %<CR>", { desc = "Run Python Interactive", buffer = true })
      keymap("n", "<leader>rP", ":!python -m pytest %<CR>", { desc = "Run Pytest", buffer = true })
    end,
  })
  
  -- Shell specific
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sh", "bash", "zsh" },
    callback = function()
      keymap("n", "<leader>rs", ":!bash %<CR>", { desc = "Run Shell Script", buffer = true })
      keymap("n", "<leader>rc", ":!shellcheck %<CR>", { desc = "Check Shell Script", buffer = true })
    end,
  })
  
  -- Terraform specific
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "terraform",
    callback = function()
      keymap("n", "<leader>tf", ":!terraform fmt %<CR>", { desc = "Terraform Format", buffer = true })
      keymap("n", "<leader>tv", ":!terraform validate<CR>", { desc = "Terraform Validate", buffer = true })
      keymap("n", "<leader>tp", ":!terraform plan<CR>", { desc = "Terraform Plan", buffer = true })
      keymap("n", "<leader>ta", ":!terraform apply<CR>", { desc = "Terraform Apply", buffer = true })
    end,
  })
  
  -- JavaScript/TypeScript specific
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
      keymap("n", "<leader>rn", ":!node %<CR>", { desc = "Run Node.js", buffer = true })
      keymap("n", "<leader>rt", ":!npm test<CR>", { desc = "Run Tests", buffer = true })
      keymap("n", "<leader>rb", ":!npm run build<CR>", { desc = "Build Project", buffer = true })
      keymap("n", "<leader>rd", ":!npm run dev<CR>", { desc = "Dev Server", buffer = true })
    end,
  })
  
  -- Markdown specific
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      keymap("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Preview Markdown", buffer = true })
      keymap("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { desc = "Stop Preview", buffer = true })
    end,
  })
end

-- AI assistance keymaps (if enabled)
function M.setup_ai_keymaps()
  -- GitHub Copilot (if installed)
  -- keymap("i", "<C-j>", "<Plug>(copilot-next)", { desc = "Copilot Next" })
  -- keymap("i", "<C-k>", "<Plug>(copilot-previous)", { desc = "Copilot Previous" })
  -- keymap("i", "<C-\\>", "<Plug>(copilot-dismiss)", { desc = "Copilot Dismiss" })
  
  -- ChatGPT (if installed)
  -- keymap("n", "<leader>cc", "<cmd>ChatGPT<CR>", { desc = "ChatGPT" })
  -- keymap("v", "<leader>ce", "<cmd>ChatGPTEditWithInstructions<CR>", { desc = "Edit with ChatGPT" })
  -- keymap("v", "<leader>cg", "<cmd>ChatGPTRun grammar_correction<CR>", { desc = "Grammar Correction" })
end

-- Quick actions and utilities
function M.setup_utility_keymaps()
  -- Format document
  keymap("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Format Document" })
  keymap("v", "<leader>fm", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Format Selection" })
  
  -- Toggle line numbers
  keymap("n", "<leader>ln", ":set nu!<CR>", { desc = "Toggle Line Numbers" })
  keymap("n", "<leader>lr", ":set rnu!<CR>", { desc = "Toggle Relative Numbers" })
  
  -- Toggle word wrap
  keymap("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle Word Wrap" })
  
  -- Clear search highlighting
  keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Clear Search Highlight" })
  
  -- Quick save and quit
  keymap("n", "<leader>w", ":w<CR>", { desc = "Save File" })
  keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
  keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Quit All" })
  
  -- Copy file path
  keymap("n", "<leader>cp", ":let @+ = expand('%:p')<CR>", { desc = "Copy File Path" })
  keymap("n", "<leader>cf", ":let @+ = expand('%:t')<CR>", { desc = "Copy File Name" })
  
  -- Spell checking
  keymap("n", "<leader>ts", ":set spell!<CR>", { desc = "Toggle Spell Check" })
  keymap("n", "]s", "]s", { desc = "Next Misspelled" })
  keymap("n", "[s", "[s", { desc = "Prev Misspelled" })
  keymap("n", "z=", "z=", { desc = "Spell Suggestions" })
  keymap("n", "zg", "zg", { desc = "Add to Dictionary" })
end

-- Main setup function for all IDE keymaps
function M.setup()
  -- Setup all keymap categories
  M.setup_file_navigation()
  M.setup_lsp_keymaps()
  M.setup_git_keymaps()
  M.setup_testing_keymaps()
  M.setup_terminal_keymaps()
  M.setup_documentation_keymaps()
  M.setup_refactoring_keymaps()
  M.setup_buffer_keymaps()
  M.setup_ide_mode_keymaps()
  M.setup_language_keymaps()
  M.setup_ai_keymaps()
  M.setup_utility_keymaps()
  
  -- Setup which-key descriptions if available
  local status_ok, which_key = pcall(require, "which-key")
  if status_ok then
    which_key.register({
      ["<leader>"] = {
        b = { name = "Buffers" },
        d = { name = "Debug" },
        f = { name = "Find" },
        g = { name = "Git" },
        h = { name = "Git Hunks" },
        i = { name = "IDE Mode" },
        l = { name = "LSP" },
        n = { name = "Neogen" },
        o = { name = "Overseer" },
        r = { name = "Refactor/Run" },
        s = { name = "Split" },
        t = { name = "Test/Toggle/Tab" },
        x = { name = "Trouble" },
      },
    })
  end
  
  vim.notify("IDE keymaps loaded", vim.log.levels.INFO)
end

return M