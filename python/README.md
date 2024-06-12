# Python Directories
Occasionally, it's helpful to use Galaxy's web API to do some tasks that would require manually editing its config files otherwise.
Each directory will contain a seperate python script and it's metadata.

## Dependencies
We'll use a few tools here to keep these different scripts isolated and kept up to date with Galaxy as it evolves.
1. [bioblend](https://github.com/galaxyproject/bioblend) - Galaxy's main API interface is usually interacted with using this python wrapper.
2. [Conda](https://conda.io/projects/conda/en/latest/index.html) - Conda keeps the libraries in these scripts from conflicting with or polluting the user's machine

## common.py
Each script will inherit from `common.py`, and this must be kept in lockstep with `common.sh` so that our logging functions have matching outputs.

## call_python_script.sh
In order to manage creating and tearing down our Conda enviroments, we'll use this wrapper shell script to help call into our python scripts.

