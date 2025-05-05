# Dotfiles

This repository contains my personal dotfiles configuration, including settings and configurations for various applications and tools I use daily. Below is a detailed explanation of the Neovim configuration and its functionalities.

# Using Stow for Dotfile Management
### Overview
This chapter explains how to manage your dotfiles efficiently using GNU Stow. GNU Stow is a symlink farm manager that helps you manage the installation of your dotfiles and other configuration files in a way that is easy to maintain and deploy across different environments. By using Stow with your .dotfiles directory, you can simplify the process of setting up your configurations on a new machine or maintaining them over time.

## requisities
Before you begin, ensure you have the following:

## GNU Stow Installed: You can install Stow using a package manager. For macOS, you can use Homebrew:

```bash
brew install stow
```

## .dotfilesmacos tree

```javascript
.dotfilesmacos
├── README.md
├── bpytop
├── brew_installed.text
├── images
│   └── template.png
├── kitty
├── lsd
├── nvim
├── scripts
│   └── bin
│       ├── og
│       ├── on
│       └── tmux-sessionizer
├── tmux
└── zsh
```
## Organizing Your Dotfiles
Using **GNU Stow** to Symlink Your Dotfiles
Navigate to Your .dotfiles Directory:

```bash
cd ~/.dotfiles
```
Stow a Configuration: To create symlinks for a specific configuration, use the following command:

```bash
stow <directory-name>
```
Replace <directory-name> with the name of the directory containing the dotfiles you want to symlink. For example, to symlink your Neovim configuration:

```bash
stow nvim
```
Verifying the Symlinks: After running the Stow command, check your home directory to ensure that the symlinks have been created correctly. For example:

```bash
ls -la ~ | grep nvim
```
Unstowing Configuration: If you ever need to remove the symlinks for a specific configuration, you can use the -D option:

```bash
stow -D <directory-name>
```
This will remove all symlinks associated with the specified directory.


## Neovim Configuration

The Neovim configuration resides in the `nvim` directory. This includes various Lua scripts and configuration files to enhance the Neovim experience.

### Key Components


1. **lua/mlem/packer.lua**
   - Handles the setup of **Packer**, a package manager for Neovim. This file defines the plugins used in the setup, ensuring they are installed and loaded correctly.

2. **lua/mlem/remap.lua**
   - Contains key mappings to enhance productivity and streamline workflow. Custom keybindings for frequently used commands or plugins are set here.

3. **lua/mlem/set.lua**
   - Configures general settings for Neovim, such as line numbers, tab behavior, and other editor options.

4. **lua/mlem/trouble.lua**
   - Sets up the **Trouble** plugin, which provides a better way to manage diagnostics and issues in the code. It allows for easier navigation through errors and warnings.

### After Plugin Configuration

- **after/plugin/**:
  - Contains specific Lua files for plugin configuration that should be executed after the plugins are loaded. Each file corresponds to a plugin with custom settings.

  - **autoclose.lua**: Automatically closes matching brackets, quotes, and other characters for better coding efficiency.
  
  - **colors.lua**: Sets the color scheme and visual appearance of the editor.

  - **fugitive.lua**: Configures the **fugitive** plugin for Git integration, providing commands to manage Git repositories directly within Neovim.

  - **harpoon.lua**: Sets up **Harpoon**, a plugin for quick file navigation. It allows marking files and switching between them easily.
  - //The gratest plugin alive by ThePrimeAgen

  - **lsp.lua**: Configures the Language Server Protocol (LSP) settings for code completion, linting, and other language-specific features.

  - **obsidian.lua**: Configures the **Obsidian** plugin for enhanced note-taking and linking features, ideal for personal knowledge management.

  - **telescope.lua**: Sets up the **Telescope** plugin for fuzzy finding files, buffers, and more within the Neovim interface.

  - **treesitter.lua**: Configures **Tree-sitter** for improved syntax highlighting and code understanding.

  - **trouble.lua**: Additional configuration for the **Trouble** plugin to handle diagnostics better.

  - **undotree.lua**: Sets up the **Undotree** plugin for better visualization and management of undo history.

# Other Configurations
## Scripts

### tmux-sessionizer 
- **The tmux-sessionizer script automates the process of managing tmux sessions based on directories. It provides a way to quickly create or switch to a tmux session named after the selected directory, significantly enhancing productivity, especially for developers working on multiple projects.

Example Usage
To use the script, you could run:

```bash
./tmux-sessionizer
```
This will prompt you to select a directory using fzf. Vim Motions are default.

Alternatively, you can provide a directory as an argument:

```bash
./tmux-sessionizer ~/personal/projects/my_project
```
This will switch to or create a tmux session named after my_project.

### on script (Obsidian Note)
- **on*** script is designed to create a new Markdown file for note-taking or journaling purposes. It generates a file name based on the current date and a user-provided title, formats it to replace spaces with hyphens, and places it in a designated directory. It automatically opens the file in Neovim for immediate editing, streamlining the note-taking process.

Example Usage
To use the script, run the following command:
```bash
on "Alice's Adventures in Wonderland"
```
This would create a new file named 2024-09-29_Alice's-Adventures-in-Wonderland.md in the inbox directory within the specified path and open it in Neovim.

### og script (Obsidian group)
**og** script is designed to organize Markdown files in your Obsidian vault by moving them into subdirectories based on their tags. It processes each file in the inbox directory, extracts the first tag found after the tags: line, and moves the file to a corresponding directory under notes. If no tag is found, the file remains in its original location.

Example Usage
To use the script:

Place it in a suitable location, such as your scripts directory. Addable to the user path.

- This will start processing all Markdown files in the specified inbox directory.
- Make sure that your Markdown files follow the expected format for tags, with a line containing tags: followed by the tag(s) on the next line. Otherwise, the script may not work as intended.

### Keybinds Overview
This section lists the custom keybindings for Neovim, organized by their purpose.

#### Obsidian Integrations:

- Convert note to template and remove leading white space:
```lua
vim.keymap.set("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
```
<p align="center">
  <img src="images/template.png" alt="Neovim Keybindings Overview" />
</p>

- Search for files in the full vault using Telescope:
```lua
vim.keymap.set("n", "<leader>os", ":Telescope find_files search_dirs={\"/Users/mlem/Library/Mobile\\ Documents/com~apple~CloudDocs/main/notes\"}<cr>")
```

- Search for content within files in the full vault:
```lua
vim.keymap.set("n", "<leader>oz", ":Telescope live_grep search_dirs={\"/Users/mlem/Library/Mobile\\ Documents/com~apple~CloudDocs/main/notes\"}<cr>")
```

- Strip date from note title and replace dashes with spaces (place cursor on title):
```lua
vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")
```
# .dotfiles
