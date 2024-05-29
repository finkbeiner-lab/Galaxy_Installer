# Galaxy Installer
Downloads, installs, and updates Galaxy, all of its dependencies, and verifies each automatically on macOS. This is designed to run idempotently and detect any issues automatically.

## What's Installed

### Xcode Tools
Xcode Tools are a package of developer tools for macOS. Specifically, we need Git from it. We could install Git with Homebrew or some other method, but using Xcode Tools provides the greatest compatability for us on macOS.

### Homebrew
Homebrew, originally built just for macOS until 2020, is a multi-platform package manager. It's very nice, and is the primary way we will install and update everything else on to the system.

### Zsh
Zsh (Z Shell) is the command-line interface we’ll be using. It executes the commands typed into the terminal. As of macOS Catalina (10.15), Zsh is the default shell on macOS, replacing Bash. However, many other systems, such as most Linux distributions, still default to Bash. We need to standardize on a single shell, Zsh, for this project to create helper shortcuts, manage keys, and other tasks effectively. Standardizing the shell also helps in testing and maintanance, removing one whole axis for descrepancies. 

### Oh-My-Zsh
Oh-My-Zsh provides a bunch of helpful changes to Zsh in a way that is cleanly automatically managed. Entirely optional, but recommended.

### Python 3
Installs a small Python stack. `pyenv` helps manage having multiple versions of Python at a time. `pipx` helps manage stand-alone programs written in Python (such as `Planemo`), making them avaiabile in all the installed versions of Python at once.
1. Python 3 (latest)
2. pyenv
3. pipx

### Tool Shed
A Galaxy ToolShed is where Galaxy Tools (modules) live. This installs our own set of custom tools into Galaxy, and `Planemo`, a tool for creating and testing new tools.

### Galaxy
The main course. Installs the latest released version of Galaxy and deploys our ToolShed on it.

