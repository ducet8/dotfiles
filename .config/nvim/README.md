# Dual-Mode Neovim IDE Configuration

A sophisticated Neovim configuration that provides two distinct modes:
- **MINIMAL MODE**: Fast, lightweight editing with essential features
- **IDE MODE**: Full development environment with advanced tooling

## 🚀 Quick Start

1. **Start Neovim** - Launches in minimal mode by default
2. **Enable IDE features** - Run `:ide` when you need full development tools
3. **Get help** - Use `:idehelp` to see all available features
4. **Return to minimal** - Use `:minimal` for lightweight editing

## 📁 Architecture Overview

```
.config/nvim/
├── init.lua                 # Main entry point
├── lua/user/
│   ├── ide.lua             # IDE mode controller
│   ├── ide/                # IDE-specific configurations
│   │   ├── plugins.lua     # IDE plugin definitions
│   │   ├── lsp.lua         # Advanced LSP configurations
│   │   ├── debugging.lua   # Debug setup for Python/JS/TS
│   │   ├── keymaps.lua     # IDE-specific keybindings
│   │   └── docs.lua        # Built-in help system
│   ├── plugins/            # Plugin configurations
│   └── (existing configs)  # Your current setup
```

## 🔧 Installation

### Prerequisites

```bash
# Install required external tools
brew install ripgrep fd neovim  # macOS
# or
sudo apt install ripgrep fd-find neovim  # Ubuntu

# Install Python debugging support
pip install debugpy

# Install Node.js for JavaScript/TypeScript support
brew install node  # or your preferred method
```

### Setup Process

1. **Backup existing config** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Your current dotfiles are already set up** - just start Neovim!

3. **First launch**:
   ```bash
   nvim
   ```
   - Lazy.nvim will install minimal plugins automatically
   - You'll see "MINIMAL mode" in the statusline

4. **Enable IDE mode**:
   ```
   :ide
   ```
   - Downloads and configures all IDE plugins
   - Takes a moment on first run as it installs language servers

## 🎯 Usage Guide

### Mode Switching

| Command | Description |
|---------|-------------|
| `:ide` | Switch to IDE mode (loads all development tools) |
| `:minimal` | Switch to minimal mode (lightweight editing) |
| `:idehelp` | Show comprehensive help and keybindings |
| `:idestatus` | Display current mode and loaded features |

### Development Workflow

#### 1. **Quick Edits** (Minimal Mode)
```bash
nvim config.yaml        # Fast startup, basic editing
# Edit and save quickly, no heavy features loaded
```

#### 2. **Development Sessions** (IDE Mode)
```bash
nvim                     # Start in minimal mode
:ide                     # Load full IDE features
# Now you have debugging, testing, advanced Git, etc.
```

#### 3. **Project Development**
```bash
cd ~/my-project
nvim .                   # Open project
:ide                     # Enable IDE features
<leader>ff               # Find files with Telescope
<leader>e                # Open file explorer
```

## 📚 Language Support

### Python
- **LSP**: pyright, pylsp with advanced features
- **Debugging**: Full nvim-dap integration with debugpy
- **Testing**: pytest integration with neotest
- **Formatting**: black, isort
- **Linting**: flake8, mypy

### JavaScript/TypeScript
- **LSP**: tsserver, eslint with inlay hints
- **Debugging**: Node.js and Chrome debugging
- **Testing**: Jest integration
- **Formatting**: prettier

### Shell Scripts
- **LSP**: bashls for Bash/Zsh
- **Formatting**: shfmt
- **Linting**: shellcheck

### Infrastructure as Code
- **Terraform**: terraformls, tflint, formatting
- **YAML**: yamlls with Kubernetes/Docker schemas
- **JSON**: jsonls with schema validation

### Markdown
- **LSP**: marksman for navigation and links
- **Formatting**: markdownlint
- **Live preview**: (can be added)

## ⌨️ Essential Keybindings

### File Navigation
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>/` | Advanced search |

### LSP & Code Intelligence
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format document |

### Git Integration
| Key | Action |
|-----|--------|
| `<leader>gs` | Git status |
| `<leader>hs` | Stage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>tb` | Toggle blame |
| `<leader>dv` | Diff view |

### Debugging
| Key | Action |
|-----|--------|
| `<F5>` | Continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<leader>b` | Toggle breakpoint |
| `<leader>du` | Toggle DAP UI |

### Testing
| Key | Action |
|-----|--------|
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>td` | Debug test |
| `<leader>tS` | Test summary |

## 🔍 Features by Mode

### Minimal Mode (Always Available)
- ✅ Basic LSP (pyright, jsonls)
- ✅ Code completion
- ✅ Syntax highlighting (Treesitter)
- ✅ File navigation (Telescope basics)
- ✅ Git integration (basic)
- ✅ Fast startup (~50ms)

### IDE Mode (On-Demand via `:ide`)
- 🚀 Advanced LSP for all languages
- 🐛 Full debugging support (Python, JS/TS)
- 🧪 Testing frameworks (pytest, Jest)
- 📁 Enhanced file explorer (Neo-tree)
- 🔄 Git workflow tools (Fugitive, Diffview)
- 📝 Documentation generation (Neogen)
- 🔧 Code refactoring tools
- 📊 Project management
- 🖥️ Advanced terminal management

## 🛠️ Customization

### Adding New Languages

1. **Add LSP server** in [`ide/lsp.lua`](.config/nvim/lua/user/ide/lsp.lua):
```lua
-- In the servers table
your_language_ls = {
  settings = {
    -- your settings here
  },
},
```

2. **Add language-specific keybindings** in [`ide/keymaps.lua`](.config/nvim/lua/user/ide/keymaps.lua):
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "your_language",
  callback = function()
    keymap("n", "<leader>custom", ":YourCommand<CR>", { desc = "Custom Action", buffer = true })
  end,
})
```

### Disabling Features

Edit [`plugins/init.lua`](.config/nvim/lua/user/plugins/init.lua) and add `enabled = false`:
```lua
{
  "plugin-name",
  cond = is_ide_mode,
  enabled = false,  -- Disable this plugin
},
```

## 🚨 Troubleshooting

### Common Issues

#### LSP Not Working
```bash
:LspInfo                 # Check LSP status
:Mason                   # Install missing servers
```

#### Plugins Not Loading
```bash
:Lazy                    # Check plugin status
:ide                     # Retry IDE mode activation
```

#### Performance Issues
```bash
:minimal                 # Return to minimal mode
# Edit ~/.config/nvim/lua/user/ide/plugins.lua to disable heavy plugins
```

#### Python Debugging Not Working
```bash
pip install debugpy      # Install Python debug adapter
:DapInstallInfo         # Check DAP status
```

### Getting Help
- `:idehelp` - Built-in comprehensive help
- `:checkhealth` - Neovim health check
- `:Mason` - Language server management
- `:Lazy` - Plugin management

## 📊 Performance Metrics

### Startup Times
- **Minimal Mode**: ~50-100ms
- **IDE Mode**: ~200-500ms (first load), ~100-200ms (subsequent)

### Memory Usage
- **Minimal Mode**: ~50-80MB
- **IDE Mode**: ~150-300MB (depending on project size)

## 🎨 Customization Examples

### Add Your Own IDE Command
```lua
-- In ~/.config/nvim/lua/user/ide.lua
vim.api.nvim_create_user_command("MyIdeFeature", function()
  -- Your custom IDE functionality
end, { desc = "My custom IDE feature" })
```

### Custom Language Configuration
```lua
-- In ~/.config/nvim/lua/user/ide/lsp.lua
my_custom_ls = {
  filetypes = { "my_language" },
  settings = {
    myLanguage = {
      enable = true,
      features = {
        completion = true,
        diagnostics = true,
      },
    },
  },
},
```

## 🤝 Contributing

This configuration is part of your personal dotfiles. To extend or modify:

1. **Fork/modify** the relevant files in `lua/user/ide/`
2. **Test thoroughly** in both minimal and IDE modes
3. **Update documentation** as needed
4. **Share improvements** in your dotfiles repository

## 📜 License

Part of your personal dotfiles configuration. Use and modify as needed for your development workflow.

---

**Happy coding with your dual-mode Neovim IDE!** 🎉

For more help: `:idehelp` or check the troubleshooting section above.