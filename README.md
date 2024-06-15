# Galaxy Installer
Downloads, installs, and updates Galaxy, all of its dependencies, and verifies each automatically on macOS. This is designed to run idempotently and detect any issues automatically.


## What's Installed

### Xcode Tools
Xcode Tools are a package of developer tools for macOS. Specifically, we need Git from it. We could install Git with Homebrew or some other method, but using Xcode Tools provides the greatest compatability for us on macOS.

### Homebrew
[Homebrew](https://brew.sh), originally built for macOS until 2020, Homebrew is now a multi-platform package manager. It's very nice, and is the primary way we will install and update everything else on to the system.

### Zsh
Zsh (Z Shell) is the command-line interface we’ll be using. It executes the commands typed into the terminal. As of macOS Catalina (10.15), Zsh is the default shell on macOS, replacing Bash. However, many other systems, such as most Linux distributions, still default to Bash. We need to standardize on a single shell, Zsh, for this project to create helper shortcuts, manage keys, and other tasks effectively. Standardizing the shell also helps in testing and maintanance, removing one whole axis for descrepancies. 

### Oh-My-Zsh
[Oh-My-Zsh](https://ohmyz.sh) provides a bunch of helpful changes to Zsh in a way that is cleanly automatically managed. It also provides a clean way for us to add helpful aliases and functions (galaxy start/stop). It is by far the most widely adopted framework for managing these.

### Python Tools
Installs a small Python stack.
`pipx` helps manage stand-alone programs written in Python (such as `Planemo`), making them avaiabile in all the installed versions of Python at once. Galaxy runs in a `venv` itself, but for tools it uses `Conda`, so we'll need both. Installing `Miniconda` gives us both and a stable Python3 release.
1. [Python 3](https://www.python.org) (latest)
2. [pipx](https://github.com/pypa/pipx)
3. [miniconda](https://docs.anaconda.com/free/miniconda/)

### Tool Shed
A Galaxy [Tool Shed](https://galaxyproject.org/toolshed/) is where Galaxy Tools (modules) live. This installs [our own](https://github.com/finkbeiner-lab/Galaxy_Tool_Shed) set of custom tools into Galaxy, and [Planemo](https://planemo.readthedocs.io/en/latest/writing_standalone.html), a python program for creating and testing new tools.

### Galaxy
[Galaxy](https://github.com/galaxyproject/galaxy) is the main course. It's a scientifc workflow manager and script runner that has a brower-based GUI (when running locally it's usually found in your browser at http://localhost:8080). This installs the latest released version of Galaxy and deploys our ToolShed on it.


# Structure of this project
The scripts in this project do make an assumption as to where they are located in order to make sure they can source `common.sh`, from then on they are mostly agnostic. However, the python helper scripts have a more strict structural requirement as they need to find `common.py`, they need a sibling `requirements.yml`, they need to be in a directory named identically to them and their Conda enviroment, and the wrapper `call_python_script.sh` has to be able to traverse this.

