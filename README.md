# Galaxy Installer
Downloads, installs, and updates the latest released version Galaxy, all of its dependencies, and verifies each automatically. This project is designed to run idempotently and detect any issues automatically.
You can always re-run this installer. It will attempt to fix, update, and verify all aspects of the project for you.

# Shortcuts
Once this installer has completed, you can use the shortcuts `galaxy start` and `galaxy stop`, and this project will continue to help manage Galaxy on your behalf.

# What's Installed

### Xcode Tools
Xcode Tools are a package of developer tools for macOS. Specifically, we need Git from it. We could install Git with Homebrew or some other method, but using Xcode Tools provides the greatest compatability for us on macOS.

### Homebrew
[Homebrew](https://brew.sh), originally built for macOS until 2020, Homebrew is now a multi-platform package manager. It's very nice, and is the primary way we will install and update everything else on to the system.

### Zsh
Zsh (Z Shell) is the command-line interface we’ll be using. It executes the commands typed into the terminal. As of macOS Catalina (10.15), Zsh is the default shell on macOS, replacing Bash. However, many other systems, such as most Linux distributions, still default to Bash. We need to standardize on a single shell for this project to create helper shortcuts, manage keys for private repositories, and other tasks effectively. Standardizing the shell also helps in testing and maintanance across different operating systems and environments. 

### Oh-My-Zsh
[Oh-My-Zsh](https://ohmyz.sh) provides a bunch of helpful changes to Zsh in a way that is cleanly automatically managed. It also provides a nice way for us to add helpful aliases and functions (galaxy start/stop). It is the most widely adopted framework in Zsh for managing these.

### Python Tools
Installs a small Python stack.
`pipx` helps manage stand-alone programs written in Python (such as `Planemo`), making them avaiabile in all the installed versions of Python at once. Galaxy runs in a `venv` itself, but for tools it uses `Conda`, so we'll need both. Installing `Miniconda` gives us both and will help us pulling in stable Python 3 releases.
1. [Python 3](https://www.python.org) (latest)
2. [pipx](https://github.com/pypa/pipx)
3. [miniconda](https://docs.anaconda.com/free/miniconda/)

### Tool Shed
A Galaxy [Tool Shed](https://galaxyproject.org/toolshed/) is where Galaxy Tools (modules) live. This installs [our own](https://github.com/finkbeiner-lab/Galaxy_Tool_Shed) set of custom tools into Galaxy, and [Planemo](https://planemo.readthedocs.io/en/latest/writing_standalone.html), a python program for creating and testing new tools.

### Galaxy
[Galaxy](https://github.com/galaxyproject/galaxy) is the workflow runner this project is built around. It's a scientifc workflow manager and script runner that has a brower-based GUI (when running locally it's usually found in your browser at http://localhost:8080). This installs the latest released version of Galaxy and deploys our Tool Shed on it.


# Structure of this project
The scripts in this project do make an assumption as to where they are located in order to make sure they can source `config.sh` and `common.sh` from the project root. The python helper scripts need to find `common.py`, and each needs a sibling `requirements.yml`. They are expected to be in a directory named identically to them and their Conda enviroment, and the wrapper `call_python_script.sh` is responsible for booting up this conda environment, running them, and returning their output back to the shell.

## Zsh plugins
This installer copies the plugin `galaxy_control` into your Zsh environment's plugin directory (usually ~/.oh-my-zsh/custom/plugins). Zsh runs the control script `galaxy_control.plugin.zsh` to setup shortcuts in your shell context (usually via ~/.zshrc) to run galaxy commands.

```galaxy start```
```galaxy stop```

### Advanced Usage
Under the hood, the shortcuts are using galaxy's `run.sh` script to start it. They will pass on additional arguments supplied to them on to `run.sh` (which Galaxy itself passes on to other scripts). So `galaxy start <foo>` calls `run.sh <foo>`. This could be helpful if there are extra flags you want to send to Galaxy.

# Help!
### 1. Logs
There are logs for both this installer project, and for galaxy itself, both stored in a directory called `temp` within this project. Navigate to the directory this project was cloned down to, and open `.log` files with any text editor. This project makes an attempt to make error messages found in the logs intelligbile and actionable, so this really does end up being your best foot forward. Folks are generally going to ask you for the logs to try to help resolve your issue, so locating these is going to be step one. The installer outputs the location of these on your machine if you need help tracking them down.

### 2. Slack
If you need active help with this Galaxy Installer, the best place to go is our Gladstone Institutes Slack in the channel `#galaxy`.

### 3. Clean Slate
If you don't have any custom tools or workflows that are only local to your machine, you can resolve most issues with a clean install of Galaxy.
#### Uninstall
1. (Nearly always required) Delete the galaxy git project directory. Usually `rm -r ~/galaxy`
2. (Often optional) Uninstall the .zsh plugin
   - a. Edit your zsh profile with your prefered text editor, usually found `~/.zshrc` and remove the galaxy control plugin entry. For example, change `plugins=(git galaxy_control)` to `plugins=(git)`
   - b. Remove the plugin script directory, usually `rm -r ~/.oh-my-zsh/custom/plugins/galaxy_control`
3. (Often optional) Delete and reclone down this git project
4. (Often optional) Remove the toolshed, usually `rm -r ~/finkbeiner_tool_shed`
#### Reinstall
1. Clone this git project somewhere on to your machine
2. `cd <directory you cloned into>/Galaxy_Installer`
3. `chmod +x ./setup.sh`
4. `./setup.sh`
