# Dotfiles

These are my personal dotfiles, managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

Before installing, ensure you have the following installed:
- `git`
- `stow`

## How to install on a new machine

1. **Clone the repository:**
   ```bash
   git clone git@github.com:ml3m/.dotfiles.git ~/.dotfiles
   ```

2. **Navigate to the directory:**
   ```bash
   cd ~/.dotfiles
   ```

3. **Run the bootstrap script:**
   ```bash
   ./bootstrap.sh
   ```
   
   *Alternatively, to do it manually:*
   ```bash
   stow -v */
   ```

## Managing packages

- **To add a new file:** Move it into the appropriate package folder inside `~/.dotfiles`, then run `stow -v <package>`.
- **To unstow a package:** `stow -D <package>`
