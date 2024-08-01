# Python Directories
Occasionally, it's helpful to use Galaxy's web API to do some tasks that would generally require manually editing its config files. We could use the JavaScript API built in to Galaxy, but here we have opted to use a Python wrapper.
Each directory will contain a seperate python script and it's metadata.

## Dependencies
We'll use a few tools here to keep these different scripts isolated and kept up to date with Galaxy as it evolves.
1. [bioblend](https://github.com/galaxyproject/bioblend) - Galaxy's main API interface in a python wrapper.
2. [Conda](https://conda.io/projects/conda/en/latest/index.html) - Conda keeps the libraries in these scripts from conflicting with or polluting the user's machine

## common.py
Each script will inherit from `common.py`, and this must be kept in lockstep with `common.sh` so that our logging functions have matching outputs.

## call_python_script.sh
In order to manage creating and tearing down our Conda enviroments, we'll use this wrapper shell script to help call into our python scripts when we want to call them from a shell.

# Debugging
In order to speed up debugging one of these python routines we need to be able to just iterate on and attach a debugger to the python script itself, or test out bioblend in the interpreter.
To do that, we need to at least set up Conda and create the Conda virtual environment. There are likely other dependencies that will be needed, depending on what we're trying to accomplish.
We often, for instance, require a Galaxy instance to recieve our API calls. By calling this project's main `setup.sh` shell script, most of what we might need will be set up automatically,
and we can start and stop Galaxy using the shortcuts that are installed for us.

1. `setup.sh` to install Conda, install the Galaxy Control plugin, and calls `conda init zsh` for us (we are expected to be using a zsh shell).
2. We can then either open a new shell, or source our zsh profile, typically `source ~./zshrc` in order to pull in the results of conda init.
3. `conda env create -f /<path>/<to>/<this>/<python>/<directory>/<some_python_script_directory_inside_it>/environment.yml` to create the Conda environment and download the dependenices in `environment.yml`.
4. `conda activate <name_of_conda_environment>` We activate the Conda environment, which essentially points our shell's Python shortcuts to run the specific copy of Python and dependencies we've installed with Conda.
   Note that you can find the name of the conda environment in the console after creating it, or in the `environment.yml` file under `name`.
5. Now you can run the files with `python3 <file> <arg1> <arg2>` as you would normally. Or just start the interpreter with `python3` or a debugger with `python -m pdb <file> <arg1> <arg2>`.
   IDEs like PyCharm and VSCode can also attach a debugger, but will need the Conda environment set up in them. You'll need to consult the documentation for your particular IDE to set this up.
